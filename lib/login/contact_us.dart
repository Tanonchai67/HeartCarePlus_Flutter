import 'package:flutter/material.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ติดต่อเรา!'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          color: Colors.black,
        ),
        backgroundColor: Colors.redAccent,
        automaticallyImplyLeading: false,
      ),
      body: const Padding(
        padding: EdgeInsets.only(
          left: 25,
          top: 2,
          right: 20,
          bottom: 5,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              // Header
              Text(
                'ข้อมูลติดต่อ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.email,
                        color: Colors.redAccent,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '65143322@cmru.ac.th',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.email,
                        color: Colors.redAccent,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '65143398@cmru.ac.th',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
