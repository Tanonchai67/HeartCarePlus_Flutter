import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NoConnectionScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const NoConnectionScreen({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
              child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Lottie.asset("assets/lottie/No Internet.json",
                    fit: BoxFit.cover),
                SizedBox(height: 30),
                Text(
                  "ไม่มีการเชื่อมต่ออินเทอร์เน็ต",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  "กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ตของคุณแล้วลงใหม่อีกครั้ง",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.black87,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.transparent,
                      // ignore: deprecated_member_use
                      shadowColor: Colors.teal.withOpacity(0.5),
                      elevation: 6,
                    ).copyWith(
                      backgroundColor:
                          WidgetStateProperty.all(Colors.transparent),
                      elevation: WidgetStateProperty.all(0),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.blue,
                            Colors.lightBlue,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(minHeight: 48),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.refresh,
                                  color: Colors.white, size: 30),
                              onPressed: () {},
                            ),
                            Text(
                              "ลองอีกครั้ง",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }
}
