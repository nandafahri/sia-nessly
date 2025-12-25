import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sia_nessly/controllers/profile_controller.dart';
import 'package:sia_nessly/pages/auth_verification_page.dart';
import 'package:sia_nessly/pages/change_email_page.dart';
import 'package:sia_nessly/pages/change_password_page.dart';
import 'package:sia_nessly/pages/detail_profile_page.dart';
import 'package:sia_nessly/pages/login_page.dart';
import 'notification_page.dart';
import 'update_info_page.dart';
import 'about_app_page.dart';
import '../controllers/change_email_controller.dart';

// Colors
const Color kPrimaryColor = Color(0xFF42A5F5);
const Color kBackgroundColor = Colors.black;
const Color kCardColor = Color(0xFF161616);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

final ProfileController homeC = Get.put<ProfileController>(ProfileController());

class _ProfilePageState extends State<ProfilePage> {
  String nama = "Memuat...";
  String kelas = "Memuat...";
  String foto = "";
  final ChangeEmailController emailController =
      Get.put(ChangeEmailController());
  var tingkat = "".obs; // ✅ TAMBAHKAN

  @override
  void initState() {
    super.initState();
    _loadDataUser();
  }

  Future<void> _loadDataUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nama = prefs.getString("nama") ?? "Pengguna Aplikasi";
      kelas = prefs.getString("nama_kelas") ?? "-";
      foto = prefs.getString("foto") ?? "";
      tingkat.value = prefs.getString("tingkat") ?? "-"; // ✅ AMBIL

      emailController.currentEmail.value = prefs.getString("email") ?? "";
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        title: const Text("Konfirmasi Keluar",
            style: TextStyle(color: Colors.white)),
        content: const Text(
          "Apakah Anda yakin ingin keluar?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal", style: TextStyle(color: kPrimaryColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text("Keluar", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("Akun Saya",
            style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: kBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildSectionTitle("Pengaturan Akun"),
            _buildTile(Icons.email_outlined, "Ganti Email", ChangeEmailPage()),
            _buildTile(
                Icons.lock_outline, "Ganti Password", ChangePasswordPage()),
            _buildTile(Icons.verified_user_outlined, "Autentikasi Akun",
                AuthVerificationPage()),
            const SizedBox(height: 32),
            _buildSectionTitle("Informasi & Aplikasi"),
            _buildTile(
                Icons.notifications_none, "Notifikasi", NotificationPage()),
            _buildTile(Icons.update_outlined, "Pembaruan Aplikasi",
                const UpdateInfoPage()),
            _buildTile(
                Icons.info_outline, "Tentang Aplikasi", const AboutAppPage()),
            const SizedBox(height: 40),
            _buildLogoutTile(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailProfilePage()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: (homeC.foto.value.isNotEmpty &&
                      homeC.foto.value.startsWith("http"))
                  ? NetworkImage(homeC.foto.value)
                  : const AssetImage("assets/default_profile.png")
                      as ImageProvider,
            ),

            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Kelas $tingkat $kelas",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54), // Putih
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, Widget page) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
          color: kCardColor, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.white), // Icon utama putih
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.chevron_right,
            color: Colors.white54), // Panah putih
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }

  Widget _buildLogoutTile() {
    return Container(
      decoration: BoxDecoration(
          color: kCardColor, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.logout,
            color: Colors.redAccent), // Tetap merah agar menonjol
        title: const Text(
          "Keluar Akun",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right,
            color: Colors.white54), // Panah putih
        onTap: _logout,
      ),
    );
  }
}
