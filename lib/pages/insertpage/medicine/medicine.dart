import 'package:flutter/material.dart';
import 'package:heartcare_plus/insert.dart';
import 'package:heartcare_plus/pages/insertpage/medicine/insert.dart';

class MedicineScreen extends StatelessWidget {
  const MedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HealthApp()),
            );
          },
        ),
        title: const Text('การทานยา'),
        actions: const [
          Icon(Icons.favorite_border, color: Colors.red),
          SizedBox(width: 16),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 186, 192, 243),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/medic.jpg', // แทนที่ด้วย URL หรือ Asset ของภาพยา
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ชื่อยา: พาราเซตามอล',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'เวลา: 10:00 น.',
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Column(
                    children: [
                      Icon(Icons.toggle_on,
                          color: Colors.red, size: 52), // ปุ่มเปิด/ปิด
                      SizedBox(height: 8),
                      Icon(Icons.edit, color: Colors.black87), // ปุ่มแก้ไข
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMedicineScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 132, 132),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('เพิ่มข้อมูล'),
            ),
          )
        ],
      ),
    );
  }
}
