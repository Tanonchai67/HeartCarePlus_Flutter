import 'package:flutter/material.dart';

class AddTreatmentPage extends StatefulWidget {
  const AddTreatmentPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddTreatmentPageState createState() => _AddTreatmentPageState();
}

class _AddTreatmentPageState extends State<AddTreatmentPage> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController detailController = TextEditingController();

  void clearFields() {
    dateController.clear();
    detailController.clear();
  }

  void saveData() {
    String date = dateController.text.trim();
    String detail = detailController.text.trim();

    if (date.isEmpty || detail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย')),
    );

    clearFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('บันทึกข้อมูลการรักษา'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.favorite, color: Colors.red),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text('วัน/เดือน/ปีที่บันทึก')),
            const SizedBox(height: 8),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.calendar_today),
                hintText: '02/05/2568',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 24),
            const Text('รายละเอียด'),
            const SizedBox(height: 8),
            TextField(
              controller: detailController,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'พิมพ์รายละเอียดที่นี่',
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: clearFields,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('ล้าง'),
                ),
                ElevatedButton(
                  onPressed: saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('บันทึก'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
