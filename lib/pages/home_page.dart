import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sia_nessly/pages/absensi_page.dart';
import 'package:sia_nessly/pages/calendar_page.dart';
import 'package:sia_nessly/pages/info_page.dart';
import 'package:sia_nessly/pages/jadwal_page.dart';
import 'package:sia_nessly/pages/nilai_page.dart';
import 'package:sia_nessly/pages/notification_page.dart';
import 'package:sia_nessly/pages/profile_page.dart';
import 'package:sia_nessly/pages/scan_page.dart';
import '../controllers/home_controller.dart';

// Warna utama
const Color kPrimaryColor = Color(0xFF42A5F5);
const Color kBackgroundColor = Colors.black;
const Color kCardColor = Color(0xFF161616);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeC = Get.put(HomeController());

    final pages = [
      _homeContent(homeC),
      CalendarPage(),
      ScanPage(),
      NotificationPage(showBack: false),
      ProfilePage(),
    ];

    return Obx(() => Scaffold(
          backgroundColor: kBackgroundColor,
          body: IndexedStack(
            index: homeC.currentIndex.value,
            children: pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: kCardColor,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: kPrimaryColor,
            unselectedItemColor: Colors.white54,
            currentIndex: homeC.currentIndex.value,
            onTap: (i) => homeC.currentIndex.value = i,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month), label: "Kalender"),
              BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "Scan"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.notifications), label: "Notifikasi"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.people), label: "Profile"),
            ],
          ),
        ));
  }

  // ============================================
  // HOME CONTENT
  // ============================================
  Widget _homeContent(HomeController homeC) {
    return SafeArea(
      child: Obx(() => ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: homeC.foto.value.isNotEmpty
                        ? NetworkImage(homeC.foto.value)
                        : const AssetImage("assets/default_profile.png")
                            as ImageProvider,
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hallo, ${homeC.nama.value}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Kelas - ${homeC.namaKelas.value}",
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // CARD PESAN HARI INI
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kCardColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    homeC.isLoadingPesan.value
                        ? const Text("Memuat pesan...",
                            style: TextStyle(color: Colors.white70))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(homeC.judulPesan.value,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(homeC.isiPesan.value,
                                  style:
                                      const TextStyle(color: Colors.white70)),
                            ],
                          ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(Icons.auto_stories,
                          color: Colors.white70, size: 30),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text("Akses Cepat",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.9, // Agar lebih lega untuk gambar + teks
                children: [
                  _menuIcon("Nilai", "assets/raport.png", NilaiPage()),
                  _menuIcon("Jadwal", "assets/jadwal.png",
                      JadwalPage(showBackButton: true)),
                  _menuIcon("Absensi", "assets/absen.png",
                      AbsensiPage(nisn: homeC.nisn.value)),
                  _menuIcon("Info", "assets/info.png", InfoDetailPage()),
                ],
              ),

              const SizedBox(height: 24),

              const Text("Visi & Misi Sekolah",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: kCardColor, borderRadius: BorderRadius.circular(12)),
                child: const Text(
                  "Terwujudnya Peserta Didik yang Santun, Aktif, Terampil, "
                  "Religius, Inovatif dan Antusias dalam meningkatkan budaya mutu sekolah.",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          )),
    );
  }

  // ============================================
  // MENU ICON DENGAN GAMBAR ASSET
  // ============================================
  Widget _menuIcon(String label, String assetPath, Widget page) {
    return GestureDetector(
      onTap: () => Get.to(() => page),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white10),
            ),
            child: Image.asset(
              assetPath,
              width: 36,
              height: 36,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
