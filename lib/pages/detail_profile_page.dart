import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/detail_profile_controller.dart';

final Color kPrimaryColor = Color(0xFF42A5F5);
final Color kBackgroundColor = Colors.black; // FULL HITAM
final Color kCardColor =
    Color(0xFF161616); // warna card sedikit lebih terang agar kontras

class DetailProfilePage extends StatelessWidget {
  DetailProfilePage({super.key});

  final DetailProfileController controller = Get.put(DetailProfileController());

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
              "Profil",
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
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeaderAvatar(),
            const SizedBox(height: 32),
            _buildSectionTitle("Informasi Pribadi"),
            _buildDetailCard([
              _buildDetailItem(
                  Icons.credit_card_outlined, "NISN", controller.nisn.value),
              _buildDetailItem(
                  Icons.email_outlined, "Email", controller.email.value),
              _buildDetailItem(
                  Icons.school_outlined, "Kelas", controller.namaKelas.value),
              _buildDetailItem(Icons.wc_outlined, "Jenis Kelamin",
                  controller.jenisKelamin.value),
            ]),
            const SizedBox(height: 32),
            _buildSectionTitle("Informasi Kontak"),
            _buildDetailCard([
              _buildDetailItem(Icons.phone_outlined, "Nomor Telepon",
                  controller.nomorTelepon.value),
              _buildDetailItem(
                  Icons.location_on_outlined, "Alamat", controller.alamat.value,
                  isMultiline: true),
            ]),
            const SizedBox(height: 30),
          ],
        );
      }),
    );
  }

  // ---- Widget Helper ----

  Widget _buildHeaderAvatar() {
    return Obx(() {
      return Center(
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[800],
              backgroundImage: (controller.foto.value.isNotEmpty &&
                      controller.foto.value.startsWith("http"))
                  ? NetworkImage(controller.foto.value)
                  : const AssetImage("assets/default_profile.png")
                      as ImageProvider,
            ),
            const SizedBox(height: 12),
            Text(
              controller.nama.value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Siswa",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title,
          style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value,
      {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: kPrimaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  maxLines: isMultiline ? 5 : 1,
                  overflow:
                      isMultiline ? TextOverflow.ellipsis : TextOverflow.fade,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
