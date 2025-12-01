import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'qr_page.dart';

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

    final idUserRaw = widget.userId;
    final idSepedaRaw = widget.sepeda['id_sepeda'] ??
        widget.sepeda['id'] ??
        widget.sepeda['idSepeda'] ??
        widget.sepeda['ID'];

    final idUser = int.tryParse(idUserRaw.toString()) ?? 0;
    final idSepeda = int.tryParse(idSepedaRaw?.toString() ?? '') ?? 0;

    print(
        '🔵 handleKonfirmasi: userId=$idUserRaw (parsed=$idUser), sepedaId=$idSepedaRaw (parsed=$idSepeda), jaminan=$selectedJaminan');

    if (idUser <= 0 || idSepeda <= 0) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '❌ Data tidak valid - UserId: $idUser, SepedaId: $idSepeda')),
      );
      return;
    }

    try {
      print('🔷 Memanggil API dengan idUser=$idUser, idSepeda=$idSepeda');
      final res = await api.pinjamSepedaWithJaminan(
          idUser, idSepeda, selectedJaminan ?? 'KTP');
      print('✅ Response: $res');

      setState(() => isLoading = false);

      if (!mounted) return;

      if (res['success'] == true) {
        // Log aktivitas peminjaman
        final merkSepeda =
            widget.sepeda['merk_model'] ?? widget.sepeda['merk'] ?? 'Sepeda';
        await api.createLogAktivitas(
          null,
          'Peminjaman',
          'User ID $idUser meminjam sepeda ($merkSepeda) ID $idSepeda dengan jaminan ${selectedJaminan ?? "KTP"}',
        );

        // Extract QR code
        final qrCode = res['qr_code'] ??
            res['data']?['qr_code'] ??
            res['data']?['qr_data'] ??
            '';

        if (qrCode.isNotEmpty) {
          // Show QR code page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => QrDisplayPage(qrCode: qrCode)),
          ).then((_) {
            // Setelah dari QR page, back ke list
            Navigator.pop(context, true);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('✅ Peminjaman berhasil! (QR tidak tersedia)')),
          );
          Navigator.pop(context, true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('❌ ${res['message'] ?? 'Gagal meminjam sepeda'}')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sepeda = widget.sepeda;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Konfirmasi Peminjaman',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
        padding: const EdgeInsets.all(20),
        child: Card(
          color: const Color(0xFF1A1A2E),
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sepeda['merk_model'] ?? sepeda['merk'] ?? 'Sepeda',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                    'Tahun: ${sepeda['tahun_pembelian'] ?? sepeda['tahun'] ?? '-'}',
                    style: const TextStyle(color: AppColors.textSecondary)),
                Text(
                    'Kondisi: ${sepeda['status_perawatan'] ?? sepeda['kondisi'] ?? '-'}',
                    style: const TextStyle(color: AppColors.textSecondary)),
                Text(
                    'Status: ${sepeda['status_saat_ini'] ?? sepeda['status'] ?? '-'}',
                    style: const TextStyle(color: AppColors.textSecondary)),
                if (sepeda['kode_qr_sepeda'] != null)
                  Text('Kode QR: ${sepeda['kode_qr_sepeda']}',
                      style: const TextStyle(color: AppColors.textSecondary)),
                const Divider(
                    height: 32, thickness: 1.2, color: Color(0xFF424242)),
                const Text(
                  'Pilih Metode Jaminan',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                RadioListTile<String>(
                  title: const Text(
                    'KTP',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: 'KTP',
                  activeColor: Colors.white,
                  groupValue: selectedJaminan,
                  onChanged: (val) => setState(() => selectedJaminan = val),
                ),
                RadioListTile<String>(
                  title: const Text(
                    'KTM',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: 'KTM',
                  activeColor: Colors.white,
                  groupValue: selectedJaminan,
                  onChanged: (val) => setState(() => selectedJaminan = val),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : handleKonfirmasi,
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(
                        isLoading ? 'Memproses...' : 'Konfirmasi Peminjaman'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
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
        ),
      ),
    );
  }
}
