import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:heartcare_plus/login/pass_on_off.dart';
import 'package:heartcare_plus/models/users_model.dart';
import 'package:heartcare_plus/pages/insertpage/history/animat_toast.dart';

class Registerpage extends StatefulWidget {
  const Registerpage({super.key});

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage> {
  final formkey = GlobalKey<FormState>();
  Users users = Users(email: '', pass: '');
  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: Center(child: Text("${snapshot.error}")),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // snapshot สำเร็จ
        return Scaffold(
          backgroundColor: const Color(0xFFF0F4F8),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // โลโก้หัวใจ
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.red.shade400, Colors.pink.shade300],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.red.shade200.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 55,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'สมัครใช้งาน HeartCarePlus',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // ฟอร์มลงทะเบียนใน Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Form(
                      key: formkey,
                      child: Column(
                        children: [
                          // อีเมล
                          TextFormField(
                            validator: MultiValidator([
                              RequiredValidator(errorText: "กรุณาป้อนอีเมล"),
                              EmailValidator(
                                  errorText:
                                      "รูปแบบอีเมลไม่ถูกต้อง *@gmail.com"),
                            ]).call,
                            onSaved: (String? email) {
                              users.email = email ?? '';
                            },
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'อีเมล',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.email),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // รหัสผ่าน
                          PassOnOff(
                            onSaved: (value) {
                              users.pass = value ?? '';
                            },
                          ),

                          const SizedBox(height: 24),

                          // ปุ่มลงทะเบียน
                          ElevatedButton(
                            onPressed: () async {
                              if (formkey.currentState?.validate() ?? false) {
                                formkey.currentState?.save();
                                try {
                                  await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                    email: users.email,
                                    password: users.pass,
                                  )
                                      .then((value) {
                                    formkey.currentState?.reset();
                                    showCustomToastUser(
                                        // ignore: use_build_context_synchronously
                                        context,
                                        "ลงทะเบียนเรียบร้อย");
                                  });
                                  await FirebaseAuth.instance.signOut();
                                } on FirebaseAuthException catch (e) {
                                  String message = '';
                                  if (e.code == 'weak-password') {
                                    message = 'รหัสผ่านต้องมีอย่างน้อย 6 ตัว';
                                  } else if (e.code == 'email-already-in-use') {
                                    message = 'อีเมลนี้ถูกใช้แล้ว';
                                  } else if (e.code ==
                                      'network-request-failed') {
                                    message = 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต';
                                  } else {
                                    message = e.message ?? 'เกิดข้อผิดพลาด';
                                  }
                                  showCustomToastUserErrors(
                                      // ignore: use_build_context_synchronously
                                      context,
                                      message);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 8,
                              shadowColor: Colors.black26,
                            ),
                            child: const Text(
                              'ลงทะเบียน',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  // ลิงก์ย้อนกลับ
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'มีบัญชีอยู่แล้ว? เข้าสู่ระบบ',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
