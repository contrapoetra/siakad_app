import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/siswa_provider.dart';
import '../providers/jadwal_provider.dart';
import '../providers/nilai_provider.dart';
import '../routes.dart';
import '../widgets/empty_state.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fl_chart/fl_chart.dart'; // Added for student grade charts

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
      Provider.of<JadwalProvider>(context, listen: false).loadJadwal();
      Provider.of<NilaiProvider>(context, listen: false).loadNilai();
    });
  }

  Future<void> _generatePdf(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final siswaProvider = Provider.of<SiswaProvider>(context, listen: false);
    final nilaiProvider = Provider.of<NilaiProvider>(context, listen: false);

    final siswa = siswaProvider.getSiswaByNis(authProvider.currentUserId!);
    final nilaiList = nilaiProvider.getNilaiByNis(authProvider.currentUserId!);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'RAPOR SISWA',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('NIS: ${siswa?.nis ?? '-'}'),
              pw.Text('Nama: ${siswa?.nama ?? '-'}'),
              pw.Text('Kelas: ${siswa?.kelas ?? '-'}'),
              pw.Text('Jurusan: ${siswa?.jurusan ?? '-'}'),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Mata Pelajaran',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Tugas',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('UTS',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('UAS',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Nilai Akhir',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Predikat',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...nilaiList.map((nilai) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(nilai.mataPelajaran),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(nilai.nilaiTugas.toStringAsFixed(1)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(nilai.nilaiUTS.toStringAsFixed(1)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(nilai.nilaiUAS.toStringAsFixed(1)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(nilai.nilaiAkhir.toStringAsFixed(2)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(nilai.predikat),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final siswaProvider = Provider.of<SiswaProvider>(context);
    final jadwalProvider = Provider.of<JadwalProvider>(context);
    final nilaiProvider = Provider.of<NilaiProvider>(context);

    final siswa = siswaProvider.getSiswaByNis(authProvider.currentUserId ?? '');
    final jadwalList = siswa != null
        ? jadwalProvider.getJadwalByKelas('${siswa.kelas} ${siswa.jurusan}')
        : [];
    final nilaiList = nilaiProvider.getNilaiByNis(authProvider.currentUserId ?? '');

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard Siswa'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.schedule), text: 'Jadwal'),
              Tab(icon: Icon(Icons.grade), text: 'Nilai'),
              Tab(icon: Icon(Icons.announcement), text: 'Pengumuman'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                authProvider.logout();
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Tab Jadwal
            _buildJadwalTab(jadwalList),
            // Tab Nilai
            _buildNilaiTab(nilaiList),
            // Tab Pengumuman
            _buildPengumumanTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildJadwalTab(List jadwalList) {
    if (jadwalList.isEmpty) {
      return const EmptyState(
        icon: Icons.schedule,
        message: 'Belum ada jadwal pelajaran',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jadwalList.length,
      itemBuilder: (context, index) {
        final jadwal = jadwalList[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[700],
              child: Text(
                jadwal.hari.substring(0, 1),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(jadwal.mataPelajaran),
            subtitle: Text(
              '${jadwal.hari}, ${jadwal.jam}\n${jadwal.guruPengampu}',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildNilaiTab(List nilaiList) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rapor Semester',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: nilaiList.isEmpty ? null : () => _generatePdf(context),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export PDF'),
              ),
            ],
          ),
        ),
        // Grade Chart Section
        nilaiList.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Grafik Nilai Akhir',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              barGroups: _getBarChartData(nilaiList),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index >= 0 && index < nilaiList.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            nilaiList[index].mataPelajaran,
                                            style: const TextStyle(fontSize: 10),
                                            textAlign: TextAlign.center,
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                    interval: 1,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    },
                                    interval: 20,
                                  ),
                                ),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    return BarTooltipItem(
                                      '${nilaiList[group.x.toInt()].mataPelajaran}\n',
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: rod.toY.toStringAsFixed(2),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                  tooltipPadding: const EdgeInsets.all(8), // Add padding for better look
                                  tooltipBorder: BorderSide(color: Theme.of(context).colorScheme.primary), // Add a border
                                  tooltipRoundedRadius: 8, // Rounded corners for tooltip
                                ),
                              ),
                              maxY: 100,
                              minY: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(), // Hide chart if no data

        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Mata Pelajaran')),
                    DataColumn(label: Text('Tugas')),
                    DataColumn(label: Text('UTS')),
                    DataColumn(label: Text('UAS')),
                    DataColumn(label: Text('Nilai Akhir')),
                    DataColumn(label: Text('Predikat')),
                  ],
                  rows: nilaiList.map((nilai) {
                    return DataRow(
                      cells: [
                        DataCell(Text(nilai.mataPelajaran)),
                        DataCell(Text(nilai.nilaiTugas.toStringAsFixed(1))),
                        DataCell(Text(nilai.nilaiUTS.toStringAsFixed(1))),
                        DataCell(Text(nilai.nilaiUAS.toStringAsFixed(1))),
                        DataCell(Text(nilai.nilaiAkhir.toStringAsFixed(2))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getPredikatColor(nilai.predikat),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              nilai.predikat,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _getBarChartData(List<dynamic> nilaiList) {
    return List.generate(nilaiList.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: nilaiList[i].nilaiAkhir,
            color: Theme.of(context).colorScheme.primary,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    });
  }

  Widget _buildPengumumanTab() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.pengumuman);
        },
        icon: const Icon(Icons.announcement),
        label: const Text('Lihat Pengumuman'),
      ),
    );
  }

  Color _getPredikatColor(String predikat) {
    switch (predikat) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
