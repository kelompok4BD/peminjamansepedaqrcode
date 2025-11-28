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
        automaticallyImplyLeading: false,
        title: const Text(
          'Daftar Stasiun Sepeda',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF1a237e),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A1428), Color(0xFF0f2342)],
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
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: stasiun.length,
                itemBuilder: (_, i) {
                  final s = stasiun[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.location_on, color: Color(0xFF6366F1), size: 24),
                      ),
                      title: Text(
                        s['nama_stasiun'] ?? 'Stasiun #${s['id_stasiun'] ?? i + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          s['alamat_stasiun'] ?? '-',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Kapasitas: ${s['kapasitas_dock'] ?? '-'}',
                          style: const TextStyle(
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
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
