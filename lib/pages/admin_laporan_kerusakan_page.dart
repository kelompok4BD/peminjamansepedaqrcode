import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminLaporanKerusakanPage extends StatefulWidget {
  const AdminLaporanKerusakanPage({super.key});

  @override
  State<AdminLaporanKerusakanPage> createState() => _AdminLaporanKerusakanPageState();
}

class _AdminLaporanKerusakanPageState extends State<AdminLaporanKerusakanPage> {
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Status diperbarui')));
      loadLaporan();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ ${res['message']}')));
    }
  }

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
          title: const Text('Tambah Laporan Kerusakan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: idSepedaCtrl,
                  decoration: const InputDecoration(labelText: 'ID Sepeda', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: idPegawaiCtrl,
                  decoration: const InputDecoration(labelText: 'ID Pegawai', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: deskripsiCtrl,
                  decoration: const InputDecoration(labelText: 'Deskripsi Kerusakan', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: statusPerbaikan,
                  onChanged: (val) => setDialogState(() => statusPerbaikan = val ?? 'Belum Diperbaiki'),
                  items: ['Belum Diperbaiki', 'Sedang Diperbaiki', 'Sudah Diperbaiki']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  decoration: const InputDecoration(labelText: 'Status Perbaikan', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final idSepeda = int.tryParse(idSepedaCtrl.text) ?? 0;
                      final idPegawai = int.tryParse(idPegawaiCtrl.text) ?? 0;
                      final deskripsi = deskripsiCtrl.text.trim();

                      if (idSepeda == 0 || idPegawai == 0 || deskripsi.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua field wajib diisi')));
                        return;
                      }

                      setDialogState(() => isLoading = true);
                      final res = await api.createLaporanKerusakan(idSepeda, idPegawai, deskripsi, statusPerbaikan);
                      if (res['success'] == true) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Laporan ditambahkan')));
                        loadLaporan();
                      } else {
                        setDialogState(() => isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ ${res['message']}')));
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002D72)),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sudah diperbaiki':
        return Colors.green[50]!;
      case 'sedang diperbaiki':
        return Colors.orange[50]!;
      default:
        return Colors.red[50]!;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'sudah diperbaiki':
        return Colors.green;
      case 'sedang diperbaiki':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Laporan Kerusakan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
            : (_error != null)
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.05)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 8),
                            const Text('Gagal memuat laporan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 6),
                            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: loadLaporan,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Muat ulang'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                              gradient: LinearGradient(
                                colors: [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.05)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.info_outline, size: 48, color: Colors.amber.shade700),
                                const SizedBox(height: 8),
                                const Text('Belum ada laporan kerusakan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 6),
                                const Text('Tambahkan laporan kerusakan baru dengan tombol di bawah.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: loadLaporan,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: laporan.length,
                          itemBuilder: (_, i) {
                            final l = laporan[i];
                            final status = (l['status_perbaikan'] ?? 'Belum Diperbaiki').toString();
                            final tglLaporan = l['tanggal_laporan'] ?? '-';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.05)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 16,
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
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text('Laporan #${l['id_laporan'] ?? i + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                        ),
                                        Chip(
                                          label: Text(status, style: TextStyle(color: _getStatusTextColor(status), fontWeight: FontWeight.w600)),
                                          backgroundColor: Colors.white70,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.pedal_bike, size: 18, color: Colors.white70),
                                        const SizedBox(width: 6),
                                        Expanded(child: Text('Sepeda ID: ${l['id_sepeda'] ?? '-'}', style: TextStyle(color: Colors.white70))),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.person, size: 18, color: Colors.white70),
                                        const SizedBox(width: 6),
                                        Expanded(child: Text('Pegawai ID: ${l['id_pegawai'] ?? '-'}', style: TextStyle(color: Colors.white70))),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 18, color: Colors.white70),
                                        const SizedBox(width: 6),
                                        Expanded(child: Text('Tanggal: $tglLaporan', style: TextStyle(color: Colors.white70))),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text('Deskripsi: ${l['deskripsi_kerusakan'] ?? '-'}', style: const TextStyle(color: Colors.white)),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _updateStatus(l['id_laporan'] ?? 0, 'Sedang Diperbaiki'),
                                            icon: const Icon(Icons.build, size: 16, color: Colors.orange),
                                            label: const Text('Perbaiki', style: TextStyle(color: Colors.orange)),
                                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.orange)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => _updateStatus(l['id_laporan'] ?? 0, 'Sudah Diperbaiki'),
                                            icon: const Icon(Icons.check_circle, size: 16, color: Colors.white),
                                            label: const Text('Selesai', style: TextStyle(color: Colors.white)),
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddModal,
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Laporan'),
      ),
    );
  }
}
