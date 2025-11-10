class LaporanKerusakanModel {
  final int idLaporan;
  final int? idSepeda;
  final int? idPegawai;
  final String? deskripsiKerusakan;
  final DateTime? tanggalLaporan;
  final String? statusPerbaikan;

  LaporanKerusakanModel({
    required this.idLaporan,
    this.idSepeda,
    this.idPegawai,
    this.deskripsiKerusakan,
    this.tanggalLaporan,
    this.statusPerbaikan,
  });

  factory LaporanKerusakanModel.fromJson(Map<String, dynamic> json) {
    return LaporanKerusakanModel(
      idLaporan: json['id_laporan'],
      idSepeda: json['id_sepeda'],
      idPegawai: json['id_pegawai'],
      deskripsiKerusakan: json['deskripsi_kerusakan'],
      tanggalLaporan: json['tanggal_laporan'] != null
          ? DateTime.parse(json['tanggal_laporan'])
          : null,
      statusPerbaikan: json['status_perbaikan'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id_laporan': idLaporan,
        'id_sepeda': idSepeda,
        'id_pegawai': idPegawai,
        'deskripsi_kerusakan': deskripsiKerusakan,
        'tanggal_laporan': tanggalLaporan?.toIso8601String(),
        'status_perbaikan': statusPerbaikan,
      };
}
