class RiwayatPemeliharaan {
  final int id;
  final int? idSepeda;
  final int? idPegawai;
  final String? tanggalMulai;
  final String? tanggalSelesai;
  final String? jenisPerbaikan;
  final int? biayaPerbaikan;
  final String? keterangan;

  RiwayatPemeliharaan({
    required this.id,
    this.idSepeda,
    this.idPegawai,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.jenisPerbaikan,
    this.biayaPerbaikan,
    this.keterangan,
  });

  factory RiwayatPemeliharaan.fromJson(Map<String, dynamic> json) {
    int _parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      final s = v.toString();
      // try integer parse first
      final i = int.tryParse(s);
      if (i != null) return i;
      // try parse as double then to int
      final d = double.tryParse(s.replaceAll(',', '.'));
      if (d != null) return d.toInt();
      return 0;
    }

    num? _parseNum(dynamic v) {
      if (v == null) return null;
      if (v is num) return v;
      final s = v.toString().replaceAll(',', '.');
      return double.tryParse(s);
    }

    return RiwayatPemeliharaan(
      id: _parseInt(json['id_pemeliharaan'] ?? json['id'] ?? 0),
      idSepeda: _parseInt(json['id_sepeda'] ?? json['idSepeda'] ?? 0),
      idPegawai: json['id_pegawai'] == null
          ? null
          : _parseInt(json['id_pegawai']),
      tanggalMulai: json['tanggal_mulai']?.toString(),
      tanggalSelesai: json['tanggal_selesai']?.toString(),
      jenisPerbaikan: json['jenis_perbaikan']?.toString(),
      biayaPerbaikan: _parseNum(json['biaya_perbaikan'] ?? json['biaya'] ?? json['cost'])?.toInt(),
      keterangan: json['ket_perbaikan']?.toString() ?? json['keterangan']?.toString(),
    );
  }
}
