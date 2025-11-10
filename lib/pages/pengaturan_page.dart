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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Pengaturan Sistem',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF002D72),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: pengaturan.isEmpty
            ? const Center(
                child: Text(
                  'Tidak ada data pengaturan',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pengaturan.length,
                itemBuilder: (_, i) {
                  final p = pengaturan[i];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pengaturan #${p['id_pengaturan'] ?? i + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF002D72),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _infoRow(Icons.access_time, 'Batas waktu pinjam',
                              '${p['batas_waktu_pinjam'] ?? '-'} jam'),
                          _infoRow(Icons.monetization_on, 'Tarif denda/jam',
                              'Rp ${p['tarif_denda_per_jam'] ?? '-'}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
