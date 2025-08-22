import 'package:flutter/material.dart';
import 'package:heartcare_plus/pages/insertpage/medicine/medicine.dart';

class AddMedicineScreen extends StatelessWidget {
  final TextEditingController nameController =
      TextEditingController(text: 'พาราเซตามอล');
  final TextEditingController timeController =
      TextEditingController(text: '10:00 น.');

  AddMedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MedicineScreen()),
            );
          },
        ),
        title: const Text('บันทึกการทานยา'),
        actions: const [
          Icon(Icons.favorite_border, color: Colors.red),
          SizedBox(width: 16),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ชื่อยา
            const Text("ชื่อยา", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.medication, color: Colors.red),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // เวลา
            const Text("เวลาในการแจ้งเตือน", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: timeController,
              readOnly: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.access_time),
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  // ignore: use_build_context_synchronously
                  timeController.text = picked.format(context);
                }
              },
            ),
            const SizedBox(height: 24),

            // อัปโหลดรูปภาพ
            const Row(
              children: [
                Icon(Icons.camera_alt_outlined),
                SizedBox(width: 8),
                Text("อัปโหลดรูปภาพ", style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 200,
                height: 130,
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: const Icon(
                  Icons.camera_alt, // ไอคอนรูปกล้อง
                  size: 40, // ปรับขนาดตามต้องการ
                  color: Colors.grey, // ปรับสีตามต้องการ
                ),
              ),
            ),
            const Spacer(),

            // ปุ่มบันทึก
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(180, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('บันทึก', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
