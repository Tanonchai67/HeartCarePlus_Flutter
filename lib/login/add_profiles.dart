import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:heartcare_plus/login/home_login.dart';
import 'package:heartcare_plus/main_page.dart';
import 'package:heartcare_plus/models/profiles_model.dart';
import 'package:heartcare_plus/pages/insertpage/history/animat_toast.dart';
import 'package:heartcare_plus/pages/insertpage/medicine/notification_service.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddProfiles extends StatefulWidget {
  const AddProfiles({super.key});

  @override
  State<AddProfiles> createState() => _AddProfilesState();
}

class _AddProfilesState extends State<AddProfiles> {
  final formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _condiseaseController = TextEditingController();
  final _allergicController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdayController = TextEditingController();
  ValueNotifier<String> genderNotifier = ValueNotifier<String>('ชาย');
  ValueNotifier<DateTime?> birthdayNotifier = ValueNotifier<DateTime?>(null);
  final ValueNotifier<File?> _imageNotifier = ValueNotifier<File?>(null);
  File? _image;
  final ImagePicker _picker = ImagePicker();
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

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        // อัปเดต notifier แทน setState
        _imageNotifier.value = file;
        // หากต้องการยังคงตัวแปร _image สำหรับ compatibility:
        _image = file;
      }
    } catch (e) {
      // จัดการ error เล็กน้อย
      debugPrint('pickImage error: $e');
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

  Future<Profiles?> futureProfile() async {
    User? user = FirebaseAuth.instance.currentUser;

    final doc = await FirebaseFirestore.instance
        .collection("profiles")
        .doc(user!.uid)
        .get();

    if (!doc.exists) return null;

    return Profiles.fromMap(doc.data() as Map<String, dynamic>);
  }

// บันทึกข้อมูล
  void _saveProfiles() async {
    if (formKey.currentState!.validate()) {
      showLoadingDialog(context);

      setState(() {
        profiles = Profiles(
          name: _nameController.text.trim(),
          lastname: _lastnameController.text.trim(),
          nickname: _nicknameController.text.trim(),
          condisease: _condiseaseController.text.trim(),
          allergic: _allergicController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          birthday: profiles.birthday,
          gender: profiles.gender,
          imageUrl: '',
        );
      });

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (_image != null) {
          File compressedFile = await compressImage(_image!);
          profiles.imageUrl = await uploadToCloudinary(compressedFile);
        }

        try {
          await FirebaseFirestore.instance
              .collection('profiles')
              .doc(user.uid)
              .set(profiles.toMap(), SetOptions(merge: true));

          //
          print("Profile saved/updated successfully!");
          hideLoadingDialog(context);
          showCustomToastUser(context, "บันทึกข้อมูลเรียบร้อย");

          //
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
            (route) => false,
          );
        } catch (e) {
          print("Error saving profile: $e");
          hideLoadingDialog(context);
        }
      } else {
        print("User not logged in!");
        hideLoadingDialog(context);
      }
    }
  }

  // ล้างฟอร์ม
  void _clearForm() {
    setState(() {
      _birthdayController.clear();
      _nameController.clear();
      _lastnameController.clear();
      _allergicController.clear();
      _condiseaseController.clear();
      _emailController.clear();
      _nicknameController.clear();
      _phoneController.clear();
      _image = null;
      profiles = Profiles(
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
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime(1980);
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthdayNotifier.value ?? initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        // ปรับธีมให้ดูโมเดิร์น
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal, // สีปุ่ม OK/Cancel
              onPrimary: Colors.white, // สีตัวอักษรบนปุ่ม
              onSurface: Colors.black, // สีตัวเลขวันที่
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.teal),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _birthdayController.text = formatDateBuddhist(picked);
      birthdayNotifier.value = picked;
      profiles.birthday = picked; // อัปเดตโมเดลทันที
    }
  }

  // Format วันที่ พ.ศ.
  String formatDateBuddhist(DateTime date) {
    final buddhistYear = date.year + 543;
    return '${DateFormat('dd/MM').format(date)}/$buddhistYear';
  }

  @override
  void initState() {
    super.initState();

    // ดึง user ปัจจุบันจาก FirebaseAuth
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      _emailController.text = user.email!; // ใส่อีเมลลงในช่องอัตโนมัติ
    }
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await scheduleAllMedicineNotifications();
  }

  Future<void> scheduleAllMedicineNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("medicines")
        .doc(user.uid)
        .collection("my_medicines")
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final name = data["name"] ?? "ไม่มีข้อมูล";
      final time = data["time"] ?? "ไม่มีข้อมูล";
      final isNotificationOn = data["isNotificationOn"] ?? true;

      if (isNotificationOn) {
        await NotificationService().scheduleMedicineNotification(
          doc.id,
          name,
          time,
        );
      } else {
        // ปิดเฉพาะรายการที่ปิด
        await NotificationService().cancelNotification(doc.id);
      }
    }
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

        return FutureBuilder(
            future: futureProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // กรณีที่มีข้อมูลแล้ว ให้ไปหน้า Home เลย
              if (snapshot.hasData && snapshot.data != null) {
                Future.microtask(() {
                  Navigator.pushAndRemoveUntil(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage()),
                    (route) => false,
                  );
                });
                return const SizedBox.shrink();
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return Scaffold(
                  backgroundColor: Color(0xFFF5F9FC),
                  // AppBar
                  appBar: AppBar(
                    elevation: 8,
                    backgroundColor: Color(0xFF4CA1A3),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(24),
                      ),
                    ),
                    title: const Text(
                      'โปรไฟล์ใหม่',
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          // Card ฟอร์ม
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            elevation: 8,
                            // ignore: deprecated_member_use
                            shadowColor: Colors.grey.withOpacity(0.6),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  // รูปโปรไฟล์
                                  GestureDetector(
                                    onTap: pickImage,
                                    child: ValueListenableBuilder<File?>(
                                      valueListenable: _imageNotifier,
                                      builder: (context, imageFile, child) {
                                        return CircleAvatar(
                                          radius: 55,
                                          backgroundImage: imageFile != null
                                              ? FileImage(imageFile)
                                                  as ImageProvider
                                              : null,
                                          child: imageFile == null
                                              ? const Icon(Icons.add_a_photo,
                                                  size: 50, color: Colors.teal)
                                              : null,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  //
                                  _buildSeniorField(
                                    controller: _nameController,
                                    label: 'ชื่อ',
                                    icon: Icons.person,
                                    readOnly: false,
                                    onSaved: (val) {},
                                  ),
                                  const SizedBox(height: 16),

                                  //
                                  _buildSeniorField(
                                    controller: _lastnameController,
                                    label: 'นามสกุล',
                                    icon: Icons.person,
                                    readOnly: false,
                                    onSaved: (val) {},
                                  ),
                                  const SizedBox(height: 16),

                                  //
                                  _buildSeniorField(
                                    controller: _nicknameController,
                                    label: 'ชื่อเล่น',
                                    icon: Icons.face,
                                    readOnly: false,
                                    onSaved: (val) {},
                                  ),
                                  const SizedBox(height: 16),

                                  //
                                  _buildSeniorField(
                                    controller: _condiseaseController,
                                    label: 'โรคประจำตัว',
                                    icon: Icons.medical_services,
                                    readOnly: false,
                                    onSaved: (val) {},
                                  ),
                                  const SizedBox(height: 16),

                                  //
                                  _buildSeniorField(
                                    controller: _allergicController,
                                    label: 'ยาที่แพ้',
                                    icon: Icons.medication_liquid,
                                    readOnly: false,
                                    onSaved: (val) {},
                                  ),
                                  const SizedBox(height: 16),

                                  //
                                  _buildSeniorField(
                                    controller: _emailController,
                                    label: 'อีเมล',
                                    icon: Icons.email,
                                    keyboardType: TextInputType.emailAddress,
                                    readOnly: true,
                                    onSaved: (val) {},
                                  ),
                                  const SizedBox(height: 16),

                                  //
                                  _buildSeniorField(
                                    controller: _phoneController,
                                    label: 'เบอร์ติดต่อ',
                                    icon: Icons.call,
                                    keyboardType: TextInputType.phone,
                                    readOnly: false,
                                    onSaved: (val) {},
                                  ),
                                  const SizedBox(height: 16),

                                  // วันเกิด
                                  ValueListenableBuilder<DateTime?>(
                                    valueListenable: birthdayNotifier,
                                    builder: (context, value, child) {
                                      return TextFormField(
                                        controller: _birthdayController,
                                        readOnly: true,
                                        style: const TextStyle(fontSize: 18),
                                        onTap: () => _selectDate(context),
                                        decoration: InputDecoration(
                                          labelText: "วัน/เดือน/ปีเกิด",
                                          labelStyle: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.black54),
                                          prefixIcon: const Icon(
                                              Icons.calendar_today,
                                              color: Colors.teal),
                                          filled: true,
                                          fillColor: Color(0xFFFFFFFF),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: BorderSide.none),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: const BorderSide(
                                                color: Colors.red, width: 2),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: const BorderSide(
                                                color: Colors.teal, width: 2),
                                          ),
                                        ),
                                        validator: (value) =>
                                            value == null || value.isEmpty
                                                ? 'กรุณาเลือก วัน/เดือน/ปีเกิด'
                                                : null,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // เพศ
                                  ValueListenableBuilder<String>(
                                    valueListenable: genderNotifier,
                                    builder: (context, gender, child) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: ["ชาย", "หญิง"].map((g) {
                                          return Row(
                                            children: [
                                              Radio<String>(
                                                value: g,
                                                // ignore: deprecated_member_use
                                                groupValue: gender,
                                                // ignore: deprecated_member_use
                                                onChanged: (val) {
                                                  // เปลี่ยนค่าโดยตรงใน ValueNotifier
                                                  genderNotifier.value =
                                                      val ?? '';
                                                  profiles.gender = val ??
                                                      ''; // อัปเดตโมเดลด้วย
                                                },
                                              ),
                                              Text(g,
                                                  style: const TextStyle(
                                                      fontSize: 18)),
                                            ],
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // ปุ่มบันทึก
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildButton(
                                              text: "ล้าง",
                                              color: Colors.orangeAccent,
                                              icon: Icons.clear,
                                              onPressed: _clearForm),
                                          _buildButton(
                                            text: "บันทึก",
                                            color: Colors.teal,
                                            icon: Icons.save,
                                            onPressed: _saveProfiles,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      _buildButton(
                                        text: "ออกจากระบบ",
                                        color: Colors.redAccent,
                                        icon: Icons.logout,
                                        onPressed: () async {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            },
                                          );
                                          await Future.delayed(
                                              const Duration(seconds: 2));
                                          Navigator.pop(context);
                                          await FirebaseAuth.instance
                                              .signOut()
                                              .then((value) async {
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const HomeLogin()),
                                              (route) => false,
                                            );
                                          });
                                        },
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return const Text("เกิดข้อผิดพลาด");
            });
      },
    );
  }
}

// ฟังก์ชันสร้าง TextField สำหรับผู้สูงอายุ
Widget _buildSeniorField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  Function(String?)? onSaved,
  bool readOnly = false,
}) {
  return TextFormField(
    controller: controller,
    onSaved: onSaved,
    keyboardType: keyboardType,
    style: const TextStyle(fontSize: 18, color: Colors.black87),
    readOnly: readOnly,
    validator: readOnly
        ? null // ถ้า readOnly ไม่ต้อง validate
        : RequiredValidator(errorText: 'กรุณากรอก $label').call,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 18, color: Colors.black54),
      prefixIcon: Icon(icon, color: Colors.teal, size: 26),
      filled: true,
      fillColor: Color(0xFFFFFFFF),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    ),
  );
}

Widget _buildButton({
  required String text,
  required Color color,
  required IconData icon,
  required VoidCallback onPressed,
}) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, color: Colors.white),
    label: Text(
      text,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 6,
    ),
  );
}
