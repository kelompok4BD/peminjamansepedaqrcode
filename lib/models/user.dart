class User {
  final int id;
  final String nim;
  final String nama;

  User({required this.id, required this.nim, required this.nama});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], nim: json['nim'], nama: json['nama']);
  }
}
