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

const Color kPrimaryColor = Color(0xFF42A5F5);
const Color kBackgroundColor = Colors.black;
const Color kCardColor = Color(0xFF161616);

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeController homeC = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    /// 🔥 INI PALING PENTING
    /// Paksa refresh status setiap Home ditampilkan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeC.refreshStatus();
    });

    final pages = [
      () => _homeContent(),
      () => CalendarPage(),
      () => ScanPage(),
      () => NotificationPage(showBack: false),
      () => ProfilePage(),
    ];

    return Obx(() => Scaffold(
          backgroundColor: kBackgroundColor,
          body: IndexedStack(
            index: homeC.currentIndex.value,
            children: pages.map((e) => e()).toList(),
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: kCardColor,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: kPrimaryColor,
            unselectedItemColor: Colors.white54,
            currentIndex: homeC.currentIndex.value,
            onTap: homeC.changeIndex,
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

  // =====================================================
  // HOME CONTENT
  // =====================================================
  Widget _homeContent() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        children: [
          // ================= HEADER =================
          Obx(() => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: homeC.foto.value.isNotEmpty
                        ? NetworkImage(homeC.foto.value)
                        : const AssetImage("assets/default_profile.png")
                            as ImageProvider,
                  ),
                  const SizedBox(width: 15),

                  /// NAMA & KELAS
                  Expanded(
                    child: Column(
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
                  ),

                  /// ===== STATUS BADGE (FIX FINAL) =====
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Obx(() {
                        if (homeC.absensiLengkap.value) {
                          return const SizedBox();
                        }

                        return _statusBadge(
                          text:
                              "${homeC.totalAbsenHariIni}/${homeC.totalMapelHariIni} Belum Absen",
                        );
                      }),

                      /// 🟠 NILAI RENDAH
                      Obx(() {
                        if (!homeC.nilaiRendah.value) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: _statusBadge(text: "Nilai Rendah"),
                        );
                      }),
                    ],
                  ),
                ],
              )),

          const SizedBox(height: 24),

          // ================= PESAN HARIAN =================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kCardColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      homeC.judulPesan.value.isEmpty
                          ? "Pesan Hari Ini"
                          : homeC.judulPesan.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      homeC.isiPesan.value.isEmpty
                          ? "Belum ada pesan hari ini"
                          : homeC.isiPesan.value,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                )),
          ),

          const SizedBox(height: 24),

          // ================= AKSES CEPAT =================
          const Text(
            "Akses Cepat",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.9,
            children: [
              _menu("Nilai", "assets/raport.png", NilaiPage()),
              _menu("Jadwal", "assets/jadwal.png",
                  JadwalPage(showBackButton: true)),
              _menu("Absensi", "assets/absen.png",
                  AbsensiPage(nisn: homeC.nisn.value)),
              _menu("Info", "assets/info.png", InfoDetailPage()),
            ],
          ),

          const SizedBox(height: 24),

          // ================= VISI & MISI =================
          const Text(
            "Visi & Misi Sekolah",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Terwujudnya Peserta Didik yang Santun, Aktif, Terampil, "
              "Religius, Inovatif dan Antusias dalam meningkatkan budaya mutu sekolah.",
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // BADGE
  // =====================================================
  Widget _statusBadge({required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // MENU ICON
  // =====================================================
  Widget _menu(String label, String asset, Widget page) {
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
            child: Image.asset(asset, width: 36),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
