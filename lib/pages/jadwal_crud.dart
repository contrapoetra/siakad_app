import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../models/jadwal.dart';
import '../models/kelas.dart'; // Import Kelas
import '../providers/jadwal_provider.dart';
import '../providers/kelas_provider.dart'; // Import KelasProvider
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
      Provider.of<KelasProvider>(context, listen: false).fetchKelas(); // Load Kelas for dropdown
    });
  }

  void _showFormDialog({Jadwal? jadwal, int? index}) {
    final formKey = GlobalKey<FormState>();
    final hariController = TextEditingController(text: jadwal?.hari ?? '');
    final jamController = TextEditingController(text: jadwal?.jam ?? '');
    Kelas? selectedKelas;
    MataPelajaran? selectedMataPelajaran;
    
    if (jadwal != null) {
      final kelasProvider = Provider.of<KelasProvider>(context, listen: false);
      selectedKelas = kelasProvider.kelasList.firstWhere((k) => k.id == jadwal.kelasId);
      selectedMataPelajaran = selectedKelas.mataPelajaranList.firstWhere((mp) => mp.id == jadwal.mapelId);
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
                DropdownButtonFormField<Kelas>(
                  decoration: const InputDecoration(labelText: 'Pilih Kelas'),
                  initialValue: selectedKelas,
                  items: Provider.of<KelasProvider>(context).kelasList.map((k) {
                    return DropdownMenuItem(value: k, child: Text(k.nama));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedKelas = value;
                      selectedMataPelajaran = null; // Reset subject when class changes
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Kelas tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<MataPelajaran>(
                  decoration: const InputDecoration(labelText: 'Pilih Mata Pelajaran'),
                  initialValue: selectedMataPelajaran,
                  items: selectedKelas?.mataPelajaranList.map((mp) {
                    return DropdownMenuItem(value: mp, child: Text(mp.nama));
                  }).toList() ?? [],
                  onChanged: selectedKelas == null ? null : (value) {
                    setState(() {
                      selectedMataPelajaran = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
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
                      final provider = Provider.of<JadwalProvider>(context, listen: false);
                      final newJadwal = Jadwal(
                        id: jadwal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        hari: hariController.text,
                        jam: jamController.text,
                        mataPelajaran: selectedMataPelajaran!.nama,
                        guruPengampu: selectedMataPelajaran!.guruNama,
                        kelas: selectedKelas!.nama,
                        kelasId: selectedKelas!.id,
                        mapelId: selectedMataPelajaran!.id,
                      );

                      if (index == null) {
                        await provider.addJadwal(newJadwal);
                      } else {
                        await provider.updateJadwal(index, newJadwal);
                      }

                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            jadwal == null
                                ? 'Jadwal berhasil ditambahkan'
                                : 'Jadwal berhasil diupdate',
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
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

  void _confirmDelete(int index, String mataPelajaran) {
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
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Jadwal berhasil dihapus'),
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
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      color: Theme.of(context).primaryColor,
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
