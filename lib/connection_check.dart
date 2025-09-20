import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:heartcare_plus/main.dart';
import 'package:heartcare_plus/no_connection_Screen.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectionCheck extends StatefulWidget {
  const ConnectionCheck({super.key});

  @override
  State<ConnectionCheck> createState() => _ConnectionCheckState();
}

class _ConnectionCheckState extends State<ConnectionCheck> {
  bool _isConnected = false;
  bool _isCheckingConnection = true;

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late StreamSubscription<InternetConnectionStatus> _internetSubscription;

  @override
  void initState() {
    super.initState();
    _initConnectivity();

    // ฟังการเปลี่ยนแปลงจาก Connectivity (wifi, mobile, none)
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      // เช็คว่ามี wifi หรือ mobile ไหม
      bool hasNetwork = results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi);

      // ถ้ามี network → ตรวจสอบว่าออกอินเทอร์เน็ตได้จริง
      bool hasInternet = false;
      if (hasNetwork) {
        hasInternet = await InternetConnectionChecker().hasConnection;
      }

      _updateConnectionStatus(hasInternet);
    });

    // ฟังสถานะ internet จริงๆ (ping ออกได้หรือไม่)
    _internetSubscription =
        InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      _updateConnectionStatus(hasInternet);
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _internetSubscription.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    setState(() {
      _isCheckingConnection = true;
    });

    bool hasInternet;
    try {
      hasInternet = await InternetConnectionChecker().hasConnection;
    } catch (e) {
      debugPrint("Couldn't check internet status: $e");
      hasInternet = false;
    }

    _updateConnectionStatus(hasInternet);
  }

  void _updateConnectionStatus(bool hasInternet) {
    setState(() {
      _isConnected = hasInternet;
      _isCheckingConnection = false;
    });
  }

  void _retryConnection() {
    _initConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (BuildContext context) {
          if (_isCheckingConnection) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return _isConnected
                ? const MyApp()
                : NoConnectionScreen(onRetry: _retryConnection);
          }
        },
      ),
    );
  }
}
