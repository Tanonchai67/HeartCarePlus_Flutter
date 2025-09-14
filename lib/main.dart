import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:heartcare_plus/login/authcheck.dart';

import 'pages/insertpage/medicine/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: const SafeArea(
          child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: AuthCheck(),
        ),
      )),
    );
  }
}
