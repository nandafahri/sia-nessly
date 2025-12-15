import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sia_nessly/pages/home_page.dart';
import 'package:sia_nessly/services/api_services.dart';

class LoginController extends GetxController {
  var nisn = ''.obs;
  var password = ''.obs;
  var loading = false.obs;

  void setNisn(String v) => nisn.value = v.trim();
  void setPassword(String v) => password.value = v.trim();

  int _safeIntParse(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  /// ============================
  /// LOGIN
  /// ============================
  Future<void> login() async {
    // === Validasi input ===
    if (nisn.value.isEmpty || password.value.isEmpty) {
      _showError("NISN dan Password wajib diisi.");
      return;
    }

    loading.value = true;

    try {
      final res = await ApiService.loginSiswa(
        nisn: nisn.value,
        password: password.value,
      );

      loading.value = false;

      final int statusCode = res["statusCode"];
      final data = res["body"];

      print("API RESPONSE => $data");

      // === Jika API error ===
      if (statusCode != 200 || data["success"] != true) {
        _showError(data["message"] ?? "Login gagal.");
        return;
      }

      final user = data["data"]["siswa"];
      final token = data["data"]["token"];

      // === SIMPAN LOCAL ===
      await _saveUserData(user, token);

      _showSuccess("Login berhasil! Selamat datang ${user["nama"]}");

      // Pindah ke Home
      Get.off(() => const HomePage(), transition: Transition.fadeIn);
    } catch (e) {
      loading.value = false;
      _showError("Tidak dapat terhubung ke server.\n$e");
    }
  }

  /// ============================
  /// SIMPAN DATA USER
  /// ============================
  Future<void> _saveUserData(dynamic user, String token) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("auth_token", token);
    await prefs.setInt("id", _safeIntParse(user["id"]));
    await prefs.setString("nama", user["nama"] ?? "");
    await prefs.setString("nisn", user["nisn"] ?? "");
    await prefs.setString("email", user["email"] ?? "");
    await prefs.setInt("kelas_id", _safeIntParse(user["kelas_id"]));
    await prefs.setString("nama_kelas", user["kelas"] ?? "Tidak Ada Kelas");
    await prefs.setString("jenis_kelamin", user["jenis_kelamin"] ?? "");
    await prefs.setString("alamat", user["alamat"] ?? "");
    await prefs.setString("nomor_telepon", user["nomor_telepon"] ?? "");
    await prefs.setString("foto", (user["foto"] ?? "").toString());
  }

  /// ============================
  /// SNACKBAR ERROR
  /// ============================
  void _showError(String message) {
    Get.snackbar(
      "Login Gagal",
      message,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 2),
      borderRadius: 12,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  /// ============================
  /// SNACKBAR SUCCESS
  /// ============================
  void _showSuccess(String message) {
    Get.snackbar(
      "Berhasil",
      message,
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 2),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }
}
