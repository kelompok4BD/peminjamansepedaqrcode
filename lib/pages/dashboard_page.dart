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
      appBar: AppBar(
        title: const Text("Dashboard Sepeda Kampus"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
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
    );
  }

  Widget _menuCard(BuildContext ctx, IconData icon, String title, Widget page) {
    return InkWell(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => page)),
      child: Card(
        elevation: 3,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: Colors.blue),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
