import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sia_nessly/services/api_services.dart';

class ScanController extends GetxController {
  // ===== STATE =====
  var isScanning = true.obs;
  var isLoading = false.obs;

  var statusMessage = "".obs;
  var statusColor = (Colors.green as Color).obs;

  // Kamera
  MobileScannerController? camera;

  // Anti spam scan
  DateTime lastScan = DateTime.now();

  // Lokasi sekolah
  final double sekolahLat = -6.199844;
  final double sekolahLng = 106.957780;
  final double radiusMeter = 100;

  void attachCamera(MobileScannerController cam) {
    camera = cam;
  }

  bool canProcess() {
    final now = DateTime.now();
    if (now.difference(lastScan).inMilliseconds < 1200) {
      return false;
    }
    lastScan = now;
    return true;
  }

  void updateStatus(String msg, Color color) {
    statusMessage.value = msg;
    statusColor.value = color;

    // Auto hide after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (statusMessage.value == msg) {
        statusMessage.value = "";
      }
    });
  }

  // ===== GET LOCATION =====
  Future<Position?> getLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        updateStatus("GPS tidak aktif!", Colors.red);
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          updateStatus("Izin lokasi ditolak!", Colors.red);
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        updateStatus("Izin lokasi ditolak permanen!", Colors.red);
        return null;
      }

      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      updateStatus("Gagal mendapatkan lokasi!", Colors.red);
      return null;
    }
  }

  bool isInsideRadius(Position pos) {
    final distance = Geolocator.distanceBetween(
        pos.latitude, pos.longitude, sekolahLat, sekolahLng);
    return distance <= radiusMeter;
  }

  // ===== CONFIRM SCAN =====
  Future<void> confirmScan(String qrUrl, BuildContext context) async {
    isScanning.value = false;

    // STOP kamera dulu
    try {
      await camera?.stop();
    } catch (_) {}

    try {
      // ---- Dapatkan token login ----
      final token = await ApiService.getToken();
      if (token == null) {
        updateStatus("Gagal mendapatkan token login!", Colors.red);
        restartCamera();
        return;
      }

      // ---- Ambil Lokasi ----
      final pos = await getLocation();
      if (pos == null) {
        restartCamera();
        return;
      }

      bool inside = isInsideRadius(pos);

      // Ambil alamat
      String alamat = "Lokasi tidak ditemukan";
      try {
        final place =
            await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (place.isNotEmpty) {
          alamat =
              "${place[0].street}, ${place[0].subLocality}, ${place[0].locality}";
        }
      } catch (_) {}

      // Tampilkan status lokasi BUKAN dialog
      updateStatus(
          inside
              ? "Di dalam radius sekolah.\n$alamat"
              : "Di luar radius sekolah!\n$alamat",
          inside ? Colors.green : Colors.red);

      // Jika di luar radius → tidak absen
      if (!inside) {
        restartCamera();
        return;
      }

      // Jika lokasi OK → langsung absen
      await submitAbsensi(qrUrl);
    } finally {
      restartCamera();
    }
  }

  // ===== SUBMIT ABSENSI =====
  Future<void> submitAbsensi(String qrUrl) async {
    isLoading.value = true;

    try {
      final uri = Uri.parse(qrUrl.trim());
      final tokenQR = uri.pathSegments.last;

      final result = await ApiService.submitAbsensi(tokenQR);
      final data = result["body"];

      if (result["statusCode"] == 200 && data["success"] == true) {
        updateStatus(data["message"], Colors.green);
      } else {
        updateStatus(data["message"] ?? "Gagal absen!", Colors.red);
      }
    } catch (e) {
      updateStatus("Gagal terhubung ke server!", Colors.red);
    }

    isLoading.value = false;
  }

  // ===== Restart Kamera =====
  Future<void> restartCamera() async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      await camera?.start();
    } catch (_) {}

    isScanning.value = true;
  }
}
