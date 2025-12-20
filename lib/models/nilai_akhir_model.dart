class NilaiAkhirModel {
  final int id;
  final int mapelId;
  final String mapelNama;
  final String semester;
  final String tahunAjaran;
  final double nilaiHarian;
  final double nilaiUts;
  final double nilaiUas;
  final double nilaiAkhir;
  final String nilaiHuruf;

  NilaiAkhirModel({
    required this.id,
    required this.mapelId,
    required this.mapelNama,
    required this.semester,
    required this.tahunAjaran,
    required this.nilaiHarian,
    required this.nilaiUts,
    required this.nilaiUas,
    required this.nilaiAkhir,
    required this.nilaiHuruf,
  });

  factory NilaiAkhirModel.fromJson(Map<String, dynamic> json) {
    return NilaiAkhirModel(
      id: json['id'],
      mapelId: json['mapel']['id'],
      mapelNama: json['mapel']['nama'],
      semester: json['semester'],
      tahunAjaran: json['tahun_ajaran'],
      nilaiHarian: double.parse(json['nilai_harian'].toString()),
      nilaiUts: double.parse(json['nilai_uts'].toString()),
      nilaiUas: double.parse(json['nilai_uas'].toString()),
      nilaiAkhir: double.parse(json['nilai_akhir'].toString()),
      nilaiHuruf: json['nilai_huruf'],
    );
  }
}
