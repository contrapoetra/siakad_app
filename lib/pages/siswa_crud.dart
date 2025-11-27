import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/siswa.dart';
import '../providers/siswa_provider.dart';
import '../widgets/custom_input.dart';
import '../widgets/empty_state.dart';

class SiswaCrudPage extends StatefulWidget {
  const SiswaCrudPage({super.key});

  @override
  State<SiswaCrudPage> createState() => _SiswaCrudPageState();
}

class _SiswaCrudPageState extends State<SiswaCrudPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SiswaProvider>(context, listen: false).loadSiswa();
    });
  }

  void _showFormDialog({Siswa? siswa, int? index}) {
    final formKey = GlobalKey<FormState>();
    final nisController = TextEditingController(text: siswa?.nis ?? '');
    final namaController = TextEditingController(text: siswa?.nama ?? '');
    final kelasController = TextEditingController(text: siswa?.kelas ?? '');
    final jurusanController = TextEditingController(text: siswa?.jurusan ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(siswa == null ? 'Tambah Siswa' : 'Edit Siswa'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomInput(
                  label: 'NIS',
                  controller: nisController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'NIS tidak boleh kosong';
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
                  label: 'Kelas',
                  controller: kelasController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kelas tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                CustomInput(
                  label: 'Jurusan',
                  controller: jurusanController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jurusan tidak boleh kosong';
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
                final provider = Provider.of<SiswaProvider>(context, listen: false);
                final newSiswa = Siswa(
                  nis: nisController.text,
                  nama: namaController.text,
                  kelas: kelasController.text,
                  jurusan: jurusanController.text,
                );

                if (index == null) {
                  await provider.addSiswa(newSiswa);
                } else {
                  await provider.updateSiswa(index, newSiswa);
                }

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        siswa == null
                            ? 'Siswa berhasil ditambahkan'
                            : 'Siswa berhasil diupdate',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int index, String nama) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus data siswa $nama?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<SiswaProvider>(context, listen: false);
              await provider.deleteSiswa(index);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Siswa berhasil dihapus'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SiswaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Siswa'),
      ),
      body: provider.siswaList.isEmpty
          ? EmptyState(
              icon: Icons.people,
              message: 'Belum ada data siswa',
              actionText: 'Tambah Siswa',
              onActionPressed: () => _showFormDialog(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.siswaList.length,
              itemBuilder: (context, index) {
                final siswa = provider.siswaList[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[700],
                      child: Text(
                        siswa.nama.substring(0, 1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(siswa.nama),
                    subtitle: Text(
                      'NIS: ${siswa.nis}\nKelas: ${siswa.kelas} ${siswa.jurusan}',
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
                          _showFormDialog(siswa: siswa, index: index);
                        } else if (value == 'delete') {
                          _confirmDelete(index, siswa.nama);
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
