import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'models/expense.dart';
import 'services/database_service.dart';
import 'screens/dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(ExpenseAdapter());

  // Initialize database service
  await DatabaseService().init();

  // Initialize date formatting for Spanish locale
  await initializeDateFormatting('es', null);

  runApp(const GastoFacilApp());
}

class GastoFacilApp extends StatefulWidget {
  const GastoFacilApp({Key? key}) : super(key: key);

  @override
  State<GastoFacilApp> createState() => _GastoFacilAppState();
}

class _GastoFacilAppState extends State<GastoFacilApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Federico',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,

      // Home screen with theme toggle callback
      home: DashboardScreen(onThemeToggle: _toggleTheme),

      // Routes (for future navigation)
      routes: {
        '/dashboard': (context) => DashboardScreen(onThemeToggle: _toggleTheme),
      },
    );
  }
}
