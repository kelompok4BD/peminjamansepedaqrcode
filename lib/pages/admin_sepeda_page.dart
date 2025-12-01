import 'package:flutter/material.dart';
import '../services/api_service.dart';
// import '../theme/app_theme.dart'; // Hapus jika error, kita gunakan custom theme di sini

class AdminSepedaPage extends StatefulWidget {
  const AdminSepedaPage({super.key});

  @override
  State<AdminSepedaPage> createState() => _AdminSepedaPageState();
}

class _AdminSepedaPageState extends State<AdminSepedaPage> {
  // --- LOGIKA (TIDAK DIUBAH) ---
  final api = ApiService();
  List<dynamic> sepeda = [];
  List<Map<String, dynamic>> stasiun = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadSepeda();
    loadStasiun();
  }

  Future<void> loadStasiun() async {
    try {
      final data = await api.getAllStasiun();
      setState(() {
        stasiun = data;
      });
    } catch (e) {
      print('Error loading stasiun: $e');
    }
  }

  Future<void> loadSepeda() async {
    setState(() => loading = true);
    try {
      final data = await api.getAllSepeda();
      setState(() {
        sepeda = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data sepeda')),
        );
      }
    }
  }

  // --- STYLE INPUT FIELD (DARK MODE) ---
  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1), // Input transparan gelap
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
          borderSide: const BorderSide(color: Color(0xFFFF007F), width: 1.5), // Pink Focus
        ),
      );

  Widget _field(String label, TextEditingController c, [TextInputType? type]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        keyboardType: type,
        style: const TextStyle(color: Colors.white), // Teks input putih
        cursorColor: const Color(0xFFFF007F), // Kursor Pink
        decoration: _inputDeco(label),
      ),
    );
  }

  // --- STYLE TOMBOL (PINK GRADIENT) ---
  ButtonStyle _btnStyle() => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF007F), // Pink Neon
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  // --- LOGIKA TAMBAH SEPEDA (TIDAK DIUBAH, HANYA UI DIALOG) ---
  Future<void> _addSepeda() async {
    final merkController = TextEditingController();
    final tahunController = TextEditingController();
    String selectedStatus = 'Tersedia';
    final kondisiController = TextEditingController(text: 'Baik');
    final kodeQrController = TextEditingController();
    int? selectedStasiun;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E), // Dialog gelap
        title: const Text('Tambah Sepeda', style: TextStyle(color: Colors.white)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: StatefulBuilder(
          builder: (dialogCtx, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field('Merk/Model', merkController),
                _field('Tahun', tahunController, TextInputType.number),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: DropdownButtonFormField<String>(
                    value: selectedStatus,
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco('Status'),
                    items: const [
                      DropdownMenuItem(value: 'Tersedia', child: Text('Tersedia')),
                      DropdownMenuItem(value: 'Dipinjam', child: Text('Dipinjam')),
                    ],
                    onChanged: (val) => setState(() => selectedStatus = val ?? 'Tersedia'),
                  ),
                ),
                _field('Kondisi', kondisiController),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: DropdownButtonFormField<int>(
                    value: selectedStasiun,
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco('Stasiun'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Pilih Stasiun')),
                      ...stasiun.map((s) => DropdownMenuItem(
                            value: s['id_stasiun'] as int,
                            child: Text(s['nama_stasiun'] ?? 'Stasiun'),
                          )),
                    ],
                    onChanged: (val) {
                      setState(() => selectedStasiun = val);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
              style: _btnStyle(),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Tambah')),
        ],
      ),
    );

    if (ok == true) {
      final result = await api.addSepeda(
        merkController.text,
        int.tryParse(tahunController.text) ?? DateTime.now().year,
        selectedStatus,
        kondisiController.text,
        kodeQrController.text,
        selectedStasiun,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result['success'] == true
                ? result['message'] ?? 'Berhasil tambah sepeda'
                : result['message'] ?? 'Gagal tambah sepeda')));
      }

      if (result['success'] == true) {
        await loadSepeda();
      }
    }
  }

  // --- LOGIKA EDIT SEPEDA (UI DIALOG DISESUAIKAN) ---
  Future<void> _editSepeda(Map<String, dynamic> s) async {
    final id = s['id'] ?? s['id_sepeda'] ?? 0;
    final merkController = TextEditingController(text: s['merk'] ?? s['merk_model']);
    final tahunController = TextEditingController(text: (s['tahun'] ?? s['tahun_pembelian'])?.toString());
    String selectedStatus = s['status'] ?? s['status_saat_ini'] ?? 'Tersedia';
    final kondisiController = TextEditingController(text: s['kondisi']);
    final kodeQrController = TextEditingController(text: s['kode_qr']);
    int? selectedStasiun = s['id_stasiun'];

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Edit Sepeda', style: TextStyle(color: Colors.white)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: StatefulBuilder(
          builder: (dialogCtx, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field('Merk/Model', merkController),
                _field('Tahun', tahunController, TextInputType.number),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: DropdownButtonFormField<String>(
                    value: selectedStatus,
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco('Status'),
                    items: const [
                      DropdownMenuItem(value: 'Tersedia', child: Text('Tersedia')),
                      DropdownMenuItem(value: 'Dipinjam', child: Text('Dipinjam')),
                    ],
                    onChanged: (val) => setState(() => selectedStatus = val ?? 'Tersedia'),
                  ),
                ),
                _field('Kondisi', kondisiController),
                _field('Kode QR', kodeQrController),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: DropdownButtonFormField<int>(
                    value: selectedStasiun,
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco('Stasiun'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Pilih Stasiun')),
                      ...stasiun.map((s) => DropdownMenuItem(
                            value: s['id_stasiun'] as int,
                            child: Text(s['nama_stasiun'] ?? 'Stasiun'),
                          )),
                    ],
                    onChanged: (val) {
                      setState(() => selectedStasiun = val);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
              style: _btnStyle(),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Simpan')),
        ],
      ),
    );

    if (ok == true) {
      final result = await api.editSepeda(
        id,
        merkController.text,
        int.tryParse(tahunController.text) ?? DateTime.now().year,
        selectedStatus,
        kondisiController.text,
        kodeQrController.text,
        selectedStasiun,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result['success'] == true
                ? result['message'] ?? 'Data sepeda diperbarui'
                : result['message'] ?? 'Gagal update sepeda')));
      }
      if (result['success'] == true) {
        await loadSepeda();
      }
    }
  }

  // --- LOGIKA DELETE SEPEDA (UI DIALOG DISESUAIKAN) ---
  Future<void> _deleteSepeda(int id) async {
    final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text('Hapus Sepeda', style: TextStyle(color: Colors.white)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: const Text('Yakin ingin menghapus sepeda ini?', style: TextStyle(color: Colors.white70)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Batal', style: TextStyle(color: Colors.white70))),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent, 
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Hapus'))
              ],
            ));

    if (ok == true) {
      final result = await api.hapusSepeda(id);

      if (result['success'] == true) {
        await api.createLogAktivitas(
          null,
          'Delete',
          'Admin menghapus sepeda ID $id dari sistem',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result['success'] == true
                ? result['message'] ?? 'Berhasil hapus sepeda'
                : result['message'] ?? 'Gagal hapus sepeda')));
      }
      if (result['success'] == true) {
        await loadSepeda();
      }
    }
  }

  // --- TAMPILAN UI UTAMA (TEMA BLACK PINK) ---
  @override
  Widget build(BuildContext context) {
    // Definisi Warna Tema
    final pinkNeon = const Color(0xFFFF007F);
    final darkPink = const Color(0xFF880E4F);
    final blackBg = const Color(0xFF000000);
    final darkCherry = const Color(0xFF25000B);

    return Scaffold(
      // AppBar Gradient Hitam ke Pink Gelap
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Kelola Sepeda',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _addSepeda
          )
        ],
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
      
      // Body Gradient Hitam ke Cherry
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [blackBg, darkCherry],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: loading
            ? Center(child: CircularProgressIndicator(color: pinkNeon))
            : sepeda.isEmpty
                ? const Center(
                    child: Text('Belum ada data sepeda',
                        style: TextStyle(color: Colors.white70)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sepeda.length,
                    itemBuilder: (context, i) {
                      final s = sepeda[i];
                      final id = s['id'] ?? s['id_sepeda'] ?? 0;
                      final merk = s['merk'] ?? s['merk_model'] ?? '-';
                      final tahun = s['tahun'] ?? s['tahun_pembelian'] ?? '-';
                      final status = s['status'] ?? s['status_saat_ini'] ?? '-';
                      final kondisi = s['kondisi'] ?? '-';
                      final kodeQR = s['kode_qr'] ?? '-';
                      final idStasiun = s['id_stasiun'];
                      final stasiunName = stasiun.firstWhere(
                              (st) => st['id_stasiun'] == idStasiun,
                              orElse: () => {'nama_stasiun': 'Tidak Ada'})['nama_stasiun'] ??
                          'Tidak Ada';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          // Glassmorphism Card
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.1), width: 1.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () => _editSepeda(s),
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.pedal_bike, color: pinkNeon, size: 24),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        merk,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: status.toLowerCase() == 'tersedia'
                                            ? Colors.greenAccent.withOpacity(0.2)
                                            : Colors.orangeAccent.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: status.toLowerCase() == 'tersedia'
                                              ? Colors.greenAccent.withOpacity(0.5)
                                              : Colors.orangeAccent.withOpacity(0.5),
                                        ),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: status.toLowerCase() == 'tersedia'
                                              ? Colors.greenAccent
                                              : Colors.orangeAccent,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Tombol Edit Kecil
                                    InkWell(
                                      onTap: () => _editSepeda(s),
                                      child: const Icon(Icons.edit,
                                          color: Colors.blueAccent, size: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    // Tombol Hapus Kecil
                                    InkWell(
                                      onTap: () => _deleteSepeda(id),
                                      child: const Icon(Icons.delete,
                                          color: Colors.redAccent, size: 20),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24, color: Colors.white12),
                                _infoRow('ID Sepeda', '#$id'),
                                _infoRow('Stasiun', stasiunName),
                                _infoRow('Tahun', tahun.toString()),
                                _infoRow('Status', status),
                                _infoRow('Kondisi', kondisi),
                                _infoRow('Kode QR', kodeQR),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  // Helper Widget Row
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5), // Label abu-abu
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white, // Teks putih
              ),
            ),
          ),
        ],
      ),
    );
  }
}