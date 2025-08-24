import 'package:flutter/material.dart';
import 'package:heartcare_plus/login/contact_us.dart';
import 'package:heartcare_plus/login/login.dart';
import 'package:heartcare_plus/login/register.dart';

class HomeLogin extends StatelessWidget {
  const HomeLogin({super.key});

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
                  'ยินดีต้อนรับ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'กรุณาลงทะเบียนหรือเข้าสู่ระบบก่อนใช้งาน',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),

                const SizedBox(height: 24),

                // ปุ่มลงทะเบียน
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Registerpage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    elevation: 10,
                    shadowColor: Colors.black,
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

                const SizedBox(height: 12),

                Text('หรือ', style: TextStyle(color: Colors.grey[600])),

                const SizedBox(height: 12),

                // ปุ่มเข้าสู่ระบบ
                OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Loginpage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      elevation: 6,
                      shadowColor: Colors.black,
                    ),
                    child: const Text(
                      'เข้าสู่ระบบ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    )),

                const SizedBox(height: 24),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ContactUs()),
                    );
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
