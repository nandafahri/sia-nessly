import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sia_nessly/pages/home_page.dart';
import 'dart:async';
import 'login_page.dart';

class SplashscreenPage extends StatefulWidget {
  final bool isLoggedIn;

  const SplashscreenPage({super.key, required this.isLoggedIn});

  @override
  State<SplashscreenPage> createState() => _SplashscreenPageState();
}

class _SplashscreenPageState extends State<SplashscreenPage> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      if (widget.isLoggedIn) {
        Get.off(() => HomePage());
      } else {
        Get.off(() => LoginPage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize
              .min, // Agar Column hanya memakan ruang secukupnya dan tetap di tengah
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO
            Image.asset(
              'assets/logo_sma.png',
              width: 150,
            ),

            const SizedBox(height: 25), // Jarak antara logo dan teks

            // TEKS LANGSUNG DI BAWAH LOGO
            const Text(
              "SMA NEGERI 1 SLIYEG",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Text(
              "portal nessly",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
