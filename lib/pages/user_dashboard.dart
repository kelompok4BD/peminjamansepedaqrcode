import 'package:flutter/material.dart';
import 'user_peminjaman_page.dart';

class UserDashboard extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserDashboard({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => UserPeminjamanPage(
            userId: userData['id_NIM_NIP'].toString(),
          ),
        ),
      );
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pedal_bike,
                size: 72,
                color: Color(0xFF002D72),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
