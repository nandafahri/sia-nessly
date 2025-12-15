import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class InfoDetailPage extends StatelessWidget {
  const InfoDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    const LatLng lokasiSMA = LatLng(-6.477000, 108.323100);

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
              "Info Sekolah",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Map bagian atas
          Flexible(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: lokasiSMA,
                  zoom: 17,
                ),
                markers: {
                  const Marker(
                    markerId: MarkerId("sma_sliyeg"),
                    position: lokasiSMA,
                    infoWindow: InfoWindow(
                      title: "SMA Negeri 1 Sliyeg",
                      snippet: "Jl. Raya Sleman, Indramayu",
                    ),
                  ),
                },
                zoomControlsEnabled: true,
                mapType: MapType.normal,
              ),
            ),
          ),

          // Deskripsi sekolah
          Flexible(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "SMA Negeri 1 Sliyeg\n\n",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text:
                            "Alamat: Jl. Raya Sleman, Sleman Lor, Kecamatan Sliyeg, Kabupaten Indramayu, Jawa Barat.\n\n"
                            "SMA Negeri 1 Sliyeg adalah sekolah unggulan yang berfokus pada prestasi, karakter, dan inovasi. "
                            "Dengan dukungan tenaga pendidik profesional dan fasilitas lengkap, sekolah ini konsisten mencetak lulusan unggulan yang siap bersaing di masa depan.\n\n"
                            "Visi:\nMenjadi lembaga pendidikan menengah yang unggul, inovatif, dan berkarakter.\n\n"
                            "Misi:\n• Meningkatkan kualitas pembelajaran\n• Membangun karakter religius dan bertanggung jawab\n• Mengembangkan potensi siswa dalam berbagai bidang\n",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
