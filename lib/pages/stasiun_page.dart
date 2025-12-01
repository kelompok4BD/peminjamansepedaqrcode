import 'package:flutter/material.dart';
import '../services/api_service.dart';
// import '../theme/app_theme.dart'; // Hapus jika tidak digunakan

class StasiunPage extends StatefulWidget {
  const StasiunPage({super.key});

  @override
  State<StasiunPage> createState() => _StasiunPageState();
}

class _StasiunPageState extends State<StasiunPage> {
  // --- LOGIKA (TIDAK DIUBAH) ---
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

  // --- STYLE HELPER (DARK THEME) ---
  final pinkNeon = const Color(0xFFFF007F);
  final darkBgDialog = const Color(0xFF1E1E1E);

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: pinkNeon, width: 1.5),
      ),
    );
  }

  // --- DIALOG EDIT/TAMBAH (UI DIUBAH KE DARK) ---
  Future<void> _showEditDialog({Map<String, dynamic>? item}) async {
    final isNew = item == null;
    final namaCtrl = TextEditingController(text: item?['nama_stasiun'] ?? '');
    final alamatCtrl = TextEditingController(text: item?['alamat_stasiun'] ?? '');
    final kapasitasCtrl = TextEditingController(text: (item?['kapasitas_dock'] ?? '').toString());
    final koordinatCtrl = TextEditingController(text: item?['koordinat_gps'] ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: darkBgDialog, // Dialog Hitam
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isNew ? 'Tambah Stasiun' : 'Edit Stasiun',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaCtrl,
                style: const TextStyle(color: Colors.white),
                cursorColor: pinkNeon,
                decoration: _inputDeco('Nama Stasiun'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: alamatCtrl,
                style: const TextStyle(color: Colors.white),
                cursorColor: pinkNeon,
                decoration: _inputDeco('Alamat'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: kapasitasCtrl,
                style: const TextStyle(color: Colors.white),
                cursorColor: pinkNeon,
                decoration: _inputDeco('Kapasitas Dock'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: koordinatCtrl,
                style: const TextStyle(color: Colors.white),
                cursorColor: pinkNeon,
                decoration: _inputDeco('Koordinat (lat,lng)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: pinkNeon,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              // --- LOGIKA SIMPAN (TIDAK DIUBAH) ---
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

  // --- DIALOG HAPUS (UI DIUBAH KE DARK) ---
  Future<void> _confirmDelete(Map<String, dynamic> item) async {
    final id = item['id_stasiun'] ?? item['id'];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: darkBgDialog,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Stasiun', style: TextStyle(color: Colors.white)),
        content: Text(
          'Hapus stasiun "${item['nama_stasiun'] ?? item['nama']}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
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

  // --- TAMPILAN UI UTAMA (TEMA BLACK PINK) ---
  @override
  Widget build(BuildContext context) {
    // Warna Tema
    final pinkNeon = const Color(0xFFFF007F);
    final darkPink = const Color(0xFF880E4F);
    final blackBg = const Color(0xFF000000);
    final darkCherry = const Color(0xFF25000B);

    return Scaffold(
      // AppBar Gradient Hitam ke Pink Gelap
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Daftar Stasiun Sepeda',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: 'Tambah Stasiun',
            onPressed: () => _showEditDialog(),
            icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
          ),
        ],
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
        child: stasiun.isEmpty
            ? const Center(
                child: Text(
                  'Tidak ada data stasiun',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: stasiun.length,
                itemBuilder: (_, i) {
                  final s = stasiun[i];
                  // Card Stasiun Glassmorphism
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05), // Background transparan
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1.0,
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
                      contentPadding: const EdgeInsets.all(16),
                      // Leading Icon (Pink Theme)
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: pinkNeon.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.location_on, color: pinkNeon, size: 24),
                      ),
                      title: Text(
                        s['nama_stasiun'] ?? 'Stasiun #${s['id_stasiun'] ?? i + 1}',
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
                          // Tag Kapasitas
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: pinkNeon.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: pinkNeon.withOpacity(0.3)),
                            ),
                            child: Text(
                              'Kap: ${s['kapasitas_dock'] ?? '-'}',
                              style: TextStyle(
                                color: pinkNeon,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Edit Button
                          IconButton(
                            tooltip: 'Edit',
                            onPressed: () => _showEditDialog(item: s),
                            icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          ),
                          // Delete Button
                          IconButton(
                            tooltip: 'Hapus',
                            onPressed: () => _confirmDelete(s),
                            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
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