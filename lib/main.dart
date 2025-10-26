import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/data_service.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize data
  await DataService().initializeData();

  // Load persisted settings
  await loadSettingsFromPrefs();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    settingsNotifier.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    settingsNotifier.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final settings = settingsNotifier.value;
  // Unified palette: white background, blue primary, black text
  const scaffoldBg = Colors.white;
  const textColor = Color(0xFF000000);
  const primaryButton = Color(0xFF2196F3); // Material Blue 500

    final lightTheme = ThemeData(
      colorScheme: const ColorScheme.light(
        primary: primaryButton,
        secondary: primaryButton,
        surface: Colors.white,
        background: scaffoldBg,
        onPrimary: Colors.white,
        onSurface: textColor,
      ),
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: ThemeData.light().textTheme.apply(
            bodyColor: textColor,
            displayColor: textColor,
          ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryButton,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: primaryButton,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryButton,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryButton, width: 2),
        ),
        labelStyle: TextStyle(color: textColor),
        hintStyle: TextStyle(color: Colors.grey),
      ),
    );

    final darkTheme = ThemeData.dark().copyWith(useMaterial3: true);

    return MaterialApp(
      title: 'App Tìm Bài Đọc Theo Ngày',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: settings.isDark ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        // Apply text scale factor from settings
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: settings.textScaleFactor),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}