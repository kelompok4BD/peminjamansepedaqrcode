class RiwayatPemeliharaan {
  final int id;
  final int idSepeda;
  final int? idPegawai;
  final String? tanggalMulai;
  final String? tanggalSelesai;
  final String? jenisPerbaikan;
  final dynamic biayaPerbaikan;
  final String? keterangan;

  RiwayatPemeliharaan({
    required this.id,
    required this.idSepeda,
    this.idPegawai,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.jenisPerbaikan,
    this.biayaPerbaikan,
    this.keterangan,
  });

  factory RiwayatPemeliharaan.fromJson(Map<String, dynamic> json) {
    return RiwayatPemeliharaan(
      id: json['id_pemeliharaan'] ?? 0,
      idSepeda: json['id_sepeda'] ?? 0,
      idPegawai: json['id_pegawai'],
      tanggalMulai: json['tanggal_mulai']?.toString(),
      tanggalSelesai: json['tanggal_selesai']?.toString(),
      jenisPerbaikan: json['jenis_perbaikan']?.toString(),
      biayaPerbaikan: json['biaya_perbaikan'],
      keterangan: json['ket_perbaikan']?.toString(),
    );
  }
}
