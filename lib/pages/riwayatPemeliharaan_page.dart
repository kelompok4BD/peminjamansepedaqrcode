import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/riwayat_pemeliharaan.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  // --- LOGIKA (TIDAK DIUBAH) ---
  final api = ApiService();
  List<RiwayatPemeliharaan> riwayat = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    loadRiwayat();
  }

  Future<void> loadRiwayat() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await api.getRiwayatPemeliharaan();
      setState(() {
        riwayat = data
            .map<RiwayatPemeliharaan>(
                (json) => RiwayatPemeliharaan.fromJson(json))
            .toList();
      });
    } catch (e) {
      setState(() {
        riwayat = [];
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // --- WARNA TEMA ---
  final pinkNeon = const Color(0xFFFF007F);
  final darkPink = const Color(0xFF880E4F);
  final blackBg = const Color(0xFF000000);
  final darkCherry = const Color(0xFF25000B);

  // --- TAMPILAN UI (TEMA BLACK PINK) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar Gradient Hitam ke Pink Gelap
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Riwayat Pemeliharaan",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [blackBg, darkPink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      
      // Body Gradient Hitam ke Cherry Gelap
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [blackBg, darkCherry],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _loading
            ? Center(child: CircularProgressIndicator(color: pinkNeon))
            : (_error != null)
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                            const SizedBox(height: 8),
                            const Text('Gagal memuat data:',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 6),
                            Text(_error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: loadRiwayat,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Muat ulang'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pinkNeon,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : riwayat.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada data riwayat pemeliharaan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: loadRiwayat,
                        color: pinkNeon,
                        backgroundColor: Colors.grey[900],
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: riwayat.length,
                          itemBuilder: (_, i) {
                            final r = riwayat[i];
                            
                            // Card Riwayat Glassmorphism
                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05), // Transparan
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.1), width: 1.0),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Sepeda ID: ${r.idSepeda}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          _formatCurrency(r.biayaPerbaikan),
                                          style: const TextStyle(
                                            color: Colors.greenAccent, // Uang tetap hijau agar kontras
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    _infoRow(Icons.build, 'Jenis Perbaikan', r.jenisPerbaikan ?? '-'),
                                    _infoRow(Icons.calendar_today, 'Mulai', _formatDate(r.tanggalMulai)),
                                    _infoRow(Icons.check_circle, 'Selesai', _formatDate(r.tanggalSelesai)),
                                    const SizedBox(height: 6),
                                    _infoRow(Icons.person, 'ID Pegawai', r.idPegawai?.toString() ?? '-'),
                                    if ((r.keterangan ?? '').isNotEmpty)
                                      _infoRow(Icons.note, 'Keterangan', r.keterangan ?? '-'),
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

  // --- HELPER WIDGETS & FORMATTERS ---

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic v) {
    if (v == null) return '-';
    try {
      final num value = (v is String) ? num.parse(v) : v as num;
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

  String _formatDate(String? s) {
    if (s == null || s.isEmpty) return '-';
    try {
      final dt = DateTime.parse(s);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return s;
    }
  }
}