import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminLaporanKerusakanPage extends StatefulWidget {
  const AdminLaporanKerusakanPage({super.key});

  @override
  State<AdminLaporanKerusakanPage> createState() =>
      _AdminLaporanKerusakanPageState();
}

class _AdminLaporanKerusakanPageState extends State<AdminLaporanKerusakanPage> {
  // --- LOGIKA (TIDAK DIUBAH SAMA SEKALI) ---
  final api = ApiService();
  List<Map<String, dynamic>> laporan = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    loadLaporan();
  }

  Future<void> loadLaporan() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await api.getLaporanKerusakan();
      setState(() => laporan = data);
    } catch (e) {
      setState(() {
        laporan = [];
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(int idLaporan, String newStatus) async {
    final res = await api.updateLaporanKerusakanStatus(idLaporan, newStatus);
    if (res['success'] == true) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('✅ Status diperbarui')));
      loadLaporan();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('❌ ${res['message']}')));
    }
  }

  // --- WARNA TEMA ---
  final pinkNeon = const Color(0xFFFF007F);
  final darkBgDialog = const Color(0xFF1E1E1E);

  // --- STYLE INPUT DECORATION (DARK MODE) ---
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

  // --- MODAL TAMBAH LAPORAN (UI DIUBAH KE DARK) ---
  void _showAddModal() {
    final idSepedaCtrl = TextEditingController();
    final idPegawaiCtrl = TextEditingController();
    final deskripsiCtrl = TextEditingController();
    String statusPerbaikan = 'Belum Diperbaiki';
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          backgroundColor: darkBgDialog, // Dialog Hitam
          title: const Text('Tambah Laporan Kerusakan',
              style: TextStyle(color: Colors.white)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: idSepedaCtrl,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: pinkNeon,
                  decoration: _inputDeco('ID Sepeda'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: idPegawaiCtrl,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: pinkNeon,
                  decoration: _inputDeco('ID Pegawai'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: deskripsiCtrl,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: pinkNeon,
                  decoration: _inputDeco('Deskripsi Kerusakan'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: statusPerbaikan,
                  dropdownColor: const Color(0xFF2C2C2C), // Dropdown gelap
                  style: const TextStyle(color: Colors.white),
                  onChanged: (val) => setDialogState(
                      () => statusPerbaikan = val ?? 'Belum Diperbaiki'),
                  items: [
                    'Belum Diperbaiki',
                    'Sedang Diperbaiki',
                    'Sudah Diperbaiki'
                  ]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  decoration: _inputDeco('Status Perbaikan'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal', style: TextStyle(color: Colors.white70))),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      // --- LOGIKA SIMPAN (TIDAK DIUBAH) ---
                      final idSepeda = int.tryParse(idSepedaCtrl.text) ?? 0;
                      final idPegawai = int.tryParse(idPegawaiCtrl.text) ?? 0;
                      final deskripsi = deskripsiCtrl.text.trim();

                      if (idSepeda == 0 ||
                          idPegawai == 0 ||
                          deskripsi.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Semua field wajib diisi')));
                        return;
                      }

                      setDialogState(() => isLoading = true);
                      final res = await api.createLaporanKerusakan(
                          idSepeda, idPegawai, deskripsi, statusPerbaikan);
                      if (res['success'] == true) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('✅ Laporan ditambahkan')));
                        loadLaporan();
                      } else {
                        setDialogState(() => isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('❌ ${res['message']}')));
                      }
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: pinkNeon, // Tombol Pink
                  foregroundColor: Colors.white),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'sudah diperbaiki':
        return Colors.greenAccent;
      case 'sedang diperbaiki':
        return Colors.orangeAccent;
      default:
        return Colors.redAccent;
    }
  }

  // --- TAMPILAN UTAMA (TEMA BLACK PINK) ---
  @override
  Widget build(BuildContext context) {
    // Definisi Warna Tema
    final darkPink = const Color(0xFF880E4F);
    final blackBg = const Color(0xFF000000);
    final darkCherry = const Color(0xFF25000B);

    return Scaffold(
      // AppBar Gradient Hitam ke Pink Gelap
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Laporan Kerusakan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
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
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton.icon(
              onPressed: _showAddModal,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Laporan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: pinkNeon, // Tombol Header Pink
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
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
        child: _loading
            ? Center(child: CircularProgressIndicator(color: pinkNeon))
            : (_error != null)
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.redAccent),
                            const SizedBox(height: 8),
                            const Text('Gagal memuat laporan',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 6),
                            Text(_error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: loadLaporan,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Muat ulang'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pinkNeon,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : laporan.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.info_outline,
                                    size: 48, color: Colors.amber.shade700),
                                const SizedBox(height: 8),
                                const Text('Belum ada laporan kerusakan',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                const SizedBox(height: 6),
                                const Text(
                                    'Tambahkan laporan kerusakan baru dengan tombol di atas.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: loadLaporan,
                        color: pinkNeon, // Loader Refresh
                        backgroundColor: Colors.grey[900],
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: laporan.length,
                          itemBuilder: (_, i) {
                            final l = laporan[i];
                            final status =
                                (l['status_perbaikan'] ?? 'Belum Diperbaiki')
                                    .toString();
                            final tglLaporan = l['tanggal_laporan'] ?? '-';
                            
                            // --- CARD LAPORAN (GLASSMORPHISM) ---
                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05), // Transparan
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1.0),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                              'Laporan #${l['id_laporan'] ?? i + 1}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.white)),
                                        ),
                                        Chip(
                                          label: Text(status,
                                              style: TextStyle(
                                                  color: _getStatusTextColor(
                                                      status),
                                                  fontWeight: FontWeight.w600)),
                                          backgroundColor: Colors.white.withOpacity(0.1),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    _buildInfoRow(Icons.pedal_bike, 'Sepeda ID: ${l['id_sepeda'] ?? '-'}'),
                                    const SizedBox(height: 6),
                                    _buildInfoRow(Icons.person, 'Pegawai ID: ${l['id_pegawai'] ?? '-'}'),
                                    const SizedBox(height: 6),
                                    _buildInfoRow(Icons.calendar_today, 'Tanggal: $tglLaporan'),
                                    const SizedBox(height: 10),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                          'Deskripsi: ${l['deskripsi_kerusakan'] ?? '-'}',
                                          style: const TextStyle(color: Colors.white)),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _updateStatus(
                                                l['id_laporan'] ?? 0,
                                                'Sedang Diperbaiki'),
                                            icon: const Icon(Icons.build,
                                                size: 16, color: Colors.orangeAccent),
                                            label: const Text('Perbaiki',
                                                style: TextStyle(
                                                    color: Colors.orangeAccent)),
                                            style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                    color: Colors.orangeAccent)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => _updateStatus(
                                                l['id_laporan'] ?? 0,
                                                'Sudah Diperbaiki'),
                                            icon: const Icon(Icons.check_circle,
                                                size: 16, color: Colors.white),
                                            label: const Text('Selesai',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 6),
        Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white70))),
      ],
    );
  }
}