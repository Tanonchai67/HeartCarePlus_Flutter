import 'package:flutter/material.dart';

class Appointments {
  DateTime dateaddAPM;
  String locationAPM;
  TimeOfDay timeAPM;
  String detailAPM;

  Appointments({
    required this.dateaddAPM,
    required this.detailAPM,
    required this.locationAPM,
    required this.timeAPM,
  });
}
