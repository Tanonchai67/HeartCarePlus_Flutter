import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heartcare_plus/pages/insertpage/persures/insert_persures.dart';
import 'package:intl/intl.dart';

class Persures extends StatefulWidget {
  const Persures({super.key});

  @override
  State<Persures> createState() => _PersuresState();
}

class _PersuresState extends State<Persures> {
  //
  String getStatus(String type, double value) {
    switch (type) {
      case "HR":
        if (value < 60 || value > 100) return "เสี่ยง";
        return "ปกติ";

      case "SYS":
        if (value < 90) return "เสี่ยง";
        if (value <= 120) return "ปกติ";
        if (value <= 139) return "เฝ้าระวัง";
        return "เสี่ยง";

      case "DIA":
        if (value < 60) return "เสี่ยง";
        if (value <= 80) return "ปกติ";
        if (value <= 89) return "เฝ้าระวัง";
        return "เสี่ยง";

      case "SpO2":
        if (value < 94) return "เสี่ยง";
        return "ปกติ";

      case "BMI":
        if (value < 18.5) return "เฝ้าระวัง";
        if (value <= 22.9) return "ปกติ";
        if (value <= 27.4) return "เฝ้าระวัง";
        return "เสี่ยง";

      default:
        return "ไม่ทราบค่า";
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "ปกติ":
        return Colors.green;
      case "เฝ้าระวัง":
        return Colors.orange;
      case "เสี่ยง":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("กรุณาเข้าสู่ระบบ")),
      );
    }

    // Stream ดึงข้อมูลจาก doc ของ user ปัจจุบัน
    final Stream<DocumentSnapshot> userStream = FirebaseFirestore.instance
        .collection("persures")
        .doc(user.uid)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'ข้อมูลสุขภาพ',
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("ยังไม่มีข้อมูล"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          double heartRate = (data["heartRate"] ?? 0).toDouble();
          double sys = (data["sys"] ?? 0).toDouble();
          double dia = (data["dia"] ?? 0).toDouble();
          double spo2 = (data["spo2"] ?? 0).toDouble();
          double bmi = (data["bmi"] ?? 0).toDouble();
          Timestamp timestamp = (data['persurestime'] ?? Timestamp.now());

          bmi = double.parse(bmi.toStringAsFixed(1));

          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              buildHealthCard("อัตราการเต้นหัวใจ", heartRate, "ครั้ง/นาที",
                  "HR", Icons.favorite),
              buildHealthCard(
                  "ความดันตัวบน", sys, "mmHg", "SYS", Icons.monitor_heart),
              buildHealthCard(
                  "ความดันตัวล่าง", dia, "mmHg", "DIA", Icons.bloodtype),
              buildHealthCard("SpO₂", spo2, "%", "SpO2", Icons.air),
              buildHealthCard("BMI", bmi, "kg/m²", "BMI", Icons.fitness_center),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    // ignore: deprecated_member_use
                    backgroundColor: Colors.green.withOpacity(0.15),
                    child: Icon(Icons.timer, color: Colors.green, size: 28),
                  ),
                  title: Text(
                    "ข้อมูลล่าสุด",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    () {
                      final dateTime = (timestamp).toDate();
                      final buddhistYear = dateTime.year + 543;
                      // format เดือน/วัน/เวลา ตาม locale ไทย
                      final formatted =
                          DateFormat('d MMMM $buddhistYear เวลา HH:mm น.', 'th')
                              .format(dateTime);
                      return formatted;
                    }(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Colors.greenAccent, Color(0xFF4DB6AC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: SizedBox(
          width: 70,
          height: 70,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InsertPersure(),
                ),
              );
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            tooltip: 'เพิ่มข้อมูลใหม่',
            child: const Icon(Icons.add, size: 40, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget buildHealthCard(
      String title, double value, String unit, String type, IconData icon) {
    String status = getStatus(type, value);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          // ignore: deprecated_member_use
          backgroundColor: getStatusColor(status).withOpacity(0.15),
          child: Icon(icon, color: getStatusColor(status), size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text("$value $unit", style: const TextStyle(fontSize: 16)),
        trailing: Text(
          status,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: getStatusColor(status),
              fontSize: 16),
        ),
      ),
    );
  }
}
