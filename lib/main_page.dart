import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:heartcare_plus/home.dart';
import 'package:heartcare_plus/insert.dart';
import 'package:heartcare_plus/pages/BMI/bmi.dart';
import 'package:heartcare_plus/pages/gemini_ai/gemini_chat.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  final List<Widget> _pages = const [
    HomePage(),
    HealthApp(),
    BMICalculatorPage(),
    GeminiChat(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Error"),
            ),
            body: Center(
              child: Text("${snapshot.error}"),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          // กำลังโหลด
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Scaffold(
            body: _pages[_selectedIndex],
            bottomNavigationBar: Container(
              color: Colors.grey,
              child: SafeArea(
                child: BottomNavigationBar(
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
                      icon: Icon(Icons.chat),
                      label: 'Gemini',
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }
}
