import 'package:flutter/material.dart';
import 'package:heartcare_plus/pages/ArticlePage/ArtiicleDetail.dart';

class ArticlePage extends StatelessWidget {
  const ArticlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('บทความ'),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          color: Colors.black,
        ),
        backgroundColor: const Color(0xFFF2F2F7),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ArticleDetailPage()),
            );
          },
          child: Container(
            width: double.infinity,
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
              'เรื่อง: คุณเป็นความดันโลหิตสูงหรือไม่\n'
              'จาก: โรงพยาบาลศิริราชปิยมหาการุณย์',
              style: TextStyle(
                fontSize: 18,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
