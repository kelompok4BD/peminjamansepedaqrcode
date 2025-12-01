import 'dart:ui'; // Tambahkan ini untuk efek Glassmorphism
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // --- LOGIKA (TIDAK DIUBAH) ---
  final _formKey = GlobalKey<FormState>();
  final api = ApiService();

  final _nimController = TextEditingController();
  final _namaController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nimController.dispose();
    _namaController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final result = await api.register(
        _nimController.text,
        _namaController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          // Sesuaikan warna snackbar dengan tema
          backgroundColor: result['success'] ? Colors.pinkAccent : Colors.grey.shade900,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (result['success']) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- LOGO SECTION ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.9),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 60,
                          height: 60,
                          // color: Colors.white, // Uncomment jika logo hitam
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
                                fontSize: 24,
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
                  const SizedBox(height: 30),
                  
                  const Text(
                    'Buat Akun Baru',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- FORM CONTAINER (GLASSMORPHISM) ---
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.15), width: 1.5),
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
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildTextField(
                                    controller: _nimController,
                                    label: 'NIM/NIP',
                                    keyboardType: TextInputType.number,
                                    prefixIcon: Icons.person,
                                    primaryColor: primaryColor,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'NIM/NIP wajib diisi';
                                      }
                                      if (value.length < 5) {
                                        return 'NIM/NIP minimal 5 karakter';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _namaController,
                                    label: 'Nama Lengkap',
                                    prefixIcon: Icons.badge,
                                    primaryColor: primaryColor,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Nama wajib diisi';
                                      }
                                      if (value.length < 3) {
                                        return 'Nama minimal 3 karakter';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    obscureText: _obscurePassword,
                                    prefixIcon: Icons.lock,
                                    primaryColor: primaryColor,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () {
                                        setState(() =>
                                            _obscurePassword = !_obscurePassword);
                                      },
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Password wajib diisi';
                                      }
                                      if (value.length < 6) {
                                        return 'Password minimal 6 karakter';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _confirmPasswordController,
                                    label: 'Konfirmasi Password',
                                    obscureText: _obscureConfirm,
                                    prefixIcon: Icons.lock_outline,
                                    primaryColor: primaryColor,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirm
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () {
                                        setState(() =>
                                            _obscureConfirm = !_obscureConfirm);
                                      },
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Konfirmasi password wajib diisi';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Password tidak sama';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 30),
                                  
                                  // --- TOMBOL DAFTAR (GRADIENT PINK) ---
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: _isLoading
                                        ? Center(
                                            child: CircularProgressIndicator(
                                                color: primaryColor))
                                        : Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  secondaryColor, // Dark Pink
                                                  primaryColor    // Neon Pink
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: primaryColor.withOpacity(0.4),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: ElevatedButton(
                                              onPressed: _register,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                              ),
                                              child: const Text(
                                                'DAFTAR',
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
                                  
                                  // --- TOMBOL LOGIN ---
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginPage(),
                                        ),
                                      );
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'Sudah Punya Akun? ',
                                        style: const TextStyle(
                                            color: Colors.white70, fontSize: 14),
                                        children: [
                                          TextSpan(
                                            text: 'Login',
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGET ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Color primaryColor,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      cursorColor: primaryColor, // Kursor Pink
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: Colors.white70) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.black.withOpacity(0.3), // Input lebih gelap
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.5), // Border Pink
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }
}