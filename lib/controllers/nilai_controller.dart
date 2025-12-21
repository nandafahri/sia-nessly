import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../models/nilai_model.dart';
import '../models/nilai_akhir_model.dart';
import '../services/api_services.dart';

class NilaiController extends GetxController {
  // ================= STATE =================
  var errorMessage = ''.obs;

  var nilai = <NilaiModel>[].obs;
  var nilaiAkhir = <NilaiAkhirModel>[].obs;
  var tingkat = "".obs; // ✅ TAMBAHKAN

  // ================= FILTER =================
  final listSemester = ["Ganjil", "Genap"];
  var selectedSemester = "Ganjil".obs;

  var listTahunAjaran = <String>[].obs;
  var selectedTahunAjaran = "".obs;

  Timer? _refreshTimer;

  // ================= INIT =================
  @override
  void onInit() {
    super.onInit();
    _initTahunAjaran();
    loadData();
    startAutoRefresh();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  // ================= LOAD DATA =================
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
      nilai.assignAll(
        nilaiData.map((e) => NilaiModel.fromJson(e)).toList(),
      );

      final akhirData = await ApiService.getNilaiAkhir(siswaId);
      nilaiAkhir.assignAll(
        akhirData.map((e) => NilaiAkhirModel.fromJson(e)).toList(),
      );
    } catch (e, s) {
      errorMessage.value = "Gagal memuat data nilai";
      debugPrint("❌ ERROR loadData: $e");
      debugPrintStack(stackTrace: s);
    }
  }

  // ================= AUTO REFRESH =================
  void startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer =
        Timer.periodic(const Duration(seconds: 8), (_) => loadData());
  }

  // ================= FILTER HANDLER =================
  void changeSemester(String semester) {
    selectedSemester.value = semester;
  }

  void changeTahunAjaran(String tahun) async {
    selectedTahunAjaran.value = tahun;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("tahun_ajaran", tahun);
  }

  // ================= FILTERED DATA =================
  List<NilaiModel> get nilaiFiltered => nilai
      .where((n) =>
          n.semester.toLowerCase() == selectedSemester.value.toLowerCase() &&
          n.tahunAjaran == selectedTahunAjaran.value)
      .toList();

  List<NilaiAkhirModel> get nilaiAkhirFiltered => nilaiAkhir
      .where((n) =>
          n.semester.toLowerCase() == selectedSemester.value.toLowerCase() &&
          n.tahunAjaran == selectedTahunAjaran.value)
      .toList();

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

  // ================= TAHUN AJARAN =================
  Future<void> _initTahunAjaran() async {
    final prefs = await SharedPreferences.getInstance();

    final defaultTA = prefs.getString("tahun_ajaran") ?? _currentTahunAjaran();

    final list = _generateTahunAjaranList();
    listTahunAjaran.assignAll(list);

    // 🔥 ANTI ERROR DROPDOWN
    selectedTahunAjaran.value =
        list.contains(defaultTA) ? defaultTA : list.first;
  }

  String _currentTahunAjaran() {
    final now = DateTime.now();
    final year = now.year;
    return now.month >= 7 ? "$year/${year + 1}" : "${year - 1}/$year";
  }

  List<String> _generateTahunAjaranList() {
    final now = DateTime.now().year;
    return List.generate(5, (i) => "${now - i}/${now - i + 1}");
  }
}
