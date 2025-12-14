import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/guru_provider.dart';
import '../providers/kelas_provider.dart';
import '../providers/siswa_provider.dart';
import '../providers/nilai_provider.dart';
import '../providers/pengumuman_provider.dart';
import '../models/kelas.dart';
import '../routes.dart';
import '../widgets/empty_state.dart';
import 'classroom_page.dart';

class GuruDashboard extends StatefulWidget {
  const GuruDashboard({super.key});

  @override
  State<GuruDashboard> createState() => _GuruDashboardState();
}

class _GuruDashboardState extends State<GuruDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GuruProvider>(context, listen: false).loadGuru();
      Provider.of<KelasProvider>(context, listen: false).fetchKelas();
      Provider.of<SiswaProvider>(context, listen: false).loadSiswa();
      Provider.of<NilaiProvider>(context, listen: false).loadNilai();
      Provider.of<PengumumanProvider>(context, listen: false).loadPengumuman();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard Guru'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Dashboard', icon: Icon(Icons.dashboard)),
              Tab(text: 'Pengumuman', icon: Icon(Icons.campaign)),
            ],
          ),
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
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              },
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            GuruHomeTab(),
            GuruPengumumanTab(),
          ],
        ),
      ),
    );
  }
}

class GuruHomeTab extends StatefulWidget {
  const GuruHomeTab({super.key});

  @override
  State<GuruHomeTab> createState() => _GuruHomeTabState();
}

class _GuruHomeTabState extends State<GuruHomeTab> {
  String _selectedSemester = 'Semester 1';
  final List<String> _semesterOptions = [
    'Semester 1', 'Semester 2', 'Semester 3', 
    'Semester 4', 'Semester 5', 'Semester 6'
  ];

  String _deriveSemester(String subjectName) {
    if (subjectName.contains('X-1')) return 'Semester 1';
    if (subjectName.contains('X-2')) return 'Semester 2';
    if (subjectName.contains('XI-1')) return 'Semester 3';
    if (subjectName.contains('XI-2')) return 'Semester 4';
    if (subjectName.contains('XII-1')) return 'Semester 5';
    if (subjectName.contains('XII-2')) return 'Semester 6';
    return 'Semester 1';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final guruProvider = Provider.of<GuruProvider>(context);
    final kelasProvider = Provider.of<KelasProvider>(context);
    final siswaProvider = Provider.of<SiswaProvider>(context);
    final nilaiProvider = Provider.of<NilaiProvider>(context);
    final pengumumanProvider = Provider.of<PengumumanProvider>(context);

    final currentGuruNip = authProvider.currentUserId;
    final currentGuru = currentGuruNip != null
        ? guruProvider.guruList.firstWhereOrNull((g) => g.nip == currentGuruNip)
        : null;

    final latestPengumuman = pengumumanProvider.pengumumanList.isNotEmpty
        ? pengumumanProvider.pengumumanList.first
        : null;

    // Get all unique subjects taught by this guru across all classes
    final List<Map<String, dynamic>> guruSubjects = []; // {kelas, mataPelajaran}
    for (var kelas in kelasProvider.kelasList) {
      for (var mapel in kelas.mataPelajaranList) {
        if (mapel.guruNip == currentGuruNip) {
          guruSubjects.add({'kelas': kelas, 'mataPelajaran': mapel});
        }
      }
    }

    // Filter by selected semester
    final filteredSubjects = guruSubjects.where((item) {
      final mapel = item['mataPelajaran'] as MataPelajaran;
      return _deriveSemester(mapel.nama) == _selectedSemester;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(context, currentGuru?.nama ?? authProvider.currentUser?.name ?? 'Guru'),
          const SizedBox(height: 16),
          if (latestPengumuman != null)
            _buildLatestPengumuman(context, latestPengumuman),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kelas yang Anda Ajar',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: _selectedSemester,
                items: _semesterOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedSemester = newValue;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (filteredSubjects.isEmpty)
             const EmptyState(message: 'Tidak ada kelas untuk semester ini.', icon: Icons.class_outlined),
          ...filteredSubjects.map((item) {
            final kelas = item['kelas'] as Kelas;
            final mapel = item['mataPelajaran'] as MataPelajaran;
            
            // Stats
            final studentsInClass = siswaProvider.siswaList.where((s) => s.kelasId == kelas.id).toList();
            final totalStudents = studentsInClass.length;
            
            // Count graded students (those who have a Nilai entry for this mapel AND specific semester)
            // Note: Since mapel is semester-specific, checking by mapel.nama is sufficient.
            int gradedCount = 0;
            for (var student in studentsInClass) {
              final hasGrade = nilaiProvider.nilaiList.any((n) => 
                n.nis == student.nis && 
                n.mataPelajaran == mapel.nama &&
                n.nilaiAkhir != null // Check if actually graded (not null)
              );
              if (hasGrade) gradedCount++;
            }
            final unGradedCount = totalStudents - gradedCount;

            return _buildClassListItem(context, kelas, mapel, totalStudents, gradedCount, unGradedCount);
          }),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, String name) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.person, size: 30, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $name!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Selamat mengajar!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestPengumuman(BuildContext context, dynamic pengumuman) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        leading: const Icon(Icons.campaign),
        title: Text(pengumuman.judul, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          pengumuman.isi, 
          maxLines: 2, 
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          DefaultTabController.of(context).animateTo(1); // Switch to Pengumuman tab
        },
      ),
    );
  }

  Widget _buildClassListItem(BuildContext context, Kelas kelas, MataPelajaran mapel, int totalStudents, int graded, int ungraded) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.classroomPage,
            arguments: ClassroomPageArgs(kelas: kelas, mataPelajaran: mapel),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    kelas.nama.replaceAll(' ', '\n'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kelas.nama,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      mapel.nama,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildStatChip(context, Icons.people, '$totalStudents Siswa', Colors.blue),
                        _buildStatChip(context, Icons.check_circle, '$graded Dinilai', Colors.green),
                        _buildStatChip(context, Icons.pending, '$ungraded Belum', Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class GuruPengumumanTab extends StatelessWidget {
  const GuruPengumumanTab({super.key});

  @override
  Widget build(BuildContext context) {
    final pengumumanProvider = Provider.of<PengumumanProvider>(context);
    final list = pengumumanProvider.pengumumanList;

    if (list.isEmpty) {
      return const EmptyState(message: 'Belum ada pengumuman.', icon: Icons.notifications_off);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.judul,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy').format(item.tanggal),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const Divider(),
                Text(item.isi),
              ],
            ),
          ),
        );
      },
    );
  }
}