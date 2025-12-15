class AbsensiItem {
  final String tanggal;
  final String jam;
  final String status;
  final String mapel;
  final String kelas;

  AbsensiItem({
    required this.tanggal,
    required this.jam,
    required this.status,
    required this.mapel,
    required this.kelas,
  });

  factory AbsensiItem.fromJson(Map<String, dynamic> json) {
    return AbsensiItem(
      tanggal: json['tanggal'] ?? '-',
      jam: json['jam'] ?? '-',
      status: json['status'] ?? '-',
      mapel: json['mapel'] ?? '-',
      kelas: json['kelas'] ?? '-',
    );
  }
}

class AbsensiResponse {
  final AbsensiItem today;
  final List<AbsensiItem> riwayat;

  AbsensiResponse({
    required this.today,
    required this.riwayat,
  });

  factory AbsensiResponse.fromJson(Map<String, dynamic> json) {
    return AbsensiResponse(
      today: AbsensiItem.fromJson(json['today']),
      riwayat: (json['riwayat'] as List)
          .map((e) => AbsensiItem.fromJson(e))
          .toList(),
    );
  }
}
