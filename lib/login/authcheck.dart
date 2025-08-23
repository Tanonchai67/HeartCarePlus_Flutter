import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heartcare_plus/home.dart';
import 'package:heartcare_plus/login/home_login.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // เช็ดสถานะการล็อกอิน
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // โหลดอยู่
        } else if (snapshot.hasData) {
          return const HomePage(); // ถ้ามี user → ไปหน้า Home
        } else {
          return const HomeLogin(); // ถ้าไม่มี user → ไปหน้า Login
        }
      },
    );
  }
}
