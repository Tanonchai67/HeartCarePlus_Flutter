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
  String? imageUrl;

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
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lastname': lastname,
      'nickname': nickname,
      'condisease': condisease,
      'allergic': allergic,
      'email': email,
      'phone': phone,
      'birthday': birthday.toIso8601String(),
      'gender': gender,
      'imageUrl': imageUrl,
    };
  }

  factory Profiles.fromMap(Map<String, dynamic> map) {
    return Profiles(
      name: map['name'] ?? '',
      lastname: map['lastname'] ?? '',
      nickname: map['nickname'] ?? '',
      condisease: map['condisease'] ?? '',
      allergic: map['allergic'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      birthday: DateTime.tryParse(map['birthday'] ?? '') ?? DateTime.now(),
      gender: map['gender'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
