import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateInfoPage extends StatelessWidget {
  const UpdateInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> changelog = [
      '✓ Penambahan halaman jadwal',
      '✓ Integrasi fitur login dengan NISN',
      '✓ Perbaikan bug input nilai',
      '✓ Penambahan fitur notifikasi sekolah',
    ];

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
              "Pembaruan",
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
          children: [
            const Text("Catatan Pembaruan",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 10),
            ...changelog.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    item,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
