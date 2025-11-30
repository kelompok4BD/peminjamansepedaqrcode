import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrDisplayPage extends StatelessWidget {
  final String qrCode;
  const QrDisplayPage({super.key, required this.qrCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR untuk Buka Kunci')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrCode,
              version: QrVersions.auto,
              size: 250,
            ),
            const SizedBox(height: 20),
            const Text(
              "Scan QR ini di stasiun untuk membuka kunci sepeda.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
