import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StasiunPage extends StatefulWidget {
  const StasiunPage({super.key});

  @override
  State<StasiunPage> createState() => _StasiunPageState();
}

class _StasiunPageState extends State<StasiunPage> {
  final api = ApiService();
  List<dynamic> stasiun = [];

  @override
  void initState() {
    super.initState();
    loadStasiun();
  }

  Future<void> loadStasiun() async {
    final data = await api.getStasiun();
    setState(() => stasiun = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Stasiun Sepeda')),
      body: stasiun.isEmpty
          ? const Center(child: Text('Tidak ada data stasiun'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (_, i) {
                final s = stasiun[i];
                return ListTile(
                  title: Text(s['nama_stasiun'] ??
                      'Stasiun #${s['id_stasiun'] ?? i + 1}'),
                  subtitle: Text(s['alamat_stasiun'] ?? '-'),
                  trailing: Text('Kapasitas: ${s['kapasitas_dock'] ?? '-'}'),
                );
              },
              separatorBuilder: (_, __) => const Divider(),
              itemCount: stasiun.length,
            ),
    );
  }
}
