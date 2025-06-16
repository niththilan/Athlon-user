// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:async';

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins', // Changed from 'Montserrat' to 'Poppins'
      ),
      home: const OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoTransitionTimer;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: "Welcome to Athlon,",
      subtitle: "your ultimate sports companion",
      description:
          "Book facilities, join activities, and track your progress all in one place!",
      image: "assets/on-bad.jpg",
      backgroundColor: Colors.white,
      textColor: const Color(0xFF0F2851),
    ),
    OnboardingItem(
      title: "Book Sports Facilities",
      subtitle: "anytime, anywhere",
      description:
          "Reserve courts, fields, and equipment with a few taps. No more waiting in line or making phone calls.",
      image: "assets/base.jpg",
      backgroundColor: Colors.white,
      textColor: const Color(0xFF0F2851),
    ),
    OnboardingItem(
      title: "Join Group Activities",
      subtitle: "and make new friends",
      description:
          "Find and join group sessions, leagues, and tournaments based on your skill level and preferences.",
      image: "assets/two.jpg",
      backgroundColor: Colors.white,
      textColor: const Color(0xFF0F2851),
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Start automatic page transition timer after a short delay to ensure everything is initialized
    Future.delayed(const Duration(milliseconds: 500), () {
      _startAutoTransition();
    });

    _pageController.addListener(() {
      if (_pageController.page != null) {
        final currentPage = _pageController.page!.round();
        if (_currentPage != currentPage) {
          setState(() {
            _currentPage = currentPage;
          });
        }
      }
    });
  }

  void _startAutoTransition() {
    // Cancel any existing timer
    _autoTransitionTimer?.cancel();

    // Create a new timer that changes page every 4 seconds
    _autoTransitionTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return; // Check if widget is still mounted

      if (_currentPage < _onboardingItems.length - 1) {
        _pageController.animateToPage(
          _currentPage + 1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        // If on last page, loop back to first page
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoTransitionTimer?.cancel();
    super.dispose();
  }

  void _onFinish() {
    // Navigate to your home screen or login screen
    print('Onboarding complete - Navigate to main app');
    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(builder: (context) => HomeScreen()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Content area (titles, description, image) with dots positioned within it
            Expanded(
              child: Stack(
                children: [
                  // PageView for the onboarding items
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _onboardingItems.length,
                    onPageChanged: (int page) {
                      // When manually swiped, reset the timer
                      setState(() {
                        _currentPage = page;
                      });
                      // Reset the timer when user manually swipes
                      _startAutoTransition();
                    },
                    itemBuilder: (context, index) {
                      return _buildPage(_onboardingItems[index]);
                    },
                  ),

                  // Page indicator dots - positioned higher up from the bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 95,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingItems.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          height: 8.0,
                          width: 8.0,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? const Color(0xFF0F2851)
                                : Colors.grey.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Explore section at the bottom - Increased height
            Container(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
              decoration: const BoxDecoration(
                color: Color(0xFFF0F2F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Explore",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Discover amazing sports facilities, unlock hidden activities, and start planning your fitness journey!",
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _onFinish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F2851),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'GET STARTED',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: safeAreaBottom > 0 ? safeAreaBottom + 5 : 15,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          // Title and subtitle
          Text(
            item.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: item.textColor,
            ),
          ),
          Text(
            item.subtitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: item.textColor,
            ),
          ),
          const SizedBox(height: 8),

          // Description - More compact to allow more space for images
          Text(
            item.description,
            style: TextStyle(
              fontSize: 13,
              color: item.textColor.withOpacity(0.7),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Main image - Using actual images with significantly increased size
          Expanded(
            flex: 10,
            child: Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 40),
              child: Center(
                child: Image.asset(
                  item.image,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                  scale: 0.62,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// Data model for onboarding items
class OnboardingItem {
  final String title;
  final String subtitle;
  final String description;
  final String image;
  final Color backgroundColor;
  final Color textColor;

  OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.image,
    required this.backgroundColor,
    required this.textColor,
  });
}
