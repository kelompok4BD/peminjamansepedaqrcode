class Sepeda {
  final String kode;
  final bool tersedia;

  Sepeda({required this.kode, required this.tersedia});

  factory Sepeda.fromJson(Map<String, dynamic> json) {
    return Sepeda(kode: json['kode'], tersedia: json['tersedia'] == 1);
  }
}
