import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../models/guru.dart';
import '../providers/guru_provider.dart';
import '../widgets/custom_input.dart';
import '../widgets/empty_state.dart';

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
    final mataPelajaranController = TextEditingController(text: guru?.mataPelajaran ?? '');

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.3)),
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
                  label: 'Mata Pelajaran',
                  controller: mataPelajaranController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mata Pelajaran tidak boleh kosong';
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
                      final provider = Provider.of<GuruProvider>(context, listen: false);
                      final newGuru = Guru(
                        nip: nipController.text,
                        nama: namaController.text,
                        mataPelajaran: mataPelajaranController.text,
                      );

                      if (index == null) {
                        await provider.addGuru(newGuru);
                      } else {
                        await provider.updateGuru(index, newGuru);
                      }

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              guru == null
                                  ? 'Guru berhasil ditambahkan'
                                  : 'Guru berhasil diupdate',
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                        );
                      }
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
              child: Container(color: Colors.black.withOpacity(0.3)),
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
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Guru berhasil dihapus'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
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
                      'NIP: ${guru.nip}\nMata Pelajaran: ${guru.mataPelajaran}',
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
