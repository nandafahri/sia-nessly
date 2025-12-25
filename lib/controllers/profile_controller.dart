// lib/controllers/profile_controller.dart

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  var nama = "".obs;
  var email = "".obs;
  var foto = "".obs;
  var namaKelas = "".obs;
  var nisn = "".obs;
  var jenisKelamin = "".obs;
  var nomorTelepon = "".obs;
  var alamat = "".obs;
  var tingkat = "".obs; // ✅ TAMBAHKAN

  @override
  void onInit() {
    super.onInit();
    loadLocalProfile();
  }

  Future<void> loadLocalProfile() async {
    final prefs = await SharedPreferences.getInstance();
    nisn.value = prefs.getString("nisn") ?? "";
    nama.value = prefs.getString("nama") ?? "";
    email.value = prefs.getString("email") ?? "";
    foto.value = prefs.getString("foto") ?? "";
    namaKelas.value = prefs.getString("nama_kelas") ?? "";
    jenisKelamin.value = prefs.getString("jenis_kelamin") ?? "";
    nomorTelepon.value = prefs.getString("nomor_telepon") ?? "";
    alamat.value = prefs.getString("alamat") ?? "";
    tingkat.value = prefs.getString("tingkat") ?? "-"; // ✅ AMBIL
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
