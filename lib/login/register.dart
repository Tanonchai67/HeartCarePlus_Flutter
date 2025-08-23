import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:heartcare_plus/model/users.dart';

class Registerpage extends StatefulWidget {
  Registerpage({super.key});

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
            appBar: AppBar(
              title: Text("Error"),
            ),
            body: Center(
              child: Text("${snapshot.error}"),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          // กำลังโหลด
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // snapshot สำเร็จ
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('ลงทะเบียน'),
            backgroundColor: Colors.redAccent,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(Icons.favorite, color: Colors.red, size: 60),
                  const SizedBox(height: 12),
                  const Text(
                    'สมัครใช้งาน HeartCarePlus',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  Form(
                    key: formkey,
                    child: Column(
                      children: [
                        TextFormField(
                          validator: MultiValidator([
                            RequiredValidator(errorText: "กรุณาป้อนอีเมล"),
                            EmailValidator(
                                errorText: "รูปแบบอีเมลไม่ถูกต้อง *@gmail.com")
                          ]),
                          onSaved: (String? email) {
                            users.email = email ?? '';
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
                        TextFormField(
                          validator:
                              RequiredValidator(errorText: "กรุณาป้อนรหัสผ่าน"),
                          onSaved: (String? pass) {
                            users.pass = pass ?? '';
                          },
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'รหัสผ่าน',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.lock),
                          ),
                        ),
                        const SizedBox(height: 24),
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

                                  // แจ้งเตือนแบบเด้งกลางจอ
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("สำเร็จ"),
                                        content: Text("ลงทะเบียนเรียบร้อย!"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("ตกลง"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                });
                              } on FirebaseAuthException catch (e) {
                                String message = '';
                                if (e.code == 'weak-password') {
                                  message =
                                      'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                                } else if (e.code == 'email-already-in-use') {
                                  message = 'อีเมลนี้ถูกใช้แล้ว';
                                } else {
                                  message = e.message ?? 'เกิดข้อผิดพลาด';
                                }

                                // แจ้งเตือน error
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("ผิดพลาด"),
                                      content: Text(message),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("ตกลง"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 10,
                            shadowColor: Colors.black,
                          ),
                          child: const Text(
                            'ลงทะเบียน',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  // ลิงก์ย้อนกลับ
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('มีบัญชีอยู่แล้ว? เข้าสู่ระบบ'),
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
