import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PengaturanUserPage extends StatefulWidget {
  const PengaturanUserPage({super.key});

  @override
  State<PengaturanUserPage> createState() => _PengaturanUserPageState();
}

class _PengaturanUserPageState extends State<PengaturanUserPage> {
  final api = ApiService();
  Map<String, dynamic>? pengaturan;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    loadPengaturan();
  }

  Future<void> loadPengaturan() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await api.getPengaturan();
      // take the first entry if exists
      setState(() => pengaturan = data.isNotEmpty ? data.first : null);
    } catch (e) {
      setState(() {
        pengaturan = null;
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    final s = v.toString();
    final i = int.tryParse(s);
    if (i != null) return i;
    final d = double.tryParse(s.replaceAll(',', '.'));
    if (d != null) return d.toInt();
    return 0;
  }

  String _formatCurrency(dynamic v) {
    if (v == null) return '-';
    try {
      final num value = (v is num) ? v : num.parse(v.toString().replaceAll(',', '.'));
      final s = value.toInt().toString();
      String rev = s.split('').reversed.join();
      final parts = <String>[];
      for (int i = 0; i < rev.length; i += 3) {
        parts.add(rev.substring(i, (i + 3).clamp(0, rev.length)));
      }
      final joined = parts.map((p) => p.split('').reversed.join()).toList().reversed.join('.');
      return 'Rp $joined';
    } catch (_) {
      return v.toString();
    }
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Pengaturan'),
        backgroundColor: const Color(0xFF002D72),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_error != null)
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 8),
                          const Text('Gagal memuat pengaturan', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: loadPengaturan,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Muat ulang'),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002D72)),
                          ),
                        ],
                      ),
                    ),
                  )
                : (pengaturan == null)
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.info_outline, size: 48, color: Colors.orange.shade700),
                              const SizedBox(height: 8),
                              const Text('Pengaturan tidak tersedia', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              const Text('Data pengaturan sistem belum dimasukkan ke database.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: loadPengaturan,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Muat ulang'),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002D72)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: loadPengaturan,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Pengaturan Sistem', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF002D72))),
                                    const SizedBox(height: 12),
                                    _infoRow(Icons.access_time, 'Batas waktu pinjam', '${_parseInt(pengaturan!['batas_waktu_pinjam'])} jam'),
                                    _infoRow(Icons.monetization_on, 'Tarif denda/jam', _formatCurrency(pengaturan!['tarif_denda_per_jam'])),
                                    _infoRow(Icons.phone, 'Kontak darurat', pengaturan!['informasi_kontak_darurat']?.toString() ?? '-'),
                                    _infoRow(Icons.location_on, 'Batas wilayah (GPS)', pengaturan!['batas_wilayah_gps']?.toString() ?? '-'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }
}
