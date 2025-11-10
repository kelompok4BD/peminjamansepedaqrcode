import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_page.dart';

class UserPeminjamanPage extends StatefulWidget {
  final String userId;

  const UserPeminjamanPage({super.key, required this.userId});

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
    sepedaList = allSepeda;
    setState(() => isLoading = false);
  }

  Future<void> handlePinjam(int idSepeda) async {
    final idUser = int.tryParse(widget.userId) ?? 0;

    final res = await api.pinjamSepeda(idUser, idSepeda);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Peminjaman berhasil!')),
      );
      fetchSemuaSepeda();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('❌ ${res['message'] ?? 'Gagal meminjam sepeda'}')),
      );
    }
  }

  // 🔹 warna card berdasarkan status
  Color _getCardColor(String status) {
    switch (status.toLowerCase()) {
      case 'tersedia':
        return Colors.green[50]!;
      case 'dipinjam':
        return Colors.red[50]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getIconColor(String status) {
    switch (status.toLowerCase()) {
      case 'tersedia':
        return Colors.green;
      case 'dipinjam':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  void _kembaliKeLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Berhasil kembali ke login')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peminjaman Sepeda'),
        backgroundColor: Colors.blue[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _kembaliKeLogin(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
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
                                    'Tahun: ${sepeda['tahun_pembelian'] ?? sepeda['tahun'] ?? '-'}'),
                                Text(
                                    'Perawatan: ${sepeda['status_perawatan'] ?? sepeda['kondisi'] ?? '-'}'),
                                Text('Status: $status'),
                              ],
                            ),
                            trailing: status.toLowerCase() == 'tersedia'
                                ? ElevatedButton(
                                    onPressed: () =>
                                        handlePinjam(sepeda['id_sepeda']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text('Pinjam'),
                                  )
                                : const Text(
                                    'Dipinjam',
                                    style: TextStyle(
                                      color: Colors.redAccent,
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
