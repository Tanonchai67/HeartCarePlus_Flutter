import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BMICalculatorPage extends StatefulWidget {
  const BMICalculatorPage({super.key});

  @override
  State<BMICalculatorPage> createState() => _BMICalculatorPageState();
}

class _BMICalculatorPageState extends State<BMICalculatorPage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  double? _bmiResult;
  String? _bmiCategory;

  void _calculateBMI() {
    final heightText = _heightController.text.trim();
    final weightText = _weightController.text.trim();

    if (heightText.isEmpty || weightText.isEmpty) return;

    final height = double.tryParse(heightText);
    final weight = double.tryParse(weightText);

    if (height == null || weight == null || height <= 0 || weight <= 0) return;

    final heightInMeter = height / 100;
    final bmi = weight / (heightInMeter * heightInMeter);

    setState(() {
      _bmiResult = bmi;
      _updateBMICategory();
    });

    // บันทึกลง Firestore
    if (_bmiResult != null && _bmiCategory != null) {
      saveBMI(_bmiResult!, _bmiCategory!);
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

  Future<void> saveBMI(double bmi, String category) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('persures').doc(user.uid).set(
        {
          'bmi': bmi,
          'bmidetail': category,
          'bmitime': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true), // สำคัญ! เพื่อไม่ลบ field อื่นๆ ที่มีอยู่
      );

      print('BMI saved to Firestore successfully');
    } catch (e) {
      print('Error saving BMI: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 8,
        backgroundColor: Colors.blue.shade600,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.fitness_center,
                  color: Colors.white, size: 30),
              onPressed: () {},
            ),
            const Text(
              'คำนวณ BMI',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // คำอธิบาย
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: const AutoSizeText(
                  'ค่า BMI คือค่าดัชนีมวลกายที่ใช้ชี้วัดความสมบูรณ์ของน้ำหนักตัวและส่วนสูง ซึ่งสามารถระบุได้ว่ารูปร่างของคุณอยู่ในระดับใด ตั้งแต่ผอมไปจนถึงอ้วนเกินไป',
                  style: TextStyle(height: 1.5),
                  maxLines: 8,
                  minFontSize: 18,
                  maxFontSize: 20,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildSection(
                    title: "ส่วนสูง (ซม.)",
                    child: TextFormField(
                      controller: _heightController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration(hintText: "165"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSection(
                    title: "น้ำหนัก (กก.)",
                    child: TextFormField(
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      controller: _weightController,
                      decoration: _inputDecoration(hintText: "60"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),

            // ปุ่มคำนวณ
            Center(
              child: _buildButton(
                text: "คำนวณ",
                color: Colors.teal.shade400,
                icon: Icons.calculate_outlined,
                onPressed: _calculateBMI,
              ),
            ),
            SizedBox(height: 30),

            // ผลลัพธ์
            if (_bmiResult != null)
              Center(
                child: Container(
                  width: 300,
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      // ignore: deprecated_member_use
                      colors: [_getBMIColor().withOpacity(0.9), _getBMIColor()],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: _getBMIColor().withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'ผลการคำนวณ BMI',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _bmiResult!.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(
                        _bmiCategory!,
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ],
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
    if (_bmiResult! < 18.5) return Colors.blueAccent;
    if (_bmiResult! < 23) return Colors.green;
    if (_bmiResult! < 25) return Colors.yellow[700]!;
    if (_bmiResult! < 30) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}

// --- Widgets Helper --- ใช้สำหรับช่วยแต่งให้สวยๆ
Widget _buildSection({
  required String title,
  required Widget child,
}) {
  return Card(
    elevation: 4,
    margin: const EdgeInsets.symmetric(vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: 120,
        height: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    ),
  );
}

InputDecoration _inputDecoration({String? hintText}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(fontSize: 20, color: Colors.grey),
    filled: true,
    fillColor: Colors.grey[50],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 25, horizontal: 16),
  );
}

Widget _buildButton({
  required String text,
  required Color color,
  required IconData icon,
  required VoidCallback onPressed,
}) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, color: Colors.white, size: 40),
    label: Text(
      text,
      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 6,
    ),
  );
}
