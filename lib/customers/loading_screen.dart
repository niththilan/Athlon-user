import 'package:flutter/material.dart';
import 'widgets/football_spinner.dart';

/// Initial loading screen shown when app starts
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // App logo
              Container(
                constraints: const BoxConstraints(
                  maxWidth: 120,
                  maxHeight: 120,
                ),
                child: Image.asset(
                  'assets/Athlon1.png',
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if image fails to load
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2C4F).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.sports_basketball,
                        size: 40,
                        color: Color(0xFF1B2C4F),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              // Loading spinner with constraints
              SizedBox(
                width: 80,
                height: 80,
                child: const FootballSpinner(
                  size: 60.0,
                  color: Color(0xFF1B2C4F),
                ),
              ),
              const SizedBox(height: 20),
              // Loading text
              const Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1B2C4F),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}