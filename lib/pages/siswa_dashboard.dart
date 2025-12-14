import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/siswa_provider.dart';
import '../providers/kelas_provider.dart';
import '../providers/jadwal_provider.dart';
import '../providers/pengumuman_provider.dart';
import '../providers/nilai_provider.dart';
import '../models/kelas.dart';
import '../models/jadwal.dart';
import '../models/nilai.dart';
import '../routes.dart';
import '../widgets/empty_state.dart';
import 'classroom_page.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
      Provider.of<JadwalProvider>(context, listen: false).loadJadwal();
      Provider.of<PengumumanProvider>(context, listen: false).loadPengumuman();
      Provider.of<NilaiProvider>(context, listen: false).loadNilai(); // Load Nilai
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Changed to 3
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard Siswa'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Dashboard', icon: Icon(Icons.dashboard)),
              Tab(text: 'Rapor', icon: Icon(Icons.assignment)), // New Tab
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
            SiswaRaporTab(), // New Tab View
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

    final List<Jadwal> studentJadwal = siswaKelas != null
        ? jadwalProvider.getJadwalByKelas(siswaKelas.id)
        : [];
    
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
          Text(
            'Jadwal Pelajaran',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
          DefaultTabController.of(context).animateTo(2); // Switch to Pengumuman tab (index 2 now)
        },
      ),
    );
  }

  Widget _buildJadwalItem(BuildContext context, Jadwal jadwal, Kelas kelas) {
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

class SiswaRaporTab extends StatelessWidget {
  const SiswaRaporTab({super.key});

  Color _getPredikatColor(String predikat) {
    switch (predikat) {
      case 'A': return Colors.green;
      case 'B': return Colors.blue;
      case 'C': return Colors.orange;
      case 'D': return Colors.red;
      default: return Colors.grey;
    }
  }

  Future<void> generateSophisticatedPdf(List<Nilai> allGrades, String sName, String sNis, Map<String, double> ipkPerSemester) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('LAPORAN AKADEMIK SISWA', style: pw.TextStyle(font: font, fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Nama Siswa: $sName', style: pw.TextStyle(font: font, fontSize: 16)),
              pw.Text('NIS: $sNis', style: pw.TextStyle(font: font, fontSize: 16)),
              pw.SizedBox(height: 30),
              pw.Text('IPK Per Semester', style: pw.TextStyle(font: font, fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headers: ['Semester', 'IPK'],
                data: ipkPerSemester.entries.map((entry) {
                  return [entry.key, entry.value.toStringAsFixed(2)];
                }).toList(),
                border: pw.TableBorder.all(color: PdfColors.grey),
                headerStyle: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold),
                cellStyle: pw.TextStyle(font: font),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                },
              ),
              pw.SizedBox(height: 30),
              pw.Text('Detail Nilai Per Mata Pelajaran', style: pw.TextStyle(font: font, fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headers: ['Mata Pelajaran', 'Semester', 'Tugas', 'UTS', 'UAS', 'Kehadiran', 'Nilai Akhir', 'Predikat'],
                data: allGrades.map((nilai) {
                  return [
                    nilai.mataPelajaran,
                    nilai.semester,
                    nilai.nilaiTugas.toStringAsFixed(0),
                    nilai.nilaiUTS.toStringAsFixed(0),
                    nilai.nilaiUAS.toStringAsFixed(0),
                    nilai.nilaiKehadiran.toStringAsFixed(0),
                    nilai.nilaiAkhir.toStringAsFixed(0),
                    nilai.predikat,
                  ];
                }).toList(),
                border: pw.TableBorder.all(color: PdfColors.grey),
                headerStyle: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold),
                cellStyle: pw.TextStyle(font: font),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                  5: pw.Alignment.center,
                  6: pw.Alignment.center,
                  7: pw.Alignment.center,
                },
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Text('Tanggal Cetak: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}', style: pw.TextStyle(font: font, fontSize: 12)),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'rapor_$sNis.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final nilaiProvider = Provider.of<NilaiProvider>(context);
    final String? currentSiswaNis = authProvider.currentUserId;

    if (currentSiswaNis == null) {
      return const Center(child: Text('Data siswa tidak ditemukan.'));
    }

    final List<Nilai> studentGrades = nilaiProvider.getNilaiByNis(currentSiswaNis);

    if (studentGrades.isEmpty) {
      return const EmptyState(message: 'Belum ada data rapor.', icon: Icons.assignment_outlined);
    }

    final String studentName = studentGrades.first.namaSiswa;

    Map<String, List<Nilai>> gradesBySemester = {};
    for (var grade in studentGrades) {
      if (!gradesBySemester.containsKey(grade.semester)) {
        gradesBySemester[grade.semester] = [];
      }
      gradesBySemester[grade.semester]!.add(grade);
    }

    final sortedSemesters = gradesBySemester.keys.toList()..sort((a, b) {
      final aNum = int.tryParse(a.replaceAll('Semester ', '')) ?? 0;
      final bNum = int.tryParse(b.replaceAll('Semester ', '')) ?? 0;
      return aNum.compareTo(bNum);
    });

    List<FlSpot> spots = [];
    List<String> semesterLabels = [];
    double maxAverageGrade = 0;
    Map<String, double> ipkPerSemester = {};

    for (int i = 0; i < sortedSemesters.length; i++) {
      final semester = sortedSemesters[i];
      final gradesInSemester = gradesBySemester[semester]!;
      final averageGrade = gradesInSemester.map((n) => n.nilaiAkhir).reduce((a, b) => a + b) / gradesInSemester.length;
      
      spots.add(FlSpot(i.toDouble(), averageGrade));
      semesterLabels.add(semester);
      ipkPerSemester[semester] = averageGrade;

      if (averageGrade > maxAverageGrade) maxAverageGrade = averageGrade;
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => generateSophisticatedPdf(studentGrades, studentName, currentSiswaNis, ipkPerSemester),
        child: const Icon(Icons.picture_as_pdf),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'IPK Per Semester',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withAlpha((255 * 0.1).round())),
                  children: const [
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Semester', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('IPK', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                  ],
                ),
                ...ipkPerSemester.entries.map((entry) {
                  return TableRow(
                    children: [
                      Padding(padding: const EdgeInsets.all(8.0), child: Text(entry.key, textAlign: TextAlign.center)),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text(entry.value.toStringAsFixed(2), textAlign: TextAlign.center)),
                    ],
                  );
                }),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              'Tren IPK',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            if (spots.isNotEmpty)
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                             if (value.toInt() >= 0 && value.toInt() < semesterLabels.length) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(semesterLabels[value.toInt()], style: const TextStyle(fontSize: 10)),
                                );
                             }
                             return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey)),
                    minX: 0,
                    maxX: (spots.length - 1).toDouble(),
                    minY: 0,
                    maxY: 100,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Theme.of(context).colorScheme.primary,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: true, color: Theme.of(context).colorScheme.primary.withAlpha(50)),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 30),
            Text(
              'Detail Nilai',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(3), // Mapel
                1: FlexColumnWidth(1.2), // Tugas
                2: FlexColumnWidth(1.2), // UTS
                3: FlexColumnWidth(1.2), // UAS
                4: FlexColumnWidth(1.5), // Kehadiran
                5: FlexColumnWidth(1.5), // Akhir
                6: FlexColumnWidth(1), // Ket
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withAlpha((255 * 0.1).round())),
                  children: const [
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Mapel', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(4.0), child: Text('Tgs', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                    Padding(padding: EdgeInsets.all(4.0), child: Text('UTS', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                    Padding(padding: EdgeInsets.all(4.0), child: Text('UAS', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                    Padding(padding: EdgeInsets.all(4.0), child: Text('Hdr', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                    Padding(padding: EdgeInsets.all(4.0), child: Text('Akh', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                    Padding(padding: EdgeInsets.all(4.0), child: Text('Ket', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                  ],
                ),
                ...studentGrades.map((nilai) {
                  return TableRow(
                    children: [
                      Padding(padding: const EdgeInsets.all(8.0), child: Text(nilai.mataPelajaran)),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text(nilai.nilaiTugas.toStringAsFixed(0), textAlign: TextAlign.center)),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text(nilai.nilaiUTS.toStringAsFixed(0), textAlign: TextAlign.center)),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text(nilai.nilaiUAS.toStringAsFixed(0), textAlign: TextAlign.center)),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text(nilai.nilaiKehadiran.toStringAsFixed(0), textAlign: TextAlign.center)),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text(nilai.nilaiAkhir.toStringAsFixed(0), textAlign: TextAlign.center)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          nilai.predikat,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getPredikatColor(nilai.predikat),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
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
