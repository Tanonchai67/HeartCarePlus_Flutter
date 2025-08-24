import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:heartcare_plus/pages/setting/setting.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

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
            const SizedBox(
              height: 25,
            ),

            Row(
              children: [
                const CircleAvatar(
                  radius: 45,
                  backgroundImage: AssetImage('assets/Doctor.png'),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: AutoSizeText(
                    'ยินดีต้อนรับ \nคุณ โฟโต้',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    minFontSize: 12,
                    maxFontSize: 24,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.settings),
                    iconSize: 35,
                    tooltip: 'ตั้งค่า',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsPage()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
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
            const SizedBox(height: 25),

            const Text(
              'ปฏิทิน',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // ปฏิทิน
            SizedBox(
              height: 400,
              width: 400,
              child: TableCalendar(
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
                rowHeight: 45,
                daysOfWeekHeight: 30,
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(fontSize: 18),
                  weekendTextStyle: TextStyle(fontSize: 18),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(fontSize: 16),
                  weekendStyle: TextStyle(fontSize: 16),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const Text(
              'ข้อมูลสุขภาพ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: SizedBox(
                  // height: ,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _dataOther('แพทย์ผู้รักษา',
                            '10 พฤษภาคม 2568, 7:30น. โรงพยาบาลนครพิงค์'),
                        const Divider(),
                        _dataOther('อัตราการเต้นของหัวใจล่าสุด', '75 BPM'),
                        const Divider(),
                        _dataOther('ค่าความดันเลือดล่าสุด', 'SYS 120 / DIA 80'),
                        const Divider(),
                        _dataOther('BMI', 'ไม่มีข้อมูล'),
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
    ];

    return Scaffold(
      body: pages[_selectedIndex],
    );
  }

  Widget _dataOther(String title, String value) {
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
