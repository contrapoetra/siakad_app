import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/siswa_provider.dart';
import '../providers/kelas_provider.dart';
import '../providers/jadwal_provider.dart'; // Import JadwalProvider
import '../providers/pengumuman_provider.dart'; // Import PengumumanProvider
import '../models/kelas.dart';
import '../models/jadwal.dart';
import '../routes.dart';
import '../widgets/empty_state.dart';
import 'classroom_page.dart';
import 'package:intl/intl.dart';

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
      Provider.of<JadwalProvider>(context, listen: false).loadJadwal(); // Load Jadwal
      Provider.of<PengumumanProvider>(context, listen: false).loadPengumuman(); // Load Pengumuman
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard Siswa'),
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
            SiswaHomeTab(),
            SiswaPengumumanTab(),
          ],
        ),
      ),
    );
  }
}

class SiswaHomeTab extends StatelessWidget {
  const SiswaHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final siswaProvider = Provider.of<SiswaProvider>(context);
    final kelasProvider = Provider.of<KelasProvider>(context);
    final jadwalProvider = Provider.of<JadwalProvider>(context);
    final pengumumanProvider = Provider.of<PengumumanProvider>(context);

    final currentSiswaNis = authProvider.currentUserId;
    final currentSiswa = currentSiswaNis != null
        ? siswaProvider.getSiswaByNis(currentSiswaNis)
        : null;

    final Kelas? siswaKelas = (currentSiswa != null && currentSiswa.kelasId != null)
        ? kelasProvider.getKelasById(currentSiswa.kelasId!)
        : null;

    final latestPengumuman = pengumumanProvider.pengumumanList.isNotEmpty
        ? pengumumanProvider.pengumumanList.first
        : null;

    // Filter jadwal for student's class
    final List<Jadwal> studentJadwal = siswaKelas != null
        ? jadwalProvider.getJadwalByKelas(siswaKelas.id)
        : [];
    
    // Sort jadwal (simple sort by day then time, ideally needs better sorting)
    studentJadwal.sort((a, b) {
      const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      int dayA = days.indexOf(a.hari);
      int dayB = days.indexOf(b.hari);
      if (dayA != dayB) return dayA.compareTo(dayB);
      return a.jam.compareTo(b.jam);
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(context, currentSiswa?.nama ?? authProvider.currentUsername ?? 'Siswa', siswaKelas?.nama),
          const SizedBox(height: 16),
          if (latestPengumuman != null)
            _buildLatestPengumuman(context, latestPengumuman),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jadwal Pelajaran',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                   Navigator.pushNamed(context, AppRoutes.studentReportCard);
                },
                child: const Text('Lihat Rapor'),
              )
            ],
          ),
          const SizedBox(height: 8),
          if (studentJadwal.isEmpty)
             const EmptyState(message: 'Tidak ada jadwal pelajaran.', icon: Icons.calendar_today),
          ...studentJadwal.map((jadwal) => _buildJadwalItem(context, jadwal, siswaKelas!)),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, String name, String? className) {
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
                  className != null ? 'Kelas $className' : 'Belum ada kelas',
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

  Widget _buildJadwalItem(BuildContext context, Jadwal jadwal, Kelas kelas) {
    // Find mata pelajaran object to navigate to classroom
    // Ideally we should have it, but here we construct or find it from kelas
    final mapel = kelas.mataPelajaranList.firstWhere(
      (m) => m.id == jadwal.mapelId, 
      orElse: () => MataPelajaran(id: '', nama: jadwal.mataPelajaran, guruNip: '', guruNama: jadwal.guruPengampu),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: Text(jadwal.mataPelajaran.substring(0, 1), style: const TextStyle(color: Colors.white)),
        ),
        title: Text(jadwal.mataPelajaran, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${jadwal.hari}, ${jadwal.jam}\n${jadwal.guruPengampu}'),
        isThreeLine: true,
        onTap: () {
           if (mapel.id.isNotEmpty) {
             Navigator.pushNamed(
              context,
              AppRoutes.classroomPage,
              arguments: ClassroomPageArgs(kelas: kelas, mataPelajaran: mapel),
            );
           }
        },
      ),
    );
  }
}

class SiswaPengumumanTab extends StatelessWidget {
  const SiswaPengumumanTab({super.key});

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