import 'package:flutter/material.dart';
import 'package:heartcare_plus/pages/insertpage/date/date_add.dart';

class DateHistory extends StatefulWidget {
  const DateHistory({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DateHis createState() => _DateHis();
}

class _DateHis extends State<DateHistory> {
  final List<Map<String, String>> historyList = [
    {
      'date': '02 พฤษภาคม 2568',
      'detail':
          'ใบส่งตัว เป็นไข้ ได้รับยาพาราเซตามอลจากโรงพยาบาลนครพิงค์ จ.เชียงใหม่'
    },
    {
      'date': '25 เมษายน 2568',
      'detail':
          'หมอนัดตรวจค่าความดันและอัตราการเต้นของหัวใจ ที่โรงพยาบาลนครพิงค์ จ.เชียงใหม่'
    },
    {
      'date': '18 เมษายน 2568',
      'detail':
          'หมอนัดตรวจค่าความดันและอัตราการเต้นของหัวใจ ที่โรงพยาบาลนครพิงค์ จ.เชียงใหม่'
    },
    {
      'date': '11 เมษายน 2568',
      'detail':
          'หมอนัดตรวจค่าความดันและอัตราการเต้นของหัวใจ ที่โรงพยาบาลนครพิงค์ จ.เชียงใหม่'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text('ประวัติการรักษา',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.favorite, color: Colors.red),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: historyList.length,
          itemBuilder: (context, index) {
            final item = historyList[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFB9CCF5),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['date'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['detail'] ?? '',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F9),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DateAdds()),
          );
        },
        backgroundColor: Colors.redAccent,
        tooltip: 'เพิ่มข้อมูลใหม่',
        child: const Icon(Icons.add),
      ),
    );
  }
}
