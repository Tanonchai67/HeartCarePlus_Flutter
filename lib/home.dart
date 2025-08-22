import 'package:flutter/material.dart';
import 'package:heartcare_plus/pages/ArticlePage/ArticlePage.dart';
import 'package:heartcare_plus/pages/BMI/bmi.dart';
import 'package:heartcare_plus/insert.dart';
import 'package:heartcare_plus/pages/setting/setting.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:auto_size_text/auto_size_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('th', null).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointmentDate = DateTime(2025, 5, 15, 15, 30);

    final List<Widget> pages = [
      SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/Doctor.png'),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: AutoSizeText(
                    'สวัสดี นายสมชาย เมืองไทย',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    minFontSize: 12,
                    maxFontSize: 24,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const SizedBox(height: 20),

            Center(
              child: Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'นัดหมายล่าสุด HeartCarePlus',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'วันที่ ${DateFormat('dd MMMM พ.ศ. y', 'th').format(appointmentDate)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'ปฏิทิน',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // ปฏิทิน
            TableCalendar(
              locale: 'th_TH',
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
            // ปฏิทิน

            const Text(
              'ประวัติการรักษา',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 300, // ปรับขนาดตามต้องการ
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMedicalRecordItem('แพทย์ผู้รักษา',
                            '10 พฤษภาคม 2568, 7:30น. โรงพยาบาลนครพิงค์'),
                        const Divider(),
                        _buildMedicalRecordItem(
                            'อัตราการเต้นของหัวใจล่าสุด', '75 BPM'),
                        const Divider(),
                        _buildMedicalRecordItem(
                            'ค่าความดันเลือดล่าสุด', 'SYS 120 / DIA 80'),
                        const Divider(),
                        _buildMedicalRecordItem('BMI', 'ไม่มีข้อมูล'),
                        // เพิ่มได้เรื่อย ๆ
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const Center(child: Text('ประวัติการวิเคราะห์')),
      const Center(child: Text('ข้อมูลส่วนตัว')),
    ];

    var column = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 253, 253, 253),
          selectedItemColor: Colors.red,
          unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HealthApp()),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BMICalculatorPage()),
                );
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ArticlePage()),
                );
                break;
            }
          },
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
      ],
    );
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('ข้อมูลผู้ป่วย'),
        backgroundColor: Colors.red[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'ตั้งค่า',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: column,
    );
  }

  Widget _buildMedicalRecordItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
