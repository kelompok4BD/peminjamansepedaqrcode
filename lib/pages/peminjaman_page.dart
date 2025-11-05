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

  final merkC = TextEditingController();
  final tahunC = TextEditingController();

  final editMerkC = TextEditingController();
  final editTahunC = TextEditingController();
  final editStatusC = TextEditingController();
  final editKondisiC = TextEditingController();
  final editKodeQRC = TextEditingController();

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
    if (merkC.text.isEmpty) return;
    final ok = await api.tambahSepeda(
      merkC.text,
      int.tryParse(tahunC.text) ?? DateTime.now().year,
    );
    if (ok) {
      merkC.clear();
      tahunC.clear();
      loadSepeda();
      _snack('Sepeda ditambahkan!');
    }
  }

  Future<void> hapusSepeda(int id) async {
    final ok = await api.hapusSepeda(id);
    if (ok) {
      sepedaList.removeWhere((s) => s['id'] == id);
      setState(() {});
      _snack('Sepeda berhasil dihapus!');
    }
  }

  Future<void> ubahStatus(int id, String status) async {
    final newStatus =
        status.toLowerCase() == 'tersedia' ? 'Dipinjam' : 'Tersedia';
    if (await api.updateStatusSepeda(id, newStatus)) loadSepeda();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> showEditDialog(Map<String, dynamic> s) async {
    editMerkC.text = s['merk'] ?? '';
    editTahunC.text = s['tahun']?.toString() ?? '';
    editStatusC.text = s['status'] ?? '';
    editKondisiC.text = s['kondisi'] ?? '';
    editKodeQRC.text = s['kode_qr'] ?? '';

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Data Sepeda',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF002D72))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field('Merk/Model', editMerkC),
            _field('Tahun', editTahunC, TextInputType.number),
            _field('Status', editStatusC),
            _field('Kondisi', editKondisiC),
            _field('Kode QR', editKodeQRC),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: _btnStyle(),
            onPressed: () async {
              final ok = await api.editSepeda(
                s['id'],
                editMerkC.text,
                int.tryParse(editTahunC.text) ?? DateTime.now().year,
                editStatusC.text,
                editKondisiC.text,
                editKodeQRC.text,
              );
              if (ok && mounted) {
                Navigator.pop(context);
                loadSepeda();
                _snack('Data sepeda diperbarui!');
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.blue[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  Widget _field(String label, TextEditingController c,
      [TextInputType? type]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        keyboardType: type,
        decoration: _inputDeco(label),
      ),
    );
  }

  ButtonStyle _btnStyle() => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF002D72),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Sepeda',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF002D72),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFFE3F2FD), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                                  controller: merkC,
                                  decoration:
                                      _inputDeco('Merk/Model Sepeda'))),
                          const SizedBox(width: 10),
                          Expanded(
                              child: TextField(
                                  controller: tahunC,
                                  decoration: _inputDeco('Tahun'),
                                  keyboardType: TextInputType.number)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton.icon(
                          style: _btnStyle(),
                          onPressed: tambahSepeda,
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Sepeda'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: sepedaList.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: sepedaList.length,
                      itemBuilder: (_, i) {
                        final s = sepedaList[i];
                        final status = s['status'] ?? 'Tidak diketahui';
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text('${s['merk']} (${s['tahun']})',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF002D72))),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Status: $status',
                                  style: TextStyle(
                                    color: status.toLowerCase() == 'tersedia'
                                        ? Colors.green
                                        : Colors.redAccent,
                                  ),
                                ),
                                Text('Kondisi: ${s['kondisi'] ?? '-'}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blueAccent),
                                    onPressed: () => showEditDialog(s)),
                                IconButton(
                                    icon: const Icon(Icons.swap_horiz,
                                        color: Colors.orange),
                                    onPressed: () =>
                                        ubahStatus(s['id'], s['status'])),
                                IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => hapusSepeda(s['id'])),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
