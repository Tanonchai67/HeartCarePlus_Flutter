import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:heartcare_plus/models/profiles_model.dart';
import 'package:heartcare_plus/pages/insertpage/history/animat_toast.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _birthdayController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  bool _isProfileLoaded = false;
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

  Stream<Profiles?> streamProfile() {
    User? user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection("profiles")
        .doc(user!.uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return Profiles.fromMap(doc.data() as Map<String, dynamic>);
    });
  }

  // Format วันที่ พ.ศ.
  String formatDateBuddhist(DateTime date) {
    final buddhistYear = date.year + 543;
    return '${DateFormat('dd/MM').format(date)}/$buddhistYear';
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

        return StreamBuilder<Profiles?>(
          stream: streamProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("ไม่พบข้อมูล"));
            }

            if (!_isProfileLoaded) {
              profiles = snapshot.data!;
              _birthdayController.text = formatDateBuddhist(profiles.birthday);
              _isProfileLoaded = true;
            }

            // // snapshot สำเร็จ
            return Scaffold(
              appBar: AppBar(
                elevation: 8,
                backgroundColor: Colors.teal.shade600,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                title: const Text(
                  'แก้ไขโปรไฟล์',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                centerTitle: true,
                automaticallyImplyLeading: false,
                actions: [
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Colors.redAccent, Colors.red],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 6,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.favorite,
                            color: Colors.white, size: 28),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // หัวข้อ
                      Text(
                        "เลือกรูป",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // เลือกรูปโปรไฟล์
                      GestureDetector(
                        onTap: pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _image != null
                              ? FileImage(_image!) // ถ้าเลือกภาพใหม่
                              : (profiles.imageUrl != null &&
                                      profiles.imageUrl!.isNotEmpty
                                  ? NetworkImage(profiles.imageUrl!)
                                      as ImageProvider
                                  : null), // ถ้ามีใน Firestore ใช้อันนี้
                          child: (_image == null &&
                                  (profiles.imageUrl == null ||
                                      profiles.imageUrl!.isEmpty))
                              ? const Icon(Icons.add_a_photo, size: 50)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Card กล่องข้อมูล
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // เพศ
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "เพศ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _genderOption("ชาย"),
                                  _genderOption("หญิง"),
                                  _genderOption("อื่น ๆ"),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // ฟิลด์ต่างๆ
                              _buildTextField(
                                  label: "ชื่อ",
                                  icon: Icons.person,
                                  readOnly: false,
                                  initialValue: profiles.name,
                                  onSaved: (val) => profiles.name = val ?? ""),
                              const SizedBox(height: 16),
                              _buildTextField(
                                  label: "นามสกุล",
                                  icon: Icons.person_outline,
                                  readOnly: false,
                                  initialValue: profiles.lastname,
                                  onSaved: (val) =>
                                      profiles.lastname = val ?? ""),
                              const SizedBox(height: 16),
                              _buildTextField(
                                  label: "ชื่อเล่น",
                                  icon: Icons.tag_faces,
                                  readOnly: false,
                                  initialValue: profiles.nickname,
                                  onSaved: (val) =>
                                      profiles.nickname = val ?? ""),
                              const SizedBox(height: 16),
                              _buildTextField(
                                  label: "โรคประจำตัว",
                                  icon: Icons.medical_services,
                                  readOnly: false,
                                  initialValue: profiles.condisease,
                                  onSaved: (val) =>
                                      profiles.condisease = val ?? ""),
                              const SizedBox(height: 16),
                              _buildTextField(
                                  label: "ยาที่แพ้",
                                  icon: Icons.warning_amber,
                                  readOnly: false,
                                  initialValue: profiles.allergic,
                                  onSaved: (val) =>
                                      profiles.allergic = val ?? ""),
                              const SizedBox(height: 16),
                              _buildTextField(
                                  label: "อีเมล",
                                  icon: Icons.email,
                                  readOnly: true,
                                  initialValue: profiles.email,
                                  keyboardType: TextInputType.emailAddress,
                                  onSaved: (val) => profiles.email = val ?? ""),
                              const SizedBox(height: 16),
                              _buildTextField(
                                  label: "เบอร์ติดต่อ",
                                  icon: Icons.call,
                                  readOnly: false,
                                  initialValue: profiles.phone,
                                  keyboardType: TextInputType.phone,
                                  onSaved: (val) => profiles.phone = val ?? ""),
                              const SizedBox(height: 16),

                              // วันเกิด
                              TextFormField(
                                controller: _birthdayController,
                                decoration: InputDecoration(
                                  labelText: 'วัน/เดือน/ปีเกิด',
                                  prefixIcon: const Icon(
                                    Icons.calendar_today,
                                    color: Colors.teal,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                readOnly: true,
                                onTap: () async {
                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: profiles.birthday,
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _birthdayController.text =
                                          formatDateBuddhist(picked);
                                      profiles.birthday = picked;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ปุ่มบันทึก
                      SizedBox(
                        width: double.infinity,
                        child: //ปุ่ม
                            ElevatedButton.icon(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              showLoadingDialog(context);

                              User? user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                if (_image != null) {
                                  File compressedFile =
                                      await compressImage(_image!);
                                  profiles.imageUrl =
                                      await uploadToCloudinary(compressedFile);
                                }

                                try {
                                  await FirebaseFirestore.instance
                                      .collection('profiles')
                                      .doc(user.uid)
                                      .set(profiles.toMap(),
                                          SetOptions(merge: true));
                                  print("Profile saved/updated successfully!");
                                } catch (e) {
                                  print("Error saving profile: $e");
                                }
                              } else {
                                print("User not logged in!");
                              }

                              hideLoadingDialog(context);
                              showCustomToastUser(context, "บันทึกเรียบร้อย");
                              Navigator.pop(context);
                            } else {
                              showCustomToastUserErrors(
                                  context, "เกิดข้อผิดพลาด");
                            }
                          },
                          icon: const Icon(Icons.save,
                              color: Colors.white, size: 28),
                          label: const Text(
                            'แก้ไข & บันทึก',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _genderOption(String gender) {
    return Row(
      children: [
        Radio<String>(
          value: gender,
          // ignore: deprecated_member_use
          groupValue: profiles.gender,
          activeColor: Colors.teal,
          // ignore: deprecated_member_use
          onChanged: (val) {
            setState(() => profiles.gender = val ?? '');
          },
        ),
        Text(
          gender,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String initialValue,
    required bool readOnly,
    required FormFieldSetter<String> onSaved,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      style: TextStyle(fontSize: 16),
      initialValue: initialValue,
      readOnly: readOnly,
      onSaved: onSaved,
      validator: RequiredValidator(errorText: "กรุณากรอก $label").call,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
