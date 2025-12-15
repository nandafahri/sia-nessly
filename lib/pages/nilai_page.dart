import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../controllers/nilai_controller.dart';
import '../models/nilai_model.dart';

const Color kPrimaryColor = Color(0xFF42A5F5);
const Color kBackgroundColor = Colors.black; // FULL HITAM
const Color kCardColor =
    Color(0xFF161616); // warna card sedikit lebih terang agar kontras

class NilaiPage extends StatelessWidget {
  NilaiPage({super.key});

  final NilaiController controller = Get.put(NilaiController());

  Future<void> sharePdf(
      List<NilaiModel> nilai, String semester, BuildContext ctx) async {
    try {
      final doc = pw.Document();

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) => [
            pw.Text("Laporan Nilai Siswa", style: pw.TextStyle(fontSize: 20)),
            pw.SizedBox(height: 10),
            pw.Text("Semester: $semester"),
            pw.SizedBox(height: 12),
            pw.Table.fromTextArray(
              headers: ["Mapel", "Semester", "Tahun", "Nilai", "Huruf", "Ket"],
              data: nilai.map((n) {
                return [
                  n.mapelNama,
                  n.semester,
                  n.tahunAjaran,
                  n.nilaiAngka.toString(),
                  n.nilaiHuruf,
                  n.keterangan
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Text("Generated: ${DateTime.now()}",
                style: pw.TextStyle(fontSize: 10)),
          ],
        ),
      );

      await Printing.sharePdf(
          bytes: await doc.save(), filename: "nilai_$semester.pdf");
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text("PDF error: $e")),
      );
    }
  }

  Widget infoBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.indigo.shade600.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
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
              "Nilai",
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
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
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

          final nilai = controller.nilaiFiltered;

          return Column(
            children: [
              // Dropdown + download button
              Row(
                children: [
                  const Text("Semester:",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    dropdownColor: Colors.black,
                    value: controller.selectedSemester.value,
                    items: const [
                      DropdownMenuItem(
                          value: "Ganjil",
                          child: Text("Ganjil",
                              style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(
                          value: "Genap",
                          child: Text("Genap",
                              style: TextStyle(color: Colors.white))),
                    ],
                    onChanged: (v) => controller.selectedSemester.value = v!,
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text("Download PDF"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      if (nilai.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Tidak ada data untuk semester ini")),
                        );
                        return;
                      }
                      sharePdf(
                          nilai, controller.selectedSemester.value, context);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Content List
              Expanded(
                child: nilai.isEmpty
                    ? const Center(
                        child: Text("Tidak ada nilai pada semester ini",
                            style: TextStyle(color: Colors.white60)),
                      )
                    : ListView.builder(
                        itemCount: nilai.length,
                        itemBuilder: (context, index) {
                          final n = nilai[index];
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
                                Text(n.mapelNama,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    infoBox("Nilai", n.nilaiAngka.toString()),
                                    infoBox("Huruf", n.nilaiHuruf),
                                    infoBox("Tahun", n.tahunAjaran),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text("Semester: ${n.semester}",
                                    style:
                                        const TextStyle(color: Colors.white70)),
                                const SizedBox(height: 6),
                                Text("Keterangan: ${n.keterangan}",
                                    style:
                                        const TextStyle(color: Colors.white70)),
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
