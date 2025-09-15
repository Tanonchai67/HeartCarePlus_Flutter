import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:heartcare_plus/models/users_model.dart';
import 'package:heartcare_plus/pages/insertpage/history/animat_toast.dart';

class ForgetPassPage extends StatefulWidget {
  const ForgetPassPage({super.key});

  @override
  State<ForgetPassPage> createState() => _ForgetPassPageState();
}

class _ForgetPassPageState extends State<ForgetPassPage> {
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
          backgroundColor: Colors.grey[50],
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),

                  // Icon โมเดิร์น
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[50],
                    child: const Icon(
                      Icons.lock_reset,
                      size: 100,
                      color: Colors.redAccent,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'รีเซ็ตรหัสผ่าน',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'กรุณากรอกอีเมลที่ใช้ลงทะเบียน\nระบบจะส่งอีเมลรีเซ็ตรหัสผ่านไปให้คุณ',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  Form(
                    key: formkey,
                    child: Column(
                      children: [
                        // Input Email
                        TextFormField(
                          validator: MultiValidator([
                            RequiredValidator(errorText: "กรุณาป้อนอีเมล"),
                            EmailValidator(
                                errorText: "รูปแบบอีเมลไม่ถูกต้อง *@gmail.com")
                          ]).call,
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

                        // ปุ่มส่งอีเมล
                        ElevatedButton(
                          onPressed: () async {
                            if (formkey.currentState?.validate() ?? false) {
                              formkey.currentState?.save();
                              try {
                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(
                                        email: users.email.trim());

                                if (!mounted) return;

                                showCustomToastUser(
                                    // ignore: use_build_context_synchronously
                                    context,
                                    "ส่งอีเมลเรียบร้อย");
                              } on FirebaseAuthException catch (e) {
                                String message = '';
                                if (e.code == 'firebase_auth/user-not-found') {
                                  message =
                                      'ไม่มีบัญชีผู้ใช้ที่ตรงกับอีเมลที่กรอก';
                                } else if (e.code == 'network-request-failed') {
                                  message = 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต';
                                } else {
                                  message = e.message ?? 'เกิดข้อผิดพลาด';
                                }

                                if (!mounted) return;

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
                            'ส่งอีเมลรีเซ็ตรหัสผ่าน',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // หมายเหตุ
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "หมายเหตุ:",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "* ต้องเป็นอีเมลที่เคยลงทะเบียนแล้วเท่านั้น ",
                          style:
                              TextStyle(fontSize: 18, color: Colors.redAccent),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "* ถ้าไม่เห็นอีเมลดูที่ช่อง 'จดหมายขยะ'",
                          style:
                              TextStyle(fontSize: 18, color: Colors.redAccent),
                        ),
                      ],
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
