import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/jadwal_controller.dart';
import '../models/jadwal_model.dart';

const Color kPrimaryColor = Color(0xFF42A5F5);
const Color kBackgroundColor = Colors.black; // FULL HITAM
const Color kCardColor =
    Color(0xFF161616); // warna card sedikit lebih terang agar kontras

class JadwalPage extends StatelessWidget {
  final bool showBackButton;

  JadwalPage({super.key, this.showBackButton = true});

  final JadwalController controller = Get.put(JadwalController());

  Widget _buildJadwalItem(JadwalModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hari & Jam
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.hari,
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 18, color: Colors.white70),
                  const SizedBox(width: 6),
                  Text(
                    "${item.jamMulai} - ${item.jamSelesai}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Mapel
          Text(
            item.namaMapel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          if (item.qrActive == true) ...[
            Row(
              children: const [
                Icon(Icons.qr_code, color: Colors.greenAccent, size: 20),
                SizedBox(width: 6),
                Text(
                  "QR Aktif",
                  style: TextStyle(color: Colors.greenAccent, fontSize: 14),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
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
              "Jadwal",
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
        child: Obx(() {
          if (controller.kelasId.value.isEmpty) {
            return const Center(
              child: Text(
                "ID Kelas tidak ditemukan.",
                style: TextStyle(color: Colors.redAccent),
              ),
            );
          }

          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }

          if (controller.jadwalList.isEmpty) {
            return const Center(
              child: Text(
                "Tidak ada jadwal ditemukan.",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            itemCount: controller.jadwalList.length,
            itemBuilder: (context, index) {
              return _buildJadwalItem(controller.jadwalList[index]);
            },
          );
        }),
      ),
    );
  }
}
