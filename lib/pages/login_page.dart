import 'dart:ui'; // Tambahkan ini untuk efek Blur/Glassmorphism
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'admin_dashboard.dart';
import 'user_dashboard.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // --- LOGIKA UTAMA (TIDAK DIUBAH) ---
  final TextEditingController nimController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;
  final ApiService api = ApiService();

  Future<void> login() async {
    setState(() => loading = true);
    final result = await api.login(nimController.text, passwordController.text);
    setState(() => loading = false);

    final success = result['success'] == true;
    final message = (result['message'] ?? 'Login gagal').toString();

    if (success) {
      final user = result['user'] is Map
          ? result['user'] as Map<String, dynamic>
          : <String, dynamic>{};
      final jenis = (user['jenis_pengguna'] ?? '').toString().toLowerCase();

      // Logika Log Aktivitas (Tetap dipertahankan)
      try {
        await api.createLogAktivitas(
          null,
          'Login',
          'User ${nimController.text} ($jenis) login ke sistem',
        );
      } catch (_) {}

      if (!mounted) return;
      if (jenis.contains('admin')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminDashboard(adminData: user)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => UserDashboard(userData: user)),
        );
      }
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.pinkAccent.shade700, // Merah/Pink Gelap untuk error
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    nimController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // --- TAMPILAN UI (TEMA BLACK PINK) ---
  @override
  Widget build(BuildContext context) {
    // Definisi Warna Tema
    final primaryColor = const Color(0xFFFF007F); // Neon Pink
    final secondaryColor = const Color(0xFF880E4F); // Dark Pink
    final blackBg = const Color(0xFF000000); // Hitam Pekat
    final darkCherry = const Color(0xFF25000B); // Merah Gelap

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Background Gradient: Hitam ke Cherry
          gradient: LinearGradient(
            colors: [blackBg, darkCherry],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),
                  
                  // --- HEADER: LOGO & JUDUL ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Container Logo dengan Glow Pink
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.9), 
                            width: 2
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            )
                          ]
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 50,
                          height: 50,
                          // color: Colors.white, // Uncomment jika logo asli hitam
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [Colors.white, primaryColor],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: const Text(
                              'CampusCycle',
                              style: TextStyle(
                                fontSize: 24, // Sedikit diperbesar
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            'Peminjaman Sepeda Kampus',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- KARTU LOGIN (GLASSMORPHISM) ---
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Efek Blur
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05), // Background transparan gelap
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              children: [
                                // Input NIM
                                TextField(
                                  controller: nimController,
                                  style: const TextStyle(color: Colors.white),
                                  cursorColor: primaryColor, // Kursor Pink
                                  decoration: InputDecoration(
                                    labelText: 'NIM/NIP',
                                    labelStyle: const TextStyle(color: Colors.white70),
                                    prefixIcon: const Icon(Icons.person, color: Colors.white70),
                                    filled: true,
                                    fillColor: Colors.black.withOpacity(0.3), // Input lebih gelap
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: primaryColor, width: 1.5), // Border Pink
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                
                                // Input Password
                                TextField(
                                  controller: passwordController,
                                  obscureText: obscurePassword,
                                  style: const TextStyle(color: Colors.white),
                                  cursorColor: primaryColor,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: const TextStyle(color: Colors.white70),
                                    prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        obscurePassword ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                                    ),
                                    filled: true,
                                    fillColor: Colors.black.withOpacity(0.3),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: primaryColor, width: 1.5),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                
                                // Tombol Login Gradient Pink
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: loading
                                      ? Center(
                                          child: CircularProgressIndicator(color: primaryColor)
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [secondaryColor, primaryColor], // Ungu ke Pink
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius: BorderRadius.circular(14),
                                            boxShadow: [
                                              BoxShadow(
                                                color: primaryColor.withOpacity(0.4),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: ElevatedButton(
                                            onPressed: login,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                            ),
                                            child: const Text(
                                              'LOGIN',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 20),
                                
                                // Tombol Daftar
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                                    );
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Belum Punya Akun? ',
                                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                                      children: [
                                        TextSpan(
                                          text: 'Daftar',
                                          style: TextStyle(
                                            color: primaryColor, // Teks Pink
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}