import 'package:flutter/material.dart';
import 'package:heartcare_plus/pages/setting/add_profile.dart';

class PatientProfilePage extends StatelessWidget {
  const PatientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                MaterialPageRoute(builder: (context) => const AddProfile()),
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
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/img/doctor.png'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'นายสมชาย เบือนไทย',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'อายุ: 50 ปี | เพศ: ชาย',
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
                _buildProfileItem('วัน/เดือน/ปีเกิด', '20 มกราคม 2518'),
                _buildProfileItem('อีเมล', 'somchaith@gmail.com'),
                _buildProfileItem('ที่อยู่',
                    '247 ม.7 บ้านปากกาวสะอาด\nต.ขึ้นเล็ก อ.แปรบ จ.เชียงใหม่ 55180'),
                _buildProfileItem('เบอร์โทรศัพท์', '061-234-5678'),
                _buildProfileItem('เบอร์ติดต่อญาติ', '061-956-7820'),
              ],
            ),

            // ข้อมูลสุขภาพ
            _buildProfileSection(
              title: 'ข้อมูลสุขภาพ',
              children: [
                _buildProfileItem('โรคประจำตัว', 'โรคความดันโลหิตสูง'),
                _buildProfileItem('ระยะเวลาที่เป็นโรค', '5 ปี'),
                _buildProfileItem('ยาที่แพ้', 'ไม่มี'),
                _buildProfileItem('อาหารที่แพ้', 'ไม่มี'),
              ],
            ),

            // ปุ่มแก้ไขโปรไฟล์
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    // Navigate to edit profile
                  },
                  child: const Text('แก้ไขข้อมูลโปรไฟล์'),
                ),
              ),
            ),
          ],
        ),
      ),
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
            color: Colors.red,
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
