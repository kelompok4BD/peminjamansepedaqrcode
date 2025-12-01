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

  Future<void> _selesaiPinjam(Map<String, dynamic> peminjaman) async {
    final idTransaksi = peminjaman['id_transaksi'] as int?;
    final idSepeda = peminjaman['id_sepeda'] as int?;

    if (idTransaksi == null || idSepeda == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Data transaksi tidak lengkap')),
      );
      return;
    }

    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pengembalian'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sepeda: ${peminjaman['merk_sepeda'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            const Text('Apakah Anda yakin ingin menyelesaikan peminjaman ini?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Ya, Selesai'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Peminjaman Aktif',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF312e81)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF6366F1)))
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
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
                              backgroundColor: const Color(0xFF6366F1),
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
                                  size: 48, color: Colors.amber.shade700),
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
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: peminjamanAktif.length,
                          itemBuilder: (context, index) {
                            final peminjaman = peminjamanAktif[index];
                            final waktuPinjam =
                                peminjaman['waktu_pinjam'] ?? '-';

                            return Card(
                              color: Colors.white.withOpacity(0.05),
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.amber.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.pedal_bike,
                                            color: Colors.amber, size: 24),
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
                                              // Show QR code in white and its code string in white
                                              if ((peminjaman['kode_qr'] ?? '')
                                                  .toString()
                                                  .isNotEmpty)
                                                Row(
                                                  children: [
                                                    QrImageView(
                                                      data: peminjaman[
                                                                  'kode_qr']
                                                              ?.toString() ??
                                                          '',
                                                      version: QrVersions.auto,
                                                      size: 72.0,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Flexible(
                                                      child: Text(
                                                        peminjaman['kode_qr']
                                                                ?.toString() ??
                                                            '',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.amber.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                              color: Colors.amber,
                                            ),
                                          ),
                                          child: const Text(
                                            'Dipinjam',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.amber,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Waktu Pinjam:',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70,
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
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            _selesaiPinjam(peminjaman),
                                        icon: const Icon(Icons.check_circle),
                                        label: const Text('Selesai Pinjam'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
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
