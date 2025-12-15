import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math'; // Import Random
import '../providers/auth_provider.dart';
import '../widgets/custom_input.dart';
import '../routes.dart';
import '../providers/theme_provider.dart'; // Import ThemeProvider

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomorIndukController = TextEditingController();
  final _nameController = TextEditingController(); // New controller for name
  String _selectedRole = 'Siswa';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateNomorInduk();
  }

  void _generateNomorInduk() {
    final random = Random();
    if (_selectedRole == 'Siswa') {
      // Pattern: 2024 + 3 random digits
      final uniqueSuffix = (random.nextInt(999) + 1).toString().padLeft(3, '0');
      _nomorIndukController.text = '2024$uniqueSuffix';
    } else if (_selectedRole == 'Guru') {
      // Pattern based on dummy data: 198501012010011001
      // Randomize year slightly (1980-1989) and suffix
      final year = 1980 + random.nextInt(10);
      final uniqueSuffix = (random.nextInt(999) + 1).toString().padLeft(3, '0');
      _nomorIndukController.text = '${year}01012010011$uniqueSuffix';
    } else {
      // Admin or other: Just generate a unique ID
       _nomorIndukController.text = DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nomorIndukController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Ensure _nomorIndukController.text is set
    if (_nomorIndukController.text.isEmpty) {
      _generateNomorInduk();
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        _nomorIndukController.text,
        _passwordController.text,
        _selectedRole,
        email: _emailController.text,
        name: _nameController.text, // Pass the new name field
      );

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        String message = 'Registrasi berhasil! Silakan login.';
        if (_selectedRole == 'Guru' || _selectedRole == 'Admin') {
          message = 'Registrasi berhasil, silakan login. Tunggu persetujuan oleh admin untuk role yang diminta';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registrasi gagal. NIS/NIP mungkin sudah terdaftar.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.person_add, size: 100, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 24),
                      Text(
                        'DAFTAR AKUN BARU',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      CustomInput(
                        label: 'Nama Lengkap', // New name input field
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
                      const SizedBox(height: 16),
                      CustomInput(
                        label: 'NIS/NIP',
                        controller: _nomorIndukController,
                        enabled: false, // Always disabled/read-only as it is auto-generated
                        validator: (value) {
                           // Since it's disabled and auto-generated, we just check if it's empty which shouldn't happen
                           if (value == null || value.isEmpty) {
                              return 'NIS/NIP tidak boleh kosong';
                           }
                           return null;
                        },
                      ),
                      CustomInput(
                        label: 'Password',
                        controller: _passwordController,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Daftar Sebagai',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        items: <String>['Siswa', 'Guru', 'Admin'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedRole = newValue!;
                            _generateNomorInduk(); // Call when role changes
                          });
                        },
                      ),
                      if (_selectedRole == 'Guru' || _selectedRole == 'Admin') ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Perhatian: Pendaftaran sebagai $_selectedRole memerlukan persetujuan Admin. Akun Anda akan berstatus sementara hingga disetujui.',
                                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  elevation: 0,
                                ),
                                child: Text(
                                  'DAFTAR',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Sudah punya akun?'),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                            },
                            child: const Text('Login di sini'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return IconButton(
                  icon: Icon(
                    themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
