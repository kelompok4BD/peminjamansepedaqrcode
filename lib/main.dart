import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PeminjamanSepedaApp());
}

class PeminjamanSepedaApp extends StatelessWidget {
  const PeminjamanSepedaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Peminjaman Sepeda Kampus',
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.backgroundStart,
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent, elevation: 0),
      ),
      home: const LoginPage(),
    );
  }
}
