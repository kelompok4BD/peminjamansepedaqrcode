import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class StasiunPage extends StatefulWidget {
  const StasiunPage({super.key});

  @override
  State<StasiunPage> createState() => _StasiunPageState();
}

class _StasiunPageState extends State<StasiunPage> {
  final api = ApiService();
  List<dynamic> stasiun = [];

  @override
  void initState() {
    super.initState();
    loadStasiun();
  }

  Future<void> loadStasiun() async {
    final data = await api.getAllStasiun();
    setState(() {
      stasiun = data;
    });
  }

  Future<void> _showEditDialog({Map<String, dynamic>? item}) async {
    final isNew = item == null;
    final namaCtrl = TextEditingController(text: item?['nama_stasiun'] ?? '');
    final alamatCtrl =
        TextEditingController(text: item?['alamat_stasiun'] ?? '');
    final kapasitasCtrl =
        TextEditingController(text: (item?['kapasitas_dock'] ?? '').toString());
    final koordinatCtrl =
        TextEditingController(text: item?['koordinat_gps'] ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isNew ? 'Tambah Stasiun' : 'Edit Stasiun'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: namaCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Stasiun')),
              TextField(
                  controller: alamatCtrl,
                  decoration: const InputDecoration(labelText: 'Alamat')),
              TextField(
                  controller: kapasitasCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Kapasitas Dock'),
                  keyboardType: TextInputType.number),
              TextField(
                  controller: koordinatCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Koordinat (lat,lng)')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final nama = namaCtrl.text.trim();
              final alamat = alamatCtrl.text.trim();
              final kapasitas = int.tryParse(kapasitasCtrl.text.trim()) ?? 0;
              final koordinat = koordinatCtrl.text.trim();

              if (nama.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama stasiun diperlukan')));
                return;
              }

              Navigator.pop(context);

              final payload = {
                'nama_stasiun': nama,
                'alamat_stasiun': alamat,
                'kapasitas_dock': kapasitas,
                'koordinat_gps': koordinat,
              };

              Map<String, dynamic> res;
              if (isNew) {
                res = await api.createStasiun(payload);
              } else {
                final id = item['id_stasiun'] ?? item['id'];
                res = await api.updateStasiun(
                    int.tryParse(id.toString()) ?? 0, payload);
              }

              if (res['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res['message'] ?? 'Berhasil')));
                await loadStasiun();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res['message'] ?? 'Gagal')));
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> item) async {
    final id = item['id_stasiun'] ?? item['id'];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Stasiun'),
        content:
            Text('Hapus stasiun "${item['nama_stasiun'] ?? item['nama']}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm != true) return;

    final res = await api.deleteStasiun(int.tryParse(id.toString()) ?? 0);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res['message'] ?? 'Terhapus')));
      await loadStasiun();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Gagal menghapus')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Daftar Stasiun Sepeda',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            tooltip: 'Tambah Stasiun',
            onPressed: () => _showEditDialog(),
            icon: const Icon(Icons.add_location_alt_outlined),
          ),
        ],
        backgroundColor: const Color(0xFF1a237e),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A1428), Color(0xFF0f2342)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: stasiun.isEmpty
            ? const Center(
                child: Text(
                  'Tidak ada data stasiun',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: stasiun.length,
                itemBuilder: (_, i) {
                  final s = stasiun[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.12),
                          Colors.white.withOpacity(0.05)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.15), width: 1.5),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.location_on,
                            color: Color(0xFF6366F1), size: 24),
                      ),
                      title: Text(
                        s['nama_stasiun'] ??
                            'Stasiun #${s['id_stasiun'] ?? i + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          s['alamat_stasiun'] ?? '-',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Kapasitas: ${s['kapasitas_dock'] ?? '-'}',
                              style: const TextStyle(
                                color: Color(0xFF6366F1),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Edit',
                            onPressed: () => _showEditDialog(item: s),
                            icon: const Icon(Icons.edit, color: Colors.white70),
                          ),
                          IconButton(
                            tooltip: 'Hapus',
                            onPressed: () => _confirmDelete(s),
                            icon: const Icon(Icons.delete_forever,
                                color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
