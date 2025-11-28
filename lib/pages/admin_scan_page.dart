import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';

class AdminScanPage extends StatefulWidget {
  final Map<String, dynamic>? adminData;

  const AdminScanPage({super.key, this.adminData});

  @override
  State<AdminScanPage> createState() => _AdminScanPageState();
}

class _AdminScanPageState extends State<AdminScanPage> {
  final api = ApiService();
  bool _scanning = false;
  String? _lastCode;
  Map<String, dynamic>? _foundSepeda;
  bool _loading = false;
  final _manualCtrl = TextEditingController();

  Future<void> _searchByCode(String code) async {
    setState(() {
      _loading = true;
      _foundSepeda = null;
      _lastCode = code;
    });

    try {
      final all = await api.getAllSepeda();
      final candidate = all.firstWhere(
        (s) {
          final k = (s['kode_qr_sepeda'] ?? s['kode_qr'] ?? '').toString();
          return k == code;
        },
        orElse: () => {},
      );

      if (candidate.isNotEmpty) {
        setState(() => _foundSepeda = candidate);

        // create a log entry for this scan (if admin info available)
        try {
          final idPegawai = widget.adminData != null
              ? (widget.adminData!['id_pegawai'] ?? widget.adminData!['id_NIM_NIP'] ?? widget.adminData!['id'])
              : null;
          final kode = candidate['kode_qr_sepeda'] ?? '';
          final parsedIdPegawai = idPegawai is int
              ? idPegawai
              : (int.tryParse(idPegawai?.toString() ?? '') ?? null);

          final logRes = await api.createLogAktivitas(
            parsedIdPegawai,
            'scan_sepeda',
            'Scan sepeda id=${candidate['id_sepeda']} kode=$kode',
          );

          if (mounted) {
            if (logRes['success'] == true) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Sepeda ditemukan dan aktivitas dicatat')));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('⚠️ Sepeda ditemukan — log gagal: ${logRes['message']}')));
            }
          }
        } catch (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('⚠️ Sepeda ditemukan — gagal mencatat log: $e')));
        }

      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sepeda tidak ditemukan')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_scanning) return;
    final raw = capture.barcodes;
    if (raw.isEmpty) return;
    final code = raw.first.rawValue ?? raw.first.displayValue ?? '';
    if (code.isEmpty) return;

    setState(() => _scanning = true);

    await _searchByCode(code);

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _scanning = false);
  }

  Future<void> _updateSepedaStatus(int id, String status) async {
    final res = await api.updateStatusSepeda(id, status);
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status sepeda diperbarui')));
      // refresh details
      if (_lastCode != null) await _searchByCode(_lastCode!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${res['message']}')));
    }
  }

  @override
  void dispose() {
    _manualCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Sepeda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: const Color(0xFF0A1428),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A1428), Color(0xFF1a3a52)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A1428), Color(0xFF0f2342)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            if (kIsWeb)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    border: Border.all(color: Colors.amber, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Mode web: gunakan input manual untuk mencari sepeda.',
                          style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 240,
                child: MobileScanner(
                  onDetect: _onDetect,
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cari Sepeda',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manualCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Masukkan kode QR atau ID',
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.08),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ElevatedButton(
                          onPressed: _loading
                              ? null
                              : () async {
                                  final code = _manualCtrl.text.trim();
                                  if (code.isEmpty) return;
                                  await _searchByCode(code);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: _loading
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Cari', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _foundSepeda == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _loading ? Icons.hourglass_bottom : Icons.qr_code_2,
                            size: 56,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _loading ? 'Mencari sepeda...' : 'Tidak ada sepeda yang dipilih',
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.05)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.pedal_bike, color: Color(0xFF6366F1), size: 20),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Sepeda Terdeteksi', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
                                      Text(
                                        '#${_foundSepeda!['id_sepeda']}',
                                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow('Merk', _foundSepeda!['merk'] ?? _foundSepeda!['merk_model'] ?? '-'),
                            const SizedBox(height: 10),
                            _buildDetailRow('Tahun', _foundSepeda!['tahun']?.toString() ?? _foundSepeda!['tahun_pembelian']?.toString() ?? '-'),
                            const SizedBox(height: 10),
                            _buildDetailRow('Status', _foundSepeda!['status'] ?? _foundSepeda!['status_saat_ini'] ?? '-'),
                            const SizedBox(height: 10),
                            _buildDetailRow('Kondisi', _foundSepeda!['kondisi'] ?? _foundSepeda!['status_perawatan'] ?? '-'),
                            const SizedBox(height: 10),
                            _buildDetailRow('Kode QR', (_foundSepeda!['kode_qr_sepeda'] ?? '-').toString().length > 20
                                ? '${(_foundSepeda!['kode_qr_sepeda'] ?? '').toString().substring(0, 17)}...'
                                : _foundSepeda!['kode_qr_sepeda'] ?? '-'),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.2),
                                      border: Border.all(color: Colors.green, width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final id = int.tryParse(_foundSepeda!['id_sepeda'].toString()) ?? 0;
                                        if (id > 0) await _updateSepedaStatus(id, 'Tersedia');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: const Text('Tersedia', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 13)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.red.withOpacity(0.8), Colors.red.withOpacity(0.6)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final id = int.tryParse(_foundSepeda!['id_sepeda'].toString()) ?? 0;
                                        if (id > 0) await _updateSepedaStatus(id, 'Tidak Tersedia');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: const Text('Tidak Tersedia', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
