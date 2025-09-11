import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:heartcare_plus/models/treatment_model.dart';
import 'package:heartcare_plus/pages/insertpage/history/animat_toast.dart';
import 'package:intl/intl.dart';

class TreatmentAddPage extends StatefulWidget {
  const TreatmentAddPage({super.key});

  @override
  State<TreatmentAddPage> createState() => _TreatmentAddPageState();
}

class _TreatmentAddPageState extends State<TreatmentAddPage> {
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();

  Treatments treatments = Treatments(dateaddTM: DateTime.now(), detailTM: '');

//ใช้ตอนโชว์เฉยๆ
  String formatDateBuddhist(DateTime date) {
    final buddhistYear = date.year + 543;
    return '${DateFormat('dd/MM').format(date)}/$buddhistYear';
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        final buddhistYear = picked.year + 543;
        _dateController.text =
            '${DateFormat('dd/MM').format(picked)}/$buddhistYear';

        treatments.dateaddTM = picked;
      });
    }
  }

  void _saveTreatment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        treatments.detailTM = _detailController.text;
      });

      // ดึง user ปัจจุบัน
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showCustomToastError(context, "ไม่มี user เข้าสู่ระบบ");
        return;
      }

      try {
        await FirebaseFirestore.instance
            .collection('treatments') // collection หลัก
            .doc(user.uid) // แยก user ด้วย uid
            .collection('my_treatments') // subcollection ของ user
            .add({
          'detail': treatments.detailTM,
          'date': treatments.dateaddTM,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // แสดง Toast ว่าสำเร็จ
        showCustomToast(context, "บันทึกข้อมูลเรียบร้อย");

        // ล้างฟอร์ม
        _clearForm();
        Navigator.pop(context);
      } catch (e) {
        debugPrint("Error saving treatment: $e");
        showCustomToastError(context, "บันทึกข้อมูลไม่สำเร็จ");
      }
    }
  }

  void _clearForm() {
    setState(() {
      _dateController.clear();
      _detailController.clear();
      treatments = Treatments(dateaddTM: DateTime.now(), detailTM: '');
    });
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

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              'บันทึกประวัติการรักษา',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.blueAccent,
            elevation: 6,
            shadowColor: Colors.black45,
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
                    gradient: const LinearGradient(
                      colors: [Colors.redAccent, Colors.red],
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
                    icon: const Icon(Icons.favorite,
                        color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFF5F5F9),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'วัน/เดือน/ปีที่บันทึก',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.calendar_today,
                          color: Colors.blueAccent),
                      hintText: formatDateBuddhist(DateTime.now()),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'รายละเอียด',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _detailController,
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText: 'พิมพ์รายละเอียดที่นี่',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'กรุณากรอกรายละเอียด';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // ปุ่มล้าง
                      ElevatedButton.icon(
                        onPressed: _clearForm,
                        icon: const Icon(Icons.clear, color: Colors.white),
                        label: const Text(
                          'ล้าง',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 6,
                        ),
                      ),
                      // ปุ่มบันทึก
                      ElevatedButton.icon(
                        onPressed: _saveTreatment,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          'บันทึก',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 6,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
