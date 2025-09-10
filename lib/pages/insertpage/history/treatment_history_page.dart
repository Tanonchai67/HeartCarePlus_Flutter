import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // สำหรับ Text-to-Speech
import 'package:intl/intl.dart';

import 'add_treatment_page.dart';

class TreatmentHistoryPage extends StatefulWidget {
  const TreatmentHistoryPage({super.key});

  @override
  State<TreatmentHistoryPage> createState() => _TreatmentHistoryPageState();
}

class _TreatmentHistoryPageState extends State<TreatmentHistoryPage> {
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'ประวัติการรักษา',
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
      body: user == null
          ? const Center(
              child: Text(
                "กรุณาเข้าสู่ระบบ",
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("treatments")
                  .doc(user!.uid)
                  .collection("my_treatments")
                  .orderBy("date", descending: true)
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
                      "ยังไม่มีประวัติการรักษา",
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final date = (data["date"] != null)
                        ? (data["date"] as Timestamp).toDate()
                        : null;
                    final detail = data["detail"] ?? "-";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB9CCF5), Color(0xFFD7E1FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (date != null)
                                  Text(
                                    "${DateFormat('dd MMMM', 'th_TH').format(date)} ${date.year + 543}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black87,
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  detail,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.volume_up,
                              size: 30,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () {
                              String textToSpeak = "";
                              if (date != null) {
                                textToSpeak +=
                                    "วันที่ ${date.day}/${date.month}/${date.year + 543}. ";
                              }
                              textToSpeak += "รายละเอียดการรักษา: $detail";
                              speak(textToSpeak);
                            },
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
            colors: [Colors.greenAccent, Colors.green],
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
                  builder: (context) => const AddTreatmentPage(),
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
