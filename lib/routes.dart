import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/admin_dashboard.dart';
import 'pages/guru_dashboard.dart';
import 'pages/siswa_dashboard.dart';
import 'pages/siswa_crud.dart';
import 'pages/guru_crud.dart';
import 'pages/jadwal_crud.dart';
import 'pages/nilai_input.dart';
import 'pages/pengumuman_page.dart';

class AppRoutes {
  static const String login = '/';
  static const String adminDashboard = '/admin';
  static const String guruDashboard = '/guru';
  static const String siswaDashboard = '/siswa';
  static const String siswaCrud = '/siswa-crud';
  static const String guruCrud = '/guru-crud';
  static const String jadwalCrud = '/jadwal-crud';
  static const String nilaiInput = '/nilai-input';
  static const String pengumuman = '/pengumuman';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginPage(),
      adminDashboard: (context) => const AdminDashboard(),
      guruDashboard: (context) => const GuruDashboard(),
      siswaDashboard: (context) => const SiswaDashboard(),
      siswaCrud: (context) => const SiswaCrudPage(),
      guruCrud: (context) => const GuruCrudPage(),
      jadwalCrud: (context) => const JadwalCrudPage(),
      nilaiInput: (context) => const NilaiInputPage(),
      pengumuman: (context) => const PengumumanPage(),
    };
  }
}
