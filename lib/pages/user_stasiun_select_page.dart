import 'package:flutter/material.dart';
import '../services/api_service.dart';
// import '../theme/app_theme.dart'; // Hapus jika tidak digunakan
import 'user_peminjaman_page.dart';

class UserStasiunSelectPage extends StatefulWidget {
  final String userId;

  const UserStasiunSelectPage({super.key, required this.userId});

  @override
  State<UserStasiunSelectPage> createState() => _UserStasiunSelectPageState();
}

class _UserStasiunSelectPageState extends State<UserStasiunSelectPage> {
  // --- LOGIKA (TIDAK DIUBAH SAMA SEKALI) ---
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

  // --- TAMPILAN UI (TEMA BLACK PINK) ---
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
          'Pilih Stasiun',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
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
        child: loading
            ? Center(child: CircularProgressIndicator(color: pinkNeon)) // Loading Pink
            : stasiun.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada stasiun tersedia',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: stasiun.length,
                    itemBuilder: (context, i) {
                      final s = stasiun[i];
                      final stasiunId = s['id_stasiun'] as int;
                      final stasiunName = s['nama_stasiun'] ?? 'Stasiun';
                      final alamat = s['alamat_stasiun'] ?? '-';
                      final kapasitas = s['kapasitas_dock'] ?? 0;

                      // --- CARD STASIUN (GLASSMORPHISM) ---
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          // Background Transparan
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1), // Border tipis
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () => selectStation(stasiunId, stasiunName),
                          borderRadius: BorderRadius.circular(16),
                          splashColor: pinkNeon.withOpacity(0.2), // Splash Pink
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: pinkNeon, // Icon Pink Neon
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
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: pinkNeon, // Icon Panah Pink
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.only(left: 40, top: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Alamat Row
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
                                      // Kapasitas Row
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