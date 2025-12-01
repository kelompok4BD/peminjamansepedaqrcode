import 'package:flutter/material.dart';
import 'admin_peminjaman_page.dart';
import 'admin_sepeda_page.dart';
import 'stasiun_page.dart';
import 'riwayatPemeliharaan_page.dart';
import 'pengaturan_page.dart';
import 'login_page.dart';
import 'admin_user_page.dart';
import 'admin_laporan_kerusakan_page.dart';
import 'admin_log_aktivitas_page.dart';

class AdminDashboard extends StatefulWidget {
  final Map<String, dynamic> adminData;

  const AdminDashboard({
    super.key,
    required this.adminData,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // --- LOGIKA (TIDAK DIUBAH SAMA SEKALI) ---
  int _selectedIndex = 0;
  int? _drawerIndex;

  late final List<Widget> _mainPages;
  late final List<Widget> _drawerPages;
  late final List<String> _drawerTitles;
  late final List<IconData> _drawerIcons;

  @override
  void initState() {
    super.initState();

    _mainPages = [
      const AdminPeminjamanPage(),
      const AdminSepedaPage(),
      const StasiunPage(),
    ];
    _drawerPages = [
      const RiwayatPage(),
      const AdminUserPage(),
      const AdminLaporanKerusakanPage(),
      const PengaturanPage(),
      const AdminLogAktivitasPage(),
    ];
    _drawerTitles = [
      'Riwayat',
      'User',
      'Kerusakan',
      'Pengaturan',
      'Log Aktivitas',
    ];
    _drawerIcons = [
      Icons.history,
      Icons.people,
      Icons.warning,
      Icons.settings,
      Icons.assignment_turned_in,
    ];
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logout berhasil')),
    );
  }

  // --- TAMPILAN UI (TEMA BLACK PINK) ---
  @override
  Widget build(BuildContext context) {
    // Definisi Warna Tema
    final pinkNeon = const Color(0xFFFF007F); // Pink Menyala
    final darkPink = const Color(0xFF880E4F); // Pink Gelap
    final blackBg = const Color(0xFF000000);  // Hitam Pekat
    final darkCherry = const Color(0xFF25000B); // Merah Kehitaman

    return Scaffold(
      extendBody: true,
      
      // --- APP BAR ---
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Ikon menu putih
        flexibleSpace: Container(
          decoration: BoxDecoration(
            // Gradient Header: Hitam ke Dark Pink
            gradient: LinearGradient(
              colors: [blackBg, darkPink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
      ),

      // --- DRAWER (MENU SAMPING) ---
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            // Background Drawer: Hitam Pekat
            gradient: LinearGradient(
              colors: [blackBg, darkCherry],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  // Header Drawer: Gradient Pink Dominan
                  gradient: LinearGradient(
                    colors: [darkPink, pinkNeon],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Menu Lainnya',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.adminData['nama']?.toString() ?? '',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              for (int i = 0; i < _drawerPages.length; i++)
                ListTile(
                  leading: Icon(
                    _drawerIcons[i],
                    // Warna Pink jika dipilih, Putih jika tidak
                    color: _drawerIndex == i ? pinkNeon : Colors.white,
                  ),
                  title: Text(
                    _drawerTitles[i],
                    style: TextStyle(
                      color: _drawerIndex == i ? pinkNeon : Colors.white,
                      fontWeight: _drawerIndex == i ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: _drawerIndex == i,
                  selectedTileColor: Colors.white.withOpacity(0.05),
                  onTap: () {
                    setState(() {
                      _drawerIndex = i;
                      Navigator.pop(context);
                    });
                  },
                ),
            ],
          ),
        ),
      ),

      // --- BODY UTAMA ---
      body: Container(
        decoration: BoxDecoration(
          // Background Body: Hitam ke Cherry Gelap
          gradient: LinearGradient(
            colors: [blackBg, darkCherry],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _drawerIndex == null
            ? _mainPages[_selectedIndex]
            : _drawerPages[_drawerIndex!],
      ),

      // --- BOTTOM NAVIGATION BAR ---
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
          selectedItemColor: pinkNeon, // Item aktif jadi Pink Neon
          unselectedItemColor: Colors.white60, // Item mati putih redup
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz),
              label: 'Transaksi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pedal_bike),
              label: 'Sepeda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: 'Stasiun',
            ),
          ],
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              _drawerIndex = null;
            });
          },
        ),
      ),
    );
  }
}