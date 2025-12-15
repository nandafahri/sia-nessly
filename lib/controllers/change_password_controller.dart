import 'dart:convert';

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
      Get.snackbar("Error", "NISN tidak ditemukan, silakan login ulang!");
      return;
    }

    if (oldPassCtrl.value.isEmpty || newPassCtrl.value.isEmpty) {
      Get.snackbar("Error", "Semua field wajib diisi");
      return;
    }

    if (oldPassCtrl.value == newPassCtrl.value) {
      Get.snackbar("Error", "Password baru harus berbeda dari password lama");
      return;
    }

    if (newPassCtrl.value.length < 6) {
      Get.snackbar("Error", "Password minimal 6 karakter");
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
      Get.snackbar("Berhasil", data["message"]);

      await prefs.clear(); // logout

      Get.offAll(() => LoginPage());
    } else {
      Get.snackbar("Gagal", data["message"] ?? "Gagal mengganti password");
    }
  }
}
