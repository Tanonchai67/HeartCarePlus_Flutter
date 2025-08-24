import 'package:flutter/material.dart';
import 'package:heartcare_plus/home.dart';
import 'package:heartcare_plus/insert.dart';
import 'package:heartcare_plus/pages/ArticlePage/ArticlePage.dart';
import 'package:heartcare_plus/pages/BMI/bmi.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    HealthApp(),
    BMICalculatorPage(),
    ArticlePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 253, 253, 253),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'เพิ่มข้อมูล',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'BMI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'บทความ',
          ),
        ],
      ),
    );
  }
}
