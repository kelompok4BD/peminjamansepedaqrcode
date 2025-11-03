import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/peminjaman.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final api = ApiService();
  List<Peminjaman> riwayat = [];

  @override
  void initState() {
    super.initState();
    loadRiwayat();
  }

  Future<void> loadRiwayat() async {
    final data = await api.getRiwayat();

    setState(() {
      riwayat =
          data.map<Peminjaman>((json) => Peminjaman.fromJson(json)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Peminjaman")),
      body: ListView.builder(
        itemCount: riwayat.length,
        itemBuilder: (_, i) {
          final r = riwayat[i];
          return ListTile(
            title: Text(r.kodeSepeda),
            subtitle: Text("Tanggal: ${r.tanggalPinjam}"),
          );
        },
      ),
    );
  }
}
