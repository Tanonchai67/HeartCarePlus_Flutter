import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:heartcare_plus/models/profiles_model.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddProfile extends StatefulWidget {
  const AddProfile({super.key});

  @override
  State<AddProfile> createState() => _AddProfileState();
}

class _AddProfileState extends State<AddProfile> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _birthdayController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  Profiles profiles = Profiles(
    name: '',
    lastname: '',
    nickname: '',
    condisease: '',
    allergic: '',
    email: '',
    phone: '',
    birthday: DateTime.now(),
    gender: 'ชาย',
    imageUrl: '',
  );

  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<File> compressImage(File file) async {
    final image = img.decodeImage(await file.readAsBytes());
    final compressed = img.encodeJpg(image!, quality: 70);

    final newFile = File('${file.path}_compressed.jpg');
    await newFile.writeAsBytes(compressed);
    return newFile;
  }

  Future<String?> uploadToCloudinary(File imageFile) async {
    final cloudName = 'dvqyd6mcf';
    final uploadPreset = 'heartcareplus';

    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    var request = http.MultipartRequest('POST', url);
    request.fields['upload_preset'] = uploadPreset;
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      final resBody = await response.stream.bytesToString();
      final data = jsonDecode(resBody);
      return data['secure_url'];
    } else {
      print('Upload failed: ${response.statusCode}');
      return null;
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Error"),
            ),
            body: Center(
              child: Text("${snapshot.error}"),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          // กำลังโหลด
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // snapshot สำเร็จ
        return Scaffold(
          appBar: AppBar(
            title: const Text('กรอกข้อมูลส่วนตัว'),
            centerTitle: true,
            titleTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: Colors.black,
            ),
            backgroundColor: Colors.redAccent,
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // รูปโปรไฟล์
                      Text(
                        'เลือกรูปโปรไฟล์',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              _image != null ? FileImage(_image!) : null,
                          child: _image == null
                              ? Icon(Icons.add_a_photo, size: 50)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ชื่อ
                      TextFormField(
                        onSaved: (String? name) {
                          profiles.name = name ?? '';
                        },
                        validator:
                            RequiredValidator(errorText: "กรุณากรอกชื่อ").call,
                        decoration: InputDecoration(
                          labelText: 'ชื่อ',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // นามสกุล
                      TextFormField(
                        onSaved: (String? lastname) {
                          profiles.lastname = lastname ?? '';
                        },
                        validator:
                            RequiredValidator(errorText: "กรุณากรอกนามสกุล")
                                .call,
                        decoration: InputDecoration(
                          labelText: 'นามสกุล',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ชื่อเล่น
                      TextFormField(
                        onSaved: (String? nickname) {
                          profiles.nickname = nickname ?? '';
                        },
                        validator:
                            RequiredValidator(errorText: "กรุณากรอกชื่อเล่น")
                                .call,
                        decoration: InputDecoration(
                          labelText: 'ชื่อเล่น',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // โรคประจำตัว
                      TextFormField(
                        onSaved: (String? condisease) {
                          profiles.condisease = condisease ?? '';
                        },
                        validator:
                            RequiredValidator(errorText: "กรุณากรอกโรคประจำตัว")
                                .call,
                        decoration: InputDecoration(
                          labelText: 'โรคประจำตัว',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.medical_services),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ยาที่แพ้
                      TextFormField(
                        onSaved: (String? allergic) {
                          profiles.allergic = allergic ?? '';
                        },
                        validator:
                            RequiredValidator(errorText: "กรุณากรอกยาที่แพ้")
                                .call,
                        decoration: InputDecoration(
                          labelText: 'ยาที่แพ้',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.medication_liquid),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // อีเมล
                      TextFormField(
                        validator: MultiValidator([
                          RequiredValidator(errorText: "กรุณากรอกอีเมล"),
                          EmailValidator(
                              errorText: "รูปแบบอีเมลไม่ถูกต้อง *@gmail.com")
                        ]).call,
                        onSaved: (String? email) {
                          profiles.email = email ?? '';
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'อีเมล',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // เบอร์ติดต่อ
                      TextFormField(
                        keyboardType: TextInputType.number,
                        onSaved: (String? phone) {
                          profiles.phone = phone ?? '';
                        },
                        validator:
                            RequiredValidator(errorText: "กรุณากรอกเบอร์ติดต่อ")
                                .call,
                        decoration: InputDecoration(
                          labelText: 'เบอร์ติดต่อ',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.call),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // วัน/เดือน/ปีเกิด
                      TextFormField(
                        controller: _birthdayController,
                        validator: RequiredValidator(
                                errorText: "กรุณาเลือกวัน/เดือน/ปีเกิด")
                            .call,
                        decoration: InputDecoration(
                          labelText: 'วัน/เดือน/ปีเกิด',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _birthdayController.text =
                                  DateFormat('dd/MM/yyyy').format(picked);
                              profiles.birthday = picked;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // เพศ
                      const Text("เพศ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Radio<String>(
                                value: "ชาย",
                                groupValue: profiles.gender,
                                onChanged: (String? gender) {
                                  setState(() {
                                    profiles.gender = gender ?? '';
                                  });
                                },
                              ),
                              const Text("ชาย"),
                            ],
                          ),
                          Row(
                            children: [
                              Radio<String>(
                                value: "หญิง",
                                groupValue: profiles.gender,
                                onChanged: (String? gender) {
                                  setState(() {
                                    profiles.gender = gender ?? '';
                                  });
                                },
                              ),
                              const Text("หญิง"),
                            ],
                          ),
                          Row(
                            children: [
                              Radio<String>(
                                value: "อื่น ๆ",
                                groupValue: profiles.gender,
                                onChanged: (String? gender) {
                                  setState(() {
                                    profiles.gender = gender ?? '';
                                  });
                                },
                              ),
                              const Text("อื่น ๆ"),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ปุ่มบันทึก
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text(
                            "บันทึกข้อมูล",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              showLoadingDialog(context);

                              if (_image != null) {
                                File compressedFile =
                                    await compressImage(_image!);
                                profiles.imageUrl =
                                    await uploadToCloudinary(compressedFile);

                                User? user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  String uid = user.uid;
                                  await FirebaseFirestore.instance
                                      .collection('profiles')
                                      .doc(uid)
                                      .set(profiles.toMap());
                                } else {
                                  print("User not logged in!");
                                }
                              }

                              print("name = ${profiles.name}");
                              print("Lastname = ${profiles.lastname}");
                              print("nickname = ${profiles.nickname}");
                              print("condisease = ${profiles.condisease}");
                              print("allergic = ${profiles.allergic}");
                              print("email = ${profiles.email}");
                              print("phone = ${profiles.phone}");
                              print("birthday = ${profiles.birthday}");
                              print("gender = ${profiles.gender}");
                              print("imageUrl = ${profiles.imageUrl}");

                              hideLoadingDialog(context);
                              // แถบโชว์ผลการทำงาน
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("บันทึกเรียบร้อย: ")),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
