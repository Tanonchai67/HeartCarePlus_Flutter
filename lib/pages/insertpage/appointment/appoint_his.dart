import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // สำหรับ Text-to-Speech
import 'package:heartcare_plus/pages/insertpage/appointment/appoint_add.dart';
import 'package:heartcare_plus/pages/insertpage/history/animat_toast.dart';
import 'package:intl/intl.dart';

class AppointHis extends StatefulWidget {
  const AppointHis({super.key});

  @override
  State<AppointHis> createState() => _AppointHisState();
}

class _AppointHisState extends State<AppointHis> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
      appBar: AppBar(
        elevation: 8,
        backgroundColor: Colors.teal.shade600,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
        title: const Text(
          'ข้อมูลการนัดหมาย',
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
                icon: const Icon(Icons.favorite, color: Colors.white, size: 28),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),

      // Body
      body: user == null
          ? const Center(
              child: Text(
                "กรุณาเข้าสู่ระบบ",
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("appointments")
                  .doc(user!.uid)
                  .collection("my_appointments")
                  .orderBy("date", descending: false)
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

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "ยังไม่มีข้อมูลการนัดหมาย",
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final date = (data["date"] != null)
                        ? (data["date"] as Timestamp).toDate()
                        : null;
                    final detail = data["detail"] ?? "-";
                    final location = data["location"] ?? "-";
                    final time = data["time"] ?? "-";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ข้อมูล
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (date != null)
                                  Text(
                                    "${DateFormat('dd MMMM', 'th_TH').format(date)} ${date.year + 543}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                const Divider(thickness: 1),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        size: 20, color: Colors.black54),
                                    const SizedBox(width: 6),
                                    Text("เวลา: $time",
                                        style: const TextStyle(fontSize: 18)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 20, color: Colors.black54),
                                    const SizedBox(width: 6),
                                    Text("สถานที่: $location",
                                        style: const TextStyle(fontSize: 18)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.note,
                                        size: 20, color: Colors.black54),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text("รายละเอียด: $detail",
                                          style: const TextStyle(fontSize: 18)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // ปุ่มเสียง
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.volume_up,
                                    size: 32, color: Colors.blueAccent),
                                onPressed: () {
                                  String textToSpeak = "";
                                  if (date != null) {
                                    textToSpeak +=
                                        "วันที่ ${date.day}/${date.month}/${date.year + 543}, ";
                                  }
                                  textToSpeak += "เวลา: $time, ";
                                  textToSpeak += "สถานที่: $location, ";
                                  textToSpeak += "รายละเอียด: $detail";
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
                                        borderRadius: BorderRadius.circular(20),
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 12),
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
                                            backgroundColor: Colors.redAccent,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 12),
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
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection("appointments")
                                          .doc(user!.uid)
                                          .collection("my_appointments")
                                          .doc(docs[index].id)
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
                        ],
                      ),
                    );
                  },
                );
              },
            ),

      backgroundColor: const Color(0xFFF0F3FA),

      // ปุ่มลอย
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.greenAccent, Colors.teal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
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
                  builder: (context) => const AppointAdds(),
                ),
              );
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.add, size: 40, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
