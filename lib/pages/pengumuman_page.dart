import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/pengumuman.dart';
import '../providers/pengumuman_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_input.dart';
import '../widgets/empty_state.dart';

class PengumumanPage extends StatefulWidget {
  const PengumumanPage({super.key});

  @override
  State<PengumumanPage> createState() => _PengumumanPageState();
}

class _PengumumanPageState extends State<PengumumanPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PengumumanProvider>(context, listen: false).loadPengumuman();
    });
  }

  void _showFormDialog({Pengumuman? pengumuman, int? index}) {
    final formKey = GlobalKey<FormState>();
    final judulController = TextEditingController(text: pengumuman?.judul ?? '');
    final isiController = TextEditingController(text: pengumuman?.isi ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pengumuman == null ? 'Tambah Pengumuman' : 'Edit Pengumuman'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomInput(
                  label: 'Judul',
                  controller: judulController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                CustomInput(
                  label: 'Isi Pengumuman',
                  controller: isiController,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Isi tidak boleh kosong';
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
                final provider = Provider.of<PengumumanProvider>(context, listen: false);
                final newPengumuman = Pengumuman(
                  judul: judulController.text,
                  isi: isiController.text,
                  tanggal: pengumuman?.tanggal ?? DateTime.now(),
                );

                if (index == null) {
                  await provider.addPengumuman(newPengumuman);
                } else {
                  await provider.updatePengumuman(index, newPengumuman);
                }

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        pengumuman == null
                            ? 'Pengumuman berhasil ditambahkan'
                            : 'Pengumuman berhasil diupdate',
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

  void _confirmDelete(int index, String judul) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus pengumuman "$judul"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<PengumumanProvider>(context, listen: false);
              await provider.deletePengumuman(index);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pengumuman berhasil dihapus'),
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

  void _showDetailDialog(Pengumuman pengumuman) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pengumuman.judul),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('dd MMMM yyyy, HH:mm').format(pengumuman.tanggal),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Text(pengumuman.isi),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PengumumanProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentRole == 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman'),
      ),
      body: provider.pengumumanList.isEmpty
          ? EmptyState(
              icon: Icons.announcement,
              message: 'Belum ada pengumuman',
              actionText: isAdmin ? 'Tambah Pengumuman' : null,
              onActionPressed: isAdmin ? () => _showFormDialog() : null,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.pengumumanList.length,
              itemBuilder: (context, index) {
                final pengumuman = provider.pengumumanList[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple[700],
                      child: const Icon(
                        Icons.announcement,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      pengumuman.judul,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          pengumuman.isi.length > 60
                              ? '${pengumuman.isi.substring(0, 60)}...'
                              : pengumuman.isi,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM yyyy').format(pengumuman.tanggal),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () => _showDetailDialog(pengumuman),
                    trailing: isAdmin
                        ? PopupMenuButton(
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
                                    Icon(Icons.delete,
                                        size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Hapus',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showFormDialog(
                                    pengumuman: pengumuman, index: index);
                              } else if (value == 'delete') {
                                _confirmDelete(index, pengumuman.judul);
                              }
                            },
                          )
                        : null,
                  ),
                );
              },
            ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _showFormDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
