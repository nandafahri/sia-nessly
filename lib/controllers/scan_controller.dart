import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sia_nessly/services/api_services.dart';
import 'package:sia_nessly/controllers/home_controller.dart';

class ScanController extends GetxController {
  final isScanning = true.obs;
  final isLoading = false.obs;

  final statusMessage = "".obs;
  final statusColor = const Color(0xFF4CAF50).obs;

  MobileScannerController? camera;
  DateTime _lastScan = DateTime.now();

  final double sekolahLat = -6.199844;
  final double sekolahLng = 106.957780;
  final double radiusMeter = 100;

  void attachCamera(MobileScannerController controller) {
    camera = controller;
  }

  bool canProcess() {
    final now = DateTime.now();
    if (now.difference(_lastScan).inMilliseconds < 1200) return false;
    _lastScan = now;
    return true;
  }

  void updateStatus(String msg, Color color) {
    statusMessage.value = msg;
    statusColor.value = color;

    Future.delayed(const Duration(seconds: 3), () {
      if (statusMessage.value == msg) {
        statusMessage.value = "";
      }
    });
  }

  // ================= LOCATION =================
  Future<Position?> _getLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      updateStatus("❌ GPS tidak aktif", Colors.red);
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      updateStatus("❌ Izin lokasi ditolak", Colors.red);
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  bool _insideRadius(Position pos) {
    final distance = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      sekolahLat,
      sekolahLng,
    );
    return distance <= radiusMeter;
  }

  Future<String> _getAddress(Position pos) async {
    try {
      final places =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (places.isEmpty) return "Alamat tidak diketahui";

      final p = places.first;
      return [
        p.street,
        p.subLocality,
        p.locality,
      ].whereType<String>().where((e) => e.isNotEmpty).join(", ");
    } catch (_) {
      return "Gagal membaca alamat";
    }
  }

  // ================= SUBMIT =================
  Future<void> confirmScan(String raw) async {
    if (!isScanning.value) return;

    isScanning.value = false;
    isLoading.value = true;

    try {
      final pos = await _getLocation();
      if (pos == null || !_insideRadius(pos)) {
        updateStatus("❌ Di luar area sekolah", Colors.red);
        return;
      }

      final uri = Uri.parse(raw.trim());
      final token = uri.pathSegments.last;

      final res = await ApiService.submitAbsensi(token);
      final body = res["body"];

      if (res["statusCode"] == 200 && body["success"] == true) {
        final distance = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          sekolahLat,
          sekolahLng,
        ).round();

        final address = await _getAddress(pos);

        updateStatus(
          "✅ Absen berhasil\n📍 $address\n📏 $distance meter",
          Colors.green,
        );

        await Get.find<HomeController>().refreshStatus();
      } else {
        updateStatus(body["message"] ?? "❌ Gagal absen", Colors.red);
      }
    } catch (e) {
      updateStatus("❌ Terjadi kesalahan", Colors.red);
    } finally {
      isLoading.value = false;
      await Future.delayed(const Duration(milliseconds: 800));
      isScanning.value = true;
    }
  }
}
