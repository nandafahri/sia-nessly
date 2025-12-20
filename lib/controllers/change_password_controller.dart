import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sia_nessly/pages/login_page.dart';
import 'package:sia_nessly/services/api_services.dart';

class ChangePasswordController extends GetxController {
  var isLoading = false.obs;

  final oldPassCtrl = ''.obs;
  final newPassCtrl = ''.obs;

  Future<void> gantiPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final nisn = prefs.getString("nisn");

    if (nisn == null) {
      showError("NISN tidak ditemukan, silakan login ulang!");
      return;
    }

    if (oldPassCtrl.value.isEmpty || newPassCtrl.value.isEmpty) {
      showError("Semua field wajib diisi");
      return;
    }

    if (oldPassCtrl.value == newPassCtrl.value) {
      showError("Password baru harus berbeda dari password lama");
      return;
    }

    if (newPassCtrl.value.length < 6) {
      showError("Password minimal 6 karakter");
      return;
    }

    isLoading.value = true;

    final res = await ApiService.changePassword(
      nisn: nisn,
      oldPassword: oldPassCtrl.value,
      newPassword: newPassCtrl.value,
    );

    isLoading.value = false;

    final data = jsonDecode(res.body);
    final statusCode = res.statusCode;

    if (statusCode == 200 && data["success"] == true) {
      showSuccess(data["message"] ?? "Password berhasil diubah");

      await prefs.remove("auth_token");
      await prefs.remove("nisn");
      Get.offAll(() => LoginPage());
    } else {
      showError(data["message"] ?? "Gagal mengganti password");
    }
  }

  // ===================== SNACKBAR SUCCESS =====================
  void showSuccess(String message) {
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
  void showError(String message) {
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
