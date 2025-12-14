import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/siswa_provider.dart';
import '../providers/kelas_provider.dart';
import '../models/kelas.dart';
import '../routes.dart';
import '../widgets/empty_state.dart';
import 'classroom_page.dart'; // Import ClassroomPage

class SiswaDashboard extends StatefulWidget {
  const SiswaDashboard({super.key});

  @override
  State<SiswaDashboard> createState() => _SiswaDashboardState();
}

class _SiswaDashboardState extends State<SiswaDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SiswaProvider>(context, listen: false).loadSiswa();
      Provider.of<KelasProvider>(context, listen: false).fetchKelas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final siswaProvider = Provider.of<SiswaProvider>(context);
    final kelasProvider = Provider.of<KelasProvider>(context);

    final currentSiswaNis = authProvider.currentUserId;
    final currentSiswa = currentSiswaNis != null
        ? siswaProvider.getSiswaByNis(currentSiswaNis)
        : null;

    final Kelas? siswaKelas = (currentSiswa != null && currentSiswa.kelasId != null)
        ? kelasProvider.getKelasById(currentSiswa.kelasId!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Siswa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
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
                                'Selamat Datang, ${currentSiswa?.nama ?? authProvider.currentUsername}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Kelas: ${siswaKelas?.nama ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface.withAlpha(178), // Changed from withOpacity
                                ),                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Menu Siswa',
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
                          icon: Icons.announcement,
                          title: 'Pengumuman',
                          color: Theme.of(context).colorScheme.primary,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.pengumuman);
                          },
                        ),
                        _buildMenuCard(
                          context,
                          icon: Icons.assignment_turned_in,
                          title: 'Rapor Saya',
                          color: Theme.of(context).colorScheme.primary,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.studentReportCard);
                          },
                        ),
                        if (siswaKelas != null && siswaKelas.mataPelajaranList.isNotEmpty) // Only show if student is in a class with subjects
                          ...siswaKelas.mataPelajaranList.map((mapel) {
                                return _buildSubjectCard(context, siswaKelas, mapel);
                              }),
                        if (siswaKelas == null || siswaKelas.mataPelajaranList.isEmpty) // Show EmptyState if no class or no subjects
                          const EmptyState(message: 'Anda belum terdaftar di mata pelajaran manapun.', icon: Icons.school),
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

  Widget _buildSubjectCard(BuildContext context, Kelas kelas, MataPelajaran mapel) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.classroomPage,
            arguments: ClassroomPageArgs(kelas: kelas, mataPelajaran: mapel),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              width: double.infinity,
              color: Theme.of(context).colorScheme.secondary,
              alignment: Alignment.center,
              child: Text(
                mapel.nama,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Kelas: ${kelas.nama}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Guru: ${mapel.guruNama}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
