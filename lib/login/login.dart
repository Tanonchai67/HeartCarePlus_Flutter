import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:heartcare_plus/home.dart';
import 'package:heartcare_plus/login/forget_pass.dart';
import 'package:heartcare_plus/model/users.dart';

class Loginpage extends StatefulWidget {
  Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
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
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // snapshot สำเร็จ
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('เข้าสู่ระบบ'),
            centerTitle: true,
            titleTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: Colors.black,
            ),
            backgroundColor: Colors.redAccent,
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(Icons.favorite, color: Colors.red, size: 60),
                  const SizedBox(height: 12),
                  const Text(
                    'HeartCarePlus',
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
                                    .signInWithEmailAndPassword(
                                        email: users.email,
                                        password: users.pass)
                                    .then((value) {
                                  formkey.currentState?.reset();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const HomePage()),
                                    (route) => false,
                                  );
                                });
                              } on FirebaseAuthException catch (e) {
                                String message = '';
                                if (e.code == 'invalid-credential') {
                                  message = 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
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
                            'เข้าสู่ระบบ',
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgetPassPage()),
                      );
                    },
                    child: const Text('ลืมรหัสผ่าน?'),
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
