class TransaksiPeminjamanModel {
  final int idTransaksi;
  final int? idSepeda;
  final DateTime? waktuPinjam;
  final DateTime? waktuKembali;
  final int? durasi;
  final String? statusTransaksi;
  final String? metodeJaminan;

  TransaksiPeminjamanModel({
    required this.idTransaksi,
    this.idSepeda,
    this.waktuPinjam,
    this.waktuKembali,
    this.durasi,
    this.statusTransaksi,
    this.metodeJaminan,
  });

  factory TransaksiPeminjamanModel.fromJson(Map<String, dynamic> json) =>
      TransaksiPeminjamanModel(
        idTransaksi: json['id_transaksi'],
        idSepeda: json['id_sepeda'],
        waktuPinjam: json['waktu_pinjam'] != null
            ? DateTime.parse(json['waktu_pinjam'])
            : null,
        waktuKembali: json['waktu_kembali'] != null
            ? DateTime.parse(json['waktu_kembali'])
            : null,
        durasi: json['durasi'],
        statusTransaksi: json['status_transaksi'],
        metodeJaminan: json['metode_jaminan'],
      );

  Map<String, dynamic> toJson() => {
        'id_transaksi': idTransaksi,
        'id_sepeda': idSepeda,
        'waktu_pinjam': waktuPinjam?.toIso8601String(),
        'waktu_kembali': waktuKembali?.toIso8601String(),
        'durasi': durasi,
        'status_transaksi': statusTransaksi,
        'metode_jaminan': metodeJaminan,
      };
}
