import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 62, // Sedikit lebih tinggi agar nyaman
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            // BACK BUTTON
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white24,
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // TITLE
            const Text(
              "Tentang Aplikasi",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Sistem Akademik SMA N 1 Sliyeg",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            SizedBox(height: 10),
            Text(
              "Aplikasi ini dibuat untuk mempermudah siswa dan guru dalam memantau absensi, nilai, jadwal, serta informasi sekolah lainnya secara online dan terintegrasi.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 30),
            Text("Versi Aplikasi: 1.0.0",
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            Text("Developer: Tim IT SMA N 1 Sliyeg",
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
