class StasiunModel {
  final int idStasiun;
  final String namaStasiun;
  final String alamatStasiun;
  final int kapasitasDock;
  final String koordinatGps;

  StasiunModel({
    required this.idStasiun,
    required this.namaStasiun,
    required this.alamatStasiun,
    required this.kapasitasDock,
    required this.koordinatGps,
  });

  factory StasiunModel.fromJson(Map<String, dynamic> json) => StasiunModel(
        idStasiun: json['id_stasiun'],
        namaStasiun: json['nama_stasiun'],
        alamatStasiun: json['alamat_stasiun'],
        kapasitasDock: json['kapasitas_dock'],
        koordinatGps: json['koordinat_gps'],
      );
}
