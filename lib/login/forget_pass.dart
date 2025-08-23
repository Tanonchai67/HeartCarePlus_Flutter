import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:heartcare_plus/model/users.dart';

class ForgetpassPage extends StatelessWidget {
  ForgetpassPage({super.key});

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
            title: const Text('ลืมรหัสผ่าน'),
            backgroundColor: Colors.redAccent,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  // Header
                  const Text(
                    'รีเซ็ตรหัสผ่าน',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'กรุณากรอกอีเมลที่ใช้ลงทะเบียน\nระบบจะส่งลิงก์รีเซ็ตรหัสผ่านไปให้คุณ',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),

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
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            if (formkey.currentState?.validate() ?? false) {
                              formkey.currentState?.save();
                              try {
                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(
                                        email: users.email.trim())
                                    .then((value) {
                                  formkey.currentState?.reset();

                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("สำเร็จ"),
                                        content: Text(
                                            "ระบบได้ทำการส่งอีเมลไปให้เรียบร้อย!"),
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
                                if (e.code == 'firebase_auth/user-not-found') {
                                  message = 'ไม่พบอีเมล';
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
                            'ส่งอีเมลรีเซ็ตรหัสผ่าน',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "หมายเหตุ:",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "* ต้องเป็นอีเมลที่เคยลงทะเบียนแล้วเท่านั้น ",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "* ถ้าไม่เห็นอีเมลกรุณาดูที่จดหมายขยะ ",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
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
