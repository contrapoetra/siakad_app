import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/nilai_provider.dart';
import '../models/nilai.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:fl_chart/fl_chart.dart'; // Import fl_chart

class StudentReportCardPage extends StatefulWidget {
  const StudentReportCardPage({super.key});

  @override
  State<StudentReportCardPage> createState() => _StudentReportCardPageState();
}

class _StudentReportCardPageState extends State<StudentReportCardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NilaiProvider>(context, listen: false).loadNilai();
    });
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

  Future<void> _generatePdf(List<Nilai> grades, String studentName, String studentNis) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('LAPORAN NILAI SISWA', style: pw.TextStyle(font: font, fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Nama Siswa: $studentName', style: pw.TextStyle(font: font, fontSize: 16)),
              pw.Text('NIS: $studentNis', style: pw.TextStyle(font: font, fontSize: 16)),
              pw.SizedBox(height: 30),
              pw.TableHelper.fromTextArray(
                headers: ['Mata Pelajaran', 'Tugas', 'UTS', 'UAS', 'Nilai Akhir', 'Predikat'],
                data: grades.map((nilai) {
                  return [
                    nilai.mataPelajaran,
                    nilai.nilaiTugas.toStringAsFixed(0),
                    nilai.nilaiUTS.toStringAsFixed(0),
                    nilai.nilaiUAS.toStringAsFixed(0),
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

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'rapor_$studentNis.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final nilaiProvider = Provider.of<NilaiProvider>(context);

    final String? currentSiswaNis = authProvider.currentUserId;

    if (currentSiswaNis == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Rapor Siswa'),
        ),
        body: const Center(
          child: Text('Anda harus login sebagai siswa untuk melihat rapor.'),
        ),
      );
    }

    final List<Nilai> studentGrades =
        nilaiProvider.getNilaiByNis(currentSiswaNis);

    if (studentGrades.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Rapor Siswa'),
        ),
        body: const Center(
          child: Text('Belum ada data rapor untuk Anda.'),
        ),
      );
    }

    final String studentName = studentGrades.first.namaSiswa; // Assuming all grades belong to the same student

    // Prepare data for FlChart
    List<BarChartGroupData> barGroups = [];
    List<String> subjectNames = [];
    for (int i = 0; i < studentGrades.length; i++) {
      final grade = studentGrades[i];
      subjectNames.add(grade.mataPelajaran);
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: grade.nilaiAkhir,
              color: Colors.blue,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapor Siswa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _generatePdf(studentGrades, studentName, currentSiswaNis),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nama Siswa: $studentName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'NIS: $currentSiswaNis',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
                4: FlexColumnWidth(2),
                5: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withAlpha((255 * 0.1).round())),
                  children: const [
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Mata Pelajaran', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Tugas', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('UTS', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('UAS', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Nilai Akhir', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Predikat', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                  ],
                ),
                ...studentGrades.map((nilai) {
                  return TableRow(
                    children: [
                      Padding(padding: const EdgeInsets.all(8.0), child: Text(nilai.mataPelajaran)),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text(nilai.nilaiTugas.toStringAsFixed(0), textAlign: TextAlign.center)),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text(nilai.nilaiUTS.toStringAsFixed(0), textAlign: TextAlign.center)),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text(nilai.nilaiUAS.toStringAsFixed(0), textAlign: TextAlign.center)),
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
                }).toList(),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              'Grafik Nilai Akhir Per Mata Pelajaran',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            if (barGroups.isNotEmpty)
              SizedBox(
                height: 250, // Height for the chart
                child: BarChart(
                  BarChartData(
                    barGroups: barGroups,
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              angle: -0.7, // Rotate labels for better fit
                              space: 4.0,
                              child: Text(
                                subjectNames[value.toInt()],
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.right,
                              ),
                            );
                          },
                          reservedSize: 60, // Space for rotated labels
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                          reservedSize: 28,
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 100, // Max grade is 100
                  ),
                ),
              ),
            if (barGroups.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Tidak ada data nilai untuk grafik.'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
