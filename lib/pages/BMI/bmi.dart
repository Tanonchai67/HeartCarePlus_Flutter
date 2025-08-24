import 'package:flutter/material.dart';

class BMICalculatorPage extends StatefulWidget {
  const BMICalculatorPage({super.key});

  @override
  State<BMICalculatorPage> createState() => _BMICalculatorPageState();
}

class _BMICalculatorPageState extends State<BMICalculatorPage> {
  double _height = 165;
  double _weight = 65;
  double? _bmiResult;
  String? _bmiCategory;

  void _calculateBMI() {
    if (_height > 0) {
      final heightInMeter = _height / 100;
      setState(() {
        _bmiResult = _weight / (heightInMeter * heightInMeter);
        _updateBMICategory();
      });
    }
  }

  void _updateBMICategory() {
    if (_bmiResult == null) return;

    if (_bmiResult! < 18.5) {
      _bmiCategory = 'น้ำหนักน้อย / ผอม';
    } else if (_bmiResult! < 23) {
      _bmiCategory = 'ปกติ (สุขภาพดี)';
    } else if (_bmiResult! < 25) {
      _bmiCategory = 'ท้วม / โรคอ้วนระดับ 1';
    } else if (_bmiResult! < 30) {
      _bmiCategory = 'อ้วน / โรคอ้วนระดับ 2';
    } else {
      _bmiCategory = 'อ้วนมาก / โรคอ้วนระดับ 3';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('คำนวณ BMI'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          color: Colors.black,
        ),
        backgroundColor: Colors.redAccent,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // คำอธิบาย BMI
            const Card(
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ค่า BMI คือค่าดัชนีมวลกายที่ใช้ชี้วัดความสมบูรณ์ของน้ำหนักตัว (กิโลกรัม) และส่วนสูง (เซนติเมตร) ซึ่งสามารถระบุได้ว่ารูปร่างของคนคนนั้นอยู่ในระดับใด ตั้งแต่ผอมไปจนถึงอ้วนเกินไป',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ส่วนสูง
            const Text(
              'ส่วนสูง (ซม.)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _height,
              min: 80,
              max: 200,
              divisions: 150,
              label: _height.toStringAsFixed(0),
              onChanged: (value) {
                setState(() {
                  _height = value;
                });
              },
            ),
            Center(
              child: Text(
                '${_height.toStringAsFixed(0)} ซม.',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 20),

            // น้ำหนัก
            const Text(
              'น้ำหนัก (กก.)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _weight,
              min: 30,
              max: 200,
              divisions: 170,
              label: _weight.toStringAsFixed(0),
              onChanged: (value) {
                setState(() {
                  _weight = value;
                });
              },
            ),
            Center(
              child: Text(
                '${_weight.toStringAsFixed(0)} กก.',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 30),

            // ปุ่มคำนวณ
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _calculateBMI,
                child: const Text(
                  'คำนวณ',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ผลลัพธ์
            if (_bmiResult != null)
              Center(
                child: SizedBox(
                  width: 300, // กำหนดความกว้าง
                  height: 200, // กำหนดความสูง
                  child: Card(
                    elevation: 3,
                    color: _getBMIColor(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'ผลการคำนวณ BMI',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _bmiResult!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 45,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _bmiCategory!,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getBMIColor() {
    if (_bmiResult == null) return Colors.grey;
    if (_bmiResult! < 18.5) return Colors.blue; // ผอม
    if (_bmiResult! < 23) return Colors.green; // ปกติ
    if (_bmiResult! < 25) return Colors.yellow[700]!; // ท้วม
    if (_bmiResult! < 30) return Colors.orange; // อ้วน
    return Colors.red; // อ้วนมาก
  }
}
