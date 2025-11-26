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
      setState(() => pengaturan = data);
    } catch (e) {
      setState(() {
        pengaturan = [];
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_error != null)
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 8),
                          const Text(
                            'Gagal memuat pengaturan',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: loadPengaturan,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Muat ulang'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF002D72),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : pengaturan.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.info_outline,
                                  size: 48, color: Colors.orange.shade700),
                              const SizedBox(height: 8),
                              const Text(
                                'Belum ada data pengaturan',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Data pengaturan sistem belum dimasukkan ke database.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: loadPengaturan,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Muat ulang'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF002D72),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: loadPengaturan,
                        child: ListView.builder(
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
                                    _infoRow(
                                      Icons.person,
                                      'ID Pegawai',
                                      p['id_pegawai']?.toString() ?? '-',
                                    ),
                                    const SizedBox(height: 6),
                                    _infoRow(
                                      Icons.access_time,
                                      'Batas waktu pinjam',
                                      '${_parseInt(p['batas_waktu_pinjam'])} jam',
                                    ),
                                    const SizedBox(height: 6),
                                    _infoRow(
                                      Icons.monetization_on,
                                      'Tarif denda/jam',
                                      _formatCurrency(p['tarif_denda_per_jam']),
                                    ),
                                    const SizedBox(height: 6),
                                    _infoRow(
                                      Icons.phone,
                                      'Kontak darurat',
                                      p['informasi_kontak_darurat']?.toString() ?? '-',
                                    ),
                                    const SizedBox(height: 6),
                                    _infoRow(
                                      Icons.location_on,
                                      'Batas wilayah (GPS)',
                                      p['batas_wilayah_gps']?.toString() ?? '-',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
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
}
