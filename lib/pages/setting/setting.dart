import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heartcare_plus/login/home_login.dart';
import 'package:heartcare_plus/pages/setting/profile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("การตั้งค่าต่างๆ")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // ปุ่มโปรไฟล์
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PatientProfilePage()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 12),
                      Text(
                        'แก้ไขโปรไฟล์',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // สวิตช์การแจ้งเตือน
          SwitchListTile(
            value: true,
            onChanged: (val) {},
            title: const Text("การแจ้งเตือน"),
            secondary: const Icon(Icons.notifications),
          ),

          const SizedBox(height: 20),

          // ปุ่มออกจากระบบ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text("ออกจากระบบ",
                    style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut().then((value) async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return const Center(child: CircularProgressIndicator());
                      },
                    );
                    await Future.delayed(const Duration(seconds: 2));
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeLogin()),
                      (route) => false,
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("หากพบปัญหาโปรดติดต่อเรา"),
            ),
          ),
        ],
      ),
    );
  }
}
