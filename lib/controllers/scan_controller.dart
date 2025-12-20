import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sia_nessly/services/api_services.dart';
import 'package:sia_nessly/controllers/home_controller.dart';

class ScanController extends GetxController {
  var isScanning = true.obs;
  var isLoading = false.obs;

  var statusMessage = "".obs;
  var statusColor = const Color(0xFF4CAF50).obs;

  MobileScannerController? camera;
  DateTime lastScan = DateTime.now();

  final double sekolahLat = -6.199844;
  final double sekolahLng = 106.957780;
  final double radiusMeter = 100;

  void attachCamera(MobileScannerController cam) {
    camera = cam;
  }

  bool canProcess() {
    final now = DateTime.now();
    if (now.difference(lastScan).inMilliseconds < 1200) return false;
    lastScan = now;
    return true;
  }

  void updateStatus(String msg, Color color) {
    statusMessage.value = msg;
    statusColor.value = color;

    Future.delayed(const Duration(seconds: 3), () {
      if (statusMessage.value == msg) statusMessage.value = "";
    });
  }

  Future<Position?> getLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        updateStatus("❌ GPS tidak aktif!", Colors.red);
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        updateStatus("❌ Izin lokasi ditolak!", Colors.red);
        return null;
      }

      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (_) {
      updateStatus("❌ Gagal mendapatkan lokasi!", Colors.red);
      return null;
    }
  }

  bool isInsideRadius(Position pos) {
    final distance = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      sekolahLat,
      sekolahLng,
    );
    return distance <= radiusMeter;
  }

  Future<Map<String, dynamic>> submitAbsensi(String qrUrl) async {
    try {
      final uri = Uri.parse(qrUrl.trim());
      final tokenQR = uri.pathSegments.last;
      return await ApiService.submitAbsensi(tokenQR);
    } catch (_) {
      return {
        "statusCode": 500,
        "body": {"success": false, "message": "Gagal terhubung"}
      };
    }
  }

  Future<String> getAddressFromPosition(Position pos) async {
    try {
      final placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);

      if (placemarks.isEmpty) return "Lokasi tidak diketahui";

      final place = placemarks.first;

      return [
        place.street,
        place.subLocality,
        place.locality,
      ].where((e) => e != null && e.isNotEmpty).join(", ");
    } catch (_) {
      return "Gagal membaca alamat";
    }
  }

  Future<void> confirmScan(String qrUrl, BuildContext context) async {
    isScanning.value = false;
    await camera?.stop();

    try {
      final pos = await getLocation();
      if (pos == null || !isInsideRadius(pos)) {
        updateStatus("❌ Di luar jangkauan sekolah", Colors.red);
        restartCamera();
        return;
      }

      isLoading.value = true;
      final result = await submitAbsensi(qrUrl);
      final data = result["body"];

      if (result["statusCode"] == 200 && data["success"] == true) {
        final distance = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          sekolahLat,
          sekolahLng,
        ).round();

        /// 🔥 AMBIL ALAMAT ASLI
        final address = await getAddressFromPosition(pos);

        updateStatus(
          "✅ Absen berhasil\n"
          "📍 $address\n"
          "📏 Jarak: ${distance} meter",
          Colors.green,
        );

        final homeC = Get.find<HomeController>();
        await homeC.refreshStatus();
      } else {
        updateStatus(data["message"] ?? "❌ Gagal absen", Colors.red);
      }
    } finally {
      isLoading.value = false;
      restartCamera();
    }
  }

  Future<void> restartCamera() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await camera?.start();
    isScanning.value = true;
  }
}
