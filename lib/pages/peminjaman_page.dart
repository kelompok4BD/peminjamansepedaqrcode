import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PeminjamanPage extends StatefulWidget {
  const PeminjamanPage({super.key});

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  final ApiService api = ApiService();
  List<dynamic> sepedaList = [];
  final TextEditingController namaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSepeda();
  }

  Future<void> loadSepeda() async {
    final data = await api.getAllSepeda();
    setState(() => sepedaList = data);
  }

  Future<void> tambahSepeda() async {
    if (namaController.text.isEmpty) return;
    final ok = await api.tambahSepeda(namaController.text);
    if (ok) {
      namaController.clear();
      loadSepeda();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Sepeda ditambahkan!')));
    }
  }

  Future<void> hapusSepeda(int id) async {
    final ok = await api.hapusSepeda(id);
    if (ok) {
      setState(() {
        sepedaList.removeWhere((item) => item['id'] == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sepeda berhasil dihapus!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus sepeda!')),
      );
    }
  }

  Future<void> ubahStatus(int id, String status) async {
    final newStatus = status == 'tersedia' ? 'dipinjam' : 'tersedia';
    final ok = await api.updateStatusPeminjaman(id, newStatus);
    if (ok) loadSepeda();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Sepeda")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: namaController,
                    decoration:
                        const InputDecoration(labelText: 'Nama Sepeda Baru'),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: tambahSepeda,
                  child: const Text("Tambah"),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sepedaList.length,
              itemBuilder: (context, index) {
                final s = sepedaList[index];
                final nama = s['nama_sepeda'] ?? 'Tidak ada nama';
                final status = s['status'] ?? 'tidak diketahui';

                return Card(
                  child: ListTile(
                    title: Text(nama),
                    subtitle: Text(
                      'Status: $status',
                      style: TextStyle(
                        color: status == 'tersedia'
                            ? Colors.green
                            : Colors.redAccent,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.swap_horiz),
                          onPressed: () => ubahStatus(s['id'], s['status']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => hapusSepeda(s['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
