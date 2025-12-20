import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/home_controller.dart';
import 'pages/splashscreen_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("auth_token");

  // 🔥 DAFTARKAN HOME CONTROLLER SEKALI (GLOBAL)
  Get.put(HomeController(), permanent: true);

  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Portal Siswa Nessly',
      debugShowCheckedModeBanner: false,
      home: SplashscreenPage(isLoggedIn: isLoggedIn),
    );
  }
}
