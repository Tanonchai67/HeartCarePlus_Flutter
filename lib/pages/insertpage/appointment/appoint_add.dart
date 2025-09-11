import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:heartcare_plus/models/appoint_model.dart';
import 'package:heartcare_plus/pages/insertpage/history/animat_toast.dart';
import 'package:intl/intl.dart';

class AppointAdds extends StatefulWidget {
  const AppointAdds({super.key});

  @override
  State<AppointAdds> createState() => _AppointAddsState();
}

class _AppointAddsState extends State<AppointAdds> {
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();
  final _timeController = TextEditingController();
  final _detailController = TextEditingController();

  Appointments appointments = Appointments(
    dateaddAPM: DateTime.now(),
    detailAPM: '-',
    locationAPM: '-',
    timeAPM: TimeOfDay.now(),
  );

  // Format วันที่ พ.ศ.
  String formatDateBuddhist(DateTime date) {
    final buddhistYear = date.year + 543;
    return '${DateFormat('dd/MM').format(date)}/$buddhistYear';
  }

  // Format เวลาไทย
  String formatThaiTime(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return "$hours:$minutes น.";
  }

  // เลือกวัน
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dateController.text = formatDateBuddhist(picked);
        appointments.dateaddAPM = picked;
      });
    }
  }

  // บันทึกข้อมูล
  void _saveAppointments() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        appointments.locationAPM = _locationController.text;
        appointments.detailAPM = _detailController.text;
      });

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showCustomToastError(context, "ไม่มี user เข้าสู่ระบบ");
        return;
      }

      try {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(user.uid)
            .collection('my_appointments')
            .add({
          'date': appointments.dateaddAPM,
          'location': appointments.locationAPM,
          'time': formatThaiTime(appointments.timeAPM),
          'detail': appointments.detailAPM,
          'timestamp': FieldValue.serverTimestamp(),
        });

        showCustomToast(context, "บันทึกข้อมูลเรียบร้อย");
        _clearForm();
        Navigator.pop(context);
      } catch (e) {
        debugPrint("Error saving appointment: $e");
        showCustomToastError(context, "บันทึกข้อมูลไม่สำเร็จ");
      }
    }
  }

  // ล้างฟอร์ม
  void _clearForm() {
    setState(() {
      _dateController.clear();
      _locationController.clear();
      _timeController.clear();
      _detailController.clear();
      appointments = Appointments(
        dateaddAPM: DateTime.now(),
        detailAPM: '-',
        locationAPM: '-',
        timeAPM: TimeOfDay.now(),
      );
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
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            elevation: 8,
            backgroundColor: Colors.teal.shade600,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            title: const Text(
              'บันทึกการนัดหมาย',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
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

          //
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildSection(
                    title: "วัน/เดือน/ปีที่นัด",
                    child: TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: _inputDecoration(
                        icon: Icons.calendar_today,
                        hint: formatDateBuddhist(DateTime.now()),
                      ),
                      onTap: () => _selectDate(context),
                    ),
                  ),

                  _buildSection(
                    title: "สถานที่",
                    child: TextFormField(
                      controller: _locationController,
                      decoration: _inputDecoration(
                        icon: Icons.local_hospital,
                        hint: 'ชื่อโรงพยาบาล / คลินิก',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณากรอกสถานที่';
                        }
                        return null;
                      },
                    ),
                  ),

                  _buildSection(
                    title: "เวลา",
                    child: TextFormField(
                      controller: _timeController,
                      readOnly: true,
                      decoration: _inputDecoration(
                        icon: Icons.access_time,
                        hint: formatThaiTime(TimeOfDay.now()),
                      ),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (picked != null) {
                          setState(() {
                            _timeController.text = formatThaiTime(picked);
                            appointments.timeAPM = picked;
                          });
                        }
                      },
                    ),
                  ),

                  _buildSection(
                    title: "รายละเอียด",
                    child: TextFormField(
                      controller: _detailController,
                      maxLines: 4,
                      decoration: _inputDecoration(
                        icon: Icons.notes,
                        hint: 'รายละเอียดเพิ่มเติม เช่น พบแพทย์, ตรวจสุขภาพ',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณากรอกรายละเอียด';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ปุ่มบันทึก/ล้าง
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton(
                        text: "ล้าง",
                        color: Colors.redAccent,
                        icon: Icons.clear,
                        onPressed: _clearForm,
                      ),
                      _buildButton(
                        text: "บันทึก",
                        color: Colors.teal,
                        icon: Icons.save,
                        onPressed: _saveAppointments,
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

  // --- Widgets Helper --- ใช้สำหรับช่วยแต่งให้สวยๆ
  Widget _buildSection({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required IconData icon, String? hint}) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.teal),
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
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
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 6,
      ),
    );
  }
}
