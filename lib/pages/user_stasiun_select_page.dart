import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'user_peminjaman_page.dart';

class UserStasiunSelectPage extends StatefulWidget {
  final String userId;

  const UserStasiunSelectPage({super.key, required this.userId});

  @override
  State<UserStasiunSelectPage> createState() => _UserStasiunSelectPageState();
}

class _UserStasiunSelectPageState extends State<UserStasiunSelectPage> {
  final api = ApiService();
  List<Map<String, dynamic>> stasiun = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadStasiun();
  }

  Future<void> loadStasiun() async {
    try {
      final data = await api.getAllStasiun();
      setState(() {
        stasiun = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data stasiun')),
        );
      }
    }
  }

  void selectStation(int stasiunId, String stasiunName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserPeminjamanPage(
          userId: widget.userId,
          stasiunId: stasiunId,
          stasiunName: stasiunName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Pilih Stasiun',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
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
            : stasiun.isEmpty
                ? const Center(
                    child: Text('Belum ada stasiun tersedia',
                        style: TextStyle(color: Colors.white70)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: stasiun.length,
                    itemBuilder: (context, i) {
                      final s = stasiun[i];
                      final stasiunId = s['id_stasiun'] as int;
                      final stasiunName = s['nama_stasiun'] ?? 'Stasiun';
                      final alamat = s['alamat_stasiun'] ?? '-';
                      final kapasitas = s['kapasitas_dock'] ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () => selectStation(stasiunId, stasiunName),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Color(0xFF6366F1),
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        stasiunName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Color(0xFF6366F1),
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 40, top: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_city,
                                            color: Colors.white70,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              alamat,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.white70,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.directions_bike,
                                            color: Colors.white70,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Kapasitas: $kapasitas dock',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
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
}
