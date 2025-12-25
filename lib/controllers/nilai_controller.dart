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
  var tingkat = "".obs;

  // ================= FILTER =================
  final listSemester = ["Ganjil", "Genap"];
  var selectedSemester = "Ganjil".obs;

  var listTahunAjaran = <String>[].obs;
  var selectedTahunAjaran = "".obs;

  Timer? _refreshTimer;

  int? _siswaId;
  bool _isLoadingData = false; // 🔒 LOCK

  // ================= INIT =================
  @override
  void onInit() {
    super.onInit();
    _initTahunAjaran();
  }

  @override
  void onReady() {
    super.onReady();
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
    if (_isLoadingData) return;
    _isLoadingData = true;

    try {
      errorMessage.value = "";

      _siswaId ??= await _getSiswaId();
      if (_siswaId == null) {
        errorMessage.value = "Siswa belum login";
        return;
      }

      final nilaiData = await ApiService.getNilai(_siswaId!);
      nilai.assignAll(nilaiData
          .map((e) => NilaiModel.fromJson(e as Map<String, dynamic>))
          .toList());

      final akhirData = await ApiService.getNilaiAkhir(_siswaId!);
      nilaiAkhir.assignAll(akhirData
          .map((e) => NilaiAkhirModel.fromJson(e as Map<String, dynamic>))
          .toList());
    } catch (e, s) {
      errorMessage.value = "Gagal memuat data nilai";
      debugPrint("❌ ERROR loadData: $e");
      debugPrintStack(stackTrace: s);
    } finally {
      _isLoadingData = false;
    }
  }

  Future<int?> _getSiswaId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt("id");
    } catch (_) {
      return null;
    }
  }

  // ================= AUTO REFRESH =================
  void startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) async {
        if (!_isLoadingData) {
          await loadData();
        }
      },
    );
  }

  // ================= FILTER HANDLER =================
  void changeSemester(String semester) {
    selectedSemester.value = semester;
  }

  void changeTahunAjaran(String tahun) async {
    selectedTahunAjaran.value = tahun;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("tahun_ajaran", tahun);
    } catch (_) {}
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final defaultTA =
          prefs.getString("tahun_ajaran") ?? _currentTahunAjaran();

      final list = _generateTahunAjaranList();
      listTahunAjaran.assignAll(list);

      selectedTahunAjaran.value =
          list.contains(defaultTA) ? defaultTA : list.first;
    } catch (_) {}
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
