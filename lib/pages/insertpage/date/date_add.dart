import 'package:flutter/material.dart';

class DateAdds extends StatelessWidget {
  const DateAdds({super.key});

  @override
  Widget build(BuildContext context) {
    final dateController = TextEditingController(text: '10/05/2568');
    final hospitalController = TextEditingController(text: 'โรงพยาบาลนครพิงค์');
    final timeController = TextEditingController(text: '07:30 น.');
    final noteController = TextEditingController(text: 'พบแพทย์');

    return Scaffold(
      appBar: AppBar(
        title: const Text('บันทึกการนัดหมาย'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.favorite, color: Colors.red),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'วัน/เดือน/ปีนัด',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: hospitalController,
              decoration: const InputDecoration(
                labelText: 'สถานที่นัดหมาย (ชื่อโรงพยาบาล)',
                prefixIcon: Icon(Icons.local_hospital),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timeController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'เวลาที่นัดหมาย',
                prefixIcon: Icon(Icons.access_time),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'เรื่องที่นัด',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                // ฟังก์ชันกดบันทึก
              },
              child: const Text(
                'บันทึก',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
