import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heartcare_plus/pages/insertpage/history/animat_toast.dart';

class InsertPersure extends StatefulWidget {
  const InsertPersure({super.key});

  @override
  State<InsertPersure> createState() => _InsertPersureState();
}

class _InsertPersureState extends State<InsertPersure> {
  final _formKey = GlobalKey<FormState>();

  final hrCtrl = TextEditingController();
  final sysCtrl = TextEditingController();
  final diaCtrl = TextEditingController();
  final spo2Ctrl = TextEditingController();

  Future<void> saveData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showCustomToastError(context, "กรุณาเข้าสู่ระบบก่อน");
      return;
    }

    Map<String, dynamic> data = {};

    if (hrCtrl.text.isNotEmpty) data["heartRate"] = double.parse(hrCtrl.text);
    if (sysCtrl.text.isNotEmpty) data["sys"] = double.parse(sysCtrl.text);
    if (diaCtrl.text.isNotEmpty) data["dia"] = double.parse(diaCtrl.text);
    if (spo2Ctrl.text.isNotEmpty) data["spo2"] = double.parse(spo2Ctrl.text);

// เพิ่ม timestamp เสมอ
    data["persurestime"] = FieldValue.serverTimestamp();

    try {
      await FirebaseFirestore.instance
          .collection("persures")
          .doc(user.uid)
          .set(data, SetOptions(merge: true));

      _clearForm();
      showCustomToast(context, "บันทึกข้อมูลเรียบร้อย");
    } catch (e) {
      showCustomToastError(context, "เกิดข้อผิดพลาด");
    }
  }

  void _clearForm() {
    setState(() {
      hrCtrl.clear();
      sysCtrl.clear();
      diaCtrl.clear();
      spo2Ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'กรอกข้อมูลสุขภาพ',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        shadowColor: Colors.black38,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.white, size: 28),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildInputCard("อัตราการเต้นหัวใจ (HR)", "ครั้ง/นาที", hrCtrl,
                  Icons.favorite, Colors.redAccent),
              buildInputCard("ความดันตัวบน (SYS)", "mmHg", sysCtrl,
                  Icons.monitor_heart, Colors.blueAccent),
              buildInputCard("ความดันตัวล่าง (DIA)", "mmHg", diaCtrl,
                  Icons.bloodtype, Colors.deepPurpleAccent),
              buildInputCard(
                  "SpO₂", "%", spo2Ctrl, Icons.air, Colors.greenAccent),
              const SizedBox(height: 30),

              //ปุ่ม
              ElevatedButton.icon(
                onPressed: () async {
                  if (hrCtrl.text.isEmpty &&
                      sysCtrl.text.isEmpty &&
                      diaCtrl.text.isEmpty &&
                      spo2Ctrl.text.isEmpty) {
                    showCustomToastError(context, "กรอกอย่างน้อย 1 ช่อง");
                  } else {
                    await saveData();
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                icon: const Icon(Icons.save, color: Colors.white, size: 28),
                label: const Text(
                  'คำนวณ & บันทึก',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputCard(String label, String unit, TextEditingController ctrl,
      IconData icon, Color iconColor) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: SizedBox(
          width: 50,
          height: 50,
          child: CircleAvatar(
            // ignore: deprecated_member_use
            backgroundColor: iconColor.withOpacity(0.2),
            child: Icon(icon, color: iconColor, size: 35),
          ),
        ),
        title: TextFormField(
          controller: ctrl,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            suffixText: unit,
            // suffixStyle: TextStyle(fontSize: 18),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
