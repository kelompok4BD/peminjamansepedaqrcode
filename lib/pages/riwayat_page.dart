import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/riwayat_pemeliharaan.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final api = ApiService();
  List<RiwayatPemeliharaan> riwayat = [];

  @override
  void initState() {
    super.initState();
    loadRiwayat();
  }

  Future<void> loadRiwayat() async {
    final data = await api.getRiwayatPemeliharaan();

    setState(() {
      riwayat = data
          .map<RiwayatPemeliharaan>(
              (json) => RiwayatPemeliharaan.fromJson(json))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Pemeliharaan")),
      body: riwayat.isEmpty
          ? const Center(child: Text('Tidak ada data riwayat pemeliharaan'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: riwayat.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) {
                final r = riwayat[i];
                return ListTile(
                  title: Text(
                      'Sepeda ID: ${r.idSepeda} - ${r.jenisPerbaikan ?? '-'}'),
                  subtitle: Text(
                      'Mulai: ${r.tanggalMulai ?? '-'}\nSelesai: ${r.tanggalSelesai ?? '-'}'),
                  trailing: Text('Rp ${r.biayaPerbaikan ?? '-'}'),
                );
              },
            ),
    );
  }
}
