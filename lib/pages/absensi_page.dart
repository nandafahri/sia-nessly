import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/absensi_controller.dart';

class AbsensiPage extends StatelessWidget {
  final String nisn;
  AbsensiPage({super.key, required this.nisn});

  final AbsensiController controller = Get.put(AbsensiController());

  final Color bg = Colors.black;
  final Color card = const Color(0xFF161616);

  @override
  Widget build(BuildContext context) {
    // LOAD + REALTIME
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.absensiResponse.value == null) {
        controller.loadAbsensi(nisn);
        controller.startRealtime(nisn); // 🔥 REALTIME AKTIF
      }
    });

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 62,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
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
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
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
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        final riwayat = controller.filteredRiwayat;

        return Column(
          children: [
            // ================= FILTER =================
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
              child: Column(
                children: [
                  TextField(
                    onChanged: controller.setSearch,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Cari mata pelajaran",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: card,
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          dropdownColor: card,
                          value: controller.selectedStatus.value,
                          items: ["Semua", "Hadir", "Izin", "Alpha"]
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e,
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  ))
                              .toList(),
                          onChanged: (v) => controller.setStatus(v!),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: card,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          tooltip: "Urutkan tanggal",
                          onPressed: controller.toggleSort,
                          icon: Obx(() => Icon(
                                controller.sortTerbaru.value
                                    ? Icons.arrow_downward_rounded
                                    : Icons.arrow_upward_rounded,
                                color: Colors.white,
                              )),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),

            // ================= LIST =================
            Expanded(
              child: riwayat.isEmpty
                  ? const Center(
                      child: Text(
                        "Data tidak ditemukan",
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 12),
                      itemCount: riwayat.length,
                      itemBuilder: (context, i) {
                        final item = riwayat[i];
                        final status = item.status;

                        final Color statusColor = status == "Hadir"
                            ? Colors.greenAccent
                            : status == "Izin"
                                ? Colors.amber
                                : Colors.redAccent;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.mapel,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${item.tanggal} • ${item.jam}",
                                      style: const TextStyle(
                                          color: Colors.white54, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}
