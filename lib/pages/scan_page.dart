import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/scan_controller.dart';

class ScanPage extends StatelessWidget {
  ScanPage({super.key});

  final ScanController c = Get.put(ScanController());

  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    returnImage: false,
    autoStart: true, // 🔥 PALING AMAN
  );

  @override
  Widget build(BuildContext context) {
    c.attachCamera(cameraController);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Scan QR Absensi",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // ================= CAMERA =================
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (!c.canProcess()) return;

              final barcode = capture.barcodes.firstOrNull;
              final raw = barcode?.rawValue;

              if (raw != null && raw.isNotEmpty) {
                c.confirmScan(raw);
              }
            },
          ),

          // ================= OVERLAY =================
          _ScanOverlay(),

          // ================= LOADING =================
          Obx(() => c.isLoading.value
              ? Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              : const SizedBox()),

          // ================= STATUS =================
          Obx(() => c.statusMessage.isNotEmpty
              ? Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: c.statusColor.value,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      c.statusMessage.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              : const SizedBox()),
        ],
      ),
    );
  }
}

// ================= OVERLAY =================
class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const double boxSize = 260;

    return Center(
      child: Container(
        width: boxSize,
        height: boxSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.cyanAccent, width: 3),
        ),
      ),
    );
  }
}
