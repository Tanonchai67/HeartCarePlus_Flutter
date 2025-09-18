import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:heartcare_plus/models/gemini_model.dart';
import 'package:intl/intl.dart';

import 'gemini_service.dart';

class GeminiChat extends StatefulWidget {
  const GeminiChat({super.key});

  @override
  State<GeminiChat> createState() => _GeminiChatState();
}

class _GeminiChatState extends State<GeminiChat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService gemini = GeminiService();
  final FlutterTts flutterTts = FlutterTts();
  String userName = "ผู้ใช้";

  List<Message> messages = [];
  bool isLoading = false;

  //speak_massage
  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("th-TH");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  //แปลงวันที่
  String getThaiDateTime() {
    final datenow = DateTime.now().toLocal();
    final yearthai = datenow.year + 543;
    final formatter = DateFormat('วันที่ d MMMM $yearthai', 'th_TH');
    return formatter.format(datenow);
  }

  //แปลงเวลา
  String getThaiTime() {
    final timenow = DateTime.now().toLocal();
    final yearthai = timenow.year + 543;
    final formatter = DateFormat('HH:mm น. วันที่ d MMMM $yearthai', 'th_TH');
    return formatter.format(timenow);
  }

  //ส่งข้อความ
  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(Message(text: text, isUser: true));
      _controller.clear();
      isLoading = true;
    });

    _scrollToBottom();

    try {
      String response;
      if (text.toLowerCase().contains("วันที่") || text.contains("วันนี้")) {
        final nowThai = getThaiDateTime();
        response = "วันนี้ $nowThai ค่ะ";
      } else if (text.toLowerCase().contains("เวลา") ||
          text.contains("ตอนนี้เวลา")) {
        final timenowThai = getThaiTime();
        response = "ขณะนี้เวลา $timenowThai ค่ะ";
      } else {
        response = await gemini.askGemini(text);
      }

      setState(() {
        messages.add(Message(text: response, isUser: false));
        isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        messages.add(Message(
            text: "❌ เกิดข้อผิดพลาด: กรุณาเชื่อมต่ออินเทอร์เน็ต!!!",
            isUser: false));
        isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessageBubble(Message message) {
    bool isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFEFEFEF), Color(0xFFD9D9D9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                fontSize: 16,
                color: isUser ? Colors.white : Colors.black87,
                height: 1.5,
              ),
            ),
            if (!isUser)
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.blueAccent),
                  onPressed: () => _speak(message.text),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "🤖 Gemini Chat",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 3),
              ),
            ],
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 3,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: IconButton(
                iconSize: 25,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.delete, color: Colors.white),
                tooltip: 'ล้างแชท',
                onPressed: () {
                  setState(() {
                    messages.clear();
                  });
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (isLoading)
            const LinearProgressIndicator(
              minHeight: 4,
              color: Colors.blueAccent,
            ),
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.smart_toy,
                          size: 80,
                          color: Colors.blueAccent.shade200,
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('profiles')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return Text(
                                "สวัสดี คุณ ผู้ใช้งาน",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..shader = const LinearGradient(
                                      colors: <Color>[
                                        Colors.blue,
                                        Colors.blueAccent,
                                        Colors.lightBlue
                                      ],
                                    ).createShader(const Rect.fromLTWH(
                                        0.0, 0.0, 200.0, 70.0)),
                                ),
                              );
                            }
                            final userData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            final userName = userData['nickname'] ?? "ผู้ใช้";

                            return Text(
                              "สวัสดี คุณ $userName",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..shader = LinearGradient(
                                    colors: <Color>[
                                      Colors.blue,
                                      Colors.blueAccent,
                                      Colors.lightBlue
                                    ],
                                  ).createShader(const Rect.fromLTWH(
                                      0.0, 0.0, 200.0, 70.0)),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "เริ่มแชทกับ Gemini ได้เลย",
                          style: TextStyle(fontSize: 20, color: Colors.black45),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(messages[index]);
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, -2),
                ),
              ],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "ถามเกี่ยวกับสุขภาพได้ที่นี่...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.grey[350],
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
