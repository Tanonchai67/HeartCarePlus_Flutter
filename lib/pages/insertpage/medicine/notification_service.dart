import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tzData;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  // เริ่มต้น Notification Service
  static Future<void> init() async {
    // เริ่ม timezone
    tzData.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);

    await _notifications.initialize(initSettings);

    // ขอ permission สำหรับ Android 13+ (POST_NOTIFICATIONS)
    if (Platform.isAndroid) {
      if (await Permission.notification.isDenied) {
        final result = await Permission.notification.request();
        if (!result.isGranted) {
          print("User denied notification permission");
        }
      }
    }
  }

  // ตั้งแจ้งเตือนตามเวลา "HH:mm"
  Future<void> scheduleMedicineNotification(
    String id,
    String name,
    String time,
  ) async {
    try {
      // ล้างค่าเวลาให้เหลือเฉพาะตัวเลขกับ :
      final cleanTime = time.trim().replaceAll(RegExp(r'[^0-9:]'), '');
      print("เวลาจาก Firestore: $time || Clean time: $cleanTime");

      final parts = cleanTime.split(':');
      if (parts.length != 2) {
        print("เวลาไม่ถูกต้อง: $time, ข้ามการตั้งแจ้งเตือน");
        return;
      }

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = tz.TZDateTime.now(tz.local);
      var scheduledTime =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

      // ถ้าเวลาที่ตั้งก่อนปัจจุบัน ให้เลื่อนไปวันถัดไป
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        id.hashCode,
        'แจ้งเตือน! $time',
        'ถึงเวลาทานยา $name',
        scheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'medicine_channel', // Channel ID
            'Medicine Reminder', // Channel Name
            channelDescription: 'แจ้งเตือนการทานยา', // Channel Description

            importance: Importance.max, // ความสำคัญสูงสุด
            priority: Priority.high, // ลำดับความสำคัญสูง

            playSound: true, // เล่นเสียง notification
            enableVibration: true, // สั่นเครื่อง
            vibrationPattern:
                Int64List.fromList([0, 500, 200, 500]), // รูปแบบสั่น

            color: Colors.blue, // สีพื้นหลังของ icon

            styleInformation: BigTextStyleInformation(
              'โปรดรับประทานยาตามเวลาที่กำหนด เพื่อสุขภาพที่ดี', // ข้อความยาว
              contentTitle:
                  'ถึงเวลาทานยาแล้ว!\n$name  $time', // หัวข้อ notification
              summaryText: 'ได้เวลารับประทานยาแล้ว', // ข้อความสรุป
            ),

            ticker: 'ถึงเวลาทานยา!', // ข้อความสั้นเวลา notification เด้ง
          ),
        ),

        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents:
            DateTimeComponents.time, // แจ้งเตือนทุกวันเวลาเดียวกัน
      );

      print("ตั้งค่าการแจ้งเตือนเรียบร้อย ชื่อยา: $name เวลา: $cleanTime น.");
    } catch (e) {
      print("Error scheduleMedicineNotification: $e");
    }
  }

  // ปิดการแจ้งเตือน
  Future<void> cancelNotification(String docId) async {
    await _notifications.cancel(docId.hashCode);
    print("ปิดการแจ้งเตือนเรียบร้อย");
  }

  /// ฟังก์ชันยกเลิกการแจ้งเตือนทั้งหมด
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print("ปิดการแจ้งเตือนทั้งหมดเรียบร้อย");
  }
}
