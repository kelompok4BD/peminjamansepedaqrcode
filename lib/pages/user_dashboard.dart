import 'package:flutter/material.dart';
import 'user_peminjaman_page.dart';
import 'pengaturan_user_page.dart';
import 'login_page.dart';

class UserDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UserDashboard({super.key, required this.userData});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
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

  @override
  Widget build(BuildContext context) {
    final userId = widget.userData['id_NIM_NIP'].toString();

    final List<Widget> pages = [
      UserPeminjamanPage(userId: userId),
      const PengaturanUserPage(),
      // improved profile page
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF002D72),
                      child: Text(
                        (widget.userData['nama'] ?? '-')
                            .toString()
                            .split(' ')
                            .map((s) => s.isNotEmpty ? s[0] : '')
                            .take(2)
                            .join()
                            .toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.userData['nama'] ?? '-',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ID: ${widget.userData['id_NIM_NIP'] ?? '-'}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.email, color: Colors.black54),
                        const SizedBox(width: 12),
                        Expanded(child: Text(widget.userData['email_kampus'] ?? '-')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.black54),
                        const SizedBox(width: 12),
                        Expanded(child: Text(widget.userData['no_hp_pengguna']?.toString() ?? '-')),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout, color: Color(0xFF002D72)),
                          label: const Text('Logout', style: TextStyle(color: Color(0xFF002D72))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF002D72)),
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
      appBar: AppBar(
        title: const Text('User Dashboard'),
        backgroundColor: const Color(0xFF002D72),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF002D72),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pedal_bike), label: 'Peminjaman'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Pengaturan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
