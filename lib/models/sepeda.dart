import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
    fetchSepedaTersedia();
  }

  Future<void> fetchSepedaTersedia() async {
    setState(() => isLoading = true);

    final allSepeda = await api.getAllSepeda();
    sepedaList = allSepeda
        .where((sepeda) =>
            sepeda['status_saat_ini'] == 'Tersedia' ||
            sepeda['status'] == 'Tersedia')
        .toList();

    setState(() => isLoading = false);
  }

  Future<void> handlePinjam(int idSepeda) async {
    final idUser = int.tryParse(widget.userId) ?? 0;

    final res = await api.pinjamSepeda(
      idUser,
      idSepeda,
    );

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Peminjaman berhasil!')),
      );
      fetchSepedaTersedia();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('❌ ${res['message'] ?? 'Gagal meminjam sepeda'}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peminjaman Sepeda'),
        backgroundColor: Colors.blue[800],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : sepedaList.isEmpty
              ? const Center(child: Text('Tidak ada sepeda tersedia 😢'))
              : ListView.builder(
                  itemCount: sepedaList.length,
                  itemBuilder: (context, index) {
                    final sepeda = sepedaList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.pedal_bike,
                            color: Colors.blueAccent, size: 40),
                        title: Text(
                          sepeda['merk_model'] ?? sepeda['merk'] ?? 'Sepeda',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Tahun: ${sepeda['tahun_pembelian'] ?? sepeda['tahun'] ?? '-'}'),
                            Text(
                                'Kondisi: ${sepeda['status_perawatan'] ?? sepeda['kondisi'] ?? '-'}'),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => handlePinjam(sepeda['id_sepeda']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Pinjam'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
