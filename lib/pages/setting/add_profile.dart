import 'dart:io';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:heartcare_plus/models/profiles_model.dart';
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
      imageFile: null);

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        profiles.imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text("เลือกรูปโปรไฟล์",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Center(
                    child: InkWell(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: profiles.imageFile != null
                            ? FileImage(profiles.imageFile!)
                            : null,
                        child: profiles.imageFile == null
                            ? const Icon(Icons.camera_alt, size: 40)
                            : null,
                      ),
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
                        RequiredValidator(errorText: "กรุณากรอกนามสกุล").call,
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
                        RequiredValidator(errorText: "กรุณากรอกชื่อเล่น").call,
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
                        RequiredValidator(errorText: "กรุณากรอกยาที่แพ้").call,
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
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          print("name = ${profiles.name}");
                          print("Lastname = ${profiles.lastname}");
                          print("nickname = ${profiles.nickname}");
                          print("condisease = ${profiles.condisease}");
                          print("allergic = ${profiles.allergic}");
                          print("email = ${profiles.email}");
                          print("phone = ${profiles.phone}");
                          print("birthday = ${profiles.birthday}");
                          print("gender = ${profiles.gender}");

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
  }
}
