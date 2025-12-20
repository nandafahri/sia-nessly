import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sia_nessly/services/api_services.dart';

class AuthVerificationController extends GetxController {
  var email = ''.obs;
  var phone = ''.obs;
  var isLoading = false.obs;

  Future<void> verifyAccount() async {
    // ================= VALIDASI =================
    if (email.value.isEmpty || phone.value.isEmpty) {
      _showError("Semua field harus diisi");
      return;
    }

    if (!email.value.contains("@")) {
      _showError("Format email tidak valid");
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
        _showSuccess(
          "Verifikasi berhasil untuk ${data['data']['nama'] ?? 'Siswa'}",
        );

        // === Redirect (opsional) ===
        // Get.to(() => ResetPasswordPage(nisn: data['data']['nisn']));
      } else {
        _showError(
          data["message"] ?? "Email atau Nomor Telepon tidak cocok",
        );
      }
    } catch (e) {
      _showError("Terjadi kesalahan koneksi");
    }

    isLoading.value = false;
  }

  // ===================== SNACKBAR SUCCESS =====================
  void _showSuccess(String message) {
    Get.snackbar(
      "Berhasil",
      message,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      icon: const Icon(
        Icons.check_circle_rounded,
        color: Colors.white,
      ),
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  // ===================== SNACKBAR ERROR =====================
  void _showError(String message) {
    Get.snackbar(
      "Gagal",
      message,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      icon: const Icon(
        Icons.error_rounded,
        color: Colors.white,
      ),
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }
}
