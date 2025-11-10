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
        title: const Text('Kelola User'),
        backgroundColor: const Color(0xFF002D72),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              value: filterStatus,
              decoration: _inputDeco('Filter Status Akun'),
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
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                    ? const Center(child: Text('Tidak ada user ditemukan'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredList.length,
                        itemBuilder: (context, i) {
                          final user = filteredList[i];
                          final status =
                              (user['status_akun'] ?? '-').toString();

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Icon(Icons.person,
                                  color: status.toLowerCase() == 'aktif'
                                      ? Colors.green
                                      : Colors.red),
                              title: Text(
                                  '${user['id_NIM_NIP'] ?? 'User'} - ${user['nama'] ?? ''}'),
                              subtitle: Text('Status: ${status.toUpperCase()}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () => _editUser(user),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteUser(
                                        user['id_NIM_NIP'].toString()),
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
    );
  }
}
