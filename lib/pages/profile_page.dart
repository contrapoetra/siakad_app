import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/siswa_provider.dart';
import '../providers/guru_provider.dart';

import '../widgets/custom_input.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late String _currentRole;
  late String _currentNisNip;
  String? _requestedRole; // For displaying pending role requests
  String? _requestStatus; // For displaying pending role requests

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _currentRole = authProvider.currentRole ?? 'Siswa';
    _currentNisNip = authProvider.currentUserId ?? '';
    _requestedRole = authProvider.currentUserRequestedRole;
    _requestStatus = authProvider.currentUserRequestStatus;

    // Initialize controllers based on user role and data availability
    if (authProvider.currentUser != null) {
      _emailController = TextEditingController(text: authProvider.currentUser!.email ?? '');
    } else {
      _emailController = TextEditingController();
    }

    _nameController = TextEditingController(text: authProvider.currentUser?.name ?? _getNameBasedOnRole());
  }

  String _getNameBasedOnRole() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final siswaProvider = Provider.of<SiswaProvider>(context, listen: false);
    final guruProvider = Provider.of<GuruProvider>(context, listen: false);

    // Prioritize the name stored directly in the User object
    if (authProvider.currentUser?.name != null && authProvider.currentUser!.name.isNotEmpty) {
      return authProvider.currentUser!.name;
    }

    if (_currentRole == 'Siswa') {
      final siswa = siswaProvider.getSiswaByNis(_currentNisNip);
      return siswa?.nama ?? '';
    } else if (_currentRole == 'Guru') {
      final guru = guruProvider.getGuruByNip(_currentNisNip);
      return guru?.nama ?? '';
    }
    return ''; // Fallback for Admin or if data not found, or empty if no name is available
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser!; // Get current User object

      // Update email in User model
      user.email = _emailController.text;
      
      // Update name in respective Siswa or Guru model
      if (_currentRole == 'Siswa') {
        final siswaProvider = Provider.of<SiswaProvider>(context, listen: false);
        final siswa = siswaProvider.getSiswaByNis(_currentNisNip);
        if (siswa != null) {
          siswa.nama = _nameController.text;
          await siswaProvider.updateSiswa(siswaProvider.getSiswaIndex(siswa), siswa);
        }
      } else if (_currentRole == 'Guru') {
        final guruProvider = Provider.of<GuruProvider>(context, listen: false);
        final guru = guruProvider.getGuruByNip(_currentNisNip);
        if (guru != null) {
          guru.nama = _nameController.text;
          await guruProvider.updateGuru(guruProvider.getGuruIndex(guru), guru);
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diupdate!')),
      );
    }
  }

  Future<void> _requestNisNip() async {
    final newNipController = TextEditingController();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final guruProvider = Provider.of<GuruProvider>(context, listen: false);
    
    // Prefill with current NIP if available
    final currentGuru = guruProvider.getGuruByNip(_currentNisNip);
    newNipController.text = currentGuru?.nip ?? '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kelola NIP'),
          content: CustomInput(
            label: 'NIP',
            controller: newNipController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'NIP tidak boleh kosong';
              }
              // Add more robust NIP validation if needed (e.g., length, format)
              return null;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newNipController.text.isNotEmpty) { // Simple validation for now
                  final oldNip = _currentNisNip;
                  final newNip = newNipController.text;

                  // Update Guru's NIP
                  final guruUpdated = await guruProvider.updateGuruNip(oldNip, newNip);
                  if (!guruUpdated) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memperbarui NIP Guru.')));
                    if (mounted) Navigator.pop(context);
                    return;
                  }

                  // Update User's nomorInduk and session
                  await authProvider.updateUserNomorInduk(oldNip, newNip);
                  
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('NIP berhasil diperbarui!')));
                  setState(() {
                    _currentNisNip = newNip; // Update local state
                  });
                  if (!mounted) return; // Add another guard before Navigator.pop
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // final authProvider = Provider.of<AuthProvider>(context); // Removed: Unused local variable
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Role Anda: $_currentRole',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Nomor Induk Anda: $_currentNisNip',
                style: const TextStyle(fontSize: 16),
              ),

              if (_requestedRole != null && _requestStatus == 'pending')
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 16.0),
                  color: Colors.blue.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Permintaan role $_requestedRole Anda sedang menunggu persetujuan admin.',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_requestedRole != null && _requestStatus == 'rejected')
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 16.0),
                  color: Colors.red.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Permintaan role $_requestedRole Anda telah ditolak oleh admin.',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              CustomInput(
                label: 'Nama Lengkap',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomInput(
                label: 'Email',
                controller: _emailController,
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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  child: const Text('Update Profil'),
                ),
              ),
              if (_currentRole == 'Guru')
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _requestNisNip,
                      child: const Text('Kelola NIP'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
