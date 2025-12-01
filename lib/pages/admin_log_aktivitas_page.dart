import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class AdminLogAktivitasPage extends StatefulWidget {
  const AdminLogAktivitasPage({super.key});

  @override
  State<AdminLogAktivitasPage> createState() => _AdminLogAktivitasPageState();
}

class _AdminLogAktivitasPageState extends State<AdminLogAktivitasPage> {
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
    if (type.contains('login')) return Colors.blue;
    if (type.contains('update')) return Colors.orange;
    if (type.contains('delete')) return Colors.red;
    if (type.contains('tambah') || type.contains('create')) return Colors.green;
    if (type.contains('pinjam') || type.contains('borrow'))
      return Colors.purple;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Aktivitas Sistem',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF312e81)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : logList.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada aktivitas',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: fetchLogs,
                    child: ListView.builder(
                      itemCount: logList.length,
                      itemBuilder: (context, index) {
                        final log = logList[index];
                        final jenisAktivitas =
                            log['jenis_aktivitas'] ?? 'Unknown';
                        final deskripsi = log['deskripsi_aktivitas'] ?? '-';
                        final waktu = log['waktu_aktivitas'] ?? '';
                        final idPegawai = log['id_pegawai'] ?? 'System';

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _getActivityColor(jenisAktivitas),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getActivityIcon(jenisAktivitas),
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              jenisAktivitas,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  deskripsi,
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDateTime(waktu),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.person,
                                      size: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'ID: $idPegawai',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
