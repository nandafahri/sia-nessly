import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/scan_controller.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  final ScanController c = Get.put(ScanController());

  /// IMPORTANT: autoStart dimatikan agar tidak terjadi double-initializing
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    returnImage: false,
    autoStart: false, // FIX agar tidak double start
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    c.attachCamera(cameraController);

    // Mulai kamera sekali
    cameraController.start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController.stop();
    cameraController.dispose();
    Get.delete<ScanController>();
    super.dispose();
  }

  /// PAUSE / RESUME kamera pada lifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    if (state == AppLifecycleState.paused) {
      cameraController.stop();
    } else if (state == AppLifecycleState.resumed) {
      cameraController.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Scan QR Absensi",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          //---------------------------------------------------
          // CAMERA VIEW
          //---------------------------------------------------
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) async {
              if (!c.canProcess()) return;
              if (!c.isScanning.value) return;

              final barcode = capture.barcodes.firstOrNull;
              final raw = barcode?.rawValue;

              if (raw != null && raw.isNotEmpty) {
                c.isScanning.value = false;
                await c.confirmScan(raw, context);
              }
            },
          ),

          //---------------------------------------------------
          // SCAN AREA OVERLAY
          //---------------------------------------------------
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const double boxSize = 260;
                final double width = constraints.maxWidth;
                final double height = constraints.maxHeight;

                final double topBottom = (height - boxSize) / 2;
                final double side = (width - boxSize) / 2;

                return Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: topBottom,
                      child: Container(color: Colors.black54),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: topBottom,
                      child: Container(color: Colors.black54),
                    ),
                    Positioned(
                      top: topBottom,
                      bottom: topBottom,
                      left: 0,
                      width: side,
                      child: Container(color: Colors.black54),
                    ),
                    Positioned(
                      top: topBottom,
                      bottom: topBottom,
                      right: 0,
                      width: side,
                      child: Container(color: Colors.black54),
                    ),
                    Positioned(
                      top: topBottom,
                      left: side,
                      width: boxSize,
                      height: boxSize,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.cyanAccent,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          //---------------------------------------------------
          // LOADING OVERLAY
          //---------------------------------------------------
          Obx(() => c.isLoading.value
              ? Container(
                  color: Colors.black.withOpacity(0.65),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                )
              : const SizedBox()),

          //---------------------------------------------------
          // STATUS MESSAGE BAWAH
          //---------------------------------------------------
          Obx(() => c.statusMessage.isNotEmpty
              ? Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    decoration: BoxDecoration(
                      color: c.statusColor.value,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Text(
                      c.statusMessage.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
