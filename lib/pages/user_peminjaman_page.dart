import 'package:flutter/material.dart';
import '../services/api_service.dart';
// import '../theme/app_theme.dart'; // Hapus jika tidak digunakan
import 'detail_pinjam_page.dart';

class UserPeminjamanPage extends StatefulWidget {
  final String userId;
  final int? stasiunId;
  final String? stasiunName;

  const UserPeminjamanPage({
    super.key,
    required this.userId,
    this.stasiunId,
    this.stasiunName,
  });

  @override
  State<UserPeminjamanPage> createState() => _UserPeminjamanPageState();
}

class _UserPeminjamanPageState extends State<UserPeminjamanPage> {
  // --- LOGIKA (TIDAK DIUBAH) ---
  final ApiService api = ApiService();
  List<Map<String, dynamic>> sepedaList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSemuaSepeda();
  }

  Future<void> fetchSemuaSepeda() async {
    setState(() => isLoading = true);
    final allSepeda = await api.getAllSepeda();

    // Filter by stasiun if stasiunId is provided
    List<Map<String, dynamic>> filtered = [];
    if (widget.stasiunId != null) {
      filtered =
          allSepeda.where((s) => s['id_stasiun'] == widget.stasiunId).toList();
    } else {
      filtered = allSepeda;
    }

    // Only show bikes with status "Tersedia"
    sepedaList = filtered
        .where((s) =>
            (s['status_saat_ini'] ?? s['status'] ?? '')
                .toString()
                .toLowerCase() ==
            'tersedia')
        .toList();

    setState(() => isLoading = false);
  }

  Future<void> handlePinjam(Map<String, dynamic> sepeda) async {
    final dynamic rawId = sepeda['id_sepeda'] ??
        sepeda['id'] ??
        sepeda['idSepeda'] ??
        sepeda['ID'];
    final resolvedId = int.tryParse(rawId?.toString() ?? '') ?? 0;

    print('🟢 Navigate -> DetailPinjamPage; sepeda object: $sepeda');
    print('   Resolved sepeda id: raw=$rawId parsed=$resolvedId');

    if (resolvedId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ ID sepeda tidak valid, coba lagi')),
      );
      return;
    }

    final normalizedSepeda = {...sepeda, 'id_sepeda': resolvedId};

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPinjamPage(
          userId: widget.userId,
          sepeda: normalizedSepeda,
        ),
      ),
    );

    // Jika berhasil pinjam (result == true), refresh list
    if (result == true && mounted) {
      print('✅ Peminjaman berhasil, refresh list');
      await fetchSemuaSepeda();
    }
  }

  // --- WARNA TEMA ---
  final pinkNeon = const Color(0xFFFF007F);
  final darkPink = const Color(0xFF880E4F);
  final blackBg = const Color(0xFF000000);
  final darkCherry = const Color(0xFF25000B);

  // --- WARNA KARTU & ICON (DARK THEME) ---
  Color _getCardBorderColor(String status) {
    switch (status.toLowerCase()) {
      case 'tersedia':
        return Colors.greenAccent; // Border hijau neon jika tersedia
      case 'dipinjam':
        return Colors.redAccent; // Border merah jika dipinjam
      default:
        return Colors.grey;
    }
  }

  Color _getIconColor(String status) {
    switch (status.toLowerCase()) {
      case 'tersedia':
        return Colors.greenAccent;
      case 'dipinjam':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  // --- TAMPILAN UI (TEMA BLACK PINK) ---
  @override
  Widget build(BuildContext context) {
    final titleText = widget.stasiunName != null
        ? 'Sepeda - ${widget.stasiunName}'
        : 'Peminjaman Sepeda';

    return Scaffold(
      extendBody: true,
      // AppBar Gradient Hitam ke Pink Gelap
      appBar: AppBar(
        automaticallyImplyLeading: widget.stasiunId != null,
        iconTheme:
            const IconThemeData(color: Colors.white), // Tombol back putih
        title: Text(titleText,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white)),
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
                child:
                    CircularProgressIndicator(color: pinkNeon)) // Loading Pink
            : sepedaList.isEmpty
                ? const Center(
                    child: Text('Tidak ada data sepeda',
                        style: TextStyle(color: Colors.white70)))
                : RefreshIndicator(
                    onRefresh: fetchSemuaSepeda,
                    color: pinkNeon,
                    backgroundColor: Colors.grey[900],
                    child: ListView.builder(
                      itemCount: sepedaList.length,
                      itemBuilder: (context, index) {
                        final sepeda = sepedaList[index];
                        final status = (sepeda['status_saat_ini'] ??
                                sepeda['status'] ??
                                '-')
                            .toString();

                        // Card Glassmorphism
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05), // Transparan
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color:
                                  _getCardBorderColor(status).withOpacity(0.3),
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
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getIconColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.pedal_bike,
                                color: _getIconColor(status),
                                size: 32,
                              ),
                            ),
                            title: Text(
                              sepeda['merk_model'] ??
                                  sepeda['merk'] ??
                                  'Sepeda',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white, // Judul Putih
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                    'Tahun: ${sepeda['tahun_pembelian'] ?? sepeda['tahun'] ?? '-'}',
                                    style:
                                        const TextStyle(color: Colors.white70)),
                                Text(
                                    'Perawatan: ${sepeda['status_perawatan'] ?? sepeda['kondisi'] ?? '-'}',
                                    style:
                                        const TextStyle(color: Colors.white70)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text('Status: ',
                                        style:
                                            TextStyle(color: Colors.white70)),
                                    Text(
                                      status,
                                      style: TextStyle(
                                        color: _getIconColor(status),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: status.toLowerCase() == 'tersedia'
                                ? ElevatedButton(
                                    onPressed: () => handlePinjam(sepeda),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.green, // Tombol Pinjam Hijau
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Pinjam'),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                        color:
                                            Colors.redAccent.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.redAccent
                                                .withOpacity(0.5))),
                                    child: const Text(
                                      'Dipinjam',
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
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
