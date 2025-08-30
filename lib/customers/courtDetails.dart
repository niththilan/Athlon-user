// ignore_for_file: deprecated_member_use, file_names

import 'package:flutter/material.dart';
import 'footer.dart';
import 'bookings.dart'; // Import bookings.dart
import 'widgets/football_spinner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B2C4F),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6F8), // Grey background
      ),
      home: const CourtDetailScreen(),
    );
  }
}

// VenueModel class is now imported from models/venue_models.dart

class SportItem {
  final String name;
  final String imageUrl;
  final double rating;

  SportItem({required this.name, required this.imageUrl, required this.rating});
}

class CourtDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? courtData;

  // Static favorites list for demo purposes
  static List<Map<String, dynamic>> favorites = [];

  const CourtDetailScreen({super.key, this.courtData});

  @override
  State<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen>
    with TickerProviderStateMixin {
  bool _isFavorite = false;
  int _currentImageIndex = 0;
  int _currentIndex = 0; // For footer navigation
  bool _isLoading = true;
  bool _showHeader = false; // For showing/hiding the header
  PageController _pageController = PageController();
  late AnimationController _indicatorController;
  late ScrollController _scrollController;

  // Mock court data
  late Map<String, dynamic> _courtDetails;

  @override
  void initState() {
    super.initState();
    _initializeCourtData();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _startSlideshow();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _indicatorController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final bool shouldShowHeader = _scrollController.offset > 10;
    if (shouldShowHeader != _showHeader) {
      setState(() {
        _showHeader = shouldShowHeader;
      });
    }
  }

  void _startSlideshow() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _pageController.hasClients) {
        final images = _courtDetails['images'];
        if (images is List && images.isNotEmpty) {
          final nextIndex = (_currentImageIndex + 1) % images.length;
          _pageController.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        }
        _startSlideshow();
      }
    });
  }

  void _initializeCourtData() {
    _courtDetails =
        widget.courtData ??
        {
          'id': 'court_001',
          'name': 'ARK SPORTS',
          'type': 'Futsal Court',
          'location': '141/A, Wattala 11300',
          'distance': '2.5 km away',
          'rating': 4.8,
          'total_reviews': 124,
          'price_per_hour': 2500.0,
          'opening_hours': 'Open Now',
          'closing_time': 'Closes at 11:00 PM',
          'phone': '+94 77 123 4567',
          'email': 'info@arksports.lk',
          'website': 'www.arksports.lk',
          'description':
              'Premium indoor futsal and cricket facility with state-of-the-art equipment and professional-grade surfaces.',
          'images': [
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1200&q=80',
            'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1200&q=80',
            'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1200&q=80',
          ],
          'sports_available': ['Futsal', 'Cricket', 'Basketball'],
        };
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    // Add to favorites if not already present
    if (_isFavorite) {
      final favVenue = {
        'id': _courtDetails['id'],
        'title': _courtDetails['name'],
        'location': _courtDetails['location'],
        'rating': _courtDetails['rating'],
        'imagePath': 'assets/placeholder.jpg', // Use asset or network as needed
        'distance': _courtDetails['distance'],
      };

      // Prevent duplicates
      if (!CourtDetailScreen.favorites.any((v) => v['id'] == favVenue['id'])) {
        CourtDetailScreen.favorites.add(favVenue);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Added to favorites')));
      }
    } else {
      // Remove from favorites
      CourtDetailScreen.favorites.removeWhere(
        (v) => v['id'] == _courtDetails['id'],
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Removed from favorites')));
    }
  }

  void _showOpeningHoursDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.white,
        elevation: 8,
        child: Container(
          width: MediaQuery.of(context).size.width > 500
              ? 480
              : MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxWidth: 480,
            minWidth: 280,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: EdgeInsets.all(
            MediaQuery.of(context).size.width < 400 ? 16 : 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Opening Hours',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width < 400 ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3142),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width < 400 ? 12 : 16,
                ),
                const Text(
                  'Weekly Schedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B2C4F),
                  ),
                ),
                const SizedBox(height: 12),
                _buildScheduleRow('Monday', '6:00 AM - 11:00 PM'),
                _buildScheduleRow('Tuesday', '6:00 AM - 11:00 PM'),
                _buildScheduleRow('Wednesday', '6:00 AM - 11:00 PM'),
                _buildScheduleRow('Thursday', '6:00 AM - 11:00 PM'),
                _buildScheduleRow('Friday', '6:00 AM - 12:00 AM'),
                _buildScheduleRow('Saturday', '5:00 AM - 12:00 AM'),
                _buildScheduleRow('Sunday', '5:00 AM - 11:00 PM'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF1B2C4F),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Hours may vary on holidays',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width < 400 ? 16 : 24,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: const Color(0xFF8A8E99),
                          fontSize: MediaQuery.of(context).size.width < 400
                              ? 14
                              : 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleRow(String day, String hours) {
    final isToday = _isToday(day);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
              color: isToday
                  ? const Color(0xFF1B2C4F)
                  : const Color(0xFF6B7280),
            ),
          ),
          Text(
            hours,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
              color: isToday
                  ? const Color(0xFF1B2C4F)
                  : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(String day) {
    final now = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final today = weekdays[now.weekday - 1];
    return day == today;
  }

  List<Widget> _buildSportsCards() {
    // Safely get sports available, ensuring it's a List<String>
    final dynamic sportsData = _courtDetails['sports_available'];
    final List<String> sportsAvailable;
    
    if (sportsData is List) {
      sportsAvailable = sportsData.cast<String>();
    } else {
      sportsAvailable = [];
    }
    
    // Return empty list if no sports available
    if (sportsAvailable.isEmpty) {
      return [];
    }
    
    // Sports image mapping
    final Map<String, String> sportsImages = {
      'Futsal': 'assets/football.jpg',
      'Football': 'assets/football.jpg',
      'Basketball': 'assets/basket.jpg',
      'Tennis': 'assets/tennis.jpg',
      'Cricket': 'assets/crickett.jpg',
      'Badminton': 'assets/badminton.jpg',
      'Swimming': 'assets/swimming.jpg',
      'Squash': 'assets/tennis.jpg',
      'Table Tennis': 'assets/tennis.jpg',
      'Volleyball': 'assets/basket.jpg',
      'Golf': 'assets/golf.jpg',
      'Boxing': 'assets/boxing.jpg',
      'MMA': 'assets/boxing.jpg',
      'Kickboxing': 'assets/boxing.jpg',
      'Water Polo': 'assets/swimming.jpg',
      'Diving': 'assets/swimming.jpg',
      'Beach Volleyball': 'assets/basket.jpg',
      'Surfing': 'assets/surfing.jpg',
      'Mountain Biking': 'assets/biking.jpg',
      'Baseball': 'assets/crickett.jpg',
      'Rugby': 'assets/football.jpg',
      'Rock Climbing': 'assets/climbing.jpg',
      'Bouldering': 'assets/climbing.jpg',
      'Netball': 'assets/basket.jpg',
    };

    // Create cards only for the sports in the list, in the exact order
    return sportsAvailable.map((sport) {
      final imagePath = sportsImages[sport] ?? 'assets/football.jpg';
      return _SportsCard(
        sport: sport,
        imagePath: imagePath,
      );
    }).toList();
  }

  void _showReviewDialog() {
    int selectedRating = 0;
    final TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          elevation: 8,
          child: Container(
            width: MediaQuery.of(context).size.width > 500
                ? 480
                : MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxWidth: 480,
              minWidth: 280,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: EdgeInsets.all(
              MediaQuery.of(context).size.width < 400 ? 16 : 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Write a Review',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 400
                          ? 16
                          : 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3142),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width < 400 ? 12 : 16,
                  ),
                  const Text(
                    'Rate your experience',
                    style: TextStyle(fontSize: 14, color: Color(0xFF8A8E99)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            selectedRating = index + 1;
                          });
                        },
                        icon: Icon(
                          index < selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: const Color(0xFFFBBF24),
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reviewController,
                    maxLines: 4,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2D3142),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Share your experience...',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8A8E99),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: const Color(0xFF8A8E99).withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFF1B2C4F),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width < 400 ? 16 : 24,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: const Color(0xFF8A8E99),
                            fontSize: MediaQuery.of(context).size.width < 400
                                ? 14
                                : 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Review submitted successfully',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B2C4F),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Submit Review',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width < 400
                                ? 14
                                : 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color backgroundColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: backgroundColor == Colors.white
              ? [
                  const BoxShadow(
                    color: Color(0xFFE5E7EB),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPressed,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: textColor, size: 20),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Book Now Button Widget
  Widget _buildBookNowButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1B2C4F), // Primary color
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B2C4F).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              // Show loading screen immediately
              showDialog(
                context: context,
                barrierDismissible: false,
                barrierColor: Colors.white,
                builder: (BuildContext context) {
                  return const FootballLoadingWidget();
                },
              );

              // Loading delay
              await Future.delayed(const Duration(milliseconds: 300));

              // Navigate to SlotsPage screen without animation
              if (context.mounted) {
                Navigator.pop(context); // Close loading dialog
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        SlotsPage(
                          courtData: _courtDetails,
                        ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  Text(
                    'Check Availability',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: FootballLoadingWidget()));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
          // Top Image Carousel
          SliverToBoxAdapter(
            child: SizedBox(
              height: 350,
              child: Stack(
                children: [
                  // Image Carousel
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _courtDetails['images'].length,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                      _indicatorController.reset();
                      _indicatorController.forward();
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(0),
                          child: Image.network(
                            _courtDetails['images'][index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.white,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                    color: const Color(0xFF1B2C4F),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.white,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.sports_soccer,
                                      size: 50,
                                      color: Color(0xFF1B2C4F),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'ARK SPORTS',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B2C4F),
                                      ),
                                    ),
                                    Text(
                                      'Indoor Sports Facility',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF1B2C4F),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  // Back arrow on top left - Go back to previous page
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 4,
                    left: 16,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),

                  // Top overlay heart icon for favorite and favorites navigation
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 4,
                    right: 16,
                    child: GestureDetector(
                      onTap:
                          _toggleFavorite, // <-- This adds/removes from favorites
                      child: Container(
                        width: 40,
                        height: 40,
                        // Remove background color and boxShadow for transparent background
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(0, 0, 0, 0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite
                              ? Colors.red
                              : const Color.fromARGB(255, 255, 255, 255),
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                  // Bottom indicators with enhanced animation
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _courtDetails['images'].length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: index == _currentImageIndex ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: index == _currentImageIndex
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: index == _currentImageIndex
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Swipe hint overlay (appears briefly on first load)
                  if (_currentImageIndex == 0)
                    Positioned(
                      bottom: 60,
                      right: 20,
                      child: AnimatedBuilder(
                        animation: _indicatorController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: 1.0 - _indicatorController.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.swipe,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Swipe',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content Section
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Rating Section
                // Remove the outer Container, keep only the inner content
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _courtDetails['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B2C4F),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              ...List.generate(5, (index) {
                                return Icon(
                                  Icons.star,
                                  size: 16,
                                  color: index < _courtDetails['rating'].floor()
                                      ? const Color(0xFFFBBF24)
                                      : const Color(0xFFE5E7EB),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        children: [
                          _buildActionButton(
                            'Directions',
                            Icons.directions,
                            const Color(0xFF1B2C4F),
                            Colors.white,
                            () {},
                          ),
                          const SizedBox(width: 12),
                          _buildActionButton(
                            'Call',
                            Icons.phone,
                            Colors.white,
                            const Color(0xFF1B2C4F),
                            () {},
                          ),
                          const SizedBox(width: 12),
                          _buildActionButton(
                            'Share',
                            Icons.share,
                            Colors.white,
                            const Color(0xFF1B2C4F),
                            () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Info Cards combined in one box
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Color(0xFF1B2C4F),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          _courtDetails['location'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B2C4F),
                          ),
                        ),
                        subtitle: Text(
                          _courtDetails['distance'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF6B7280),
                          size: 16,
                        ),
                      ),
                      const Divider(
                        color: Color(0xFFE5E7EB),
                        thickness: 1,
                        height: 0,
                        indent: 16,
                        endIndent: 16,
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.access_time,
                            color: Color(0xFF1B2C4F),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          _courtDetails['opening_hours'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B2C4F),
                          ),
                        ),
                        subtitle: Text(
                          _courtDetails['closing_time'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF6B7280),
                          size: 16,
                        ),
                        onTap: _showOpeningHoursDialog,
                      ),
                      const Divider(
                        color: Color(0xFFE5E7EB),
                        thickness: 1,
                        height: 0,
                        indent: 16,
                        endIndent: 16,
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Color(0xFF1B2C4F),
                            size: 20,
                          ),
                        ),
                        title: const Text(
                          'Write a Review',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B2C4F),
                          ),
                        ),
                        subtitle: const Text(
                          'Share your experience',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF6B7280),
                          size: 16,
                        ),
                        onTap: _showReviewDialog,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                // Book Now Button (moved above Available Sports)
                _buildBookNowButton(),

                const SizedBox(height: 5),

                // Available Sports Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        const Color(0xFFF8FAFC),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B2C4F).withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 0,
                        offset: const Offset(0, 1),
                        spreadRadius: 0,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFE5E7EB).withOpacity(0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Available Sports",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1B2C4F),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Sports offered at this venue",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B7280),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: _buildSportsCards(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ...existing code...
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
        ],
      ),
          
          // Navy blue header that appears when scrolling
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _showHeader ? MediaQuery.of(context).padding.top + 50 : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showHeader ? 1.0 : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2C4F),
                  boxShadow: _showHeader ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: SafeArea(
                  child: Container(
                    height: 50,
                    child: Row(
                      children: [
                        // Back button with exact same styling as history.dart
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 3, 8, 8),
                          child: IconButton(
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            tooltip: 'Back',
                          ),
                        ),
                        
                        // Court name with exact same text styling as history.dart
                        Expanded(
                          child: Text(
                            _courtDetails['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        // Heart icon with proper padding to match the layout
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: GestureDetector(
                            onTap: _toggleFavorite,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: AppFooter(
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _SportsCard extends StatelessWidget {
  final String sport;
  final String imagePath;

  const _SportsCard({required this.sport, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final isNetwork = imagePath.startsWith('http');
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: () {
          // Get court data from the parent widget
          final courtDetailsState = context.findAncestorStateOfType<_CourtDetailScreenState>();
          if (courtDetailsState != null) {
            // Create court data with selected sport
            final Map<String, dynamic> courtDataWithSport = Map.from(courtDetailsState._courtDetails);
            // Update the sports_available to prioritize the selected sport
            courtDataWithSport['sports_available'] = [sport];
            
            // Navigate to SlotsPage with the court data
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SlotsPage(
                  courtData: courtDataWithSport,
                ),
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B2C4F).withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.9),
                blurRadius: 0,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      const Color(0xFFF8FAFC),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB).withOpacity(0.6),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B2C4F).withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(19),
                  child: Stack(
                    children: [
                      // Background gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              const Color(0xFF1B2C4F).withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                      // Sport image
                      Positioned.fill(
                        child: Image(
                          image: isNetwork
                              ? NetworkImage(imagePath)
                              : AssetImage(imagePath) as ImageProvider,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF1B2C4F).withOpacity(0.8),
                                    const Color(0xFF2D3E5F).withOpacity(0.9),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.sports_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Sport name overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Text(
                            sport,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.3,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
