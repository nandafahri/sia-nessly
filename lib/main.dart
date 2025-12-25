import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sia_nessly/pages/splashscreen_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Portal Siswa Nessly',
      debugShowCheckedModeBanner: false,
      home: const SplashscreenPage(),
    );
  }
}
