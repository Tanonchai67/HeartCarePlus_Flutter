import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // สำหรับ Text-to-Speech
import 'package:heartcare_plus/pages/insertpage/history/animat_toast.dart';
import 'package:heartcare_plus/pages/insertpage/medicine/medicine_add.dart';
import 'package:heartcare_plus/pages/insertpage/medicine/notification_service.dart';

class MedicineList extends StatefulWidget {
  const MedicineList({super.key});

  @override
  State<MedicineList> createState() => _MedicineListState();
}

class _MedicineListState extends State<MedicineList> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FlutterTts flutterTts = FlutterTts();

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("th-TH");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    NotificationService.init();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'ข้อมูลการทานยา',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Color(0xFF4DB6AC),
        elevation: 6,
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
      body: user == null
          ? const Center(
              child: Text(
                "กรุณาเข้าสู่ระบบ",
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("medicines")
                  .doc(user!.uid)
                  .collection("my_medicines")
                  .orderBy("time", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "เกิดข้อผิดพลาด: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final doc = snapshot.data!.docs;

                if (doc.isEmpty) {
                  return const Center(
                    child: Text(
                      "ยังไม่มีข้อมูลการทานยา",
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: doc.length,
                  itemBuilder: (context, index) {
                    final data = doc[index].data() as Map<String, dynamic>;
                    final nameMDC = data["name"] ?? "-";
                    final timeMDC = data["time"] ?? "-";
                    var isNotificationOn = data["isNotificationOn"] ?? true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white, // ใช้สีพื้นขาวสบายตา
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ข้อมูลยา
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (nameMDC != null)
                                  Text(
                                    nameMDC,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24, // ใหญ่ อ่านง่าย
                                      color: Colors.black87,
                                    ),
                                  ),
                                const SizedBox(height: 6),
                                Text(
                                  "เวลา: $timeMDC",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Column(
                            children: [
                              // ปุ่ม TTS
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.volume_up,
                                      size: 30,
                                      color: Colors.blueAccent,
                                    ),
                                    onPressed: () {
                                      String textToSpeak = "";
                                      if (nameMDC != null) {
                                        textToSpeak += "ชื่อยา: $nameMDC";
                                      }
                                      textToSpeak += "เวลากินยา: $timeMDC";
                                      speak(textToSpeak);
                                    },
                                  ),
                                  // ปุ่มลบ
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 30,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () async {
                                      // แสดง dialog ยืนยันก่อนลบ
                                      bool? confirm = await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          backgroundColor: Colors.white,
                                          elevation: 8,
                                          title: const Text(
                                            "ยืนยันการลบ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                          content: const Text(
                                            "คุณต้องการลบประวัตินี้หรือไม่?",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87),
                                          ),
                                          actionsAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          actions: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.grey.shade300,
                                                foregroundColor: Colors.black87,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                elevation: 4,
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text(
                                                "ยกเลิก",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.redAccent,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                elevation: 4,
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text(
                                                "ลบ",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection("medicines")
                                              .doc(user!.uid)
                                              .collection("my_medicines")
                                              .doc(doc[index].id)
                                              .delete();

                                          showCustomToast(
                                              context, "ลบข้อมูลเรียบร้อย");
                                        } catch (e) {
                                          showCustomToastError(
                                              context, "ลบข้อมูลไม่สำเร็จ");
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),

                              // ปุ่มตั้งค่าแจ้งเตือน
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isNotificationOn
                                          ? Icons.notifications_active
                                          : Icons.notifications_off,
                                      size: 30,
                                      color: isNotificationOn
                                          ? Colors.blueAccent
                                          : Colors.grey,
                                    ),
                                    onPressed: () async {
                                      final newStatus =
                                          !isNotificationOn; // สลับสถานะ

                                      // อัปเดต Firestore
                                      await FirebaseFirestore.instance
                                          .collection("medicines")
                                          .doc(user!.uid)
                                          .collection("my_medicines")
                                          .doc(doc[index].id)
                                          .update(
                                              {"isNotificationOn": newStatus});

                                      if (newStatus) {
                                        await NotificationService()
                                            .scheduleMedicineNotification(
                                          doc[index].id,
                                          nameMDC,
                                          timeMDC,
                                        );
                                        showCustomToast(context,
                                            "เปิดการแจ้งเตือน\n ชื่อยา: $nameMDC");
                                      } else {
                                        await NotificationService()
                                            .cancelNotification(doc[index].id);
                                        showCustomToastError(context,
                                            "ปิดการแจ้งเตือน\n ชื่อยา: $nameMDC");
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      backgroundColor: const Color(0xFFF5F5F9),
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
                  builder: (context) => const MedicineAdd(),
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
}
