import 'package:flutter/material.dart';
import 'customers/home.dart';
import 'customers/loading_screen.dart';
import 'customers/services/navigation_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Athlon',
      navigatorKey: NavigationService.navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B2C4F),
          brightness: Brightness.light,
          surface: const Color.fromARGB(255, 34, 51, 117),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const AppInitializer(),
    );
  }
}

/// App initializer that shows loading screen then navigates to home
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isNavigated = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulate sophisticated loading sequence from vendor app

    // 1. Supabase initialization (500ms-1s)
    await Future.delayed(const Duration(milliseconds: 800));

    // 2. Auth state check (100-300ms)
    await Future.delayed(const Duration(milliseconds: 200));

    // 3. Profile fetch - network dependent (500ms-2s)
    await Future.delayed(const Duration(milliseconds: 1200));

    // 4. Provider initialization (50-100ms)
    await Future.delayed(const Duration(milliseconds: 75));

    // Total realistic loading time: ~2.3 seconds (matching vendor app)

    if (mounted && !_isNavigated) {
      _isNavigated = true;

      // Use Navigator.of(context).pushAndRemoveUntil to clear the stack
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
        (route) => false, // Remove all routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const LoadingScreen();
  }
}
