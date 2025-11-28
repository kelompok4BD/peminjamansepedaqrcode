import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';
import 'detail_pinjam_page.dart';

class ScanQrPage extends StatefulWidget {
  final String userId;

  const ScanQrPage({super.key, required this.userId});

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  late final MobileScannerController cameraController;
  final ApiService api = ApiService();
  bool _scanning = true;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      cameraController = MobileScannerController();
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_scanning) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue ?? '';
    if (code.isEmpty) return;

    setState(() => _scanning = false);
    cameraController.stop();

    // show dialog with scanned value and option to lookup
    final proceed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('QR Terbaca'),
        content: Text('Kode: $code'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Buka')),
        ],
      ),
    );

    if (proceed != true) {
      // resume
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        cameraController.start();
        setState(() => _scanning = true);
      }
      return;
    }

    // lookup sepeda by kode QR
    final all = await api.getAllSepeda();
    Map<String, dynamic>? found;
    for (final s in all) {
      final candidate = <String, dynamic>{};
      // normalize keys
      candidate['id_sepeda'] = s['id_sepeda'] ?? s['id'] ?? s['id_sepeda'] ?? s['id_sepeda'];
      candidate['merk_model'] = s['merk_model'] ?? s['merk'] ?? s['merk_model'] ?? s['merk'];
      candidate['tahun_pembelian'] = s['tahun_pembelian'] ?? s['tahun'] ?? s['tahun_pembelian'];
      candidate['status_saat_ini'] = s['status_saat_ini'] ?? s['status'] ?? s['status_saat_ini'];
      candidate['status_perawatan'] = s['status_perawatan'] ?? s['kondisi'] ?? s['status_perawatan'];
      candidate['kode_qr_sepeda'] = s['kode_qr_sepeda'] ?? s['kode_qr'] ?? s['kode_qr_sepeda'];

      final kode = (candidate['kode_qr_sepeda'] ?? '').toString();
      if (kode.isNotEmpty && kode == code) {
        found = candidate;
        break;
      }
    }

    if (found == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sepeda dengan QR tersebut tidak ditemukan')));
      if (mounted) {
        cameraController.start();
        setState(() => _scanning = true);
      }
      return;
    }

    // navigate to detail pinjam for confirmation
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailPinjamPage(userId: widget.userId, sepeda: found!)),
    ).then((_) async {
      // when returning, resume scanning
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        cameraController.start();
        setState(() => _scanning = true);
      }
    });
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      cameraController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If on web, show not-supported message
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pindai QR Sepeda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF312e81)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, size: 56, color: Colors.white70),
                  const SizedBox(height: 12),
                  const Text(
                    'Fitur pemindaian QR hanya tersedia pada aplikasi mobile. Silakan buka aplikasi di perangkat Android atau iOS untuk menggunakan scanner.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pindai QR Sepeda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF312e81)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  MobileScanner(controller: cameraController, onDetect: _onDetect),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: const EdgeInsets.only(top: 24),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Arahkan kamera ke kode QR sepeda', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_scanning) {
                        await cameraController.toggleTorch();
                      }
                    },
                    icon: const Icon(Icons.flash_on),
                    label: const Text('Lampu'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await cameraController.switchCamera();
                    },
                    icon: const Icon(Icons.cameraswitch),
                    label: const Text('Ganti Kamera'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
