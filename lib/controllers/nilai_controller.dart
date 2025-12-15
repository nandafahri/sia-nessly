import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sia_nessly/services/api_services.dart';
import '../models/nilai_model.dart';

class NilaiController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = "".obs;

  var allNilai = <NilaiModel>[].obs;
  var selectedSemester = "Genap".obs;

  @override
  void onInit() {
    super.onInit();
    loadNilai();
  }

  Future<void> loadNilai() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      final prefs = await SharedPreferences.getInstance();
      final siswaId = prefs.getInt("id");

      if (siswaId == null) {
        errorMessage.value = "ID siswa tidak ditemukan, silakan login ulang.";
        return;
      }

      final List<dynamic> data = await ApiService.getNilai(siswaId);

      allNilai.value = data.map((json) => NilaiModel.fromJson(json)).toList();
    } catch (e) {
      errorMessage.value = "Gagal memuat nilai: $e";
    } finally {
      isLoading.value = false;
    }
  }

  List<NilaiModel> get nilaiFiltered =>
      allNilai.where((n) => n.semester == selectedSemester.value).toList();
}
