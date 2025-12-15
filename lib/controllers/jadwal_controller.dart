import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sia_nessly/services/api_services.dart';
import '../models/jadwal_model.dart';

class JadwalController extends GetxController {
  var jadwalList = <JadwalModel>[].obs;
  var isLoading = false.obs;
  var kelasId = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  /// Ambil kelas_id dari SharedPreferences
  Future<void> loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final kelasInt = prefs.getInt("kelas_id");

    if (kelasInt == null) {
      kelasId.value = "";
      return;
    }

    kelasId.value = kelasInt.toString();
    fetchJadwal();
  }

  /// Ambil jadwal melalui ApiService
  Future<void> fetchJadwal() async {
    if (kelasId.value.isEmpty) return;

    try {
      isLoading.value = true;

      final List<dynamic> data = await ApiService.getJadwal(kelasId.value);

      jadwalList.value =
          data.map((json) => JadwalModel.fromJson(json)).toList();
    } catch (e) {
      print("Gagal memuat jadwal: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
