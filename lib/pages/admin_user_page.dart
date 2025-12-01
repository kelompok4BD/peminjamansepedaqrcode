import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminUserPage extends StatefulWidget {
  const AdminUserPage({super.key});

  @override
  State<AdminUserPage> createState() => _AdminUserPageState();
}

class _AdminUserPageState extends State<AdminUserPage> {
  // --- LOGIKA (TIDAK DIUBAH SAMA SEKALI) ---
  final ApiService api = ApiService();
  List<Map<String, dynamic>> userList = [];
  List<Map<String, dynamic>> filteredList = [];
  bool isLoading = false;
  String filterStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);
    try {
      final data = await api.getAllUser();
      setState(() {
        userList = List<Map<String, dynamic>>.from(data);
        applyFilter();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data user')),
      );
    }
  }

  void applyFilter() {
    setState(() {
      if (filterStatus == 'Semua') {
        filteredList = List.from(userList);
      } else {
        filteredList = userList
            .where((user) =>
                (user['status_akun'] ?? '').toString().toLowerCase() ==
                filterStatus.toLowerCase())
            .toList();
      }
    });
  }

  // --- WARNA TEMA ---
  final pinkNeon = const Color(0xFFFF007F);
  final darkBgDialog = const Color(0xFF1E1E1E);

  // --- STYLE INPUT (DARK MODE) ---
  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1), // Background transparan
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: pinkNeon, width: 1.5),
        ),
      );

  Widget _field(String label, TextEditingController c,
      {bool obscure = false, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        obscureText: obscure,
        enabled: enabled,
        style: const TextStyle(color: Colors.white), // Teks Putih
        cursorColor: pinkNeon,
        decoration: _inputDeco(label),
      ),
    );
  }

  // --- STYLE BUTTON (PINK NEON) ---
  ButtonStyle _btnStyle() => ElevatedButton.styleFrom(
        backgroundColor: pinkNeon,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  // --- DIALOG EDIT USER (UI DARK) ---
  Future<void> _editUser(Map<String, dynamic> user) async {
    final nimController =
        TextEditingController(text: user['id_NIM_NIP'].toString());
    final passwordController = TextEditingController(text: user['password']);
    String status = (user['status_akun'] ?? 'aktif').toLowerCase();
    bool showPassword = false;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: darkBgDialog, // Background hitam
          title: const Text('Edit User', style: TextStyle(color: Colors.white)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field('NIM/NIP', nimController, enabled: false),
              TextField(
                controller: passwordController,
                obscureText: !showPassword,
                style: const TextStyle(color: Colors.white),
                cursorColor: pinkNeon,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: pinkNeon, width: 1.5),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                        showPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70),
                    onPressed: () =>
                        setStateDialog(() => showPassword = !showPassword),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: status,
                decoration: _inputDeco('Status Akun'),
                dropdownColor: const Color(0xFF2C2C2C), // Dropdown gelap
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
                  DropdownMenuItem(value: 'nonaktif', child: Text('Nonaktif')),
                ],
                onChanged: (val) => status = val ?? 'aktif',
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal', style: TextStyle(color: Colors.white70))),
            ElevatedButton(
                style: _btnStyle(),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Simpan')),
          ],
        ),
      ),
    );

    if (ok == true) {
      final result = await api.updateUser(
        user['id_NIM_NIP'].toString(),
        user['nama'] ?? '',
        passwordController.text,
        status,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Data user diperbarui')),
      );

      fetchUsers();
    }
  }

  // --- DIALOG DELETE USER (UI DARK) ---
  Future<void> _deleteUser(String idNim) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: darkBgDialog,
        title: const Text('Hapus User', style: TextStyle(color: Colors.white)),
        content: const Text('Yakin ingin menghapus user ini?', 
            style: TextStyle(color: Colors.white70)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus')),
        ],
      ),
    );

    if (ok == true) {
      final result = await api.deleteUser(idNim);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'User berhasil dihapus')),
      );
      fetchUsers();
    }
  }

  // --- TAMPILAN UI UTAMA (TEMA BLACK PINK) ---
  @override
  Widget build(BuildContext context) {
    // Definisi Warna Tema
    final darkPink = const Color(0xFF880E4F);
    final blackBg = const Color(0xFF000000);
    final darkCherry = const Color(0xFF25000B);

    return Scaffold(
      // AppBar Gradient Hitam ke Pink Gelap
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Kelola User', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
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
        child: Column(
          children: [
            // --- FILTER DROPDOWN ---
            Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButtonFormField<String>(
                value: filterStatus,
                dropdownColor: const Color(0xFF2C2C2C), // Menu dropdown gelap
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco('Filter Status Akun').copyWith(
                  prefixIcon: Icon(Icons.filter_list, color: pinkNeon),
                ),
                items: const [
                  DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                  DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
                  DropdownMenuItem(value: 'nonaktif', child: Text('Nonaktif')),
                ],
                onChanged: (val) {
                  filterStatus = val!;
                  applyFilter();
                },
              ),
            ),
            
            // --- LIST USER ---
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: pinkNeon))
                  : filteredList.isEmpty
                      ? const Center(
                          child: Text('Tidak ada user ditemukan', 
                              style: TextStyle(color: Colors.white70)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredList.length,
                          itemBuilder: (context, i) {
                            final user = filteredList[i];
                            final status = (user['status_akun'] ?? '-').toString();

                            // Glassmorphism Card
                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05), // Transparan
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.1), width: 1.0),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: status.toLowerCase() == 'aktif'
                                        ? Colors.greenAccent.withOpacity(0.2)
                                        : Colors.redAccent.withOpacity(0.2),
                                  ),
                                  child: Icon(Icons.person,
                                      color: status.toLowerCase() == 'aktif'
                                          ? Colors.greenAccent
                                          : Colors.redAccent),
                                ),
                                title: Text(
                                    '${user['id_NIM_NIP'] ?? 'User'} - ${user['nama'] ?? ''}',
                                    style: const TextStyle(
                                        color: Colors.white, 
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text('Status: ${status.toUpperCase()}', 
                                    style: const TextStyle(color: Colors.white70)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: pinkNeon), // Icon Edit Pink
                                      onPressed: () => _editUser(user),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                      onPressed: () => _deleteUser(user['id_NIM_NIP'].toString()),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}