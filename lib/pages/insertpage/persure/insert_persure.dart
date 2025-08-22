import 'package:flutter/material.dart';

class BloodPressureForm extends StatelessWidget {
  const BloodPressureForm({super.key});

  @override
  Widget build(BuildContext context) {
    final dateController = TextEditingController(text: '');
    final sysController = TextEditingController(text: '');
    final diaController = TextEditingController(text: '');
    final pulController = TextEditingController(text: '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('บันทึกความดันและหัวใจ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
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
              decoration: const InputDecoration(
                labelText: 'วัน/เดือน/ปีที่บันทึก',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: sysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'SYS (Systolic Pressure) ค่าความดันขณะหัวใจบีบตัว',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: diaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'DIA (Diastolic Pressure) ค่าความดันขณะหัวใจคลายตัว',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pulController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'PUL (Pulse Rate) ชีพจรหรืออัตราการเต้นของหัวใจ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Icon(Icons.favorite, size: 100, color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                // กดบันทึก
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
