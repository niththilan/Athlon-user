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
          seedColor: const Color(0xFF1B2C4F),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
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
    VenueModel(
      id: '4',
      title: "AQUA SPORTS CENTER",
      location: "78 Poolside Avenue, Mount Lavinia 10370",
      rating: 4.67,
      distance: 5.2,
      imageUrl:
          "https://images.unsplash.com/photo-1576610616656-d3aa5d1f4534?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
      sports: ["Swimming", "Water Polo", "Diving"],
      openingHours: "5:30 AM - 9:30 PM",
      ratePerHour: "Rs. 1,200",
    ),
    VenueModel(
      id: '5',
      title: "ELITE BASKETBALL ACADEMY",
      location: "92 Court Lane, Dehiwala 10350",
      rating: 4.45,
      distance: 2.7,
      imageUrl:
          "https://images.unsplash.com/photo-1546519638-68e109498ffc?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
      sports: ["Basketball", "Volleyball"],
      openingHours: "7:00 AM - 11:00 PM",
      ratePerHour: "Rs. 1,800",
    ),
    VenueModel(
      id: '6',
      title: "VICTORY VALLEY GOLF CLUB",
      location: "156 Greens Road, Kandy 20000",
      rating: 4.92,
      distance: 8.6,
      imageUrl:
          "https://images.unsplash.com/photo-1587174486073-ae5e5cff23aa?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
      sports: ["Golf"],
      openingHours: "6:00 AM - 8:00 PM",
      ratePerHour: "Rs. 5,000",
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
          'name': 'CR7 FUTSAL & INDOOR CRICKET ARENA',
          'type': 'Futsal Court',
          'location': '23 Mile Post Ave, Colombo 00300',
          'rating': 4.75,
          'total_reviews': 124,
          'distance': '2.3 km',
          'price_per_hour': 2500.0,
          'opening_hours': '6:00 AM - 11:00 PM',
          'phone': '+94 77 123 4567',
          'email': 'info@cr7arena.lk',
          'website': 'www.cr7arena.lk',
          'description':
              'Premium indoor futsal and cricket facility with state-of-the-art equipment and professional-grade surfaces. Perfect for casual games, tournaments, and training sessions.',
          'owner_name': 'Ahmed Silva',
          'owner_avatar': null,
          'images': [
            'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
            'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
            'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          ],
          'amenities': [
            {'name': 'Parking', 'icon': Icons.local_parking, 'available': true},
            {'name': 'Changing Rooms', 'icon': Icons.wc, 'available': true},
            {'name': 'Shower Facilities', 'icon': Icons.shower, 'available': true},
            {'name': 'Equipment Rental', 'icon': Icons.sports_soccer, 'available': true},
            {'name': 'Refreshments', 'icon': Icons.local_cafe, 'available': true},
            {'name': 'First Aid', 'icon': Icons.medical_services, 'available': true},
            {'name': 'CCTV Security', 'icon': Icons.security, 'available': true},
            {'name': 'Air Conditioning', 'icon': Icons.ac_unit, 'available': true},
            {'name': 'WiFi', 'icon': Icons.wifi, 'available': false},
            {'name': 'Scoreboard', 'icon': Icons.leaderboard, 'available': true},
          ],
          'sports_available': ['Futsal', 'Indoor Cricket', 'Basketball'],
          'surface_type': 'Artificial Turf',
          'capacity': '5v5 - 10 players',
          'court_dimensions': '40m x 20m',
          'booking_advance_days': 30,
          'cancellation_policy':
              'Free cancellation up to 24 hours before booking',
          'reviews': [
            {
              'id': '1',
              'user_name': 'Kasun Perera',
              'user_avatar': null,
              'rating': 5.0,
              'date': '2024-01-15',
              'comment':
                  'Excellent facility! The surface is perfect and the equipment is top-notch. Highly recommended for serious players.',
            },
            {
              'id': '2',
              'user_name': 'Nimal Fernando',
              'user_avatar': null,
              'rating': 4.5,
              'date': '2024-01-10',
              'comment':
                  'Great place to play futsal. Clean facilities and friendly staff. The only downside is parking can be limited during peak hours.',
            },
          ],
        };
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? 'Added to favorites' : 'Removed from favorites',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color backgroundColor, Color textColor, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          minimumSize: const Size(0, 48),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayIcon(IconData icon, VoidCallback onTap, {Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor ?? Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSportCard(String sport) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Text(
        sport,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3142),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String content) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2C4F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF1B2C4F), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueCard(VenueModel venue) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
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
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              height: 110,
              width: double.infinity,
              color: Colors.grey[200],
              child: Image.network(
                venue.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[100],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Venue details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  venue.location,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      venue.rating.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      venue.ratePerHour,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B2C4F),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        slivers: [
          // Top Image Carousel as Sliver
          SliverToBoxAdapter(
            child: Container(
              height: 300,
              width: double.infinity,
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
                            color: Colors.grey[300],
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
                            color: Colors.grey[300],
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image, size: 50),
                                Text('Failed to load image'),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Overlay icons on top right
                  Positioned(
                    top: 50,
                    right: 16,
                    child: Row(
                      children: [
                        _buildOverlayIcon(Icons.grid_view, () {}),
                        const SizedBox(width: 8),
                        _buildOverlayIcon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          _toggleFavorite,
                          iconColor: _isFavorite ? Colors.red : Colors.white,
                        ),
                        const SizedBox(width: 8),
                        _buildOverlayIcon(Icons.notifications_outlined, () {}),
                      ],
                    ),
                  ),
                  // Back button
                  Positioned(
                    top: 50,
                    left: 16,
                    child: _buildOverlayIcon(Icons.arrow_back, () => Navigator.pop(context)),
                  ),
                  // White circular indicator dots at bottom center
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _courtDetails['images'].length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
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

          // Sticky Header with Matching Background
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              child: Text(
                _courtDetails['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Scrollable Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating Row (now scrollable)
                  Row(
                    children: [
                      Text(
                        '${_courtDetails['rating']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            Icons.star,
                            size: 18,
                            color: index < _courtDetails['rating']
                                ? Colors.amber
                                : Colors.grey[300],
                          );
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  // Three Action Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Directions',
                          Icons.directions,
                          const Color(0xFF1B2C4F),
                          Colors.white,
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opening directions...')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          'Call',
                          Icons.phone,
                          Colors.grey[200]!,
                          const Color(0xFF2D3142),
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Calling ${_courtDetails['phone']}...')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          'Share',
                          Icons.share,
                          Colors.grey[200]!,
                          const Color(0xFF2D3142),
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sharing...')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Address Card
                  _buildInfoCard(
                    Icons.location_on,
                    'Address',
                    _courtDetails['location'],
                  ),

                  const SizedBox(height: 12),

                  // Open Hours Card
                  _buildInfoCard(
                    Icons.access_time,
                    'Open Hours',
                    'Today 6:00 AM - 11:00 PM',
                  ),

                  const SizedBox(height: 12),

                  // Review Card
                  _buildInfoCard(
                    Icons.star,
                    'Reviews',
                    'Overall ${_courtDetails['rating']} rating • ${_courtDetails['total_reviews']} reviews',
                  ),

                  const SizedBox(height: 24),

                  // Available Sports Section
                  const Text(
                    'Available Sports',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _courtDetails['sports_available'].length,
                      itemBuilder: (context, index) {
                        return _buildSportCard(_courtDetails['sports_available'][index]);
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Similar Venues Section
                  const Text(
                    'Similar Venues',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _similarVenues.length,
                      itemBuilder: (context, index) {
                        return _buildVenueCard(_similarVenues[index]);
                      },
                    ),
                  ),

                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar using AppFooter
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

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 120; // Increased height to accommodate safe area + text
  
  @override
  double get maxExtent => 120; // Same height to keep it simple

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final safePadding = MediaQuery.of(context).padding.top;
    
    return Container(
      height: 120,
      color: const Color(0xFFF5F6FA),
      padding: EdgeInsets.only(
        top: safePadding + 8, // Safe area + minimal padding
        left: 16,
        right: 16,
        bottom: 8,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
