import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../routes.dart';

class GuruDashboard extends StatelessWidget {
  const GuruDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Guru'),
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (authProvider.currentUserRequestedRole != null &&
              authProvider.currentUserRequestStatus != 'approved')
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                String message = '';
                Color backgroundColor = Colors.amber;
                IconData icon = Icons.info_outline;

                if (authProvider.currentUserRequestStatus == 'pending') {
                  message =
                      'Permintaan role ${authProvider.currentUserRequestedRole} Anda sedang menunggu persetujuan admin.';
                  backgroundColor = Colors.blue.shade100;
                  icon = Icons.info_outline;
                } else if (authProvider.currentUserRequestStatus == 'rejected') {
                  message =
                      'Permintaan role ${authProvider.currentUserRequestedRole} Anda telah ditolak oleh admin.';
                  backgroundColor = Colors.red.shade100;
                  icon = Icons.error_outline;
                }

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  color: backgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(icon, color: Theme.of(context).colorScheme.onSurface),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            message,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            color: Theme.of(context).colorScheme.primary, // Primary color
                            child: Icon(
                              Icons.person,
                              size: 35,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selamat Datang, ${authProvider.currentUsername}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Role: ${authProvider.currentRole}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Menu Guru',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildMenuCard(
                          context,
                          icon: Icons.grade,
                          title: 'Input Nilai',
                          color: Theme.of(context).colorScheme.primary,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.nilaiInput);
                          },
                        ),
                        _buildMenuCard(
                          context,
                          icon: Icons.schedule,
                          title: 'Jadwal Pelajaran',
                          color: Theme.of(context).colorScheme.primary,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.jadwalCrud);
                          },
                        ),
                        _buildMenuCard(
                          context,
                          icon: Icons.announcement,
                          title: 'Pengumuman',
                          color: Theme.of(context).colorScheme.primary,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.pengumuman);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
