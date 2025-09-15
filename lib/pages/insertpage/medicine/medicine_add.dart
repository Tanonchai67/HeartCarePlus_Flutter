import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:heartcare_plus/models/medicine_model.dart';
import 'package:heartcare_plus/pages/insertpage/history/animat_toast.dart';
import 'package:heartcare_plus/pages/insertpage/medicine/notification_service.dart';

class MedicineAdd extends StatefulWidget {
  const MedicineAdd({super.key});

  @override
  State<MedicineAdd> createState() => _MedicineAddState();
}

class _MedicineAddState extends State<MedicineAdd> {
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  bool isNotificationOn = true;
  Medicines medicines = Medicines(nameMDC: '', timeMDC: '');

// แปลง TimeOfDay เป็น HH:mm 24 ชั่วโมง
  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  //
  Future<void> scheduleAllMedicineNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("medicines")
        .doc(user.uid)
        .collection("my_medicines")
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final name = data["name"] ?? "ไม่มีข้อมูล";
      final time = data["time"] ?? "ไม่มีข้อมูล";
      final isNotificationOn = data["isNotificationOn"] ?? true;

      if (isNotificationOn) {
        await NotificationService().scheduleMedicineNotification(
          doc.id,
          name,
          time,
        );
      } else {
        // ปิดเฉพาะรายการที่ปิด
        await NotificationService().cancelNotification(doc.id);
      }
    }
  }

  void _saveMedicine() async {
    await NotificationService.init();
    if (_formKey.currentState!.validate()) {
      setState(() {
        medicines.nameMDC = _nameController.text.trim();
      });

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showCustomToastError(context, "ไม่มี user เข้าสู่ระบบ");
        return;
      }

      // ✅ บันทึกลง Firestore
      try {
        await FirebaseFirestore.instance
            .collection("medicines")
            .doc(user.uid)
            .collection("my_medicines")
            .add({
          "name": medicines.nameMDC,
          "time": medicines.timeMDC,
          "isNotificationOn": isNotificationOn,
          "createdAt": FieldValue.serverTimestamp(),
        });
        await scheduleAllMedicineNotifications();

        showCustomToast(context, "บันทึกข้อมูลเรียบร้อย");
        _clearForm();
        Navigator.pop(context);
      } catch (e) {
        showCustomToastError(context, "บันทึกข้อมูลไม่สำเร็จ");
      }
    }
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _timeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'ตั้งเวลาทานยา',
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
        backgroundColor: Color(0xFF4DB6AC),
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
                icon: const Icon(Icons.favorite, color: Colors.white, size: 28),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ชื่อยา",
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 16, 145, 134))),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.medication_liquid_outlined,
                            color: Color(0xFF4DB6AC),
                          ),
                          hintText: "กรอกชื่อยา",
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 16),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? "กรุณากรอกชื่อยา"
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("เวลาแจ้งเตือน",
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 16, 145, 134))),
                      const SizedBox(height: 10),

                      //
                      TextFormField(
                        controller: _timeController,
                        readOnly: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.access_time,
                              color: Color(0xFF4DB6AC)),
                          hintText: "เลือกเวลา",
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 16),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? "กรุณาเลือกเวลา"
                            : null,
                        onTap: () async {
                          TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              String formatted = formatTimeOfDay(picked);
                              _timeController.text = "$formatted น.";
                              medicines.timeMDC = "$formatted น.";
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Toggle แจ้งเตือน
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("เปิดการแจ้งเตือน",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  Switch(
                    value: isNotificationOn,
                    onChanged: (value) {
                      setState(() {
                        isNotificationOn = value;
                      });
                    },
                    activeThumbColor: Color(0xFF4DB6AC),
                  )
                ],
              ),
              const SizedBox(height: 36),

              //ปุ่ม
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ปุ่มล้าง
                  ElevatedButton.icon(
                    onPressed: _clearForm,
                    icon: const Icon(Icons.clear, color: Colors.white),
                    label: const Text(
                      'ล้าง',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    onPressed: _saveMedicine,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'บันทึก',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4DB6AC),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
