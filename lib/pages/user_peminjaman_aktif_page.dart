import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UserPeminjamanAktifPage extends StatefulWidget {
  final String userId;

  const UserPeminjamanAktifPage({
    super.key,
    required this.userId,
  });

  @override
  State<UserPeminjamanAktifPage> createState() =>
      _UserPeminjamanAktifPageState();
}

class _UserPeminjamanAktifPageState extends State<UserPeminjamanAktifPage> {
  // --- LOGIKA (TIDAK DIUBAH SAMA SEKALI) ---
  final ApiService api = ApiService();
  List<Map<String, dynamic>> peminjamanAktif = [];
  bool isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    loadPeminjamanAktif();
  }

  Future<void> loadPeminjamanAktif() async {
    setState(() {
      isLoading = true;
      _error = null;
    });

    try {
      final allPeminjaman = await api.getPeminjaman();

      // Filter only active rentals (status: 'Dipinjam') and for this user
      final aktif = (allPeminjaman as List)
          .where((p) =>
              p['status_transaksi']?.toString().toLowerCase() == 'dipinjam' &&
              p['id_user']?.toString() == widget.userId.toString())
          .cast<Map<String, dynamic>>()
          .toList();

      setState(() {
        peminjamanAktif = aktif;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat peminjaman aktif: $e';
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- WARNA TEMA ---
  final pinkNeon = const Color(0xFFFF007F);
  final darkPink = const Color(0xFF880E4F);
  final blackBg = const Color(0xFF000000);
  final darkCherry = const Color(0xFF25000B);
  final darkBgDialog = const Color(0xFF1E1E1E);

  // --- DIALOG KONFIRMASI (TEMA DARK) ---
  Future<void> _selesaiPinjam(Map<String, dynamic> peminjaman) async {
    final idTransaksi = peminjaman['id_transaksi'] as int?;
    final idSepeda = peminjaman['id_sepeda'] as int?;

    if (idTransaksi == null || idSepeda == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Data transaksi tidak lengkap')),
      );
      return;
    }

    // Confirmation dialog with Dark Theme
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: darkBgDialog,
        title: const Text('Konfirmasi Pengembalian',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sepeda: ${peminjaman['merk_sepeda'] ?? 'N/A'}',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            const Text('Apakah Anda yakin ingin menyelesaikan peminjaman ini?',
                style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: pinkNeon, // Tombol Pink
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Selesai'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⏳ Memproses pengembalian...')),
      );
    }

    try {
      final result = await api.selesaiPinjam(idTransaksi, idSepeda);

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(result['message'] ?? '✅ Sepeda berhasil dikembalikan'),
            backgroundColor: Colors.green,
          ),
        );
        await loadPeminjamanAktif();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '❌ ${result['message'] ?? 'Gagal menyelesaikan peminjaman'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- TAMPILAN UI (TEMA BLACK PINK) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar Gradient Hitam ke Pink Gelap
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Peminjaman Aktif',
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
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(color: pinkNeon)) // Loading Pink
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.redAccent),
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: loadPeminjamanAktif,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: pinkNeon,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : peminjamanAktif.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline,
                                  size: 48, color: pinkNeon.withOpacity(0.7)),
                              const SizedBox(height: 12),
                              const Text(
                                'Tidak ada peminjaman aktif',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: loadPeminjamanAktif,
                        color: pinkNeon,
                        backgroundColor: Colors.grey[900],
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: peminjamanAktif.length,
                          itemBuilder: (context, index) {
                            final peminjaman = peminjamanAktif[index];
                            final waktuPinjam =
                                peminjaman['waktu_pinjam'] ?? '-';

                            // --- CARD PEMINJAMAN (GLASSMORPHISM) ---
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05), // Transparan
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: pinkNeon.withOpacity(0.3), // Border Pink Tipis
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.pedal_bike,
                                            color: pinkNeon, size: 24),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                peminjaman['merk_sepeda'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              // QR Code
                                              if ((peminjaman['kode_qr'] ?? '')
                                                  .toString()
                                                  .isNotEmpty)
                                                Row(
                                                  children: [
                                                    // Container Putih khusus QR agar bisa discan
                                                    Container(
                                                      padding: const EdgeInsets.all(4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white, 
                                                        borderRadius: BorderRadius.circular(4)
                                                      ),
                                                      child: QrImageView(
                                                        data: peminjaman['kode_qr']?.toString() ?? '',
                                                        version: QrVersions.auto,
                                                        size: 60.0, // Sedikit diperkecil agar pas
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Flexible(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            'Kode QR:',
                                                            style: TextStyle(color: Colors.white54, fontSize: 10),
                                                          ),
                                                          Text(
                                                            peminjaman['kode_qr']?.toString() ?? '',
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              else
                                                const Text(
                                                  'QR: N/A',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        // Badge Status
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: pinkNeon.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: pinkNeon,
                                            ),
                                          ),
                                          child: Text(
                                            'Dipinjam',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: pinkNeon,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // Info Waktu
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.access_time, color: Colors.white70, size: 16),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Waktu Pinjam',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white54,
                                                ),
                                              ),
                                              Text(
                                                waktuPinjam.toString(),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // Tombol Selesai (Button Gradient Pink)
                                    SizedBox(
                                      width: double.infinity,
                                      height: 45,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [darkPink, pinkNeon],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(25), // Pill shape
                                          boxShadow: [
                                            BoxShadow(
                                              color: pinkNeon.withOpacity(0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            )
                                          ]
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: () => _selesaiPinjam(peminjaman),
                                          icon: const Icon(Icons.check_circle, color: Colors.white),
                                          label: const Text('Selesai Pinjam'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(25),
                                            ),
                                          ),
                                        ),
                                      ),
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
}