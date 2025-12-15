import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sia_nessly/services/api_services.dart';
import 'package:flutter/material.dart';

class ChangeEmailController extends GetxController {
  var loading = false.obs;
  var currentEmail = "".obs; // RxString untuk email realtime

  @override
  void onInit() {
    super.onInit();
    _loadEmail();
  }

  // Load email dari SharedPreferences saat init
  Future<void> _loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    currentEmail.value = prefs.getString("email") ?? "";
  }

  Future<void> updateEmail(String newEmail) async {
    newEmail = newEmail.trim();

    if (newEmail.isEmpty || !newEmail.contains("@")) {
      Get.snackbar(
        "Error",
        "Email tidak valid",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    loading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final nisn = prefs.getString("nisn");

      if (nisn == null) throw "NISN tidak ditemukan!";

      final response = await ApiService.updateEmail(nisn, newEmail);
      print("Response API: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["email"] != null) {
        // Update SharedPreferences
        await prefs.setString("email", newEmail);

        // Update RxString agar UI terupdate otomatis
        currentEmail.value = newEmail;

        // Panggil snackbar setelah frame build agar pasti muncul
        Future.delayed(Duration.zero, () {
          Get.snackbar(
            "Berhasil",
            data["message"] ?? "Email berhasil diperbarui!",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
        });

        Get.back();
      } else {
        Get.snackbar(
          "Gagal",
          data["message"] ?? "Terjadi kesalahan!",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      loading.value = false;
    }
  }
}
