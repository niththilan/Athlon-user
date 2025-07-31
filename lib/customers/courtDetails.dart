// ignore: file_names
// ignore_for_file: deprecated_member_use, file_names, duplicate_ignore

import 'package:flutter/material.dart';
import 'footer.dart';

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
          seedColor: const Color(0xFF050E22),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      ),
      home: const CourtDetailScreen(),
    );
  }
}

class DirectionsIconPainter extends CustomPainter {
  final Color color;

  DirectionsIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final diamondSize = size.width * 0.7;

    // Draw diamond shape
    final path = Path();
    path.moveTo(center.dx, center.dy - diamondSize / 2); // Top
    path.lineTo(center.dx + diamondSize / 2, center.dy); // Right
    path.lineTo(center.dx, center.dy + diamondSize / 2); // Bottom
    path.lineTo(center.dx - diamondSize / 2, center.dy); // Left
    path.close();

    canvas.drawPath(path, paint);

    // Draw dots inside
    final dotRadius = size.width * 0.08;
    final dotPaint = Paint()
      ..color = color == Colors.white ? const Color(0xFF050E22) : Colors.white
      ..style = PaintingStyle.fill;

    // Center dot
    canvas.drawCircle(center, dotRadius, dotPaint);
    
    // Top dot
    canvas.drawCircle(
      Offset(center.dx, center.dy - diamondSize * 0.25),
      dotRadius * 0.7,
      dotPaint,
    );
    
    // Bottom dot
    canvas.drawCircle(
      Offset(center.dx, center.dy + diamondSize * 0.25),
      dotRadius * 0.7,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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

class CourtDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? courtData;

  const CourtDetailScreen({super.key, this.courtData});

  @override
  State<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen> {
  bool _isFavorite = false;
  int _currentImageIndex = 0;
  int _currentIndex = 0; // For footer navigation

  // Mock court data
  late Map<String, dynamic> _courtDetails;

  // Similar venues data from nearbyVenues.dart
  final List<VenueModel> _similarVenues = [
    VenueModel(
      id: '1',
      title: "CR7 FUTSAL & INDOOR CRICKET",
      location: "23 Mile Post Ave, Colombo 00300",
      rating: 4.75,
      distance: 1.2,
      imageUrl:
          "https://images.unsplash.com/photo-1575361204480-aadea25e6e68?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
      sports: ["Futsal", "Cricket", "Indoor"],
      openingHours: "6:00 AM - 11:00 PM",
      ratePerHour: "Rs. 3,000",
    ),
    VenueModel(
      id: '2',
      title: "ARK SPORTS - INDOOR CRICKET & FUTSAL",
      location: "141/A, Wattala 11300",
      rating: 4.23,
      distance: 3.5,
      imageUrl:
          "https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
      sports: ["Futsal", "Cricket", "Indoor"],
      openingHours: "7:00 AM - 10:00 PM",
      ratePerHour: "Rs. 2,500",
    ),
    VenueModel(
      id: '3',
      title: "CHAMPION'S ARENA",
      location: "45 Sports Complex Road, Rajagiriya 10100",
      rating: 4.89,
      distance: 0.8,
      imageUrl:
          "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
      sports: ["Badminton", "Tennis", "Squash", "Outdoor"],
      openingHours: "6:00 AM - 10:00 PM",
      ratePerHour: "Rs. 2,000",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeCourtData();
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
            'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
            'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
            'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          ],
          'sports_available': ['Football', 'Cricket', 'Basketball'],
          'sport_images': [
            'https://images.unsplash.com/photo-1553778263-73a83bab9b0c?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
            'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
            'https://images.unsplash.com/photo-1546519638-68e109498ffc?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
          ],
        };
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  Widget _buildDirectionsIcon({Color color = Colors.white, double size = 20}) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: DirectionsIconPainter(color: color),
      ),
    );
  }

  Widget _buildActionButton(String text, dynamic icon, Color backgroundColor, Color textColor, VoidCallback onPressed) {
    return Expanded(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: backgroundColor != const Color(0xFF050E22) ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                if (icon is IconData)
                  Icon(icon, color: textColor, size: 20)
                else if (icon is Widget)
                  icon
                else
                  _buildDirectionsIcon(color: textColor, size: 20),
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

  Widget _buildOverlayIcon(IconData icon, VoidCallback onTap, {Color? backgroundColor, Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withOpacity(0.9),
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
          icon,
          color: iconColor ?? Colors.black87,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String subtitle, {VoidCallback? onTap, bool showDivider = true}) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFBFBFB), // Slightly off-white for cards
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: const Color(0xFF4A5568),
                        size: 18,
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
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF718096),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFFCBD5E0),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showDivider)
            Container(
              margin: const EdgeInsets.only(left: 68),
              height: 1,
              color: const Color(0xFFF1F3F5),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
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
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 50),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  
                  // Top overlay icons
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    right: 16,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
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
            child: Container(
              color: const Color(0xFFFEFEFE), // Off-white content background
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Rating Section
                  Padding(
                    padding: const EdgeInsets.all(20),
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
                                  color: Color(0xFF2D3748),
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
                                    color: Color(0xFF2D3748),
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
                              _buildDirectionsIcon(color: Colors.white, size: 20),
                              const Color(0xFF050E22),
                              Colors.white,
                              () {},
                            ),
                            const SizedBox(width: 12),
                            _buildActionButton(
                              'Call',
                              Icons.phone,
                              Colors.white,
                              const Color(0xFF050E22),
                              () {},
                            ),
                            const SizedBox(width: 12),
                            _buildActionButton(
                              'Share',
                              Icons.share,
                              Colors.white,
                              const Color(0xFF050E22),
                              () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Info Cards
                  _buildInfoCard(
                    Icons.location_on,
                    _courtDetails['location'],
                    _courtDetails['distance'],
                  ),
                  
                  _buildInfoCard(
                    Icons.access_time,
                    _courtDetails['opening_hours'],
                    _courtDetails['closing_time'],
                  ),
                  
                  _buildInfoCard(
                    Icons.star,
                    'Write a Review',
                    'Share your experience',
                    showDivider: false,
                  ),

                  const SizedBox(height: 32),

                  // Available Sports Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Available Sports',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: List.generate(
                            _courtDetails['sport_images'].length,
                            (index) => Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: index < _courtDetails['sport_images'].length - 1 ? 8 : 0,
                                ),
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _courtDetails['sport_images'][index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: Icon(Icons.sports, color: Colors.grey),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 80 + MediaQuery.of(context).padding.bottom,
        decoration: BoxDecoration(
          color: const Color(0xFFFEFEFE), // Off-white navigation background
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', 0),
              _buildNavItem(Icons.arrow_back_ios, '', 1),
              _buildNavItem(Icons.arrow_forward_ios, '', 2),
              _buildNavItem(Icons.chat_bubble_outline, 'Chat', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF050E22) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : const Color(0xFF9CA3AF),
                size: 20,
              ),
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isActive ? const Color(0xFF050E22) : const Color(0xFF9CA3AF),
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}