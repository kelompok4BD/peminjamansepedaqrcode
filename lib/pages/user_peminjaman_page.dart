import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
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
    if (widget.stasiunId != null) {
      sepedaList =
          allSepeda.where((s) => s['id_stasiun'] == widget.stasiunId).toList();
    } else {
      sepedaList = allSepeda;
    }

    setState(() => isLoading = false);
  }

  Future<void> handlePinjam(Map<String, dynamic> sepeda) async {
    // Resolve possible id fields and log the full object for debugging
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

  Color _getCardColor(String status) {
    switch (status.toLowerCase()) {
      case 'tersedia':
        return const Color(0xFF1B5E20); // dark green
      case 'dipinjam':
        return const Color(0xFF5F0000); // dark red
      default:
        return const Color(0xFF1A1A2E); // dark gray
    }
  }

  Color _getIconColor(String status) {
    switch (status.toLowerCase()) {
      case 'tersedia':
        return const Color(0xFF4CAF50); // lighter green for icon
      case 'dipinjam':
        return const Color(0xFFEF5350); // lighter red for icon
      default:
        return const Color(0xFF90A4AE); // lighter gray for icon
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.stasiunName != null
        ? 'Sepeda - ${widget.stasiunName}'
        : 'Peminjaman Sepeda';

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: widget.stasiunId != null,
        title: Text(titleText,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : sepedaList.isEmpty
                ? const Center(child: Text('Tidak ada data sepeda'))
                : RefreshIndicator(
                    onRefresh: fetchSemuaSepeda,
                    child: ListView.builder(
                      itemCount: sepedaList.length,
                      itemBuilder: (context, index) {
                        final sepeda = sepedaList[index];
                        final status = (sepeda['status_saat_ini'] ??
                                sepeda['status'] ??
                                '-')
                            .toString();

                        return Card(
                          color: _getCardColor(status),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.pedal_bike,
                              color: _getIconColor(status),
                              size: 40,
                            ),
                            title: Text(
                              sepeda['merk_model'] ??
                                  sepeda['merk'] ??
                                  'Sepeda',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Tahun: ${sepeda['tahun_pembelian'] ?? sepeda['tahun'] ?? '-'}',
                                    style: const TextStyle(
                                        color: AppColors.textSecondary)),
                                Text(
                                    'Perawatan: ${sepeda['status_perawatan'] ?? sepeda['kondisi'] ?? '-'}',
                                    style: const TextStyle(
                                        color: AppColors.textSecondary)),
                                Text('Status: $status',
                                    style: const TextStyle(
                                        color: AppColors.textPrimary)),
                              ],
                            ),
                            trailing: status.toLowerCase() == 'tersedia'
                                ? ElevatedButton(
                                    onPressed: () => handlePinjam(sepeda),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.success,
                                    ),
                                    child: const Text('Pinjam'),
                                  )
                                : const Text(
                                    'Dipinjam',
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.bold,
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
