import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sia_nessly/services/api_services.dart';
import '../models/absensi_model.dart';

class AbsensiController extends GetxController {
  var isLoading = false.obs;
  var absensiResponse = Rx<AbsensiResponse?>(null);
  var errorMessage = "".obs;

  Future<void> loadAbsensi(String nisn) async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token") ?? "";

      final res = await ApiService.getAbsensi(nisn, token);

      final statusCode = res["statusCode"];
      final body = res["body"];

      if (statusCode != 200) {
        errorMessage.value = body["message"] ?? "Gagal memuat data";
        return;
      }

      absensiResponse.value = AbsensiResponse.fromJson(body);
    } catch (e) {
      errorMessage.value = "Terjadi kesalahan: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
