import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:heartcare_plus/login/add_profiles.dart';
import 'package:heartcare_plus/login/forget_pass.dart';
import 'package:heartcare_plus/login/pass_on_off.dart';
import 'package:heartcare_plus/models/users_model.dart';
import 'package:heartcare_plus/pages/insertpage/history/animat_toast.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final formkey = GlobalKey<FormState>();
  Users users = Users(email: '', pass: '');
  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
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
            appBar: AppBar(title: const Text("Error")),
            body: Center(child: Text("${snapshot.error}")),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF0F4F8),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),

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
                    'HeartCarePlus',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ฟอร์ม Login ใน Card
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
                          TextFormField(
                            validator: MultiValidator([
                              RequiredValidator(errorText: "กรุณาป้อนอีเมล"),
                              EmailValidator(
                                  errorText:
                                      "รูปแบบอีเมลไม่ถูกต้อง *@gmail.com")
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
                          const SizedBox(height: 16),
                          PassOnOff(
                            onSaved: (value) {
                              users.pass = value ?? '';
                            },
                          ),
                          const SizedBox(height: 24),

                          // ปุ่มเข้าสู่ระบบ
                          ElevatedButton(
                            onPressed: () async {
                              if (formkey.currentState?.validate() ?? false) {
                                formkey.currentState?.save();
                                try {
                                  showLoadingDialog(context);
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                          email: users.email,
                                          password: users.pass)
                                      .then((value) async {
                                    formkey.currentState?.reset();
                                    // ignore: use_build_context_synchronously
                                    hideLoadingDialog(context);
                                    showCustomToastUser(
                                        // ignore: use_build_context_synchronously
                                        context,
                                        "เข้าสู่ระบบเรียบร้อย");

                                    Navigator.pushAndRemoveUntil(
                                      // ignore: use_build_context_synchronously
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AddProfiles()),
                                      (route) => false,
                                    );
                                  });
                                } on FirebaseAuthException catch (e) {
                                  // ignore: use_build_context_synchronously
                                  hideLoadingDialog(context);
                                  String message = '';
                                  if (e.code == 'invalid-credential') {
                                    message = 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
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
                              'เข้าสู่ระบบ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ForgetPassPage()),
                              );
                            },
                            child: const Text(
                              'ลืมรหัสผ่าน?',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                          ),
                        ],
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
  }
}
