import 'package:auto_size_text/auto_size_text.dart';
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
    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) {
      age--;
    }
    return age;
  }

  String formatThaiDate(DateTime date) {
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
            appBar: AppBar(title: const Text("Error")),
            body: Center(child: Text("${snapshot.error}")),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
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
            return Scaffold(
              appBar: AppBar(
                elevation: 8,
                backgroundColor: Colors.teal.shade600,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                title: const Text(
                  'โปรไฟล์',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                centerTitle: true,
                automaticallyImplyLeading: false,
                actions: [
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.teal],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 6,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.white, size: 25),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const EditProfile()),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // รูปโปรไฟล์
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
                          AutoSizeText(
                            '${profiles.name} ${profiles.lastname}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            minFontSize: 20,
                            maxFontSize: 26,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'อายุ: ${calculateAge(profiles.birthday)} ปี | เพศ: ${profiles.gender}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ข้อมูลส่วนตัว
                    _buildProfileSection(
                      icon: Icons.person,
                      title: 'ข้อมูลส่วนตัว',
                      children: [
                        _buildProfileItem(
                            Icons.face,
                            'ชื่อเล่น',
                            profiles.nickname.isEmpty
                                ? "-"
                                : profiles.nickname),
                        _buildProfileItem(Icons.cake, 'วัน/เดือน/ปีเกิด',
                            formatThaiDate(profiles.birthday)),
                        _buildProfileItem(Icons.email, 'อีเมล',
                            profiles.email.isEmpty ? "-" : profiles.email),
                        _buildProfileItem(Icons.phone, 'เบอร์ติดต่อ',
                            profiles.phone.isEmpty ? "-" : profiles.phone),
                      ],
                    ),

                    // ข้อมูลสุขภาพ
                    _buildProfileSection(
                      icon: Icons.favorite,
                      title: 'ข้อมูลสุขภาพ',
                      children: [
                        _buildProfileItem(
                            Icons.healing,
                            'โรคประจำตัว',
                            profiles.condisease.isEmpty
                                ? "-"
                                : profiles.condisease),
                        _buildProfileItem(
                            Icons.warning,
                            'ยาที่แพ้',
                            profiles.allergic.isEmpty
                                ? "-"
                                : profiles.allergic),
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

  Widget _buildProfileSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.teal, size: 22),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal, // ✅ เปลี่ยนจากแดงเป็นเขียว
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: children),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // วงกลมสำหรับ Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFE0F2F1), // ✅ teal อ่อน
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.teal,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),

            // Label + Value
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AutoSizeText(
                    value.isNotEmpty ? value : "ไม่มีข้อมูล",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    minFontSize: 14,
                    maxFontSize: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
