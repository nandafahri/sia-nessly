import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // static const String baseUrl = "http://192.168.1.3:8000/api"; //real device
  static const String baseUrl = "http://10.0.2.2:8000/api"; //emulator

  static Map<String, String> authHeader(String token) => {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      };

  // UNIVERSAL GET REQUEST
  static Future<Map<String, dynamic>> getRequest(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");

    final response = await http.get(url, headers: {
      "Accept": "application/json",
    });

    return jsonDecode(response.body);
  }

  // UNIVERSAL POST REQUEST
  static Future<Map<String, dynamic>> postRequest(
      String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse("$baseUrl$endpoint");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

// UNIVERSAL PUT REQUEST
  static Future<Map<String, dynamic>> putRequest(
      String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse("$baseUrl$endpoint");

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

// UNIVERSAL DELETE REQUEST
  static Future<Map<String, dynamic>> deleteRequest(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");

    final response = await http.delete(
      url,
      headers: {
        "Accept": "application/json",
      },
    );

    return jsonDecode(response.body);
  }

  // ================================
  // LOGIN SISWA
  // ================================
  static Future<Map<String, dynamic>> loginSiswa({
    required String nisn,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/login-siswa");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nisn": nisn, "password": password}),
    );
    return {
      "statusCode": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }

  // ================================
  // PESAN HARI INI
  // ================================

  static Future<Map<String, dynamic>> getPesanHarian() async {
    return await getRequest("/pesan-hari-ini");
  }

  // ================================
  // ABSENSI SISWA
  // ================================
  static Future<Map<String, dynamic>> getAbsensi(
      String nisn, String token) async {
    final url = Uri.parse("$baseUrl/absensi/$nisn");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    return {
      "statusCode": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }

  // ================================
  // JADWAL PELAJARAN
  // ================================
  static Future<List<dynamic>> getJadwal(String kelasId) async {
    final url = Uri.parse("$baseUrl/jadwal?kelas_id=$kelasId");

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Gagal memuat jadwal. Status: ${response.statusCode}");
    }

    return jsonDecode(response.body);
  }

  // ================================
  // NILAI SISWA
  // ================================
  static Future<List<dynamic>> getNilai(int siswaId) async {
    final url = Uri.parse("$baseUrl/nilai?siswa_id=$siswaId");

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Gagal memuat nilai. Status: ${response.statusCode}");
    }

    final body = jsonDecode(response.body);
    return body["data"] ?? [];
  }

  static Future<List<dynamic>> getNilaiAkhir(int siswaId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/nilai-akhir?siswa_id=$siswaId"),
      headers: {
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body["data"];
    } else {
      throw Exception("Gagal memuat nilai akhir");
    }
  }

  // ================================
  // NOTIFIKASI
  // ================================
  static Future<List<dynamic>> getNotifications() async {
    final response = await getRequest("/notifikasi");
    return response["data"] ?? [];
  }

  // // Ambil profil siswa
  // static Future<Map<String, dynamic>> getProfile(String nisn) async {
  //   final url = Uri.parse("$baseUrl/siswa/profile/$nisn");

  //   final response = await http.get(url);

  //   return json.decode(response.body);
  // }

  // Logout siswa
  static Future<bool> logout(String nisn) async {
    final url = Uri.parse("$baseUrl/siswa/logout");

    final response = await http.post(url, body: {"nisn": nisn});

    return response.statusCode == 200;
  }

  static Future<http.Response> updateEmail(String nisn, String email) {
    final url = Uri.parse("$baseUrl/siswa/update-email");
    return http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nisn": nisn, "email": email}),
    );
  }

  // ================================
// GANTI PASSWORD SISWA
// ================================
  static Future<http.Response> changePassword({
    required String nisn,
    required String oldPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse("$baseUrl/siswa/change-password");

    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nisn": nisn,
        "old_password": oldPassword,
        "new_password": newPassword,
      }),
    );
  }

  // ================================
// VERIFIKASI AKUN (EMAIL + TELEPON)
// ================================
  static Future<Map<String, dynamic>> verifyAccount({
    required String email,
    required String nomorTelepon,
  }) async {
    final url = Uri.parse("$baseUrl/siswa/verify");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "nomor_telepon": nomorTelepon,
      }),
    );

    return {
      "statusCode": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }

  // ================================
// GET TOKEN DARI LOCAL STORAGE
// ================================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

// ================================
// SUBMIT ABSENSI QR
// ================================
  static Future<Map<String, dynamic>> submitAbsensi(String tokenQr) async {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "message": "Token tidak ditemukan"};
    }

    final url = Uri.parse("$baseUrl/absen/$tokenQr");

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return {
      "statusCode": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }

  // ================================
// STATUS ABSENSI SISWA (FINAL)
// ================================

  static Future<int> getJumlahAbsenHariIni(String nisn) async {
    try {
      final token = await getToken();
      if (token == null) return 0;

      final url = Uri.parse("$baseUrl/status/jumlah-absensi/$nisn");

      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode != 200) return 0;

      final body = jsonDecode(response.body);
      return body["jumlah"] ?? 0;
    } catch (e) {
      debugPrint("ERROR getJumlahAbsenHariIni: $e");
      return 0;
    }
  }

  static Future<int> getJumlahMapelHariIni(String nisn) async {
    try {
      final token = await getToken();
      if (token == null) return 0;

      final url = Uri.parse("$baseUrl/status/jumlah-jadwal/$nisn");

      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode != 200) return 0;

      final body = jsonDecode(response.body);
      return body["jumlah"] ?? 0;
    } catch (e) {
      debugPrint("ERROR getJumlahMapelHariIni: $e");
      return 0;
    }
  }
}
