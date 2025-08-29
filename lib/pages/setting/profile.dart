import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:heartcare_plus/models/profiles_model.dart';
import 'package:heartcare_plus/pages/setting/edit_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  Profiles profiles = Profiles(
    name: '',
    lastname: '',
    nickname: '',
    condisease: '',
    allergic: '',
    email: '',
    phone: '',
    birthday: DateTime.now(),
    gender: 'ชาย',
    imageUrl: '',
  );

  Stream<Profiles?> streamProfile() {
    User? user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection("profiles")
        .doc(user!.uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return Profiles.fromMap(doc.data() as Map<String, dynamic>);
    });
  }

  int calculateAge(DateTime birthday) {
    DateTime today = DateTime.now();
    int age = today.year - birthday.year;

    // ถ้าวันเดือนเกิดยังไม่ถึงในปีนี้ ให้ลดลง 1
    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) {
      age--;
    }
    return age;
  }

  String formatThaiDate(DateTime date) {
    // เปลี่ยนปีเป็น พ.ศ.
    final thaiYear = date.year + 543;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/$thaiYear';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Error"),
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

        return StreamBuilder<Profiles?>(
          stream: streamProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("ไม่พบข้อมูล"));
            }

            Profiles profiles = snapshot.data!;
            // // snapshot สำเร็จ
            return Scaffold(
              appBar: AppBar(
                title: const Text('ข้อมูลส่วนตัว'),
                centerTitle: true,
                titleTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.black,
                ),
                backgroundColor: Colors.redAccent,
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Icon(Icons.edit),
                    ),
                    iconSize: 35,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditProfile()),
                      );
                    },
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ส่วนหัวโปรไฟล์
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 70,
                            backgroundImage: (profiles.imageUrl != null &&
                                    profiles.imageUrl!.isNotEmpty)
                                ? NetworkImage(
                                    profiles.imageUrl!) // โหลดรูปจาก Firestore
                                : null, // ถ้าไม่มีรูป
                            child: (profiles.imageUrl == null ||
                                    profiles.imageUrl!.isEmpty)
                                ? const Icon(Icons.person,
                                    size: 70) // แสดงไอคอนแทน
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${profiles.name} ${profiles.lastname}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'อายุ: ${calculateAge(profiles.birthday)} ปี | เพศ: ${profiles.gender}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ข้อมูลส่วนตัว
                    _buildProfileSection(
                      title: 'ข้อมูลส่วนตัว',
                      children: [
                        _buildProfileItem('ชื่อเล่น', '${profiles.nickname} '),
                        _buildProfileItem('วัน/เดือน/ปีเกิด',
                            formatThaiDate(profiles.birthday)),
                        _buildProfileItem('อีเมล', '${profiles.email} '),
                        _buildProfileItem('เบอร์ติดต่อ', '${profiles.phone} '),
                      ],
                    ),

                    // ข้อมูลสุขภาพ
                    _buildProfileSection(
                      title: 'ข้อมูลสุขภาพ',
                      children: [
                        _buildProfileItem(
                            'โรคประจำตัว', '${profiles.condisease} '),
                        _buildProfileItem('ยาที่แพ้', '${profiles.allergic} '),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: children,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
