import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../models/nilai.dart';
import '../providers/nilai_provider.dart';
import '../providers/siswa_provider.dart';
import '../providers/guru_provider.dart';
import '../widgets/custom_input.dart';
import '../widgets/empty_state.dart';

class NilaiInputPage extends StatefulWidget {
  const NilaiInputPage({super.key});

  @override
  State<NilaiInputPage> createState() => _NilaiInputPageState();
}

class _NilaiInputPageState extends State<NilaiInputPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NilaiProvider>(context, listen: false).loadNilai();
      Provider.of<SiswaProvider>(context, listen: false).loadSiswa();
      Provider.of<GuruProvider>(context, listen: false).loadGuru();
    });
  }

  void _showFormDialog({Nilai? nilai, int? index}) {
    final formKey = GlobalKey<FormState>();
    final siswaProvider = Provider.of<SiswaProvider>(context, listen: false);
    final guruProvider = Provider.of<GuruProvider>(context, listen: false);

    String? selectedNis = nilai?.nis;
    String? selectedMataPelajaran = nilai?.mataPelajaran;
    final tugasController = TextEditingController(
        text: nilai?.nilaiTugas.toString() ?? '');
    final utsController = TextEditingController(
        text: nilai?.nilaiUTS.toString() ?? '');
    final uasController = TextEditingController(
        text: nilai?.nilaiUAS.toString() ?? '');

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
              title: Text(nilai == null ? 'Input Nilai' : 'Edit Nilai'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: StatefulBuilder(
                    builder: (context, setDialogState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedNis,
                      decoration: InputDecoration(
                        labelText: 'Pilih Siswa',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      items: siswaProvider.siswaList.map((siswa) {
                        return DropdownMenuItem(
                          value: siswa.nis,
                          child: Text('${siswa.nama} - ${siswa.nis}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedNis = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Siswa harus dipilih';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedMataPelajaran,
                      decoration: InputDecoration(
                        labelText: 'Pilih Mata Pelajaran',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      items: guruProvider.guruList.map((guru) {
                        return DropdownMenuItem(
                          value: guru.gelar,
                          child: Text(guru.gelar),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedMataPelajaran = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mata Pelajaran harus dipilih';
                        }
                        return null;
                      },
                    ),
                    CustomInput(
                      label: 'Nilai Tugas (0-100)',
                      controller: tugasController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nilai Tugas tidak boleh kosong';
                        }
                        final nilai = double.tryParse(value);
                        if (nilai == null || nilai < 0 || nilai > 100) {
                          return 'Nilai harus antara 0-100';
                        }
                        return null;
                      },
                    ),
                    CustomInput(
                      label: 'Nilai UTS (0-100)',
                      controller: utsController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nilai UTS tidak boleh kosong';
                        }
                        final nilai = double.tryParse(value);
                        if (nilai == null || nilai < 0 || nilai > 100) {
                          return 'Nilai harus antara 0-100';
                        }
                        return null;
                      },
                    ),
                    CustomInput(
                      label: 'Nilai UAS (0-100)',
                      controller: uasController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nilai UAS tidak boleh kosong';
                        }
                        final nilai = double.tryParse(value);
                        if (nilai == null || nilai < 0 || nilai > 100) {
                          return 'Nilai harus antara 0-100';
                        }
                        return null;
                      },
                    ),
                  ],
                );
              },
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
                      final provider = Provider.of<NilaiProvider>(context, listen: false);
                      final siswa = siswaProvider.getSiswaByNis(selectedNis!);

                      final newNilai = Nilai(
                        nis: selectedNis!,
                        namaSiswa: siswa?.nama ?? '',
                        mataPelajaran: selectedMataPelajaran!,
                        nilaiTugas: double.parse(tugasController.text),
                        nilaiUTS: double.parse(utsController.text),
                        nilaiUAS: double.parse(uasController.text),
                      );

                      if (index == null) {
                        // Check if nilai already exists
                        final existingIndex = provider.getNilaiIndex(
                          selectedNis!,
                          selectedMataPelajaran!,
                        );
                        if (existingIndex != null) {
                          await provider.updateNilai(existingIndex, newNilai);
                        } else {
                          await provider.addNilai(newNilai);
                        }
                      } else {
                        await provider.updateNilai(index, newNilai);
                      }

                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            nilai == null
                                ? 'Nilai berhasil disimpan'
                                : 'Nilai berhasil diupdate',
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

  void _confirmDelete(int index, String namaSiswa, String mataPelajaran) {
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
              content: Text(
                  'Apakah Anda yakin ingin menghapus nilai $mataPelajaran untuk $namaSiswa?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final provider = Provider.of<NilaiProvider>(context, listen: false);
                    await provider.deleteNilai(index);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Nilai berhasil dihapus'),
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

  Color _getPredikatColor(String predikat) {
    switch (predikat) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NilaiProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Nilai'),
      ),
      body: provider.nilaiList.isEmpty
          ? EmptyState(
              icon: Icons.grade,
              message: 'Belum ada data nilai',
              actionText: 'Input Nilai',
              onActionPressed: () => _showFormDialog(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.nilaiList.length,
              itemBuilder: (context, index) {
                final nilai = provider.nilaiList[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      color: _getPredikatColor(nilai.predikat),
                      child: Text(
                        nilai.predikat,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(nilai.namaSiswa),
                    subtitle: Text(
                      'NIS: ${nilai.nis}\nMata Pelajaran: ${nilai.mataPelajaran}',
                    ),
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
                          _showFormDialog(nilai: nilai, index: index);
                        } else if (value == 'delete') {
                          _confirmDelete(
                              index, nilai.namaSiswa, nilai.mataPelajaran);
                        }
                      },
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Tugas:'),
                                Text(nilai.nilaiTugas.toStringAsFixed(1)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('UTS:'),
                                Text(nilai.nilaiUTS.toStringAsFixed(1)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('UAS:'),
                                Text(nilai.nilaiUAS.toStringAsFixed(1)),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Nilai Akhir:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  nilai.nilaiAkhir.toStringAsFixed(2),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
