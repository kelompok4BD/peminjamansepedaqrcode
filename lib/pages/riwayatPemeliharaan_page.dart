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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Riwayat Pemeliharaan",
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
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 8),
                          Text(
                            'Gagal memuat data:',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: loadRiwayat,
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
                : riwayat.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada data riwayat pemeliharaan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                    onRefresh: loadRiwayat,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: riwayat.length,
                      itemBuilder: (_, i) {
                        final r = riwayat[i];
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Sepeda ID: ${r.idSepeda}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF002D72),
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      _formatCurrency(r.biayaPerbaikan),
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _infoRow(Icons.build, 'Jenis Perbaikan',
                                    r.jenisPerbaikan ?? '-'),
                                _infoRow(Icons.calendar_today, 'Mulai',
                                    _formatDate(r.tanggalMulai)),
                                _infoRow(Icons.check_circle, 'Selesai',
                                    _formatDate(r.tanggalSelesai)),
                                const SizedBox(height: 6),
                                _infoRow(Icons.person, 'ID Pegawai',
                                    r.idPegawai?.toString() ?? '-'),
                                if ((r.keterangan ?? '').isNotEmpty)
                                  _infoRow(Icons.note, 'Keterangan',
                                      r.keterangan ?? '-'),
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
