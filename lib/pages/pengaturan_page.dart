import 'package:flutter/material.dart';
import '../services/api_service.dart';
// import '../theme/app_theme.dart'; // Dihapus/dikomentari agar menggunakan style lokal

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  // --- LOGIKA (TIDAK DIUBAH SAMA SEKALI) ---
  final api = ApiService();
  List<dynamic> pengaturan = [];
  Map<int, bool> _editingMode = {};
  Map<int, Map<String, dynamic>> _editedData = {};
  Map<int, bool> _saving = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    loadPengaturan();
  }

  Future<void> loadPengaturan() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await api.getPengaturan();
      setState(() {
        pengaturan = data;
        for (var item in data) {
          _editingMode[item['id_pengaturan']] = false;
          _editedData[item['id_pengaturan']] = {};
          _saving[item['id_pengaturan']] = false;
        }
      });
    } catch (e) {
      setState(() {
        pengaturan = [];
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggleEditMode(int id) {
    setState(() {
      _editingMode[id] = !(_editingMode[id] ?? false);
      if (_editingMode[id] == false) {
        _editedData[id] = {};
      }
    });
  }

  void _updateField(int id, String field, String value) {
    setState(() {
      _editedData[id] ??= {};
      _editedData[id]![field] = value;
    });
  }

  Future<void> _saveChanges(int id, dynamic item) async {
    if (_editedData[id]?.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada perubahan yang perlu disimpan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _saving[id] = true);

    try {
      final batasWaktuStr = _editedData[id]?['batas_waktu_pinjam'] ?? '';
      final tarifStr = _editedData[id]?['tarif_denda_per_jam'] ?? '';

      final dataToSend = <String, dynamic>{};

      if (batasWaktuStr.isNotEmpty) {
        final batasWaktu = int.tryParse(batasWaktuStr);
        if (batasWaktu == null) {
          throw 'Batas waktu harus berupa angka';
        }
        dataToSend['batas_waktu_pinjam'] = batasWaktu;
      }

      if (tarifStr.isNotEmpty) {
        final tarif = double.tryParse(tarifStr);
        if (tarif == null) {
          throw 'Tarif denda harus berupa angka';
        }
        dataToSend['tarif_denda_per_jam'] = tarif;
      }

      if (_editedData[id]?['informasi_kontak_darurat'] != null) {
        dataToSend['informasi_kontak_darurat'] =
            _editedData[id]!['informasi_kontak_darurat'];
      }

      if (_editedData[id]?['batas_wilayah_gps'] != null) {
        dataToSend['batas_wilayah_gps'] = _editedData[id]!['batas_wilayah_gps'];
      }

      await api.updatePengaturan(id, dataToSend);

      final index = pengaturan.indexWhere((p) => p['id_pengaturan'] == id);
      if (index != -1) {
        setState(() {
          // Convert LinkedMap to regular Map to avoid type errors
          final updatedItem = Map<String, dynamic>.from(pengaturan[index])
            ..addAll(dataToSend);
          pengaturan[index] = updatedItem;
          _editingMode[id] = false;
          _editedData[id] = {};
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pengaturan berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving[id] = false);
    }
  }

  // --- WARNA TEMA ---
  final pinkNeon = const Color(0xFFFF007F);
  final darkPink = const Color(0xFF880E4F);
  final blackBg = const Color(0xFF000000);
  final darkCherry = const Color(0xFF25000B);

  // --- TAMPILAN UI (TEMA BLACK PINK) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar Gradient Hitam ke Pink Gelap
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Pengaturan Sistem',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [blackBg, darkPink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      // Body Gradient Hitam ke Cherry Gelap
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [blackBg, darkCherry],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _loading
            ? Center(child: CircularProgressIndicator(color: pinkNeon))
            : (_error != null)
                ? _buildErrorWidget()
                : pengaturan.isEmpty
                    ? _buildEmptyWidget()
                    : _buildListView(),
      ),
    );
  }

  // --- WIDGET ERROR (DARK MODE) ---
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border:
                Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: Colors.redAccent),
              const SizedBox(height: 8),
              const Text('Gagal memuat pengaturan',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 6),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: loadPengaturan,
                icon: const Icon(Icons.refresh),
                label: const Text('Muat ulang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pinkNeon,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET KOSONG (DARK MODE) ---
  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border:
                Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.amber.shade700),
              const SizedBox(height: 8),
              const Text('Belum ada data pengaturan',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 6),
              const Text('Data pengaturan sistem belum dimasukkan ke database.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: loadPengaturan,
                icon: const Icon(Icons.refresh),
                label: const Text('Muat ulang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pinkNeon,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- LIST DATA (GLASSMORPHISM CARDS) ---
  Widget _buildListView() {
    return RefreshIndicator(
      onRefresh: loadPengaturan,
      color: pinkNeon,
      backgroundColor: Colors.grey[900],
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pengaturan.length,
        itemBuilder: (_, i) {
          final p = pengaturan[i];
          final id = p['id_pengaturan'];
          final isEditing = _editingMode[id] ?? false;
          final isSaving = _saving[id] ?? false;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05), // Background Transparan
              border: Border.all(
                  color: isEditing ? pinkNeon : Colors.white.withOpacity(0.15),
                  width: isEditing ? 2.0 : 1.0),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pengaturan #${p['id_pengaturan'] ?? i + 1}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18),
                      ),
                      if (!isEditing)
                        IconButton(
                          icon: Icon(Icons.edit,
                              color: pinkNeon, size: 20), // Icon Edit Pink
                          onPressed: () => _toggleEditMode(id),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  isEditing
                      ? _editableField(
                          id,
                          'Batas waktu pinjam',
                          'batas_waktu_pinjam',
                          p['batas_waktu_pinjam']?.toString() ?? '',
                          'Dalam jam',
                        )
                      : _infoRow(
                          Icons.access_time,
                          'Batas waktu pinjam',
                          '${_parseInt(p['batas_waktu_pinjam'])} jam',
                        ),
                  const SizedBox(height: 6),
                  isEditing
                      ? _editableField(
                          id,
                          'Tarif denda/jam',
                          'tarif_denda_per_jam',
                          p['tarif_denda_per_jam']?.toString() ?? '',
                          'Dalam rupiah',
                        )
                      : _infoRow(
                          Icons.monetization_on,
                          'Tarif denda/jam',
                          _formatCurrency(p['tarif_denda_per_jam']),
                        ),
                  const SizedBox(height: 6),
                  isEditing
                      ? _editableField(
                          id,
                          'Kontak darurat',
                          'informasi_kontak_darurat',
                          p['informasi_kontak_darurat']?.toString() ?? '',
                          'Nomor telepon',
                        )
                      : _infoRow(
                          Icons.phone,
                          'Kontak darurat',
                          p['informasi_kontak_darurat']?.toString() ?? '-',
                        ),
                  const SizedBox(height: 6),
                  isEditing
                      ? _editableField(
                          id,
                          'Batas wilayah (GPS)',
                          'batas_wilayah_gps',
                          p['batas_wilayah_gps']?.toString() ?? '',
                          'Format: lat,long',
                        )
                      : _infoRow(
                          Icons.location_on,
                          'Batas wilayah (GPS)',
                          p['batas_wilayah_gps']?.toString() ?? '-',
                        ),
                  if (isEditing) ...[
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed:
                              isSaving ? null : () => _toggleEditMode(id),
                          icon: const Icon(Icons.close),
                          label: const Text('Batal'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed:
                              isSaving ? null : () => _saveChanges(id, p),
                          icon: isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(isSaving ? 'Menyimpan...' : 'Simpan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pinkNeon, // Tombol Simpan Pink
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- EDITABLE FIELD WIDGET ---
  Widget _editableField(
      int id, String label, String field, String currentValue, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white, // Label Putih
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: TextEditingController(
              text: _editedData[id]?[field] ?? currentValue,
            ),
            onChanged: (value) => _updateField(id, field, value),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: pinkNeon, width: 2), // Focus Pink
              ),
              filled: true,
              fillColor:
                  Colors.black.withOpacity(0.3), // Background Input Gelap
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            style: const TextStyle(color: Colors.white),
            cursorColor: pinkNeon, // Kursor Pink
            keyboardType: field.contains('jam') || field.contains('tarif')
                ? TextInputType.number
                : TextInputType.text,
          ),
        ],
      ),
    );
  }

  // --- READ-ONLY INFO ROW ---
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white), // Value Putih
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    final s = v.toString();
    final i = int.tryParse(s);
    if (i != null) return i;
    final d = double.tryParse(s.replaceAll(',', '.'));
    if (d != null) return d.toInt();
    return 0;
  }

  String _formatCurrency(dynamic v) {
    if (v == null) return '-';
    try {
      final num value =
          (v is num) ? v : num.parse(v.toString().replaceAll(',', '.'));
      final s = value.toInt().toString();
      String rev = s.split('').reversed.join();
      final parts = <String>[];
      for (int i = 0; i < rev.length; i += 3) {
        parts.add(rev.substring(i, (i + 3).clamp(0, rev.length)));
      }
      final joined = parts
          .map((p) => p.split('').reversed.join())
          .toList()
          .reversed
          .join('.');
      return 'Rp $joined';
    } catch (_) {
      return v.toString();
    }
  }
}
