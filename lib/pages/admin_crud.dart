import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_input.dart';
import '../widgets/empty_state.dart';

class AdminCrudPage extends StatefulWidget {
  const AdminCrudPage({super.key});

  @override
  State<AdminCrudPage> createState() => _AdminCrudPageState();
}

class _AdminCrudPageState extends State<AdminCrudPage> {
  // No explicit load needed as AuthProvider loads users from Hive on init and methods access Hive directly
  
  void _showFormDialog({User? admin}) {
    final formKey = GlobalKey<FormState>();
    final nomorIndukController = TextEditingController(text: admin?.nomorInduk ?? '');
    final nameController = TextEditingController(text: admin?.name ?? '');
    final emailController = TextEditingController(text: admin?.email ?? '');
    final passwordController = TextEditingController(); // Empty for new/edit (unless resetting) 
    
    // Generate ID for new admin if not provided
    if (admin == null) {
      nomorIndukController.text = DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10);
    }

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withAlpha(76)),
            ),
          ),
          Center(
            child: AlertDialog(
              title: Text(admin == null ? 'Tambah Admin' : 'Edit Admin'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomInput(
                        label: 'Nama',
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      CustomInput(
                        label: 'Email',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!value.contains('@')) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      CustomInput(
                        label: 'ID Admin (Username)',
                        controller: nomorIndukController,
                        enabled: false, // Auto-generated/read-only
                      ),
                      if (admin == null) // Only show password field when creating new admin
                        CustomInput(
                          label: 'Password',
                          controller: passwordController,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                      if (admin != null)
                         Padding(
                           padding: const EdgeInsets.only(top: 8.0),
                           child: Text(
                             'Password tidak dapat diubah di sini. Gunakan fitur Reset Password jika diperlukan.',
                             style: TextStyle(color: Colors.grey[600], fontSize: 12),
                           ),
                         ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final provider = Provider.of<AuthProvider>(context, listen: false);
                      
                      if (admin == null) {
                         // Create new
                        final newAdmin = User(
                          nomorInduk: nomorIndukController.text,
                          password: passwordController.text,
                          role: 'Admin',
                          name: nameController.text,
                          email: emailController.text,
                          isPasswordSet: true,
                        );
                        final success = await provider.addAdmin(newAdmin);
                        if (!success && context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Gagal menambahkan admin. ID mungkin duplikat.'),
                              backgroundColor: Theme.of(context).colorScheme.error,
                            ),
                          );
                          return;
                        }
                      } else {
                        // Update existing
                        // Keep existing password
                        admin.name = nameController.text;
                        admin.email = emailController.text;
                        // nomorInduk is typically the key/ID, changing it is complex, let's assume it's fixed or handled like NIP update
                        // For this simple form, we just update mutable fields
                        await provider.updateAdmin(admin.nomorInduk, admin);
                      }

                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            admin == null
                                ? 'Admin berhasil ditambahkan'
                                : 'Data admin berhasil diupdate',
                          ),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String nomorInduk, String nama) {
    // Prevent deleting self
    final currentUserId = Provider.of<AuthProvider>(context, listen: false).currentUserId;
    if (currentUserId == nomorInduk) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Anda tidak dapat menghapus akun Anda sendiri.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withAlpha(76)),
            ),
          ),
          Center(
            child: AlertDialog(
              title: const Text('Konfirmasi Hapus'),
              content: Text('Apakah Anda yakin ingin menghapus admin $nama?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final provider = Provider.of<AuthProvider>(context, listen: false);
                    await provider.deleteAdmin(nomorInduk);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Admin berhasil dihapus'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                  child: const Text('Hapus'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context);
    final adminList = provider.getAllAdmins();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Admin'),
      ),
      body: adminList.isEmpty
          ? EmptyState(
              icon: Icons.admin_panel_settings,
              message: 'Belum ada data admin lain',
              actionText: 'Tambah Admin',
              onActionPressed: () => _showFormDialog(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: adminList.length,
              itemBuilder: (context, index) {
                final admin = adminList[index];
                final isSelf = admin.nomorInduk == provider.currentUserId;

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      color: isSelf ? Colors.green : Theme.of(context).colorScheme.primary,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Text('${admin.name} ${isSelf ? "(Saya)" : ""}'),
                    subtitle: Text(
                      'ID: ${admin.nomorInduk}\nEmail: ${admin.email ?? "-"}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        if (!isSelf)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Hapus', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showFormDialog(admin: admin);
                        } else if (value == 'delete') {
                          _confirmDelete(admin.nomorInduk, admin.name);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
