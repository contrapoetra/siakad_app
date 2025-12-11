import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../models/guru.dart';
import '../providers/guru_provider.dart';
import '../widgets/custom_input.dart';
import '../widgets/empty_state.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class GuruCrudPage extends StatefulWidget {
  const GuruCrudPage({super.key});

  @override
  State<GuruCrudPage> createState() => _GuruCrudPageState();
}

class _GuruCrudPageState extends State<GuruCrudPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GuruProvider>(context, listen: false).loadGuru();
    });
  }

  void _showFormDialog({Guru? guru, int? index}) {
    final formKey = GlobalKey<FormState>();
    final nipController = TextEditingController(text: guru?.nip ?? '');
    final namaController = TextEditingController(text: guru?.nama ?? '');
    final emailController = TextEditingController(text: guru?.email ?? '');
    final tempatLahirController = TextEditingController(text: guru?.tempatLahir ?? '');
    final gelarController = TextEditingController(text: guru?.gelar ?? '');

    DateTime? selectedTanggalLahir = guru?.tanggalLahir;

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
              title: Text(guru == null ? 'Tambah Guru' : 'Edit Guru'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomInput(
                        label: 'NIP',
                        controller: nipController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'NIP tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      CustomInput(
                        label: 'Nama',
                        controller: namaController,
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
                        label: 'Tanggal Lahir',
                        controller: TextEditingController(text: selectedTanggalLahir != null ? DateFormat('dd/MM/yyyy').format(selectedTanggalLahir!) : ''),
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedTanggalLahir ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() { // setState for the dialog
                              selectedTanggalLahir = pickedDate;
                              (formKey.currentState as dynamic)?.setState(() {}); // Force rebuild of dialog content
                            });
                          }
                        },
                        validator: (value) {
                          if (selectedTanggalLahir == null) {
                            return 'Tanggal Lahir tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      CustomInput(
                        label: 'Tempat Lahir',
                        controller: tempatLahirController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tempat Lahir tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      CustomInput(
                        label: 'Gelar',
                        controller: gelarController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Gelar tidak boleh kosong';
                          }
                          return null;
                        },
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
                      if (selectedTanggalLahir == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Tanggal Lahir harus diisi.'),
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                        );
                        return;
                      }
                      
                      final provider = Provider.of<GuruProvider>(context, listen: false);
                      final newGuru = Guru(
                        nip: nipController.text,
                        nama: namaController.text,
                        email: emailController.text,
                        tanggalLahir: selectedTanggalLahir!,
                        tempatLahir: tempatLahirController.text,
                        gelar: gelarController.text,
                      );

                      if (index == null) {
                        await provider.addGuru(newGuru);
                      } else {
                        await provider.updateGuru(index, newGuru);
                      }

                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            guru == null
                                ? 'Guru berhasil ditambahkan'
                                : 'Guru berhasil diupdate',
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

  void _confirmDelete(int index, String nama) {
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
              content: Text('Apakah Anda yakin ingin menghapus data guru $nama?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final provider = Provider.of<GuruProvider>(context, listen: false);
                    await provider.deleteGuru(index);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Guru berhasil dihapus'),
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
    final provider = Provider.of<GuruProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Guru'),
      ),
      body: provider.guruList.isEmpty
          ? EmptyState(
              icon: Icons.person,
              message: 'Belum ada data guru',
              actionText: 'Tambah Guru',
              onActionPressed: () => _showFormDialog(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.guruList.length,
              itemBuilder: (context, index) {
                final guru = provider.guruList[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Text(
                        guru.nama.substring(0, 1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(guru.nama),
                    subtitle: Text(
                      'NIP: ${guru.nip}\nEmail: ${guru.email}\nTTL: ${DateFormat('dd/MM/yyyy').format(guru.tanggalLahir)} di ${guru.tempatLahir}\nGelar: ${guru.gelar}',
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
                          _showFormDialog(guru: guru, index: index);
                        } else if (value == 'delete') {
                          _confirmDelete(index, guru.nama);
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
