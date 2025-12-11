import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kelas.dart';
import '../providers/kelas_provider.dart';
import '../providers/guru_provider.dart';
import '../widgets/empty_state.dart';

class KelasCrudPage extends StatefulWidget {
  const KelasCrudPage({super.key});

  @override
  State<KelasCrudPage> createState() => _KelasCrudPageState();
}

class _KelasCrudPageState extends State<KelasCrudPage> {
  @override
  Widget build(BuildContext context) {
    final kelasProvider = Provider.of<KelasProvider>(context);
    
    // Ensure data is loaded
    if (kelasProvider.kelasList.isEmpty) {
        // Ideally we check if it's loading or really empty, 
        // but for now relying on the provider's initial fetch.
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Kelas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Auto Assign Students & Teachers',
            onPressed: () async {
              final kelasProvider = Provider.of<KelasProvider>(context, listen: false);
              await kelasProvider.autoAssignStudentsAndTeachers(context: context);
              
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Auto assignment complete!')),
              );
            },
          ),
        ],
      ),
      body: kelasProvider.kelasList.isEmpty
          ? const EmptyState(icon: Icons.class_, message: 'Belum ada data kelas')
          : ListView.builder(
              itemCount: kelasProvider.kelasList.length,
              itemBuilder: (context, index) {
                final kelas = kelasProvider.kelasList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ExpansionTile(
                    title: Text('${kelas.nama} (${kelas.tingkat} - ${kelas.jurusan})'),
                    subtitle: Text('Jumlah Mata Pelajaran: ${kelas.mataPelajaranList.length}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showKelasDialog(context, kelas: kelas),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, kelas),
                        ),
                      ],
                    ),
                    children: kelas.mataPelajaranList.map((mapel) {
                      return ListTile(
                        title: Text(mapel.nama),
                        subtitle: Text('Guru: ${mapel.guruNama}'),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showKelasDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Kelas kelas) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kelas'),
        content: Text('Apakah Anda yakin ingin menghapus kelas ${kelas.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Provider.of<KelasProvider>(context, listen: false).deleteKelas(kelas.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kelas berhasil dihapus')),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showKelasDialog(BuildContext context, {Kelas? kelas}) {
    showDialog(
      context: context,
      builder: (context) => KelasDialog(kelas: kelas),
    );
  }
}

class KelasDialog extends StatefulWidget {
  final Kelas? kelas;

  const KelasDialog({super.key, this.kelas});

  @override
  State<KelasDialog> createState() => _KelasDialogState();
}

class _KelasDialogState extends State<KelasDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late String _selectedTingkat;
  late String _selectedJurusan;
  List<MataPelajaran> _mataPelajaranList = [];

  final List<String> _tingkatOptions = ['X', 'XI', 'XII'];
  final List<String> _jurusanOptions = ['IPA', 'IPS', 'Bahasa'];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.kelas?.nama ?? '');
    _selectedTingkat = widget.kelas?.tingkat ?? _tingkatOptions.first;
    _selectedJurusan = widget.kelas?.jurusan ?? _jurusanOptions.first;
    
    // Copy existing list or start empty
    if (widget.kelas != null) {
      // Create a shallow copy to avoid modifying the original list directly until save
      _mataPelajaranList = List.from(widget.kelas!.mataPelajaranList); 
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  void _addMataPelajaran() {
    setState(() {
      _mataPelajaranList.add(MataPelajaran(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: '',
        guruNip: '',
        guruNama: '',
      ));
    });
  }

  void _removeMataPelajaran(int index) {
    setState(() {
      _mataPelajaranList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final guruList = Provider.of<GuruProvider>(context).guruList;

    return AlertDialog(
      title: Text(widget.kelas == null ? 'Tambah Kelas' : 'Edit Kelas'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(labelText: 'Nama Kelas (e.g. X IPA 1)'),
                  validator: (value) => value == null || value.isEmpty ? 'Harus diisi' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedTingkat,
                  decoration: const InputDecoration(labelText: 'Tingkat'),
                  items: _tingkatOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setState(() => _selectedTingkat = val!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedJurusan,
                  decoration: const InputDecoration(labelText: 'Jurusan'),
                  items: _jurusanOptions.map((j) => DropdownMenuItem(value: j, child: Text(j))).toList(),
                  onChanged: (val) => setState(() => _selectedJurusan = val!),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mata Pelajaran', style: TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      onPressed: _addMataPelajaran,
                    ),
                  ],
                ),
                ..._mataPelajaranList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final mapel = entry.value;
                  return Card(
                    elevation: 0,
                    color: Colors.grey[100],
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: mapel.nama,
                                  decoration: const InputDecoration(labelText: 'Nama Mapel'),
                                  onChanged: (val) {
                                    mapel.nama = val;
                                  },
                                  validator: (val) => val == null || val.isEmpty ? 'Wajib' : null,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => _removeMataPelajaran(index),
                              ),
                            ],
                          ),
                          DropdownButtonFormField<String>(
                            value: mapel.guruNip.isNotEmpty && guruList.any((g) => g.nip == mapel.guruNip) ? mapel.guruNip : null,
                            decoration: const InputDecoration(labelText: 'Guru Pengampu'),
                            items: guruList.map((g) => DropdownMenuItem(
                              value: g.nip,
                              child: Text(g.nama),
                            )).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                final guru = guruList.firstWhere((g) => g.nip == val);
                                setState(() {
                                  mapel.guruNip = guru.nip;
                                  mapel.guruNama = guru.nama;
                                });
                              }
                            },
                            validator: (val) => val == null ? 'Pilih Guru' : null,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newKelas = Kelas(
                id: widget.kelas?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                nama: _namaController.text,
                tingkat: _selectedTingkat,
                jurusan: _selectedJurusan,
                mataPelajaranList: _mataPelajaranList,
              );
              
              if (widget.kelas == null) {
                Provider.of<KelasProvider>(context, listen: false).addKelas(newKelas);
              } else {
                Provider.of<KelasProvider>(context, listen: false).updateKelas(newKelas);
              }
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data kelas berhasil disimpan')),
              );
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
