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
            // Render QR in white by inverting colors of the default renderer
            ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                -1, 0, 0, 0, 255, // Red
                0, -1, 0, 0, 255, // Green
                0, 0, -1, 0, 255, // Blue
                0, 0, 0, 1, 0, // Alpha
              ]),
              child: QrImageView(
                data: qrCode,
                version: QrVersions.auto,
                size: 250,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Scan QR ini di stasiun untuk membuka kunci sepeda.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
