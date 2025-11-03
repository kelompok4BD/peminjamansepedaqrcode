class Peminjaman {
  final String kodeSepeda;
  final String tanggalPinjam;

  Peminjaman({required this.kodeSepeda, required this.tanggalPinjam});

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    return Peminjaman(
      kodeSepeda: json['kode_sepeda'],
      tanggalPinjam: json['tanggal_pinjam'],
    );
  }
}
