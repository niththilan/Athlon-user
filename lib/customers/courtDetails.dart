// ignore: file_names
// ignore_for_file: deprecated_member_use, file_names, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Import your other screens
import 'bookNow.dart'; // Your BookNow screen (uncomment and update path as needed)
// import 'messages.dart'; // Your Messages screen (uncomment and update path as needed)

// Temporary BookNowScreen - replace with actual import when files are properly set up
// class BookNowScreen extends StatefulWidget {
//   final Map<String, dynamic>? venue;

//   const BookNowScreen({super.key, this.venue});

//   @override
//   State<BookNowScreen> createState() => BookNowScreenState();
// }

// class _BookNowScreenState extends State<BookNowScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1B2C4F),
//         elevation: 2,
//         toolbarHeight: 50.0,
//         title: const Text(
//           "Book Now",
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: false,
//         leading: IconButton(
//           icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => BookNowScreen()),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

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

class CourtDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? courtData;

  const CourtDetailScreen({super.key, this.courtData});

  @override
  State<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _isFavorite = false;
  int _currentImageIndex = 0;
  bool _showAllAmenities = false;
  bool _showAllReviews = false;

  // Mock court data
  late Map<String, dynamic> _courtDetails;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initializeCourtData();
  }

  void _initializeCourtData() {
    _courtDetails =
        widget.courtData ??
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
            {
              'name': 'Shower Facilities',
              'icon': Icons.shower,
              'available': true,
            },
            {
              'name': 'Equipment Rental',
              'icon': Icons.sports_soccer,
              'available': true,
            },
            {
              'name': 'Refreshments',
              'icon': Icons.local_cafe,
              'available': true,
            },
            {
              'name': 'First Aid',
              'icon': Icons.medical_services,
              'available': true,
            },
            {
              'name': 'CCTV Security',
              'icon': Icons.security,
              'available': true,
            },
            {
              'name': 'Air Conditioning',
              'icon': Icons.ac_unit,
              'available': true,
            },
            {'name': 'WiFi', 'icon': Icons.wifi, 'available': false},
            {
              'name': 'Scoreboard',
              'icon': Icons.leaderboard,
              'available': true,
            },
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
            {
              'id': '3',
              'user_name': 'Priya Jayawardena',
              'user_avatar': null,
              'rating': 5.0,
              'date': '2024-01-08',
              'comment':
                  'Love this place! Been coming here for months. The court is always well-maintained and the booking system is convenient.',
            },
            {
              'id': '4',
              'user_name': 'Chaminda Silva',
              'user_avatar': null,
              'rating': 4.0,
              'date': '2024-01-05',
              'comment':
                  'Good court overall. Equipment could be updated but the playing surface is excellent.',
            },
          ],
        };
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 200 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
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

  void _showImageGallery() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: StatefulBuilder(
          builder: (context, setDialogState) => Container(
            height: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black87,
            ),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {}, // Prevent dialog close on image tap
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        _courtDetails['images'][_currentImageIndex],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 50),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Navigation arrows in gallery
                if (_courtDetails['images'].length > 1) ...[
                  // Left arrow
                  Positioned(
                    left: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          if (_currentImageIndex > 0) {
                            setState(() {
                              _currentImageIndex--;
                            });
                            setDialogState(() {});
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            color: _currentImageIndex > 0
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Right arrow
                  Positioned(
                    right: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          if (_currentImageIndex <
                              _courtDetails['images'].length - 1) {
                            setState(() {
                              _currentImageIndex++;
                            });
                            setDialogState(() {});
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chevron_right,
                            color:
                                _currentImageIndex <
                                    _courtDetails['images'].length - 1
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black45,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _courtDetails['images'].length,
                      (index) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentImageIndex = index;
                          });
                          setDialogState(() {});
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == _currentImageIndex
                                ? Colors.white
                                : Colors.white54,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Updated method to show a simple chat placeholder instead of navigating to chat screen
  void _navigateToChat() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.message, color: Color(0xFF1B2C4F)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Message ${_courtDetails['name']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          content: const Text(
            'Chat functionality will open here.\n\nYou can message the venue directly to inquire about availability, pricing, or any special requirements.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chat feature coming soon!'),
                    backgroundColor: Color(0xFF1B2C4F),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B2C4F),
                foregroundColor: Colors.white,
              ),
              child: const Text('Start Chat'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1B2C4F)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2D3142),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityChip(Map<String, dynamic> amenity) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: amenity['available']
            ? const Color(0xFF1B2C4F).withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: amenity['available']
              ? const Color(0xFF1B2C4F).withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            amenity['icon'],
            size: 16,
            color: amenity['available']
                ? const Color(0xFF1B2C4F)
                : Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Text(
            amenity['name'],
            style: TextStyle(
              fontSize: 12,
              color: amenity['available']
                  ? const Color(0xFF1B2C4F)
                  : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!amenity['available']) ...[
            const SizedBox(width: 4),
            Icon(Icons.close, size: 14, color: Colors.grey[600]),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF1B2C4F).withOpacity(0.1),
                child: Text(
                  review['user_name'][0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF1B2C4F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['user_name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    Text(
                      DateFormat(
                        'MMM d, yyyy',
                      ).format(DateTime.parse(review['date'])),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    size: 16,
                    color: index < review['rating']
                        ? Colors.amber
                        : Colors.grey[300],
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['comment'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToBooking() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => BookNowScreen(
          venue: {
            'title': _courtDetails['name'],
            'location': _courtDetails['location'],
            'sport': _courtDetails['type'],
            'rating': _courtDetails['rating'],
            'rate_per_hour': 'Rs. ${_courtDetails['price_per_hour']}',
            'distance': _courtDetails['distance'],
          },
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar with images
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF1B2C4F),
            title: _isScrolled
                ? Text(
                    _courtDetails['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            // Updated leading without transparent background circle
            leading: IconButton(
              icon: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                  size: 28,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image display with arrow navigation only
                  GestureDetector(
                    onTap: _showImageGallery,
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Image.network(
                        _courtDetails['images'][_currentImageIndex],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
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
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                  // Enhanced image indicators and navigation
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(
                            _courtDetails['images'].length,
                            (index) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: index == _currentImageIndex
                                      ? Colors.white
                                      : Colors.white54,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_currentImageIndex + 1}/${_courtDetails['images'].length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Add navigation arrows for better UX
                  if (_courtDetails['images'].length > 1) ...[
                    // Left arrow
                    Positioned(
                      left: 16,
                      top: MediaQuery.of(context).size.height * 0.15,
                      bottom: MediaQuery.of(context).size.height * 0.15,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            if (_currentImageIndex > 0) {
                              setState(() {
                                _currentImageIndex--;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chevron_left,
                              color: _currentImageIndex > 0
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Right arrow
                    Positioned(
                      right: 16,
                      top: MediaQuery.of(context).size.height * 0.15,
                      bottom: MediaQuery.of(context).size.height * 0.15,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            if (_currentImageIndex <
                                _courtDetails['images'].length - 1) {
                              setState(() {
                                _currentImageIndex++;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              color:
                                  _currentImageIndex <
                                      _courtDetails['images'].length - 1
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Court Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _courtDetails['name'],
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3142),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF1B2C4F,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          _courtDetails['type'],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF1B2C4F),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _courtDetails['rating'].toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3142),
                                    ),
                                  ),
                                  Text(
                                    ' (${_courtDetails['total_reviews']})',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Quick Info Grid
                        Column(
                          children: [
                            _buildInfoRow(
                              Icons.location_on,
                              'Location',
                              _courtDetails['distance'],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              Icons.monetization_on,
                              'Price',
                              'Rs. ${_courtDetails['price_per_hour']}/hr',
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              Icons.access_time,
                              'Hours',
                              _courtDetails['opening_hours'],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              Icons.people,
                              'Capacity',
                              _courtDetails['capacity'],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _navigateToBooking,
                                icon: const Icon(Icons.calendar_today),
                                label: const Text('Book Now'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1B2C4F),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed:
                                  _navigateToChat, // Updated to navigate to chat
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF1B2C4F),
                                side: const BorderSide(
                                  color: Color(0xFF1B2C4F),
                                ),
                                padding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Icon(Icons.message),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About This Court',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _courtDetails['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Court Specifications
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoRow(
                                      Icons.straighten,
                                      'Dimensions',
                                      _courtDetails['court_dimensions'],
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoRow(
                                      Icons.grass,
                                      'Surface',
                                      _courtDetails['surface_type'],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Amenities Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Amenities & Facilities',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3142),
                              ),
                            ),
                            if (_courtDetails['amenities'].length > 6)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _showAllAmenities = !_showAllAmenities;
                                  });
                                },
                                child: Text(
                                  _showAllAmenities ? 'Show Less' : 'Show All',
                                  style: const TextStyle(
                                    color: Color(0xFF1B2C4F),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          children:
                              (_showAllAmenities
                                      ? _courtDetails['amenities']
                                      : _courtDetails['amenities']
                                            .take(6)
                                            .toList())
                                  .map<Widget>(
                                    (amenity) => _buildAmenityChip(amenity),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Contact Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contact Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.location_on,
                          'Address',
                          _courtDetails['location'],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.phone,
                          'Phone',
                          _courtDetails['phone'],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.email,
                          'Email',
                          _courtDetails['email'],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.web,
                          'Website',
                          _courtDetails['website'],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Reviews Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reviews (${_courtDetails['total_reviews']})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3142),
                              ),
                            ),
                            if (_courtDetails['reviews'].length > 2)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _showAllReviews = !_showAllReviews;
                                  });
                                },
                                child: Text(
                                  _showAllReviews ? 'Show Less' : 'View All',
                                  style: const TextStyle(
                                    color: Color(0xFF1B2C4F),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children:
                              (_showAllReviews
                                      ? _courtDetails['reviews']
                                      : _courtDetails['reviews']
                                            .take(2)
                                            .toList())
                                  .map<Widget>(
                                    (review) => _buildReviewItem(review),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Policies Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Booking Policies',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.event_available,
                          'Advance Booking',
                          'Up to ${_courtDetails['booking_advance_days']} days',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.cancel,
                          'Cancellation',
                          _courtDetails['cancellation_policy'],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
