import 'package:flutter/material.dart';
import 'package:heartcare_plus/pages/login/login.dart';
import 'package:heartcare_plus/pages/login/registor.dart';

void main() => runApp(const HeartCarePlusApp());

class HeartCarePlusApp extends StatelessWidget {
  const HeartCarePlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'HeartCare Plus',
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // โลโก้หัวใจ
                const Icon(Icons.favorite, color: Colors.red, size: 60),

                const SizedBox(height: 16),

                // ชื่อแอป
                const Text(
                  'HeartCare\nPlus',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 16),

                // ภาพหมอ (แทนด้วย Icon หรือภาพ Asset)
                Image.asset(
                  'assets/Doctor.png', // เปลี่ยน path ตามรูปที่คุณมี
                  height: 160,
                ),

                const SizedBox(height: 24),

                const Text(
                  'เข้าสู่ระบบ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'กรุณาลงทะเบียนใหม่หรือล็อกอินเข้าสู่ระบบก่อน',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),

                const SizedBox(height: 24),

                // ปุ่มลงทะเบียน
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Registorpage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child:
                      const Text('ลงทะเบียน', style: TextStyle(fontSize: 16)),
                ),

                const SizedBox(height: 12),

                Text('หรือ', style: TextStyle(color: Colors.grey[600])),

                const SizedBox(height: 12),

                // ปุ่มเข้าสู่ระบบ
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Loginpage()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('เข้าสู่ระบบ',
                      style: TextStyle(fontSize: 16, color: Colors.blueGrey)),
                ),

                const SizedBox(height: 24),

                GestureDetector(
                  onTap: () {
                    // นำทางไปหน้าติดต่อเรา
                  },
                  child: const Text(
                    'หากพบปัญหาในการเข้าสู่ระบบโปรด ติดต่อเรา',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blueAccent,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
