import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:heartcare_plus/models/profiles_model.dart';
import 'package:intl/intl.dart';

class AddProfile extends StatefulWidget {
  const AddProfile({super.key});

  @override
  State<AddProfile> createState() => _AddProfileState();
}

class _AddProfileState extends State<AddProfile> {
  final formKey = GlobalKey<FormState>();
  Profiles profiles = Profiles(
      name: '', lastname: '', email: '', phone: 0, birthday: DateTime.now());
  final TextEditingController _birthdayController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('th', 'TH'), // ภาษาไทย
        Locale('en', 'US'), // ภาษาอังกฤษ
      ],
      home: Scaffold(
        appBar: AppBar(
          title: const Text('กรอกข้อมูลส่วนตัว'),
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.black,
          ),
          backgroundColor: Colors.redAccent,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ชื่อ
                    TextFormField(
                      onSaved: (String? name) {
                        profiles.name = name ?? '';
                      },
                      validator:
                          RequiredValidator(errorText: "กรุณากรอกชื่อ").call,
                      decoration: InputDecoration(
                        labelText: 'ชื่อ',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    //นามสกุล
                    TextFormField(
                      onSaved: (String? lastname) {
                        profiles.lastname = lastname ?? '';
                      },
                      validator:
                          RequiredValidator(errorText: "กรุณากรอกนามสกุล").call,
                      decoration: InputDecoration(
                        labelText: 'นามสกุล',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    //อีเมล์
                    TextFormField(
                      validator: MultiValidator([
                        RequiredValidator(errorText: "กรุณากรอกอีเมล"),
                        EmailValidator(
                            errorText: "รูปแบบอีเมลไม่ถูกต้อง *@gmail.com")
                      ]).call,
                      onSaved: (String? email) {
                        profiles.email = email ?? '';
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'อีเมล',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      onSaved: (String? value) {
                        profiles.phone = int.tryParse(value ?? '0') ?? 0;
                      },
                      validator:
                          RequiredValidator(errorText: "กรุณากรอกเบอร์ติดต่อ")
                              .call,
                      decoration: InputDecoration(
                        labelText: 'เบอร์ติดต่อ',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.call),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _birthdayController,
                      validator: RequiredValidator(
                              errorText: "กรุณาเลือกวัน/เดือน/ปีเกิด")
                          .call,
                      decoration: InputDecoration(
                        labelText: 'วัน/เดือน/ปีเกิด',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          locale: const Locale('th', 'TH'),
                        );
                        if (picked != null) {
                          setState(() {
                            _birthdayController.text =
                                DateFormat('dd/MM/yyyy').format(picked);
                            profiles.birthday = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // ปุ่มบันทึก
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          "บันทึกข้อมูล",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("บันทึกเรียบร้อย: ")),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
