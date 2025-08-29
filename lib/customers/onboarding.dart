import 'package:flutter/material.dart';
import 'home.dart'; // Add home import

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Match other files
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildLocationScreen(),
                  _buildInstructionsScreen(),
                  _buildProceedScreen(),
                ],
              ),
            ),
            _buildPageIndicator(),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFF1B2C4F).withOpacity(0.1), // Match theme
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              size: 80,
              color: Color(0xFF1B2C4F), // Match primary color
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Allow Location Access',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2C4F), // Match primary color
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'We need your location to find nearby sports venues and provide you with the best booking experience.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _requestLocationPermission,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B2C4F), // Match primary color
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // Match border radius
              ),
            ),
            child: const Text(
              'Allow Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFF1B2C4F).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.book_online,
              size: 80,
              color: Color(0xFF1B2C4F),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'How Booking Works',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2C4F),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          _buildInstructionItem(
            Icons.search,
            'Browse Services',
            'Find the perfect sports venue for your needs from our wide range of options.',
          ),
          _buildInstructionItem(
            Icons.calendar_today,
            'Select Date & Time',
            'Choose your preferred date and time slot that works best for you.',
          ),
          _buildInstructionItem(
            Icons.payment,
            'Secure Payment',
            'Pay safely through our secure payment gateway and get instant confirmation.',
          ),
          _buildInstructionItem(
            Icons.check_circle,
            'Enjoy Service',
            'Relax and enjoy your booked venue at your chosen location and time.',
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1B2C4F).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1B2C4F),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B2C4F), // Match text color
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProceedScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1B2C4F).withOpacity(0.8),
                  const Color(0xFF1B2C4F),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.rocket_launch,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Ready to Get Started!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2C4F),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'You\'re all set! Start exploring amazing sports venues and book your first appointment with ease.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _proceedToApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B2C4F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
              ),
              child: const Text(
                'Start Exploring',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? const Color(0xFF1B2C4F) // Match primary color
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text(
                'Back',
                style: TextStyle(
                  color: Color(0xFF1B2C4F), // Match primary color
                  fontSize: 16,
                ),
              ),
            )
          else
            const SizedBox(width: 60),
          if (_currentPage < 2)
            TextButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text(
                'Next',
                style: TextStyle(
                  color: Color(0xFF1B2C4F), // Match primary color
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            const SizedBox(width: 60),
        ],
      ),
    );
  }

  Future<void> _requestLocationPermission() async {
    // Simulate location permission request
    await Future.delayed(const Duration(milliseconds: 500));
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location access granted!'),
        backgroundColor: Color(0xFF1B2C4F), // Use consistent primary color
      ),
    );
  }

  void _proceedToApp() {
    // Navigate to home screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }
}

