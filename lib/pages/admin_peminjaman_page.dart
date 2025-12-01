import 'package:flutter/material.dart';
import '../services/api_service.dart';
// Hapus import theme lama jika error, karena kita akan pakai warna custom di sini
// import '../theme/app_theme.dart'; 

class AdminPeminjamanPage extends StatefulWidget {
  const AdminPeminjamanPage({super.key});

  @override
  State<AdminPeminjamanPage> createState() => _AdminPeminjamanPageState();
}

class _AdminPeminjamanPageState extends State<AdminPeminjamanPage> {
  // --- LOGIKA (TIDAK DIUBAH) ---
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

  // --- WARNA STATUS (DARK MODE) ---
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.greenAccent.withOpacity(0.2); // Transparan Neon
      case 'dipinjam':
        return Colors.orangeAccent.withOpacity(0.2);
      case 'batal':
        return Colors.redAccent.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  Color getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.greenAccent; // Neon Green
      case 'dipinjam':
        return Colors.orangeAccent; // Neon Orange
      case 'batal':
        return Colors.redAccent; // Neon Red
      default:
        return Colors.white70;
    }
  }

  // --- TAMPILAN UI (TEMA BLACK PINK) ---
  @override
  Widget build(BuildContext context) {
    // Definisi Warna Tema
    final pinkNeon = const Color(0xFFFF007F);
    final darkPink = const Color(0xFF880E4F);
    final blackBg = const Color(0xFF000000);
    final darkCherry = const Color(0xFF25000B);

    return Scaffold(
      // AppBar Gradient Hitam ke Pink Gelap
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Transaksi Peminjaman',
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
      // Body Gradient Hitam ke Cherry
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [blackBg, darkCherry],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: loading
            ? Center(child: CircularProgressIndicator(color: pinkNeon))
            : peminjaman.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada transaksi peminjaman',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: loadPeminjaman,
                    color: pinkNeon, // Loader warna Pink
                    backgroundColor: Colors.grey[900],
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

                        // Card Transaksi (Glassmorphism Dark)
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05), // Background transparan
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1), // Border tipis putih
                              width: 1.0,
                            ),
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
                                  children: [
                                    Icon(Icons.pedal_bike, color: pinkNeon), // Icon Pink
                                    const SizedBox(width: 8),
                                    Text(
                                      'Transaksi #$idTransaksi',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Spacer(),
                                    // Badge Status
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: getStatusColor(status),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: getStatusTextColor(status).withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: getStatusTextColor(status),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20, color: Colors.white12),
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

  // Helper Widget Row Info
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
                color: Colors.white.withOpacity(0.5), // Label abu-abu
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
                color: Colors.white, // Value putih
              ),
            ),
          ),
        ],
      ),
    );
  }
}