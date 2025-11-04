import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  final api = ApiService();
  List<dynamic> pengaturan = [];

  @override
  void initState() {
    super.initState();
    loadPengaturan();
  }

  Future<void> loadPengaturan() async {
    final data = await api.getPengaturan();
    setState(() => pengaturan = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Sistem')),
      body: pengaturan.isEmpty
          ? const Center(child: Text('Tidak ada data pengaturan'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (_, i) {
                final p = pengaturan[i];
                return ListTile(
                  title: Text('Pengaturan #${p['id_pengaturan'] ?? i + 1}'),
                  subtitle: Text(
                      'Batas waktu pinjam: ${p['batas_waktu_pinjam'] ?? '-'} jam\nTarif denda/jam: ${p['tarif_denda_per_jam'] ?? '-'}'),
                );
              },
              separatorBuilder: (_, __) => const Divider(),
              itemCount: pengaturan.length,
            ),
    );
  }
}
