// ignore_for_file: file_names
import 'package:flutter/material.dart';

class ArticleDetailPage extends StatelessWidget {
  const ArticleDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('รายละเอียดบทความ',
            style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.favorite, color: Colors.red),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Text(
                'คุณเป็นความดันโลหิตสูงหรือไม่\n\n'
                'ความดันโลหิตสูง ภาวะที่ตรวจพบว่ามีความดันโลหิตอยู่ในระดับสูงผิดปกติซึ่งเกิดขึ้นจากเหตุของภาวะแทรกซ้อนต่างๆ\n\n'
                'ความดันโลหิตคืออะไร?\n'
                'ความดันโลหิตเป็นแรงดันเลือดที่เกิดจากหัวใจสูบฉีดเลือดไปยังอวัยวะทั่วร่างกาย ซึ่งวัดได้ 2 ค่า ได้แก่\n'
                '1. ความดันโลหิตค่าบน คือ แรงดันโลหิตขณะหัวใจบีบตัวเต้นเต็มที่\n'
                '2. ความดันโลหิตค่าล่าง คือ แรงดันโลหิตขณะหัวใจคลายตัวเต้นเต็มที่\n\n'
                'ความดันโลหิตสูงคืออะไร?\n'
                'ความดันโลหิตสูง (Hypertension) เป็นภาวะที่ตรวจพบว่าความดันโลหิตอยู่ในระดับสูงผิดปกติ คือมากกว่า หรือเท่ากับ 140/90 มิลลิเมตรปรอท ซึ่งอาจเป็นอันตรายเพราะแรงดันที่มากเกินทำให้เกิดภาวะแทรกซ้อนได้ เช่น หัวใจวาย โรคหลอดเลือดสมองอุดตัน เลือดออกในสมอง หัวใจวาย ไตวาย เป็นต้น\n\n'
                'หากไม่ได้รับการรักษาอย่างถูกต้องและทันเวลา อาจทำให้ผู้ป่วยมีภาวะแทรกซ้อนหรือเสียชีวิตได้',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            const Column(
              children: [
                Icon(Icons.diamond, size: 36, color: Colors.brown),
                SizedBox(height: 4),
                Text(
                  'โรงพยาบาลศิริราช\nปิยมหาราชการุณย์',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
