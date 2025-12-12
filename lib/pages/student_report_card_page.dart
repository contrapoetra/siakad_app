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

    // Prepare data for LineChart: Group grades by semester and calculate average
    Map<String, List<Nilai>> gradesBySemester = {};
    for (var grade in studentGrades) {
      if (!gradesBySemester.containsKey(grade.semester)) {
        gradesBySemester[grade.semester] = [];
      }
      gradesBySemester[grade.semester]!.add(grade);
    }

    // Sort semesters for consistent trend display
    final sortedSemesters = gradesBySemester.keys.toList()..sort((a, b) {
      // Simple numeric sort for semesters like "Semester 1", "Semester 2"
      final aNum = int.tryParse(a.replaceAll('Semester ', '')) ?? 0;
      final bNum = int.tryParse(b.replaceAll('Semester ', '')) ?? 0;
      return aNum.compareTo(bNum);
    });

    List<FlSpot> spots = [];
    List<String> semesterLabels = [];
    double maxAverageGrade = 0;

    // Calculate IPK (average grade) for each semester
    for (int i = 0; i < sortedSemesters.length; i++) {
      final semester = sortedSemesters[i];
      final gradesInSemester = gradesBySemester[semester]!;
      final averageGrade = gradesInSemester.map((n) => n.nilaiAkhir).reduce((a, b) => a + b) / gradesInSemester.length;
      
      spots.add(FlSpot(i.toDouble(), averageGrade));
      semesterLabels.add(semester);

      if (averageGrade > maxAverageGrade) {
        maxAverageGrade = averageGrade;
      }
    }

    // PDF generation (more sophisticated)
    Future<void> _generateSophisticatedPdf(List<Nilai> allGrades, String sName, String sNis, Map<String, double> ipkPerSemester) async {
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
                  headers: ['Mata Pelajaran', 'Semester', 'Tugas', 'UTS', 'UAS', 'Nilai Akhir', 'Predikat'],
                  data: allGrades.map((nilai) {
                    return [
                      nilai.mataPelajaran,
                      nilai.semester,
                      nilai.nilaiTugas.toStringAsFixed(0),
                      nilai.nilaiUTS.toStringAsFixed(0),
                      nilai.nilaiUAS.toStringAsFixed(0),
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

    // Calculate IPK per semester for PDF
    Map<String, double> ipkPerSemester = {};
    for (var semester in sortedSemesters) {
      final gradesInSemester = gradesBySemester[semester]!;
      final averageGrade = gradesInSemester.map((n) => n.nilaiAkhir).reduce((a, b) => a + b) / gradesInSemester.length;
      ipkPerSemester[semester] = averageGrade;
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapor Siswa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _generateSophisticatedPdf(studentGrades, studentName, currentSiswaNis, ipkPerSemester),
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
            // Displaying IPK per semester in a table
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
              'Tren IPK Per Semester',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            if (spots.isNotEmpty)
              SizedBox(
                height: 250, // Height for the chart
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      getDrawingHorizontalLine: (value) {
                        return const FlLine(
                          color: Color(0xff37434d),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return const FlLine(
                          color: Color(0xff37434d),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 8.0,
                              child: Text(semesterLabels[value.toInt()], style: const TextStyle(fontSize: 10)),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                          },
                          reservedSize: 38,
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: const Color(0xff37434d), width: 1),
                    ),
                    minX: 0,
                    maxX: spots.length.toDouble() -1,
                    minY: 0,
                    maxY: 100, // Max grade is 100
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: false, // Make it sharp
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                        barWidth: 5,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary.withAlpha((255 * 0.3).round()),
                              Theme.of(context).colorScheme.secondary.withAlpha((255 * 0.3).round()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (spots.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Tidak ada data nilai untuk grafik tren.'),
                ),
              ),
            const SizedBox(height: 30),
            Text(
              'Nilai Akhir Per Mata Pelajaran',
              style: Theme.of(context).textTheme.headlineSmall,
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
          ],
        ),
      ),
    );
  }
}
