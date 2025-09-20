import 'package:flutter/material.dart';
import 'package:heartcare_plus/pages/insertpage/appointment/appoint_his.dart';
import 'package:heartcare_plus/pages/insertpage/history/treatment_history_page.dart';
import 'package:heartcare_plus/pages/insertpage/medicine/medicine_list.dart';
import 'package:heartcare_plus/pages/insertpage/persures/persures.dart';

class HealthApp extends StatelessWidget {
  const HealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HealthRecordPage(),
      theme: ThemeData(
        primaryColor: Colors.redAccent,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      routes: {
        '/appointhiss': (context) => const AppointHis(),
        '/history': (context) => const TreatmentHistoryPage(),
        '/medicine': (context) => const MedicineList(),
        '/pressure': (context) => const Persures(),
      },
    );
  }
}

class HealthRecordPage extends StatelessWidget {
  const HealthRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'บันทึกข้อมูลสุขภาพ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 6,
        shadowColor: Colors.black38,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMenuCard(
              context,
              icon: Icons.medical_services,
              iconColor: Colors.blueAccent,
              title: 'ประวัติการรักษา',
              subtitle: 'บันทึกและดูประวัติการรักษาทั้งหมด',
              routeName: '/history',
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              icon: Icons.calendar_today,
              iconColor: Colors.orangeAccent,
              title: 'การนัดหมาย',
              subtitle: 'ดูและบันทึกการนัดหมายกับแพทย์',
              routeName: '/appointhiss',
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              icon: Icons.medication,
              iconColor: Colors.green,
              title: 'การทานยา',
              subtitle: 'ดูและบันทึกเวลารับประทานยา',
              routeName: '/medicine',
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              icon: Icons.monitor_heart,
              iconColor: Colors.redAccent,
              title: 'ความดันและหัวใจ',
              subtitle: 'บันทึกค่าความดันและอัตราการเต้นหัวใจ',
              routeName: '/pressure',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String routeName,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    // ignore: deprecated_member_use
                    colors: [iconColor.withOpacity(0.6), iconColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
