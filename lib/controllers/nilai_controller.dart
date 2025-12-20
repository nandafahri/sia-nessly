import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/nilai_model.dart';
import '../models/nilai_akhir_model.dart';
import '../services/api_services.dart';

class NilaiController extends GetxController {
  var isLoading = false.obs; // Tidak digunakan untuk UI lagi
  var errorMessage = ''.obs;

  var nilai = <NilaiModel>[].obs;
  var nilaiAkhir = <NilaiAkhirModel>[].obs;
  var selectedSemester = "Ganjil".obs;

  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    // Data sudah di-load dari Home/Login, jadi tidak load lagi di sini
    // Jika belum ada data, baru load
    if (nilai.isEmpty && nilaiAkhir.isEmpty) {
      loadData();
    }
    startAutoRefresh(); // Langsung mulai refresh realtime
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  Future<void> loadData() async {
    try {
      errorMessage.value = "";
      final prefs = await SharedPreferences.getInstance();
      final siswaId = prefs.getInt("id");

      if (siswaId == null) {
        errorMessage.value = "Siswa belum login";
        return;
      }

      final nilaiData = await ApiService.getNilai(siswaId);
      nilai.assignAll(nilaiData.map((e) => NilaiModel.fromJson(e)).toList());

      final akhirData = await ApiService.getNilaiAkhir(siswaId);
      nilaiAkhir.assignAll(akhirData.map((e) => NilaiAkhirModel.fromJson(e)).toList());

    } catch (e, s) {
      errorMessage.value = "Gagal memuat data";
      debugPrint("❌ ERROR loadData: $e");
      debugPrintStack(stackTrace: s);
    }
  }

  // Refresh lebih cepat: setiap 8 detik
  void startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      loadData(); // Update diam-diam
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
  }

  void changeSemester(String semester) {
    selectedSemester.value = semester;
    // Tidak perlu loadData lagi karena data sudah ada dan akan di-refresh otomatis
  }

  List<NilaiModel> get nilaiFiltered =>
      nilai.where((n) => n.semester.toLowerCase() == selectedSemester.value.toLowerCase()).toList();

  List<NilaiAkhirModel> get nilaiAkhirFiltered =>
      nilaiAkhir.where((n) => n.semester.toLowerCase() == selectedSemester.value.toLowerCase()).toList();

  Map<int, List<NilaiModel>> get nilaiGroupedByMapel {
    final map = <int, List<NilaiModel>>{};
    for (var n in nilaiFiltered) {
      map.putIfAbsent(n.mapelId, () => []).add(n);
    }
    return map;
  }

  NilaiAkhirModel? getNilaiAkhirByMapel(int mapelId) {
    try {
      return nilaiAkhirFiltered.firstWhere((a) => a.mapelId == mapelId);
    } catch (_) {
      return null;
    }
  }
}