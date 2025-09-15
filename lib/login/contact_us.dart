import 'package:flutter/material.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // รูป Avatar/โลโก้
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[50],
              child: const Icon(
                Icons.support_agent,
                size: 100,
                color: Colors.teal,
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "ทีมพัฒนา HeartCarePlus",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "เราพร้อมช่วยเหลือคุณเสมอ",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),

            const SizedBox(height: 40),

            // การ์ดติดต่อ
            _buildContactTile(
              icon: Icons.email_outlined,
              title: "65143322@g.cmru.ac.th",
              subtitle: "ผู้พัฒนาโครงการ",
              color: Colors.teal,
            ),
            const SizedBox(height: 20),
            _buildContactTile(
              icon: Icons.email_outlined,
              title: "65143398@g.cmru.ac.th",
              subtitle: "ผู้พัฒนาโครงการ",
              color: Colors.teal,
            ),
            const SizedBox(height: 20),

            const Spacer(),

            // Footer
            Text(
              "© ${DateTime.now().year} HeartCarePlus",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
