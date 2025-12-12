import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart'; // Add this import
import '../models/user.dart'; // Add this import
import '../providers/auth_provider.dart';
import '../widgets/custom_input.dart';
import '../routes.dart';
import '../providers/theme_provider.dart'; // Import ThemeProvider

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController(); // Renamed to _identifierController
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose(); // Renamed to _identifierController
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _identifierController.text, // Use identifier
        _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        final role = authProvider.currentRole;
        String route = AppRoutes.adminDashboard;

        if (role == 'Guru') {
          route = AppRoutes.guruDashboard;
        } else if (role == 'Siswa') {
          route = AppRoutes.siswaDashboard;
        }

        Navigator.of(context).pushReplacementNamed(route);
      } else if (mounted) {
        // Retrieve the identifier used for login
        final String identifier = _identifierController.text;
        final userBox = Hive.box<User>('users');

        // Try to find user by identifier (which could be nomorInduk or email)
        User? user;
        user = userBox.values.firstWhere(
          (u) => u.nomorInduk == identifier,
          orElse: () => User(nomorInduk: '', password: '', role: '') // Fallback
        );
        if (user.nomorInduk.isEmpty && identifier.contains('@')) { // If not found by nomorInduk, and identifier is likely an email
          user = userBox.values.firstWhere(
            (u) => u.email == identifier,
            orElse: () => User(nomorInduk: '', password: '', role: '') // Fallback
          );
        }


        String errorMessage = 'Email/Nomor Induk atau password salah!';
        if (user.nomorInduk.isNotEmpty && !user.isPasswordSet) {
          errorMessage = 'Anda perlu mengatur password Anda. Silakan gunakan fitur Lupa Password.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
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
                      Icon(Icons.school, size: 100, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 24),
                      Text(
                        'SIAKAD SEKOLAH',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sistem Informasi Akademik',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      CustomInput(
                        label: 'Email atau NIS/NIP', // Changed label
                        controller: _identifierController, // Changed controller
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email atau Nomor Induk tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomInput(
                        label: 'Password',
                        controller: _passwordController,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(AppRoutes.forgotPassword); // New route
                          },
                          child: const Text('Lupa Password?'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                              height: 56, // Taller button for fullscreen look
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary, // Primary button
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  elevation: 0,
                                ),
                                child: Text(
                                  'LOGIN',
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
                          const Text('Belum punya akun?'),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed(AppRoutes.register);
                            },
                            child: const Text('Daftar di sini'),
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

