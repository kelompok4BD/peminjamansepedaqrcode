import 'package:flutter/material.dart';
// import '../theme/app_theme.dart'; // Bisa dihapus jika tidak dipakai
import 'user_stasiun_select_page.dart';
import 'user_peminjaman_aktif_page.dart';
import 'login_page.dart';

class UserDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UserDashboard({super.key, required this.userData});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  // --- LOGIKA (TIDAK DIUBAH) ---
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
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

    final userId = widget.userData['id_NIM_NIP'].toString();

    final List<Widget> pages = [
      UserStasiunSelectPage(userId: userId),
      UserPeminjamanAktifPage(userId: userId),
      // --- HALAMAN PROFIL (STYLE DARK) ---
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              color: Colors.white.withOpacity(0.05), // Background kartu transparan gelap
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withOpacity(0.1)), // Border tipis
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: pinkNeon, // Avatar Pink
                      child: Text(
                        (widget.userData['nama'] ?? '-')
                            .toString()
                            .split(' ')
                            .map((s) => s.isNotEmpty ? s[0] : '')
                            .take(2)
                            .join()
                            .toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.userData['nama'] ?? '-',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white), // Teks Putih
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ID: ${widget.userData['id_NIM_NIP'] ?? '-'}',
                      style: const TextStyle(color: Colors.white70), // Teks Abu Terang
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 8),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _logout,
                          icon: Icon(Icons.logout,
                              color: pinkNeon), // Ikon Pink
                          label: Text('Logout',
                              style: TextStyle(color: pinkNeon)), // Teks Pink
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: pinkNeon), // Border Pink
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      extendBody: true,
      // AppBar Gradient Hitam ke Pink Gelap
      appBar: AppBar(
        title: const Text('User Dashboard',
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
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
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
        child: pages[_selectedIndex],
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4), // Transparan gelap
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5)
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: pinkNeon, // Item aktif Pink Neon
          unselectedItemColor: Colors.white60, // Item tidak aktif putih redup
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.location_on), label: 'Cari Stasiun'),
            BottomNavigationBarItem(
                icon: Icon(Icons.pedal_bike), label: 'Peminjaman Aktif'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}