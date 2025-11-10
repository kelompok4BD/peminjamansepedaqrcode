class PengaturanModel {
  final int idPengaturan;
  final int? idPegawai;
  final int? batasWaktuPinjam;
  final double? tarifDendaPerJam;
  final String? informasiKontakDarurat;
  final String? batasWilayahGps;

  PengaturanModel({
    required this.idPengaturan,
    this.idPegawai,
    this.batasWaktuPinjam,
    this.tarifDendaPerJam,
    this.informasiKontakDarurat,
    this.batasWilayahGps,
  });

  factory PengaturanModel.fromJson(Map<String, dynamic> json) {
    return PengaturanModel(
      idPengaturan: json['id_pengaturan'],
      idPegawai: json['id_pegawai'],
      batasWaktuPinjam: json['batas_waktu_pinjam'],
      tarifDendaPerJam: (json['tarif_denda_per_jam'] != null)
          ? double.tryParse(json['tarif_denda_per_jam'].toString())
          : null,
      informasiKontakDarurat: json['informasi_kontak_darurat'],
      batasWilayahGps: json['batas_wilayah_gps'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id_pengaturan': idPengaturan,
        'id_pegawai': idPegawai,
        'batas_waktu_pinjam': batasWaktuPinjam,
        'tarif_denda_per_jam': tarifDendaPerJam,
        'informasi_kontak_darurat': informasiKontakDarurat,
        'batas_wilayah_gps': batasWilayahGps,
      };
}
