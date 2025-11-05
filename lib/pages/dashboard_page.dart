import 'package:flutter/material.dart';
import 'scan_qr_page.dart';
import 'peminjaman_page.dart';
import 'riwayat_page.dart';
import 'pengaturan_page.dart';
import 'stasiun_page.dart';
import 'login_page.dart'; // <-- tambahin ini

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  void _logout(BuildContext context) {
    // Balik ke halaman login dan hapus semua route sebelumnya
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );

    // Optional: tampilkan notifikasi kecil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Berhasil logout')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // make AppBar visually match register/login header (logo + name)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', width: 40, height: 40),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CampusCycle',
                  style: TextStyle(
                    color: Color(0xFF002D72),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Peminjaman Sepeda',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF002D72)),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      // body uses same gradient background as login/register
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'SELAMAT DATANG DI CAMPUSCYCLE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002D72),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    children: [
                      _menuCard(
                        context,
                        Icons.pedal_bike,
                        'Peminjaman',
                        const PeminjamanPage(),
                      ),
                      _menuCard(context, Icons.history, 'Riwayat Pemeliharaan',
                          const RiwayatPage()),
                      _menuCard(
                          context, Icons.settings, 'Pengaturan', const PengaturanPage()),
                      _menuCard(context, Icons.place, 'Stasiun', const StasiunPage()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuCard(BuildContext ctx, IconData icon, String title, Widget page) {
    return InkWell(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => page)),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: const Color(0xFF002D72)),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Color(0xFF002D72)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
