import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sia_nessly/services/api_services.dart';

class HomeController extends GetxController {
  var nama = "".obs;
  var nisn = "".obs;
  var namaKelas = "".obs;
  var jenisKelamin = "".obs;
  var nomorTelepon = "".obs;
  var alamat = "".obs;
  var foto = "".obs;

  var judulPesan = "".obs;
  var isiPesan = "".obs;
  var isLoadingPesan = true.obs;

  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    getPesanHarian();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    nama.value = prefs.getString("nama") ?? "Pengguna";
    nisn.value = prefs.getString("nisn") ?? "";
    namaKelas.value = prefs.getString("nama_kelas") ?? "Belum Ditentukan";
    jenisKelamin.value = prefs.getString("jenis_kelamin") ?? "";
    nomorTelepon.value = prefs.getString("nomor_telepon") ?? "";
    alamat.value = prefs.getString("alamat") ?? "";
    foto.value = prefs.getString("foto") ?? "";
  }

  // ================================
  // MENGAMBIL PESAN HARIAN DARI API SERVICE
  // ================================
  Future<void> getPesanHarian() async {
    try {
      isLoadingPesan.value = true;

      final data = await ApiService.getPesanHarian();

      isiPesan.value = data["pesan"] ?? "-";
      judulPesan.value = "Pesan Hari Ini";

      isLoadingPesan.value = false;
    } catch (e) {
      isLoadingPesan.value = false;
      Get.snackbar("Error", "Gagal memuat pesan harian");
    }
  }

  void changeIndex(int i) {
    currentIndex.value = i;
  }
}
