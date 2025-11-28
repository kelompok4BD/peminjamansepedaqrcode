import 'package:flutter/material.dart';
import 'admin_peminjaman_page.dart';
import 'admin_sepeda_page.dart';
import 'stasiun_page.dart';
import 'riwayatPemeliharaan_page.dart';
import 'pengaturan_page.dart';
import 'login_page.dart';
import 'admin_user_page.dart';
import 'admin_laporan_kerusakan_page.dart';
import 'admin_scan_page.dart';

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

  int _selectedIndex = 0;
  int? _drawerIndex; // null means not using drawer

  // Main nav bar pages: Transaksi, Sepeda, Scan, Stasiun
  late final List<Widget> _mainPages;
  // Drawer pages: Riwayat, User, Kerusakan, Pengaturan
  late final List<Widget> _drawerPages;
  late final List<String> _drawerTitles;
  late final List<IconData> _drawerIcons;

  @override
  void initState() {
    super.initState();

    _mainPages = [
      const AdminPeminjamanPage(),
      const AdminSepedaPage(),
      AdminScanPage(adminData: widget.adminData),
      const StasiunPage(),
    ];
    _drawerPages = [
      const RiwayatPage(),
      const AdminUserPage(),
      const AdminLaporanKerusakanPage(),
      const PengaturanPage(),
    ];
    _drawerTitles = [
      'Riwayat',
      'User',
      'Kerusakan',
      'Pengaturan',
    ];
    _drawerIcons = [
      Icons.history,
      Icons.people,
      Icons.warning,
      Icons.settings,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF312e81)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Menu Lainnya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(widget.adminData['nama']?.toString() ?? '', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              for (int i = 0; i < _drawerPages.length; i++)
                ListTile(
                  leading: Icon(_drawerIcons[i], color: Colors.white),
                  title: Text(_drawerTitles[i], style: const TextStyle(color: Colors.white)),
                  selected: _drawerIndex == i,
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF312e81)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _drawerIndex == null
            ? _mainPages[_selectedIndex]
            : _drawerPages[_drawerIndex!],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF6366F1),
          unselectedItemColor: Colors.white70,
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
              icon: Icon(Icons.qr_code_scanner),
              label: 'Scan',
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
