import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'hive_setup.dart';
import 'routes.dart';
import 'providers/auth_provider.dart';
import 'providers/siswa_provider.dart';
import 'providers/guru_provider.dart';
import 'providers/jadwal_provider.dart';
import 'providers/nilai_provider.dart';
import 'providers/pengumuman_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/kelas_provider.dart';
import 'providers/tugas_provider.dart';
import 'providers/absensi_provider.dart';
import 'providers/materi_provider.dart'; // Import MateriProvider
import 'providers/submission_provider.dart'; // Import SubmissionProvider
import 'services/notification_service.dart'; // Import NotificationService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  await NotificationService().initNotifications(); // Initialize notifications
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SiswaProvider()),
        ChangeNotifierProvider(create: (_) => GuruProvider()),
        ChangeNotifierProvider(create: (_) => JadwalProvider()),
        ChangeNotifierProvider(create: (_) => NilaiProvider()),
        ChangeNotifierProvider(create: (_) => PengumumanProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => KelasProvider()),
        ChangeNotifierProvider(create: (_) => TugasProvider()),
        ChangeNotifierProvider(create: (_) => AbsensiProvider()),
        ChangeNotifierProvider(create: (_) => MateriProvider()), // Add MateriProvider
        ChangeNotifierProvider(create: (_) => SubmissionProvider()), // Add SubmissionProvider
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'SIAKAD XYZ',
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              // GitHub-like Light Theme
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF24292E), // GitHub dark grey for seeding
                brightness: Brightness.light,
                primary: const Color(0xFF24292E), // Dark grey for primary elements
                onPrimary: Colors.white, // White text on primary
                secondary: const Color(0xFF6A737D), // Lighter grey for secondary elements
                onSecondary: Colors.white, // White text on secondary
                tertiary: const Color(0xFFE1E4E8), // Light grey for subtle borders/dividers
                surface: Colors.white, // White background for surfaces
                surfaceTint: Colors.white, // Use surfaceTint instead of background for clarity
                onSurface: const Color(0xFF24292E), // Dark grey text on surfaces
                error: const Color(0xFFCB2431), // GitHub red for errors
              ),
              useMaterial3: false,
              textTheme: GoogleFonts.interTextTheme(), // Using Inter font for GitHub feel
              scaffoldBackgroundColor: Colors.white,
                          appBarTheme: AppBarTheme(
                            backgroundColor: Theme.of(context).colorScheme.surface, // Use surface color for app bar
                            foregroundColor: const Color(0xFF24292E),
                            elevation: 0,
                            centerTitle: false,
                            titleTextStyle: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF24292E),
                              letterSpacing: 0.5,
                            ),
                            surfaceTintColor: Colors.transparent, // Use surfaceTintColor
                            iconTheme: const IconThemeData(color: Color(0xFF24292E)),
                            shape: const Border(bottom: BorderSide(color: Color(0xFFE1E4E8), width: 1)),
                          ),              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFFF6F8FA), // Light grey fill
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6), // Slightly less rounded
                  borderSide: const BorderSide(color: Color(0xFFE1E4E8), width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFE1E4E8), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF0366D6), width: 1), // GitHub blue for focus
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                labelStyle: GoogleFonts.inter(
                  color: const Color(0xFF586069),
                  fontWeight: FontWeight.w600,
                ),
                hintStyle: GoogleFonts.inter(
                  color: const Color(0xFF6A737D),
                ),
                prefixIconColor: const Color(0xFF586069),
                suffixIconColor: const Color(0xFF586069),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2EA44F), // GitHub green for primary action
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  textStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  elevation: 0,
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0366D6), // GitHub blue
                  textStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
              ),
              chipTheme: ChipThemeData(
                backgroundColor: const Color(0xFFF6F8FA),
                selectedColor: const Color(0xFF0366D6), // GitHub blue
                labelStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                secondaryLabelStyle: GoogleFonts.inter(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25), // Rounded chips
                  side: const BorderSide(color: Color(0xFFE1E4E8), width: 1),
                ),
                checkmarkColor: Colors.white,
              ),
              listTileTheme: const ListTileThemeData(
                shape: Border(
                  bottom: BorderSide(color: Color(0xFFE1E4E8), width: 1),
                ),
                tileColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                iconColor: Color(0xFF586069),
                textColor: Color(0xFF24292E),
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: Colors.white,
                selectedItemColor: const Color(0xFF24292E), // Dark grey
                unselectedItemColor: const Color(0xFF6A737D), // Medium grey
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: const Color(0xFF2EA44F), // GitHub green
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 4,
              ),
              cardTheme: CardThemeData(
                color: Colors.white,
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: const BorderSide(color: Color(0xFFE1E4E8), width: 1),
                ),
                margin: const EdgeInsets.all(8),
              ),
              dialogTheme: DialogThemeData(
                backgroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: const BorderSide(color: Color(0xFFE1E4E8), width: 1),
                ),
              ),
              dividerTheme: const DividerThemeData(
                color: Color(0xFFE1E4E8),
                thickness: 1,
                space: 16,
              ),
              progressIndicatorTheme: const ProgressIndicatorThemeData(
                color: Color(0xFF0366D6), // GitHub blue
                linearTrackColor: Color(0xFFE1E4E8),
              ),
              snackBarTheme: SnackBarThemeData(
                backgroundColor: const Color(0xFF24292E), // Dark grey
                contentTextStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                behavior: SnackBarBehavior.floating,
                elevation: 4,
              ),
            ),
            darkTheme: ThemeData(
              // GitHub-like Dark Theme
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0D1117), // GitHub dark background
                brightness: Brightness.dark,
                primary: const Color(0xFF58A6FF), // GitHub blue for primary elements
                onPrimary: Colors.white, // White text on primary
                secondary: const Color(0xFF8B949E), // Lighter grey for secondary elements
                onSecondary: Colors.white, // White text on secondary
                tertiary: const Color(0xFF30363D), // Medium grey for subtle borders/dividers
                surface: const Color(0xFF161B22), // Darker grey for surfaces
                surfaceTint: const Color(0xFF0D1117), // Use surfaceTint instead of background
                onSurface: const Color(0xFFC9D1D9), // Light grey text on surfaces
                error: const Color(0xFFFA4549), // GitHub red for errors
              ),
              useMaterial3: false,
              textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
              scaffoldBackgroundColor: const Color(0xFF0D1117),
              iconTheme: const IconThemeData(color: Color(0xFFC9D1D9)),
              listTileTheme: ListTileThemeData(
                iconColor: const Color(0xFFC9D1D9),
                textColor: const Color(0xFFC9D1D9),
                tileColor: const Color(0xFF161B22),
                shape: const Border(
                  bottom: BorderSide(color: Color(0xFF30363D), width: 1),
                ),
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: const Color(0xFF161B22),
                foregroundColor: const Color(0xFFC9D1D9),
                elevation: 0,
                shape: const Border(bottom: BorderSide(color: Color(0xFF30363D), width: 1)),
                titleTextStyle: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFC9D1D9),
                  letterSpacing: 0.5,
                ),
              ),
              cardTheme: CardThemeData(
                color: const Color(0xFF161B22),
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: const BorderSide(color: Color(0xFF30363D), width: 1),
                ),
                margin: const EdgeInsets.all(8),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2EA44F), // GitHub green
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  textStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  elevation: 0,
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF58A6FF), // GitHub blue
                  textStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
              ),
              chipTheme: ChipThemeData(
                backgroundColor: const Color(0xFF30363D),
                selectedColor: const Color(0xFF58A6FF), // GitHub blue
                labelStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                secondaryLabelStyle: GoogleFonts.inter(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: const BorderSide(color: Color(0xFF444C56), width: 1),
                ),
                checkmarkColor: Colors.white,
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: const Color(0xFF161B22),
                selectedItemColor: const Color(0xFFC9D1D9), // Light grey
                unselectedItemColor: const Color(0xFF8B949E), // Medium grey
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: const Color(0xFF2EA44F), // GitHub green
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 4,
              ),
              dialogTheme: DialogThemeData(
                backgroundColor: const Color(0xFF161B22),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: const BorderSide(color: Color(0xFF30363D), width: 1),
                ),
              ),
              dividerTheme: const DividerThemeData(
                color: Color(0xFF30363D),
                thickness: 1,
                space: 16,
              ),
              progressIndicatorTheme: const ProgressIndicatorThemeData(
                color: Color(0xFF58A6FF), // GitHub blue
                linearTrackColor: Color(0xFF30363D),
              ),
              snackBarTheme: SnackBarThemeData(
                backgroundColor: const Color(0xFF24292E), // Dark grey
                contentTextStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                behavior: SnackBarBehavior.floating,
                elevation: 4,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF0D1117), // Darker fill
                labelStyle: GoogleFonts.inter(color: const Color(0xFF8B949E)),
                hintStyle: GoogleFonts.inter(color: const Color(0xFF6A737D)),
                prefixIconColor: const Color(0xFF8B949E),
                suffixIconColor: const Color(0xFF8B949E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF30363D), width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF444C56), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF58A6FF), width: 1), // GitHub blue for focus
                ),
              ),
            ),
            debugShowCheckedModeBanner: false,
            initialRoute: AppRoutes.login,
            routes: AppRoutes.getRoutes(),
          );
        },
      ),
    );
  }
}

extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
