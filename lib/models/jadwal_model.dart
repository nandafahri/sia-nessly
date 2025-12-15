class JadwalModel {
  final int id;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final String namaMapel;
  final String namaKelas;
  final bool qrActive;
  final String? qrUrl;
  final String? qrExpiredAt;

  JadwalModel({
    required this.id,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.namaMapel,
    required this.namaKelas,
    required this.qrActive,
    this.qrUrl,
    this.qrExpiredAt,
  });

  factory JadwalModel.fromJson(Map<String, dynamic> json) {
    return JadwalModel(
      id: json["id"] ?? 0,
      hari: json["hari"] ?? "-",
      jamMulai: json["jam_mulai"] ?? "-",
      jamSelesai: json["jam_selesai"] ?? "-",

      // SAFE ACCESS
      namaMapel: json["mapel"]?["nama"] ?? "Mata Pelajaran Tidak Dikenal",
      namaKelas: json["kelas"]?["nama"] ?? "-",

      qrActive: json["qr_active"] ?? false,
      qrUrl: json["qr_url"],
      qrExpiredAt: json["qr_expired_at"],
    );
  }
}
