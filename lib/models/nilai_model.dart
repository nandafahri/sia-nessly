class NilaiModel {
  final int id;
  final String semester;
  final String tahunAjaran;
  final int nilaiAngka;
  final String nilaiHuruf;
  final String keterangan;
  final String mapelNama;

  NilaiModel({
    required this.id,
    required this.semester,
    required this.tahunAjaran,
    required this.nilaiAngka,
    required this.nilaiHuruf,
    required this.keterangan,
    required this.mapelNama,
  });

  factory NilaiModel.fromJson(Map<String, dynamic> json) {
    return NilaiModel(
      id: json['id'],
      semester: json['semester'] ?? '-',
      tahunAjaran: json['tahun_ajaran'] ?? '-',
      nilaiAngka: json['nilai_angka'] ?? 0,
      nilaiHuruf: json['nilai_huruf'] ?? '-',
      keterangan: json['keterangan'] ?? '-',
      mapelNama: json['mapel']?['nama'] ?? 'Tidak diketahui',
    );
  }
}
