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
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'SIAKAD XYZ',
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black,
            brightness: Brightness.light,
            primary: Colors.black,
            secondary: Colors.black,
            tertiary: Colors.grey.shade800,
            surface: Colors.white,
            background: Colors.white,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Colors.black,
            error: Colors.red.shade700,
          ),
          useMaterial3: false,
          textTheme: GoogleFonts.montserratTextTheme(),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: 0.5,
            ),
            surfaceTintColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.black),
            shape: const Border(bottom: BorderSide(color: Colors.black, width: 1)),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 20,
            ),
            labelStyle: GoogleFonts.montserrat(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
            hintStyle: GoogleFonts.montserrat(
              color: Colors.black54,
            ),
            prefixIconColor: Colors.black,
            suffixIconColor: Colors.black,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.black, width: 1),
              ),
              textStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.0,
              ),
              elevation: 0,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              textStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Colors.grey.shade200,
            selectedColor: Colors.black,
            labelStyle: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold),
            secondaryLabelStyle: GoogleFonts.montserrat(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.black, width: 1),
            ),
            checkmarkColor: Colors.white,
          ),
          listTileTheme: ListTileThemeData(
            shape: Border(
              bottom: BorderSide(color: Colors.black, width: 1),
            ),
            tileColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            iconColor: Colors.black,
            textColor: Colors.black,
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey.shade600,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w800),
            landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.black, width: 1),
            ),
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.black, width: 1),
            ),
            margin: const EdgeInsets.all(8),
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.black, width: 1),
            ),
          ),
          dividerTheme: const DividerThemeData(
            color: Colors.black,
            thickness: 1,
            space: 24,
          ),
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Colors.black,
            linearTrackColor: Colors.grey,
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: Colors.black,
            contentTextStyle: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.black, width: 1),
            ),
            behavior: SnackBarBehavior.floating,
            elevation: 0,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.white,
            brightness: Brightness.dark,
            primary: Colors.white,
            secondary: Colors.white,
            tertiary: Colors.grey.shade200,
            surface: Colors.black,
            background: Colors.black,
            onPrimary: Colors.black,
            onSecondary: Colors.black,
            onSurface: Colors.white,
            error: Colors.red.shade400,
          ),
          useMaterial3: false,
          textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
          scaffoldBackgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          listTileTheme: ListTileThemeData(
            iconColor: Colors.white,
            textColor: Colors.white,
            tileColor: Colors.grey.shade900,
            shape: Border(
              bottom: BorderSide(color: Colors.grey.shade600, width: 1),
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: Border(bottom: BorderSide(color: Colors.grey.shade600, width: 1)),
            titleTextStyle: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          cardTheme: CardThemeData(
            color: Colors.grey.shade900,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade600, width: 1),
            ),
            margin: const EdgeInsets.all(8),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade600, width: 1),
              ),
              textStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.0,
              ),
              elevation: 0,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              textStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Colors.grey.shade800,
            selectedColor: Colors.white,
            labelStyle: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold),
            secondaryLabelStyle: GoogleFonts.montserrat(color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade600, width: 1),
            ),
            checkmarkColor: Colors.black,
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.black,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey.shade400,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w800),
            landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade600, width: 1),
            ),
            elevation: 0,
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: Colors.grey.shade900,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade600, width: 1),
            ),
          ),
          dividerTheme: const DividerThemeData(
            color: Colors.grey,
            thickness: 1,
            space: 24,
          ),
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Colors.white,
            linearTrackColor: Colors.grey,
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: Colors.black,
            contentTextStyle: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade600, width: 1),
            ),
            behavior: SnackBarBehavior.floating,
            elevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade900,
            labelStyle: GoogleFonts.montserrat(color: Colors.white),
            hintStyle: GoogleFonts.montserrat(color: Colors.white54),
            prefixIconColor: Colors.white,
            suffixIconColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade600, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade600, width: 1),
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
