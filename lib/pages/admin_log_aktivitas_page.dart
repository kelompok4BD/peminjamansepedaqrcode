import 'package:flutter/material.dart';
import '../services/api_service.dart';
// import '../theme/app_theme.dart'; // Hapus jika tidak digunakan

class AdminLogAktivitasPage extends StatefulWidget {
  const AdminLogAktivitasPage({super.key});

  @override
  State<AdminLogAktivitasPage> createState() => _AdminLogAktivitasPageState();
}

class _AdminLogAktivitasPageState extends State<AdminLogAktivitasPage> {
  // --- LOGIKA (TIDAK DIUBAH SAMA SEKALI) ---
  final ApiService api = ApiService();
  List<Map<String, dynamic>> logList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    setState(() => isLoading = true);
    final logs = await api.getLogAktivitas();
    setState(() {
      logList = logs;
      isLoading = false;
    });
  }

  Color _getActivityColor(String? jenis) {
    final type = jenis?.toLowerCase() ?? '';
    if (type.contains('login')) return Colors.blueAccent;
    if (type.contains('update')) return Colors.orangeAccent;
    if (type.contains('delete')) return Colors.redAccent;
    if (type.contains('tambah') || type.contains('create')) return Colors.greenAccent;
    if (type.contains('pinjam') || type.contains('borrow'))
      return Colors.purpleAccent;
    return Colors.grey;
  }

  IconData _getActivityIcon(String? jenis) {
    final type = jenis?.toLowerCase() ?? '';
    if (type.contains('login')) return Icons.login;
    if (type.contains('update')) return Icons.edit;
    if (type.contains('delete')) return Icons.delete;
    if (type.contains('tambah') || type.contains('create'))
      return Icons.add_circle;
    if (type.contains('pinjam') || type.contains('borrow'))
      return Icons.pedal_bike;
    return Icons.info;
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
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
        title: const Text('Log Aktivitas Sistem',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(color: pinkNeon), // Loading Pink
              )
            : logList.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada aktivitas',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: fetchLogs,
                    color: pinkNeon,
                    backgroundColor: Colors.grey[900],
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: logList.length,
                      itemBuilder: (context, index) {
                        final log = logList[index];
                        final jenisAktivitas =
                            log['jenis_aktivitas'] ?? 'Unknown';
                        final deskripsi = log['deskripsi_aktivitas'] ?? '-';
                        final waktu = log['waktu_aktivitas'] ?? '';
                        final idPegawai = log['id_pegawai'] ?? 'System';

                        // --- CONTAINER GLASSMORPHISM (PENGGANTI CARD) ---
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05), // Transparan
                            borderRadius: BorderRadius.circular(16),
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
                            // Icon Container
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _getActivityColor(jenisAktivitas).withOpacity(0.2), // Warna transparan
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getActivityColor(jenisAktivitas).withOpacity(0.5),
                                  width: 1,
                                )
                              ),
                              child: Icon(
                                _getActivityIcon(jenisAktivitas),
                                color: _getActivityColor(jenisAktivitas), // Icon berwarna neon sesuai tipe
                                size: 24,
                              ),
                            ),
                            title: Text(
                              jenisAktivitas,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white, // Judul Putih
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  deskripsi,
                                  style: const TextStyle(fontSize: 12, color: Colors.white70), // Deskripsi abu terang
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 12,
                                      color: Colors.white54,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDateTime(waktu),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white54,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.person,
                                      size: 12,
                                      color: Colors.white54,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'ID: $idPegawai',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white54,
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
}