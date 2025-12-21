import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sia_nessly/services/api_services.dart';

class HomeController extends GetxController {
  // ================= USER DATA =================
  var nama = "".obs;
  var nisn = "".obs;
  var namaKelas = "".obs;
  var foto = "".obs;
  var tingkat = "".obs; // ✅ TAMBAHKAN

  // ================= STATUS ABSENSI =================
  /// total mapel hari ini
  var totalMapelHariIni = 0.obs;

  /// total absen hari ini
  var totalAbsenHariIni = 0.obs;

  /// true = semua mapel sudah absen → badge HILANG
  /// false = masih ada mapel belum absen → badge MUNCUL
  var absensiLengkap = false.obs;

  /// nilai rendah
  var nilaiRendah = false.obs;

  // ================= PESAN =================
  var judulPesan = "".obs;
  var isiPesan = "".obs;

  int _lastUpdate = 0;
  Timer? _timer;

  // ================= NAV =================
  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await loadUser();
    await refreshStatus(); // 🔥 WAJIB
    _startAutoRefreshPesan();
  }

  // ================= USER =================
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    nama.value = prefs.getString("nama") ?? "Pengguna";
    nisn.value = prefs.getString("nisn") ?? "";
    namaKelas.value = prefs.getString("nama_kelas") ?? "";
    foto.value = prefs.getString("foto") ?? "";
    tingkat.value = prefs.getString("tingkat") ?? "-"; // ✅ AMBIL
    debugPrint("HOME LOAD TINGKAT => ${tingkat.value}");
  }

  Future<void> refreshStatus() async {
    try {
      if (nisn.value.isEmpty) return;

      final totalMapel = await ApiService.getJumlahMapelHariIni(nisn.value);

      final totalAbsen = await ApiService.getJumlahAbsenHariIni(nisn.value);

      totalMapelHariIni.value = totalMapel;
      totalAbsenHariIni.value = totalAbsen;

      /// 🔥 LOGIKA BADGE FINAL
      absensiLengkap.value = totalMapel > 0 && totalAbsen >= totalMapel;

      debugPrint(
          "ABSENSI STATUS → $totalAbsen / $totalMapel | lengkap=${absensiLengkap.value}");
    } catch (e) {
      debugPrint("ERROR refreshStatus: $e");
    }
  }

  // ================= AUTO PESAN =================
  void _startAutoRefreshPesan() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkPesan();
    });
  }

  Future<void> _checkPesan() async {
    try {
      final data = await ApiService.getPesanHarian();
      final int serverUpdated = data['updated_at'] ?? 0;

      if (serverUpdated == _lastUpdate) return;

      _lastUpdate = serverUpdated;
      judulPesan.value = data['judul'] ?? '';
      isiPesan.value = data['isi'] ?? '';
    } catch (_) {}
  }

  // ================= NAV =================
  void changeIndex(int i) {
    currentIndex.value = i;

    /// 🔥 SETIAP BALIK KE HOME, REFRESH
    if (i == 0) {
      refreshStatus();
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
