import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/jadwal_controller.dart';
import '../models/jadwal_model.dart';

const Color kPrimaryColor = Color(0xFF42A5F5);
const Color kBackgroundColor = Colors.black;
const Color kCardColor = Color(0xFF161616);

class JadwalPage extends StatefulWidget {
  final bool showBackButton;

  const JadwalPage({super.key, this.showBackButton = true});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  final JadwalController c = Get.put(JadwalController());

  @override
  void initState() {
    super.initState();

    /// 🔥 RESET KE HARI INI SETIAP MASUK HALAMAN
    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.onReady(); // ← PAKSA PANGGIL RESET
    });
  }

  // ================= DAY SELECTOR =================
  Widget _buildDaySelector() {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: c.days.length,
        itemBuilder: (_, index) {
          final day = c.days[index];
          final isActive = c.selectedDay.value == day;

          return GestureDetector(
            onTap: () => c.selectedDay.value = day,
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? kPrimaryColor : Colors.white10,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                day,
                style: TextStyle(
                  color: isActive ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= JADWAL ITEM =================
  Widget _buildJadwalItem(JadwalModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.hari,
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${item.jamMulai} - ${item.jamSelesai}",
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.namaMapel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (item.qrActive == true) ...[
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.qr_code, color: Colors.greenAccent, size: 18),
                SizedBox(width: 6),
                Text(
                  "QR Aktif",
                  style: TextStyle(color: Colors.greenAccent),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ================= MAIN UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            if (widget.showBackButton)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 16),
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
          if (c.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: kPrimaryColor,
              ),
            );
          }

          return Column(
            children: [
              _buildDaySelector(),
              const SizedBox(height: 20),
              Expanded(
                child: c.filteredJadwal.isEmpty
                    ? const Center(
                        child: Text(
                          "Tidak ada jadwal",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: c.filteredJadwal.length,
                        itemBuilder: (_, i) =>
                            _buildJadwalItem(c.filteredJadwal[i]),
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
