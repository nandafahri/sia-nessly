class NilaiModel {
  final int id;
  final int mapelId;
  final String mapelNama;
  final String semester;
  final String tahunAjaran;
  final double nilaiAngka;
  final String nilaiHuruf;
  final String keterangan;

  NilaiModel({
    required this.id,
    required this.mapelId,
    required this.mapelNama,
    required this.semester,
    required this.tahunAjaran,
    required this.nilaiAngka,
    required this.nilaiHuruf,
    required this.keterangan,
  });

  factory NilaiModel.fromJson(Map<String, dynamic> json) {
    return NilaiModel(
      id: json['id'],
      mapelId: json['mapel']['id'], // ambil dari nested mapel
      mapelNama: json['mapel']['nama'], // ambil dari nested mapel
      semester: json['semester'],
      tahunAjaran: json['tahun_ajaran'],
      nilaiAngka: (json['nilai_angka'] as num).toDouble(),
      nilaiHuruf: json['nilai_huruf'],
      keterangan: json['keterangan'],
    );
  }
}
