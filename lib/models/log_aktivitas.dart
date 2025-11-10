class LogAktivitasModel {
  final int idLog;
  final int? idPegawai;
  final DateTime? waktuAktivitas;
  final String? jenisAktivitas;
  final String? deskripsiAktivitas;

  LogAktivitasModel({
    required this.idLog,
    this.idPegawai,
    this.waktuAktivitas,
    this.jenisAktivitas,
    this.deskripsiAktivitas,
  });

  factory LogAktivitasModel.fromJson(Map<String, dynamic> json) {
    return LogAktivitasModel(
      idLog: json['id_log'],
      idPegawai: json['id_pegawai'],
      waktuAktivitas: json['waktu_aktivitas'] != null
          ? DateTime.parse(json['waktu_aktivitas'])
          : null,
      jenisAktivitas: json['jenis_aktivitas'],
      deskripsiAktivitas: json['deskripsi_aktivitas'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id_log': idLog,
        'id_pegawai': idPegawai,
        'waktu_aktivitas': waktuAktivitas?.toIso8601String(),
        'jenis_aktivitas': jenisAktivitas,
        'deskripsi_aktivitas': deskripsiAktivitas,
      };
}
