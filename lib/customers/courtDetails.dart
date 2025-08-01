// ignore_for_file: deprecated_member_use, file_names

import 'package:flutter/material.dart';
import 'footer.dart';
import 'favourites.dart';
import 'BookNow.dart'; // Import BookNow.dart

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

// VenueModel class for similar venues
class VenueModel {
  final String id;
  final String title;
  final String location;
  final double rating;
  final String imageUrl;
  final List<String> sports;
  final double distance;
  final String openingHours;
  final String ratePerHour;

  VenueModel({
    required this.id,
    required this.title,
    required this.location,
    required this.rating,
    required this.imageUrl,
    required this.sports,
    required this.distance,
    required this.openingHours,
    required this.ratePerHour,
  });
}

class SportItem {
  final String name;
  final String imageUrl;
  final double rating;

  SportItem({
    required this.name,
    required this.imageUrl,
    required this.rating,
  });
}

class CourtDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? courtData;

  // Static favorites list for demo purposes
  static List<Map<String, dynamic>> favorites = [];

  const CourtDetailScreen({super.key, this.courtData});

  @override
  State<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen> {
  bool _isFavorite = false;
  int _currentImageIndex = 0;
  int _currentIndex = 0; // For footer navigation
  bool _showLocationEdit = false;
  bool _showTimeEdit = false;
  bool _showReviewEdit = false;

  // Mock court data
  late Map<String, dynamic> _courtDetails;

  // Sports data with names and ratings
  final List<SportItem> _sportsItems = [
    SportItem(
      name: "Football",
      imageUrl: "https://images.unsplash.com/photo-1553778263-73a83bab9b0c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=400&q=80",
      rating: 4.8,
    ),
    SportItem(
      name: "Cricket",
      imageUrl: "https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=400&q=80",
      rating: 4.6,
    ),
    SportItem(
      name: "Basketball",
      imageUrl: "https://images.unsplash.com/photo-1546519638-68e109498ffc?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=400&q=80",
      rating: 4.7,
    ),
    SportItem(
      name: "Tennis",
      imageUrl: "https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80",
      rating: 4.5,
    ),
    SportItem(
      name: "Badminton",
      imageUrl: "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80",
      rating: 4.9,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeCourtData();
    _startSlideshow();
  }

  void _startSlideshow() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final images = _courtDetails['images'];
        if (images is List && images.isNotEmpty) {
          setState(() {
            _currentImageIndex = (_currentImageIndex + 1) % images.length;
          });
        }
        _startSlideshow();
      }
    });
  }

  void _initializeCourtData() {
    _courtDetails = widget.courtData ??
        {
          'id': 'court_001',
          'name': 'ARK SPORTS',
          'type': 'Futsal Court',
          'location': '141/A, Wattala 11300',
          'distance': '2.5 km away',
          'rating': 4.6,
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
          'sports_available': ['Football', 'Cricket', 'Basketball'],
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to favorites')),
        );
      }
    } else {
      // Remove from favorites
      CourtDetailScreen.favorites.removeWhere((v) => v['id'] == _courtDetails['id']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from favorites')),
      );
    }
  }

  // Add this method to navigate to FavoritesScreen
  void _goToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesScreen(
          favoriteVenues: CourtDetailScreen.favorites,
          onRemoveFavorite: (venue) {
            setState(() {
              CourtDetailScreen.favorites.removeWhere((v) => v['id'] == venue['id']);
            });
          },
        ),
      ),
    );
  }

  // Navigate back to BookNow screen
  void _navigateToBookNow() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BookNowScreen()),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color backgroundColor, Color textColor, VoidCallback onPressed) {
    return Expanded(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: backgroundColor == Colors.white ? [
            const BoxShadow(
              color: Color(0xFFE5E7EB),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ] : [],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: CustomScrollView(
        slivers: [
          // Top Image Carousel
          SliverToBoxAdapter(
            child: Container(
              height: 300,
              child: Stack(
                children: [
                  // Image Carousel
                  PageView.builder(
                    itemCount: _courtDetails['images'].length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
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
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
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
                                Icon(Icons.sports_soccer, size: 50, color: Color(0xFF1B2C4F)),
                                SizedBox(height: 8),
                                Text('ARK SPORTS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B2C4F))),
                                Text('Indoor Sports Facility', style: TextStyle(fontSize: 12, color: Color(0xFF1B2C4F))),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // Back arrow on top left - Go back to previous page
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    left: 16,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xFF1B2C4F),
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  // Top overlay heart icon for favorite and favorites navigation
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    right: 16,
                    child: GestureDetector(
                      onTap: _toggleFavorite, // <-- This adds/removes from favorites
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : const Color(0xFF1B2C4F),
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                  // Bottom indicators
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _courtDetails['images'].length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == _currentImageIndex
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
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
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _courtDetails['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
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
                              const SizedBox(width: 6),
                              Text(
                                _courtDetails['rating'].toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1B2C4F),
                                ),
                              ),
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
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                        leading: const Icon(Icons.location_on, color: Color(0xFF1B2C4F)),
                        title: Text(
                          _courtDetails['location'],
                          style: const TextStyle(
                            fontSize: 16,
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
                      ),
                      const Divider(
                        color: Color(0xFFE5E7EB),
                        thickness: 1,
                        height: 0,
                        indent: 16,
                        endIndent: 16,
                      ),
                      ListTile(
                        leading: const Icon(Icons.access_time, color: Color(0xFF1B2C4F)),
                        title: Text(
                          _courtDetails['opening_hours'],
                          style: const TextStyle(
                            fontSize: 16,
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
                      ),
                      const Divider(
                        color: Color(0xFFE5E7EB),
                        thickness: 1,
                        height: 0,
                        indent: 16,
                        endIndent: 16,
                      ),
                      ListTile(
                        leading: const Icon(Icons.star, color: Color(0xFF1B2C4F)),
                        title: const Text(
                          'Write a Review',
                          style: TextStyle(
                            fontSize: 16,
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
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Available Sports Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Available Sports',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B2C4F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _courtDetails['name'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 150,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _sportsItems.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final sport = _sportsItems[index];
                            return Container(
                              width: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: const Color(0xFFF8F9FA),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Image.network(
                                      sport.imageUrl,
                                      height: 90,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 90,
                                          color: const Color(0xFFF8F9FA),
                                          child: const Center(
                                            child: Icon(Icons.sports, color: Color(0xFF1B2C4F)),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sport.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1B2C4F),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              size: 13,
                                              color: Color(0xFFFBBF24),
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              sport.rating.toString(),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100), // Space for bottom nav
              ],
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