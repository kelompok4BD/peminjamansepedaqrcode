import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminPeminjamanPage extends StatefulWidget {
  const AdminPeminjamanPage({super.key});

  @override
  State<AdminPeminjamanPage> createState() => _AdminPeminjamanPageState();
}

class _AdminPeminjamanPageState extends State<AdminPeminjamanPage> {
  final ApiService api = ApiService();
  List<Map<String, dynamic>> peminjaman = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadPeminjaman();
  }

  Future<void> loadPeminjaman() async {
    setState(() => loading = true);
    final data = await api.getPeminjaman();
    setState(() {
      peminjaman = data;
      loading = false;
    });
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.green[100]!;
      case 'dipinjam':
        return Colors.orange[100]!;
      case 'batal':
        return Colors.red[100]!;
      default:
        return Colors.grey[200]!;
    }
  }

  Color getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.green[800]!;
      case 'dipinjam':
        return Colors.orange[800]!;
      case 'batal':
        return Colors.red[800]!;
      default:
        return Colors.grey[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Transaksi Peminjaman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
        child: loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
            : peminjaman.isEmpty
                ? const Center(child: Text('Belum ada transaksi peminjaman', style: TextStyle(color: Colors.white70)))
                : RefreshIndicator(
                    onRefresh: loadPeminjaman,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: peminjaman.length,
                      itemBuilder: (context, i) {
                        final p = peminjaman[i];
                        final idTransaksi = p['id_transaksi'] ?? '-';
                        final idSepeda = p['id_sepeda'] ?? '-';
                        final waktuPinjam = formatDate(p['waktu_pinjam']);
                        final waktuKembali = formatDate(p['waktu_kembali']);
                        final durasi = p['durasi']?.toString() ?? 'Tidak diketahui';
                        final metodeJaminan = p['metode_jaminan'] ?? 'Tidak ada';
                        final status = p['status_transaksi'] ?? 'Tidak diketahui';

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
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.pedal_bike, color: Color(0xFF6366F1)),
                                    const SizedBox(width: 8),
                                    Text('Transaksi #$idTransaksi', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: getStatusColor(status),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: getStatusTextColor(status),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20, color: Colors.white24),
                                _infoRow('ID Sepeda', idSepeda.toString()),
                                _infoRow('Durasi (menit)', durasi),
                                _infoRow('Metode Jaminan', metodeJaminan),
                                _infoRow('Waktu Pinjam', waktuPinjam),
                                if (waktuKembali != '-')
                                  _infoRow('Waktu Kembali', waktuKembali),
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
