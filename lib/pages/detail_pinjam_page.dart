import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DetailPinjamPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> sepeda;

  const DetailPinjamPage(
      {super.key, required this.userId, required this.sepeda});

  @override
  State<DetailPinjamPage> createState() => _PinjamPageState();
}

class _PinjamPageState extends State<DetailPinjamPage> {
  final ApiService api = ApiService();
  String? selectedJaminan = 'KTP';
  bool isLoading = false;

  Future<void> handleKonfirmasi() async {
    setState(() => isLoading = true);

    final idUser = int.tryParse(widget.userId) ?? 0;
    final idSepeda = widget.sepeda['id_sepeda'];

    final res = await api.pinjamSepeda(
      idUser,
      idSepeda,
    );

    setState(() => isLoading = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Peminjaman berhasil!')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('❌ ${res['message'] ?? 'Gagal meminjam sepeda'}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sepeda = widget.sepeda;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Peminjaman'),
        backgroundColor: Colors.blue[800],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sepeda['merk_model'] ?? sepeda['merk'] ?? 'Sepeda',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
                'Tahun: ${sepeda['tahun_pembelian'] ?? sepeda['tahun'] ?? '-'}'),
            Text(
                'Kondisi: ${sepeda['status_perawatan'] ?? sepeda['kondisi'] ?? '-'}'),
            Text(
                'Status: ${sepeda['status_saat_ini'] ?? sepeda['status'] ?? '-'}'),
            if (sepeda['kode_qr_sepeda'] != null)
              Text('Kode QR: ${sepeda['kode_qr_sepeda']}'),
            const Divider(height: 32, thickness: 1.2),
            const Text(
              'Pilih Metode Jaminan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            RadioListTile<String>(
              title: const Text('KTP'),
              value: 'KTP',
              groupValue: selectedJaminan,
              onChanged: (val) => setState(() => selectedJaminan = val),
            ),
            RadioListTile<String>(
              title: const Text('KTM'),
              value: 'KTM',
              groupValue: selectedJaminan,
              onChanged: (val) => setState(() => selectedJaminan = val),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : handleKonfirmasi,
                icon: const Icon(Icons.check_circle_outline),
                label:
                    Text(isLoading ? 'Memproses...' : 'Konfirmasi Peminjaman'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
