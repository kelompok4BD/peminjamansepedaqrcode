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
      appBar: AppBar(
        title: const Text(
          'Daftar Stasiun Sepeda',
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
        child: stasiun.isEmpty
            ? const Center(
                child: Text(
                  'Tidak ada data stasiun',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: stasiun.length,
                itemBuilder: (_, i) {
                  final s = stasiun[i];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF002D72),
                        child: Icon(Icons.location_on, color: Colors.white),
                      ),
                      title: Text(
                        s['nama_stasiun'] ??
                            'Stasiun #${s['id_stasiun'] ?? i + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF002D72),
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          s['alamat_stasiun'] ?? '-',
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Kapasitas: ${s['kapasitas_dock'] ?? '-'}',
                          style: const TextStyle(
                            color: Color(0xFF002D72),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
