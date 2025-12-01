import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class AdminSepedaPage extends StatefulWidget {
  const AdminSepedaPage({super.key});

  @override
  State<AdminSepedaPage> createState() => _AdminSepedaPageState();
}

class _AdminSepedaPageState extends State<AdminSepedaPage> {
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

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.blue[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  Widget _field(String label, TextEditingController c, [TextInputType? type]) {
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

  Future<void> _addSepeda() async {
    final merkController = TextEditingController();
    final tahunController = TextEditingController();
    final statusController = TextEditingController(text: 'Tersedia');
    final kondisiController = TextEditingController(text: 'Baik');
    final kodeQrController = TextEditingController();
    int? selectedStasiun;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Sepeda'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: StatefulBuilder(
          builder: (dialogCtx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field('Merk/Model', merkController),
              _field('Tahun', tahunController, TextInputType.number),
              _field('Status', statusController),
              _field('Kondisi', kondisiController),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: DropdownButtonFormField<int>(
                  value: selectedStasiun,
                  decoration: _inputDeco('Stasiun'),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Pilih Stasiun')),
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
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
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
        statusController.text,
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

  Future<void> _editSepeda(Map<String, dynamic> s) async {
    final id = s['id'] ?? s['id_sepeda'] ?? 0;
    final merkController =
        TextEditingController(text: s['merk'] ?? s['merk_model']);
    final tahunController = TextEditingController(
        text: (s['tahun'] ?? s['tahun_pembelian'])?.toString());
    final statusController =
        TextEditingController(text: s['status'] ?? s['status_saat_ini']);
    final kondisiController = TextEditingController(text: s['kondisi']);
    final kodeQrController = TextEditingController(text: s['kode_qr']);
    int? selectedStasiun = s['id_stasiun'];

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Sepeda'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: StatefulBuilder(
          builder: (dialogCtx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field('Merk/Model', merkController),
              _field('Tahun', tahunController, TextInputType.number),
              _field('Status', statusController),
              _field('Kondisi', kondisiController),
              _field('Kode QR', kodeQrController),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: DropdownButtonFormField<int>(
                  value: selectedStasiun,
                  decoration: _inputDeco('Stasiun'),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Pilih Stasiun')),
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
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
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
        statusController.text,
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

  Future<void> _deleteSepeda(int id) async {
    final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Hapus Sepeda'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              content: const Text('Yakin ingin menghapus sepeda ini?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Batal')),
                ElevatedButton(
                    style: _btnStyle(),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Hapus'))
              ],
            ));

    if (ok == true) {
      final result = await api.hapusSepeda(id);

      if (result['success'] == true) {
        // Log aktivitas delete
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Kelola Sepeda',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: const Color(0xFF1a237e),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addSepeda)
        ],
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
        child: loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF6366F1)))
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
                              orElse: () => {
                                    'nama_stasiun': 'Tidak Ada'
                                  })['nama_stasiun'] ??
                          'Tidak Ada';

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
                              color: Colors.white.withOpacity(0.15),
                              width: 1.5),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 16,
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
                                    const Icon(
                                      Icons.pedal_bike,
                                      color: Color(0xFF6366F1),
                                      size: 24,
                                    ),
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
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            status.toLowerCase() == 'tersedia'
                                                ? Colors.green.withOpacity(0.18)
                                                : Colors.red.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color:
                                              status.toLowerCase() == 'tersedia'
                                                  ? Colors.greenAccent.shade200
                                                  : Colors.redAccent.shade100,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Color(0xFF6366F1), size: 20),
                                      onPressed: () => _editSepeda(s),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.redAccent, size: 20),
                                      onPressed: () => _deleteSepeda(id),
                                    ),
                                  ],
                                ),
                                const Divider(
                                    height: 24, color: Colors.white24),
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
              style: const TextStyle(
                color: AppColors.textSecondary,
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
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
