// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';

/// Initial loading screen shown when app starts
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bigger logo - try different asset paths
            Container(
              width: 250,
              height: 250,
              child: Image.asset(
                'assets/Athlon1.png', // Try this path first
                width: 250,
                height: 250,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if logo.png doesn't work
                  return Image.asset(
                    'assets/images/Athlon1.png',
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // If no logo found, show app name
                      return Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2C4F),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            'ATHLON',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            // Football/loading animation
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1B2C4F)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
