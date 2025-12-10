import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../models/siswa.dart';
import '../providers/siswa_provider.dart';
import '../widgets/custom_input.dart';
import '../widgets/empty_state.dart';
import 'package:intl/intl.dart'; // Import for date formatting

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
    final emailController = TextEditingController(text: siswa?.email ?? '');
    final tempatLahirController = TextEditingController(text: siswa?.tempatLahir ?? '');
    final namaAyahController = TextEditingController(text: siswa?.namaAyah ?? '');
    final namaIbuController = TextEditingController(text: siswa?.namaIbu ?? '');
    final kelasController = TextEditingController(text: siswa?.kelas ?? '');
    final jurusanController = TextEditingController(text: siswa?.jurusan ?? '');

    DateTime? selectedTanggalLahir = siswa?.tanggalLahir;

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
                        label: 'Nama Ayah',
                        controller: namaAyahController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama Ayah tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      CustomInput(
                        label: 'Nama Ibu',
                        controller: namaIbuController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama Ibu tidak boleh kosong';
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
                      if (selectedTanggalLahir == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Tanggal Lahir harus diisi.'),
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                        );
                        return;
                      }

                      final provider = Provider.of<SiswaProvider>(context, listen: false);
                      final newSiswa = Siswa(
                        nis: nisController.text,
                        nama: namaController.text,
                        email: emailController.text,
                        tanggalLahir: selectedTanggalLahir!,
                        tempatLahir: tempatLahirController.text,
                        namaAyah: namaAyahController.text,
                        namaIbu: namaIbuController.text,
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
                            backgroundColor: Theme.of(context).colorScheme.primary,
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
                        SnackBar(
                          content: Text('Siswa berhasil dihapus'),
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
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      color: Theme.of(context).primaryColor,
                      child: Text(
                        siswa.nama.substring(0, 1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(siswa.nama),
                    subtitle: Text(
                      'NIS: ${siswa.nis}\nEmail: ${siswa.email}\nTTL: ${DateFormat('dd/MM/yyyy').format(siswa.tanggalLahir)} di ${siswa.tempatLahir}\nOrang Tua: ${siswa.namaAyah} & ${siswa.namaIbu}\nKelas: ${siswa.kelas} ${siswa.jurusan}',
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
