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
import 'pages/role_request_page.dart';
import 'pages/register_page.dart';
import 'pages/forgot_password_page.dart'; // Import the new page
import 'pages/kelas_crud.dart';
import 'pages/classroom_page.dart'; // Import the new page

class AppRoutes {
  static const String login = '/';
  static const String adminDashboard = '/admin';
  static const String guruDashboard = '/guru';
  static const String siswaDashboard = '/siswa';
  static const String siswaCrud = '/siswa-crud';
  static const String guruCrud = '/guru-crud';
  static const String kelasCrud = '/kelas-crud';
  static const String jadwalCrud = '/jadwal-crud';
  static const String nilaiInput = '/nilai-input';
  static const String pengumuman = '/pengumuman';
  static const String roleRequest = '/role-request';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password'; // New route
  static const String classroomPage = '/classroom';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginPage(),
      adminDashboard: (context) => const AdminDashboard(),
      guruDashboard: (context) => const GuruDashboard(),
      siswaDashboard: (context) => const SiswaDashboard(),
      siswaCrud: (context) => const SiswaCrudPage(),
      guruCrud: (context) => const GuruCrudPage(),
      kelasCrud: (context) => const KelasCrudPage(),
      jadwalCrud: (context) => const JadwalCrudPage(),
      nilaiInput: (context) => const NilaiInputPage(),
      pengumuman: (context) => const PengumumanPage(),
      roleRequest: (context) => const RoleRequestPage(),
      register: (context) => const RegisterPage(),
      forgotPassword: (context) => const ForgotPasswordPage(), // Map the new page
      classroomPage: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as ClassroomPageArgs;
        return ClassroomPage(kelas: args.kelas, mataPelajaran: args.mataPelajaran);
      },
    };
  }
}
