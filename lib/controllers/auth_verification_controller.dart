import 'package:get/get.dart';
import 'package:sia_nessly/services/api_services.dart';

class AuthVerificationController extends GetxController {
  var email = ''.obs;
  var phone = ''.obs;
  var isLoading = false.obs;

  Future<void> verifyAccount() async {
    if (email.value.isEmpty || phone.value.isEmpty) {
      Get.snackbar("Error", "Semua field harus diisi");
      return;
    }

    if (!email.value.contains("@")) {
      Get.snackbar("Error", "Format email tidak valid");
      return;
    }

    isLoading.value = true;

    try {
      final res = await ApiService.verifyAccount(
        email: email.value.trim(),
        nomorTelepon: phone.value.trim(),
      );

      final data = res["body"];
      final statusCode = res["statusCode"];

      if (statusCode == 200 && data["success"] == true) {
        Get.snackbar("Sukses",
            "Verifikasi Berhasil: ${data['data']['nama'] ?? 'Siswa'}");

        // Jika mau redirect:
        // Get.to(() => ResetPasswordPage(nisn: data['data']['nisn']));
      } else {
        Get.snackbar(
            "Gagal", data["message"] ?? "Email atau Nomor Telepon tidak cocok");
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan koneksi");
    }

    isLoading.value = false;
  }
}
