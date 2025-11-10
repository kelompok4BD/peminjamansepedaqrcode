import 'package:flutter/material.dart';
import 'pages/login_page.dart';

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
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const LoginPage(),
    );
  }
}
