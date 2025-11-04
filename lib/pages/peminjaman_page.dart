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
  // Controllers for the add form (top of page)
  final TextEditingController addMerkController = TextEditingController();
  final TextEditingController addTahunController = TextEditingController();

  // Controllers for the edit dialog (separate to avoid accidental add)
  final TextEditingController editMerkController = TextEditingController();
  final TextEditingController editTahunController = TextEditingController();
  final TextEditingController editStatusController = TextEditingController();
  final TextEditingController editKondisiController = TextEditingController();
  final TextEditingController editKodeQRController = TextEditingController();
  @override
  void initState() {
    super.initState();
    loadSepeda();
  }

  Future<void> loadSepeda() async {
    final data = await api.getAllSepeda();
    setState(() => sepedaList = data);
  }

  // Dialog untuk edit sepeda (ditempatkan di level class supaya bisa dipanggil dari builder)
  Future<void> showEditDialog(Map<String, dynamic> sepeda) async {
    // Pre-fill controllers with existing data (use edit controllers)
    editMerkController.text = sepeda['merk'] ?? '';
    editTahunController.text = sepeda['tahun']?.toString() ?? '';
    editStatusController.text = sepeda['status'] ?? '';
    editKondisiController.text = sepeda['kondisi'] ?? '';
    editKodeQRController.text = sepeda['kode_qr'] ?? '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Data Sepeda'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editMerkController,
                decoration: const InputDecoration(labelText: 'Merk/Model'),
              ),
              TextField(
                controller: editTahunController,
                decoration: const InputDecoration(labelText: 'Tahun'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: editStatusController,
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              TextField(
                controller: editKondisiController,
                decoration: const InputDecoration(labelText: 'Kondisi'),
              ),
              TextField(
                controller: editKodeQRController,
                decoration: const InputDecoration(labelText: 'Kode QR'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await api.editSepeda(
                sepeda['id'],
                editMerkController.text,
                int.tryParse(editTahunController.text) ?? DateTime.now().year,
                editStatusController.text,
                editKondisiController.text,
                editKodeQRController.text,
              );

              if (success) {
                loadSepeda();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Data sepeda berhasil diperbarui!')),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Gagal memperbarui data sepeda')),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    // Clear edit controllers after dialog is closed
    editMerkController.clear();
    editTahunController.clear();
    editStatusController.clear();
    editKondisiController.clear();
    editKodeQRController.clear();
  }

  Future<void> tambahSepeda() async {
    if (addMerkController.text.isEmpty) return;
    final ok = await api.tambahSepeda(
      addMerkController.text,
      int.tryParse(addTahunController.text) ?? DateTime.now().year,
    );
    if (ok) {
      addMerkController.clear();
      addTahunController.clear();
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
    final newStatus =
        status.toString().toLowerCase() == 'tersedia' ? 'Dipinjam' : 'Tersedia';
    final ok = await api.updateStatusSepeda(id, newStatus);
    if (ok) loadSepeda();
  }

  @override
  void dispose() {
    // dispose both add and edit controllers
    addMerkController.dispose();
    addTahunController.dispose();
    editMerkController.dispose();
    editTahunController.dispose();
    editStatusController.dispose();
    editKondisiController.dispose();
    editKodeQRController.dispose();
    super.dispose();
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
                  flex: 2,
                  child: TextField(
                    controller: addMerkController,
                    decoration: const InputDecoration(
                      labelText: 'Merk/Model Sepeda',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: addTahunController,
                    decoration: const InputDecoration(
                      labelText: 'Tahun',
                    ),
                    keyboardType: TextInputType.number,
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
                final merk = s['merk'] ?? 'Tidak ada nama';
                final status = s['status'] ?? 'Tidak diketahui';
                final tahun = s['tahun']?.toString() ?? '-';
                final kondisi = s['kondisi'] ?? 'Tidak diketahui';

                return Card(
                  child: ListTile(
                    title: Text('$merk ($tahun)'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: $status',
                          style: TextStyle(
                            color: status.toLowerCase() == 'tersedia'
                                ? Colors.green
                                : Colors.redAccent,
                          ),
                        ),
                        Text('Kondisi: $kondisi'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => showEditDialog(s),
                        ),
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
