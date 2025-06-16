// ignore_for_file: file_names

import 'package:flutter/material.dart';
// Add this import for the AppFooter
// Add import for the booking page
// Add this import at the top with other imports

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B2C4F),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        cardTheme: const CardThemeData(
          elevation: 4,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      home: const SportsComplexDetailsScreen(),
    ),
  );
}

class SportsComplexDetailsScreen extends StatelessWidget {
  const SportsComplexDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sports Complex Details')),
      body: const Center(child: Text('Details page coming soon')),
    );
  }
}
