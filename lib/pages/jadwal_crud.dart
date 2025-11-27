import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/jadwal.dart';
import '../providers/jadwal_provider.dart';
import '../widgets/custom_input.dart';
import '../widgets/empty_state.dart';

class JadwalCrudPage extends StatefulWidget {
  const JadwalCrudPage({super.key});

  @override
  State<JadwalCrudPage> createState() => _JadwalCrudPageState();
}

class _JadwalCrudPageState extends State<JadwalCrudPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JadwalProvider>(context, listen: false).loadJadwal();
    });
  }

  void _showFormDialog({Jadwal? jadwal, int? index}) {
    final formKey = GlobalKey<FormState>();
    final hariController = TextEditingController(text: jadwal?.hari ?? '');
    final jamController = TextEditingController(text: jadwal?.jam ?? '');
    final mataPelajaranController = TextEditingController(text: jadwal?.mataPelajaran ?? '');
    final guruPengampuController = TextEditingController(text: jadwal?.guruPengampu ?? '');
    final kelasController = TextEditingController(text: jadwal?.kelas ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(jadwal == null ? 'Tambah Jadwal' : 'Edit Jadwal'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomInput(
                  label: 'Hari',
                  controller: hariController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Hari tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                CustomInput(
                  label: 'Jam (contoh: 07:00 - 08:30)',
                  controller: jamController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jam tidak boleh kosong';
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
                CustomInput(
                  label: 'Guru Pengampu',
                  controller: guruPengampuController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Guru Pengampu tidak boleh kosong';
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
                final provider = Provider.of<JadwalProvider>(context, listen: false);
                final newJadwal = Jadwal(
                  hari: hariController.text,
                  jam: jamController.text,
                  mataPelajaran: mataPelajaranController.text,
                  guruPengampu: guruPengampuController.text,
                  kelas: kelasController.text,
                );

                if (index == null) {
                  await provider.addJadwal(newJadwal);
                } else {
                  await provider.updateJadwal(index, newJadwal);
                }

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        jadwal == null
                            ? 'Jadwal berhasil ditambahkan'
                            : 'Jadwal berhasil diupdate',
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

  void _confirmDelete(int index, String mataPelajaran) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus jadwal $mataPelajaran?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<JadwalProvider>(context, listen: false);
              await provider.deleteJadwal(index);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Jadwal berhasil dihapus'),
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
    final provider = Provider.of<JadwalProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Pelajaran'),
      ),
      body: provider.jadwalList.isEmpty
          ? EmptyState(
              icon: Icons.schedule,
              message: 'Belum ada jadwal pelajaran',
              actionText: 'Tambah Jadwal',
              onActionPressed: () => _showFormDialog(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.jadwalList.length,
              itemBuilder: (context, index) {
                final jadwal = provider.jadwalList[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange[700],
                      child: Text(
                        jadwal.hari.substring(0, 1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(jadwal.mataPelajaran),
                    subtitle: Text(
                      '${jadwal.hari}, ${jadwal.jam}\nKelas: ${jadwal.kelas}\nGuru: ${jadwal.guruPengampu}',
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
                          _showFormDialog(jadwal: jadwal, index: index);
                        } else if (value == 'delete') {
                          _confirmDelete(index, jadwal.mataPelajaran);
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
