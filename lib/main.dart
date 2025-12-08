import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'hive_setup.dart';
import 'routes.dart';
import 'providers/auth_provider.dart';
import 'providers/siswa_provider.dart';
import 'providers/guru_provider.dart';
import 'providers/jadwal_provider.dart';
import 'providers/nilai_provider.dart';
import 'providers/pengumuman_provider.dart';
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
      ],
      child: MaterialApp(
        title: 'SIAKAD XYZ',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2D5A27),
            brightness: Brightness.light,
            primary: const Color(0xFF2D5A27), // Forest Green
            secondary: const Color(0xFF8B7355), // Khaki Brown
            tertiary: const Color(0xFF4A7C59), // Sage Green
            surface: const Color(0xFFF5F1E6), // Cream
            background: const Color(0xFFF9F7F0), // Light Cream
            onPrimary: Colors.white,
            onSecondary: Colors.white,
          ),
          useMaterial3: true,
          fontFamily: 'Poppins',
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF2D5A27),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
            surfaceTintColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF8B7355)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF8B7355)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D5A27), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            labelStyle: const TextStyle(
              color: Color(0xFF2D5A27),
              fontWeight: FontWeight.w500,
            ),
            hintStyle: TextStyle(
              color: const Color(0xFF2D5A27).withOpacity(0.6),
            ),
            prefixIconColor: const Color(0xFF2D5A27),
            suffixIconColor: const Color(0xFF2D5A27),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5A27),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
              elevation: 3,
              shadowColor: const Color(0xFF2D5A27).withOpacity(0.3),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4A7C59),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: const Color(0xFFE8E2D1),
            selectedColor: const Color(0xFF4A7C59),
            labelStyle: const TextStyle(color: Color(0xFF2D5A27)),
            secondaryLabelStyle: const TextStyle(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: BorderSide.none,
            checkmarkColor: Colors.white,
          ),
          listTileTheme: ListTileThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: const Color(0xFFF5F1E6),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            iconColor: const Color(0xFF2D5A27),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: const Color(0xFFF5F1E6),
            selectedItemColor: const Color(0xFF2D5A27),
            unselectedItemColor: const Color(0xFF8B7355),
            elevation: 8,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF4A7C59),
            foregroundColor: Colors.white,
            shape: CircleBorder(),
          ),
          dividerTheme: DividerThemeData(
            color: const Color(0xFF8B7355).withOpacity(0.3),
            thickness: 1,
            space: 20,
          ),
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Color(0xFF4A7C59),
            linearTrackColor: Color(0xFFE8E2D1),
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: const Color(0xFF2D5A27),
            contentTextStyle: const TextStyle(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4A7C59),
            brightness: Brightness.dark,
            primary: const Color(0xFF4A7C59), // Darker Sage Green
            secondary: const Color(0xFFA99276), // Lighter Brown
            tertiary: const Color(0xFF3A5A40), // Deep Forest Green
            surface: const Color(0xFF2C3E2B), // Dark Earth
            background: const Color(0xFF1E281E), // Darker Earth
          ),
          useMaterial3: true,
          fontFamily: 'Poppins',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2C3E2B),
            foregroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.login,
        routes: AppRoutes.getRoutes(),
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
