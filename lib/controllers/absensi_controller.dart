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
  String? _token;
  bool _isPolling = false; // 🔒 LOCK

  // ================= LOAD DATA =================
  Future<void> loadAbsensi(String nisn, {bool silent = false}) async {
    try {
      if (!silent) isLoading.value = true;
      errorMessage.value = "";
      _nisn = nisn;

      // 🔒 Ambil token SEKALI
      _token ??= await _getToken();
      if (_token == null || _token!.isEmpty) return;

      final res = await ApiService.getAbsensi(nisn, _token!);

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

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString("auth_token");
    } catch (_) {
      return null;
    }
  }

  // ================= REALTIME POLLING =================
  void startRealtime(String nisn) {
    if (nisn.isEmpty) return;

    _nisn = nisn;
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) async {
        if (_isPolling || _nisn == null) return;

        _isPolling = true;
        try {
          await loadAbsensi(_nisn!, silent: true);
        } catch (_) {
          // diamkan, jangan pause debugger
        } finally {
          _isPolling = false;
        }
      },
    );
  }

  // ================= FILTERED DATA =================
  List<AbsensiItem> get filteredRiwayat {
    if (absensiResponse.value == null) return [];

    List<AbsensiItem> data =
        List<AbsensiItem>.from(absensiResponse.value!.riwayat);

    if (selectedStatus.value != "Semua") {
      data = data
          .where((e) =>
              e.status.toLowerCase() == selectedStatus.value.toLowerCase())
          .toList();
    }

    if (searchQuery.value.isNotEmpty) {
      data = data
          .where((e) =>
              e.mapel.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }

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
