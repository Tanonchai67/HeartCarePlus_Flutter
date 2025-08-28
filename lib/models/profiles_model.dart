import 'dart:io';

class Profiles {
  String name;
  String lastname;
  String nickname;
  String condisease;
  String allergic;
  String email;
  String phone;
  DateTime birthday;
  String gender;
  File? imageFile;

  Profiles({
    required this.name,
    required this.lastname,
    required this.nickname,
    required this.condisease,
    required this.allergic,
    required this.email,
    required this.phone,
    required this.birthday,
    required this.gender,
    this.imageFile,
  });
}
