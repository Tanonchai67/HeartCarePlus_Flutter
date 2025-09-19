import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heartcare_plus/login/home_login.dart';
import 'package:heartcare_plus/models/profiles_model.dart';
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
  DateTime? _selectedDay;
  final DateTime _focusedDay = DateTime.now();
  final Map<DateTime, List<String>> _events = {};
  Profiles profiles = Profiles(
    name: '',
    lastname: '',
    nickname: '',
    condisease: '',
    allergic: '',
    email: '',
    phone: '',
    birthday: DateTime.now(),
    gender: 'ชาย',
    imageUrl: '',
  );

  //ใช้สำหรับดึงข้อมูล User
  Stream<Profiles?> streamProfiles() {
    User? user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection("profiles")
        .doc(user!.uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return Profiles.fromMap(doc.data() as Map<String, dynamic>);
    });
  }

  //ใช้สำหรับดึงข้อมูลประวัติการรักษาล่าสุด
  Stream<Map<String, dynamic>?> streamLatestTreatment() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('treatments')
        .doc(user.uid)
        .collection('my_treatments')
        .orderBy('timestamp', descending: false)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return {
        'detail': doc['detail'] ?? 'ไม่มีข้อมูล',
        'date': doc['date'] ?? Timestamp.now(),
      };
    });
  }

  //ใช้สำหรับดึงข้อมูลนัดหมายที่กำลังจะถึง
  Stream<Map<String, dynamic>?> streamUpcomingAppointment() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    final now = Timestamp.now();

    return FirebaseFirestore.instance
        .collection('appointments')
        .doc(user.uid)
        .collection('my_appointments')
        .where('date', isGreaterThanOrEqualTo: now) // เลือกวันที่อนาคต
        .orderBy('date', descending: false) // เรียงจากนัดหมายที่เร็วที่สุด
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      return {
        'date': doc['date'] ?? Timestamp.now(),
        'time': doc['time'] ?? 'ไม่มีข้อมูล',
        'location': doc['location'] ?? 'ไม่มีข้อมูล',
        'detail': doc['detail'] ?? 'ไม่มีข้อมูล',
      };
    });
  }

  //ใช้สำหรับดึงข้อมูลสุขภาพ
  Stream<Map<String, dynamic>?> streamPersure() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(null);

    return FirebaseFirestore.instance
        .collection('persures')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      return {
        'heartRate': data['heartRate'] ?? 0,
        'sys': data['sys'] ?? 0,
        'dia': data['dia'] ?? 0,
        'spo2': data['spo2'] ?? 0,
        'bmi': data['bmi'] ?? 0.0,
        'bmidetail': data['bmidetail'] ?? 'ไม่มีข้อมูล',
        'bmitime': data['bmitime'] ?? Timestamp.now(),
      };
    });
  }

  //ใช้สำหรับโหลดข้อมูลปฎิทิน
  void _loadEvents(List<Map<String, dynamic>> appointments) {
    _events.clear(); // เคลียร์ก่อนทุกครั้ง
    for (var appt in appointments) {
      Timestamp ts = appt['date'];
      DateTime day =
          DateTime(ts.toDate().year, ts.toDate().month, ts.toDate().day);
      if (_events.containsKey(day)) {
        _events[day]!.add(appt['detail']);
      } else {
        _events[day] = [appt['detail']];
      }
    }
  }

  //ใช้สำหรับดึงข้อมูลนัดหมายทั้งหมด เพื่อโชว์ในปฎิทิน
  Stream<List<Map<String, dynamic>>> streamAppointmentsEvent() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('appointments')
        .doc(user.uid)
        .collection('my_appointments')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'date': doc['date'] ?? Timestamp.now(),
          'time': doc['time'] ?? 'ไม่มีข้อมูล',
          'location': doc['location'] ?? 'ไม่มีข้อมูล',
          'detail': doc['detail'] ?? 'ไม่มีข้อมูล',
        };
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('th', null).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Profiles?>(
      stream: streamProfiles(),
      builder: (context, snapshotprofiles) {
        if (snapshotprofiles.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshotprofiles.hasData || snapshotprofiles.data == null) {
          return Padding(
            padding: const EdgeInsets.only(top: 300),
            child: Scaffold(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(
                      child: Text(
                    "ไม่พบข้อมูล",
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                  )),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text("ออกจากระบบ",
                        style: TextStyle(color: Colors.red)),
                    onPressed: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      );
                      await Future.delayed(const Duration(seconds: 2));
                      Navigator.pop(context);
                      await FirebaseAuth.instance.signOut().then((value) async {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeLogin()),
                          (route) => false,
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        Profiles profiles = snapshotprofiles.data!;

        return StreamBuilder(
            stream: streamLatestTreatment(),
            builder: (context, snapshottreatment) {
              if (snapshottreatment.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // ถ้าไม่มีข้อมูล ให้ใช้ค่า default
              final treatment =
                  (snapshottreatment.hasData && snapshottreatment.data != null)
                      ? snapshottreatment.data!
                      : {
                          'detail': 'ไม่มีข้อมูล',
                          'date': Timestamp.now(),
                        };

              // รายละเอียดการรักษา
              final treatmentDetail = "${treatment['detail'] ?? 'ไม่มีข้อมูล'}";

              // วันที่
              Timestamp timestampTM = treatment['date'] ?? Timestamp.now();
              DateTime dateTM = timestampTM.toDate();
              int yearTM = dateTM.year + 543;
              String treatmentDate =
                  DateFormat('dd MMMM $yearTM', 'th').format(dateTM);

              return StreamBuilder(
                  stream: streamUpcomingAppointment(),
                  builder: (context, snapshotappointment) {
                    if (snapshotappointment.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // ถ้าไม่มีข้อมูล ให้ใช้ค่า default
                    final appointment = (snapshotappointment.hasData &&
                            snapshotappointment.data != null)
                        ? snapshotappointment.data!
                        : {
                            'date': Timestamp.now(),
                            'time': 'ไม่มีข้อมูล',
                            'location': 'ไม่มีข้อมูล',
                            'detail': 'ไม่มีข้อมูล',
                          };

                    // แปลงวันอย่างปลอดภัย
                    Timestamp timestampAPM =
                        appointment['date'] ?? Timestamp.now();
                    DateTime dateAPM = timestampAPM.toDate();
                    int yearAPM = dateAPM.year + 543;
                    String appointmentDate =
                        DateFormat('dd MMMM $yearAPM', 'th').format(dateAPM);

                    // เวลา, สถานที่, รายละเอียด
                    String appointmentTime =
                        "${appointment['time'] ?? 'ไม่มีข้อมูล'}";
                    String appointmentLocation =
                        "${appointment['location'] ?? 'ไม่มีข้อมูล'}";
                    String appointmentDetail =
                        "${appointment['detail'] ?? 'ไม่มีข้อมูล'}";

                    return StreamBuilder(
                        stream: streamPersure(),
                        builder: (context, snapshotpersure) {
                          if (snapshotpersure.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          // ถ้าไม่มีข้อมูล ให้ใช้ค่า default
                          final persure = (snapshotpersure.hasData &&
                                  snapshotpersure.data != null)
                              ? snapshotpersure.data!
                              : {
                                  'heartRate': 0,
                                  'sys': 0,
                                  'dia': 0,
                                  'spo2': 0,
                                  'bmi': 0.0,
                                  'bmidetail': 'ไม่มีข้อมูล',
                                  'bmitime': Timestamp.now(),
                                };

                          // แปลงค่า heartRate, sys, dia, spo2 ให้เป็น int อย่างปลอดภัย
                          int parseInt(dynamic value) {
                            if (value == null) return 0;
                            if (value is int) return value;
                            if (value is double) return value.toInt();
                            return int.tryParse(value.toString()) ?? 0;
                          }

                          final int persureHr = parseInt(persure['heartRate']);
                          final int persureSys = parseInt(persure['sys']);
                          final int persureDia = parseInt(persure['dia']);
                          final int persureSpo2 = parseInt(persure['spo2']);

                          // แปลง BMI เป็น double ปลอดภัย
                          double parseDouble(dynamic value) {
                            if (value == null) return 0.0;
                            if (value is double) return value;
                            if (value is int) return value.toDouble();
                            return double.tryParse(value.toString()) ?? 0.0;
                          }

                          final double bmiValue = parseDouble(persure['bmi']);
                          final String persuresBmi =
                              bmiValue.toStringAsFixed(1);
                          final String persuresBmiDetail =
                              "${persure['bmidetail']}";

                          // แปลงวัน
                          Timestamp timestampBMI =
                              persure['bmitime'] ?? Timestamp.now();
                          DateTime dateBMI = timestampBMI.toDate();
                          int yearBMI = dateBMI.year + 543;
                          String persuresBmiTime =
                              DateFormat('dd MMMM $yearBMI', 'th')
                                  .format(dateBMI);

                          return StreamBuilder(
                              stream: streamAppointmentsEvent(),
                              builder: (context, snapshotappointmentEvent) {
                                if (snapshotappointmentEvent.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                final appointmentsEvent =
                                    snapshotappointmentEvent.data ?? [];
                                _loadEvents(
                                    appointmentsEvent); // อัพเดทอีเว้นท์ทุกครั้ง

                                return SingleChildScrollView(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 25,
                                      ),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 45,
                                            backgroundImage: (profiles
                                                            .imageUrl !=
                                                        null &&
                                                    profiles
                                                        .imageUrl!.isNotEmpty)
                                                ? NetworkImage(profiles
                                                    .imageUrl!) // โหลดรูปจาก Firestore
                                                : null, // ถ้าไม่มีรูป
                                            child: (profiles.imageUrl == null ||
                                                    profiles.imageUrl!.isEmpty)
                                                ? const Icon(Icons.person,
                                                    size: 50) // แสดงไอคอนแทน
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: AutoSizeText(
                                              'ยินดีต้อนรับ \nคุณ ${profiles.nickname} ${profiles.name}',
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
                                                      builder: (context) =>
                                                          const SettingsPage()),
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
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          shadowColor:
                                              // ignore: deprecated_member_use
                                              Colors.grey.withOpacity(0.6),
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                AutoSizeText(
                                                  'นัดหมายที่กำลังจะถึง',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                  maxLines: 1,
                                                  minFontSize: 18,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.access_time,
                                                        color: Colors.orange,
                                                        size: 22),
                                                    const SizedBox(width: 6),
                                                    AutoSizeText(
                                                      "$appointmentTime || วันที่ $appointmentDate",
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      maxLines: 1,
                                                      minFontSize: 16,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.location_on,
                                                        color: Colors.redAccent,
                                                        size: 22),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: AutoSizeText(
                                                        appointmentLocation,
                                                        style: const TextStyle(
                                                            fontSize: 18),
                                                        maxLines: 2,
                                                        minFontSize: 16,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                AutoSizeText(
                                                  appointmentDetail,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.grey,
                                                  ),
                                                  maxLines: 3,
                                                  minFontSize: 16,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 25),
                                      const Text(
                                        'ปฏิทิน',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Text(
                                        '* จุดแดง คือวันที่นัดหมาย',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.red),
                                      ),
                                      SizedBox(
                                        height: 350,
                                        width: 400,
                                        child: TableCalendar(
                                          locale: 'th_TH',
                                          firstDay: DateTime.utc(2000, 1, 1),
                                          lastDay: DateTime.utc(2100, 12, 31),
                                          focusedDay: _focusedDay,
                                          selectedDayPredicate: (day) =>
                                              isSameDay(_selectedDay, day),
                                          eventLoader: (day) {
                                            final d = DateTime(
                                                day.year, day.month, day.day);
                                            return _events[d] ?? [];
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
                                            markerDecoration: BoxDecoration(
                                              color: Colors.redAccent,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          daysOfWeekStyle:
                                              const DaysOfWeekStyle(
                                            weekdayStyle:
                                                TextStyle(fontSize: 16),
                                            weekendStyle:
                                                TextStyle(fontSize: 16),
                                          ),
                                          headerStyle: HeaderStyle(
                                            titleCentered: true,
                                            formatButtonVisible: false,
                                            titleTextFormatter: (date, locale) {
                                              int buddhistYear =
                                                  date.year + 543;
                                              String monthName =
                                                  DateFormat.MMMM('th')
                                                      .format(date);
                                              return '$monthName $buddhistYear';
                                            },
                                            titleTextStyle: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),

                                      //
                                      const Text(
                                        'ข้อมูลสุขภาพล่าสุด',
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
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  _dataOther('ประวัติการรักษา',
                                                      "วันที่ $treatmentDate\n$treatmentDetail"),
                                                  const Divider(),
                                                  _dataOther(
                                                      'อัตราการเต้นของหัวใจล่าสุด',
                                                      '$persureHr ครั้ง/นาที'),
                                                  const Divider(),
                                                  _dataOther(
                                                      'ค่าความดันเลือดล่าสุด',
                                                      'SYS $persureSys mmHg || DIA $persureDia mmHg'),
                                                  const Divider(),
                                                  _dataOther(
                                                      'SpO₂ (ความอิ่มตัวของออกซิเจนในเลือด)',
                                                      '$persureSpo2 %'),
                                                  const Divider(),
                                                  _dataOther(
                                                      'BMI (ค่าดัชนีมวลกาย)',
                                                      '$persuresBmi kg/m² || $persuresBmiDetail\nข้อมูลล่าสุด $persuresBmiTime'),
                                                  // เพิ่มได้เรื่อย ๆ
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
                        });
                  });
            });
      },
    );
  }

  Widget _dataOther(String title, String value, {IconData? icon}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      // ignore: deprecated_member_use
      shadowColor: Colors.grey.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.teal[400], size: 28),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                    maxLines: 1,
                    minFontSize: 16,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  AutoSizeText(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    minFontSize: 14,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
