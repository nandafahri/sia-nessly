import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sia_nessly/services/api_services.dart';
import '../models/jadwal_model.dart';

class JadwalController extends GetxController {
  final jadwalList = <JadwalModel>[].obs;
  final isLoading = false.obs;
  final kelasId = "".obs;

  final selectedDay = "Senin".obs;

  final List<String> days = [
    "Senin",
    "Selasa",
    "Rabu",
    "Kamis",
    "Jumat",
    "Sabtu",
  ];

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  /// 🔥 DIPANGGIL SETIAP HALAMAN DITAMPILKAN
  @override
  void onReady() {
    super.onReady();
    _setTodayAsDefault();
  }

  void _setTodayAsDefault() {
    final now = DateTime.now().weekday;
    if (now >= 1 && now <= 6) {
      selectedDay.value = days[now - 1];
    } else {
      selectedDay.value = days.first;
    }
  }

  Future<void> loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final kelas = prefs.getInt("kelas_id");
    if (kelas == null) return;

    kelasId.value = kelas.toString();
    fetchJadwal();
  }

  Future<void> fetchJadwal() async {
    try {
      isLoading.value = true;
      final data = await ApiService.getJadwal(kelasId.value);
      jadwalList.value = data.map((e) => JadwalModel.fromJson(e)).toList();
    } finally {
      isLoading.value = false;
    }
  }

  List<JadwalModel> get filteredJadwal =>
      jadwalList.where((e) => e.hari == selectedDay.value).toList();
}
