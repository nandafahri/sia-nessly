import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk SystemUiOverlayStyle
import 'package:get/get.dart';
// Asumsikan controller dan model ada di path ini
import '../controllers/absensi_controller.dart';
// Asumsikan model AbsensiResponse dan Riwayat di-import dari sini
// import '../models/absensi_model.dart';

class AbsensiPage extends StatelessWidget {
  final String nisn;

  // Constructor
  AbsensiPage({super.key, required this.nisn});

  // Inisialisasi Controller
  final AbsensiController controller = Get.put(AbsensiController());

  final Color kPrimaryColor = Color(0xFF42A5F5);
  final Color kBackgroundColor = Colors.black; // FULL HITAM
  final Color kCardColor =
      Color(0xFF161616); // warna card sedikit lebih terang agar kontras

  // Helper untuk mendapatkan ikon berdasarkan status
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case "hadir":
        return Icons.check_circle;
      case "izin":
        return Icons.info;
      case "alpha":
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  // Helper untuk mendapatkan warna berdasarkan status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "hadir":
        return Colors.greenAccent;
      case "izin":
        return Colors.amber;
      case "alpha":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Panggil load data setelah frame pertama selesai di-render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.isLoading.value) {
        controller.loadAbsensi(nisn);
      }
    });

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
              "Riwayat Absensi",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Error: ${controller.errorMessage.value}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            ),
          );
        }

        final data = controller.absensiResponse.value;
        // Penanganan jika data null atau riwayat kosong
        final riwayat = data?.riwayat ?? [];

        if (data == null || riwayat.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sentiment_dissatisfied,
                    color: Colors.white70, size: 50),
                const SizedBox(height: 10),
                Text(
                  data == null
                      ? "Gagal memuat data atau data kosong."
                      : "Belum ada riwayat absensi untuk NISN ini.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: riwayat.length,
          itemBuilder: (context, index) {
            final item = riwayat[index];
            final statusColor = _getStatusColor(item.status);
            final statusIcon = _getStatusIcon(item.status);

            return Card(
              color: kCardColor,
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.white12, width: 0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bagian Atas: Tanggal dan Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tanggal
                        Text(
                          item.tanggal,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        // Status (Menonjol)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(statusIcon, color: statusColor, size: 16),
                              const SizedBox(width: 5),
                              Text(
                                item.status.toUpperCase(),
                                style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 20),
                    // Bagian Bawah: Detail
                    _buildDetailRow(
                        Icons.access_time, "Jam", item.jam, Colors.white70),
                    _buildDetailRow(
                        Icons.book, "Mapel", item.mapel, Colors.white70),
                    _buildDetailRow(
                        Icons.school, "Kelas", item.kelas, Colors.white70),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // Widget Helper untuk baris detail yang rapih
  Widget _buildDetailRow(
      IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withOpacity(0.8), size: 18),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: TextStyle(color: color, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
