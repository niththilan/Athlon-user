import 'package:flutter/material.dart';
import 'customers/home.dart' as home;
import 'customers/loading_screen.dart';
import 'customers/UserLogin.dart';
import 'customers/services/navigation_service.dart';
import 'customers/services/supabase_service.dart';
import 'customers/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  try {
    await SupabaseService.initialize();
    print('Supabase initialized successfully');
    
    // Initialize AuthService
    await AuthService().initialize();
    print('AuthService initialized successfully');
  } catch (e) {
    print('Error initializing services: $e');
    // Continue without services for now - app will handle gracefully
  }
  
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

/// App initializer that shows loading screen then navigates based on auth state
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
    // Simulate loading sequence
    await Future.delayed(const Duration(milliseconds: 800));

    // Auth state check
    await Future.delayed(const Duration(milliseconds: 200));

    // Check if user is authenticated
    final authService = AuthService();
    final isAuthenticated = authService.isAuthenticated;

    // Navigate based on authentication status
    if (mounted && !_isNavigated) {
      _isNavigated = true;

      if (isAuthenticated) {
        // User is logged in, go to home screen
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const home.HomeScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
          (route) => false,
        );
      } else {
        // User is not logged in, go to home screen
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const home.HomeScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const LoadingScreen();
  }
}
