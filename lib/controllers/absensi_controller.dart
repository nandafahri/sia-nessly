import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sia_nessly/services/api_services.dart';
import '../models/absensi_model.dart';

class AbsensiController extends GetxController {
  // ================= STATE =================
  var isLoading = false.obs;
  var errorMessage = "".obs;
  var absensiResponse = Rx<AbsensiResponse?>(null);

  // ================= FILTER STATE =================
  var selectedStatus = "Semua".obs;
  var searchQuery = "".obs;
  var sortTerbaru = true.obs;

  // ================= REALTIME =================
  Timer? _timer;
  String? _nisn;

  // ================= LOAD DATA =================
  Future<void> loadAbsensi(String nisn, {bool silent = false}) async {
    try {
      if (!silent) isLoading.value = true;
      errorMessage.value = "";
      _nisn = nisn;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token") ?? "";

      final res = await ApiService.getAbsensi(nisn, token);

      if (res["statusCode"] != 200) {
        errorMessage.value =
            res["body"]["message"] ?? "Gagal memuat data absensi";
        return;
      }

      absensiResponse.value = AbsensiResponse.fromJson(res["body"]);
    } catch (e) {
      errorMessage.value = "Terjadi kesalahan: $e";
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  // ================= REALTIME POLLING =================
  void startRealtime(String nisn) {
    _nisn = nisn;
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 5), // ⏱ realtime tiap 5 detik
      (_) {
        if (_nisn != null) {
          loadAbsensi(_nisn!, silent: true);
        }
      },
    );
  }

  // ================= FILTERED DATA =================
  List<AbsensiItem> get filteredRiwayat {
    if (absensiResponse.value == null) return [];

    List<AbsensiItem> data =
        List<AbsensiItem>.from(absensiResponse.value!.riwayat);

    // FILTER STATUS
    if (selectedStatus.value != "Semua") {
      data = data
          .where((e) =>
              e.status.toLowerCase() ==
              selectedStatus.value.toLowerCase())
          .toList();
    }

    // SEARCH MAPEL
    if (searchQuery.value.isNotEmpty) {
      data = data
          .where((e) =>
              e.mapel.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    // SORT TANGGAL (AMAN)
    data.sort((a, b) {
      final dateA = DateTime.tryParse(a.tanggal) ?? DateTime(2000);
      final dateB = DateTime.tryParse(b.tanggal) ?? DateTime(2000);

      return sortTerbaru.value
          ? dateB.compareTo(dateA)
          : dateA.compareTo(dateB);
    });

    return data;
  }

  // ================= ACTION =================
  void setStatus(String status) => selectedStatus.value = status;
  void setSearch(String value) => searchQuery.value = value;
  void toggleSort() => sortTerbaru.value = !sortTerbaru.value;

  // ================= CLEANUP =================
  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
