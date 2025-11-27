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
        Expanded(
          child: nilaiList.isEmpty
              ? const EmptyState(
                  icon: Icons.grade,
                  message: 'Belum ada nilai',
                )
              : SingleChildScrollView(
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
