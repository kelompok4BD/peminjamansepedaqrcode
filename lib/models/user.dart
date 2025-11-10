class UserModel {
  final int id;
  final String nama;
  final String? emailKampus;
  final String? statusJaminan;
  final String? statusAkun;
  final String? jenisPengguna;
  final String? noHp;
  final String password;

  UserModel({
    required this.id,
    required this.nama,
    this.emailKampus,
    this.statusJaminan,
    this.statusAkun,
    this.jenisPengguna,
    this.noHp,
    required this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id_NIM_NIP'],
        nama: json['nama'],
        emailKampus: json['email_kampus'],
        statusJaminan: json['status_jaminan'],
        statusAkun: json['status_akun'],
        jenisPengguna: json['jenis_pengguna'],
        noHp: json['no_hp_pengguna'],
        password: json['password'],
      );

  Map<String, dynamic> toJson() => {
        'id_NIM_NIP': id,
        'nama': nama,
        'email_kampus': emailKampus,
        'status_jaminan': statusJaminan,
        'status_akun': statusAkun,
        'jenis_pengguna': jenisPengguna,
        'no_hp_pengguna': noHp,
        'password': password,
      };
}
