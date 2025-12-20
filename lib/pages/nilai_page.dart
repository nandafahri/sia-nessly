import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../controllers/nilai_controller.dart';

const Color kPrimaryColor = Color(0xFF42A5F5);
const Color kBackgroundColor = Colors.black;
const Color kCardColor = Color(0xFF161616);

class NilaiPage extends StatelessWidget {
  NilaiPage({super.key});

  // Gunakan Get.find karena controller sudah di-load sebelumnya (di login/home)
  final NilaiController controller =
      Get.put<NilaiController>(NilaiController());

  // ===============================
  // PDF GENERATOR
  // ===============================
  Future<void> _downloadPdf(
    BuildContext context,
    String nama,
    String namaKelas,
  ) async {
    try {
      final doc = pw.Document();

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) => [
            pw.Text(
              "RAPOR NILAI SISWA",
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Text("Nama   : $nama"),
            pw.Text("Kelas  : $namaKelas"),
            pw.Text("Semester : ${controller.selectedSemester.value}"),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.center,
              headers: const [
                "Mapel",
                "Harian",
                "UTS",
                "UAS",
                "Akhir",
                "Huruf",
              ],
              data: controller.nilaiAkhirFiltered.map((n) {
                return [
                  n.mapelNama,
                  n.nilaiHarian.toStringAsFixed(0),
                  n.nilaiUts.toStringAsFixed(0),
                  n.nilaiUas.toStringAsFixed(0),
                  n.nilaiAkhir.toStringAsFixed(0),
                  n.nilaiHuruf,
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              "Dicetak pada: ${DateTime.now()}",
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      );

      await Printing.sharePdf(
        bytes: await doc.save(),
        filename: "rapor_nilai_${controller.selectedSemester.value}.pdf",
      );
    } catch (e) {
      debugPrint("❌ ERROR PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal membuat PDF: $e")),
      );
    }
  }

  // ===============================
  // INFO BOX
  // ===============================
  Widget infoBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.indigo.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,

      // ===============================
      // APPBAR
      // ===============================
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
                  child: const Center(
                    child: Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              "Nilai",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final nilaiAkhir = controller.nilaiAkhirFiltered;

          return Column(
            children: [
              // ===============================
              // FILTER + DOWNLOAD BUTTON
              // ===============================
              Row(
                children: [
                  const Text("Semester:",
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    dropdownColor: Colors.black,
                    value: controller.selectedSemester.value,
                    items: const [
                      DropdownMenuItem(
                        value: "Ganjil",
                        child: Text("Ganjil",
                            style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: "Genap",
                        child: Text("Genap",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        controller.changeSemester(
                            v); // Hanya ganti filter, data sudah ada
                      }
                    },
                  ),
                  const Spacer(),

                  // DOWNLOAD BUTTON
                  IconButton(
                    tooltip: "Download PDF",
                    icon: const Icon(Icons.picture_as_pdf,
                        color: Colors.redAccent),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final nama = prefs.getString("nama") ?? "-";
                      final kelas = prefs.getString("nama_kelas") ?? "-";

                      _downloadPdf(context, nama, kelas);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ===============================
              // LIST NILAI AKHIR
              // ===============================
              Expanded(
                child: controller.errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          controller.errorMessage.value,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : nilaiAkhir.isEmpty
                        ? const Center(
                            child: Text(
                              "Tidak ada nilai",
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            itemCount: nilaiAkhir.length,
                            itemBuilder: (_, i) {
                              final n = nilaiAkhir[i];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: kCardColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.mapelNama,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        infoBox("Harian",
                                            n.nilaiHarian.toStringAsFixed(0)),
                                        const SizedBox(width: 8),
                                        infoBox("UTS",
                                            n.nilaiUts.toStringAsFixed(0)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        infoBox("UAS",
                                            n.nilaiUas.toStringAsFixed(0)),
                                        const SizedBox(width: 8),
                                        infoBox("Akhir",
                                            n.nilaiAkhir.toStringAsFixed(0)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Center(
                                      child: Text(
                                        "Nilai Huruf: ${n.nilaiHuruf}",
                                        style: const TextStyle(
                                          color: Colors.greenAccent,
                                          fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
