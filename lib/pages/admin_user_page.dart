import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminUserPage extends StatefulWidget {
  const AdminUserPage({super.key});

  @override
  State<AdminUserPage> createState() => _AdminUserPageState();
}

class _AdminUserPageState extends State<AdminUserPage> {
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
          title: const Text('Edit User'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field('NIM/NIP', nimController, enabled: false),
              TextField(
                controller: passwordController,
                obscureText: !showPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Colors.blue[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                        showPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () =>
                        setStateDialog(() => showPassword = !showPassword),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: status,
                decoration: _inputDeco('Status Akun'),
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
                child: const Text('Batal')),
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

  Future<void> _deleteUser(String idNim) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus User'),
        content: const Text('Yakin ingin menghapus user ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
              style: _btnStyle(),
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

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.blue[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
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
        decoration: _inputDeco(label),
      ),
    );
  }

  ButtonStyle _btnStyle() => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF002D72),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Kelola User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: const Color(0xFF1a237e),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButtonFormField<String>(
                value: filterStatus,
                decoration: _inputDeco('Filter Status Akun').copyWith(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
                  ),
                ),
                dropdownColor: const Color(0xFF1a237e),
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: 'Semua', child: Text('Semua', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'aktif', child: Text('Aktif', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'nonaktif', child: Text('Nonaktif', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (val) {
                  filterStatus = val!;
                  applyFilter();
                },
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                  : filteredList.isEmpty
                      ? const Center(child: Text('Tidak ada user ditemukan', style: TextStyle(color: Colors.white70)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredList.length,
                          itemBuilder: (context, i) {
                            final user = filteredList[i];
                            final status = (user['status_akun'] ?? '-').toString();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.05)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: Icon(Icons.person,
                                    color: status.toLowerCase() == 'aktif'
                                        ? Colors.greenAccent.shade200
                                        : Colors.redAccent.shade100),
                                title: Text(
                                    '${user['id_NIM_NIP'] ?? 'User'} - ${user['nama'] ?? ''}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                subtitle: Text('Status: ${status.toUpperCase()}', style: const TextStyle(color: Colors.white70)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Color(0xFF6366F1)),
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
