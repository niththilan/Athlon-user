// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'bookings.dart'; // Import the bookings.dart file
import 'nearbyVenues.dart'; // Import for VenueModel
import 'footer.dart'; // Import footer

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Athlon Sports',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B2C4F),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      ),
      home: const SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  // Updated recent searches to be sports-related
  final List<String> _recentSearches = [
    'Badminton Courts',
    'Swimming Pool',
    'Football Field',
    'Tennis Coaching',
  ];

  List<VenueResult> _searchResults = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  int _currentTabIndex = 0; // Add current tab index for footer

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call with sports venue results
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _searchResults = [
          VenueResult(
            title: 'CHAMPION\'S ARENA',
            location: '45 Sports Complex Road, Rajagiriya 10100',
            type: 'Badminton',
            rating: 4.9,
            price: '2000',
            distance: '0.8 km',
            timeSlot: '6:00 AM - 10:00 PM',
            imageUrl:
                'https://images.unsplash.com/photo-1544551763-46a013bb70d5?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
          ),
          VenueResult(
            title: 'AQUA SPORTS CENTER',
            location: '78 Poolside Avenue, Mount Lavinia',
            type: 'Swimming',
            rating: 4.5,
            price: '1800',
            distance: '3.1 km',
            timeSlot: '5:00 AM - 11:00 PM',
            imageUrl:
                'https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
          ),
          VenueResult(
            title: 'VICTORY FOOTBALL GROUND',
            location: '156 Greens Road, Kandy',
            type: 'Football',
            rating: 4.7,
            price: '2500',
            distance: '4.2 km',
            timeSlot: '6:00 AM - 9:00 PM',
            imageUrl:
                'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
          ),
        ];
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2C4F),
        elevation: _isScrolled ? 2 : 0,
        toolbarHeight: 50,
        title: const Text(
          "Search",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        leading: Container(
          margin: const EdgeInsets.fromLTRB(16, 3, 8, 8),
          child: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _searchController.text.isEmpty
                ? _buildRecentSearches()
                : _buildSearchResults(),
          ),
        ],
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: _currentTabIndex,
        onTabSelected: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B2C4F).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(
            color: Color(0xFF2D3142),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: 'Search sports venues...',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.all(2),
              child: const Icon(
                Icons.search_rounded,
                color: Color(0xFF1B2C4F),
                size: 24,
              ),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.all(10),
                    child: IconButton(
                      icon: const Icon(
                        Icons.clear_rounded,
                        color: Color(0xFF1B2C4F),
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchResults.clear();
                        });
                      },
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: const Color(0xFF1B2C4F).withOpacity(0.2),
                width: 1.5,
              ),
            ),
            isDense: true,
            isCollapsed: false,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            alignLabelWithHint: true,
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              _performSearch(value);
            } else {
              setState(() {
                _searchResults.clear();
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 12, 24, 8),
          child: Text(
            "Recent Searches",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2C4F),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            physics: const BouncingScrollPhysics(),
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B2C4F).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: Color(0xFF1B2C4F),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    _recentSearches[index],
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF1B2C4F),
                    size: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    _searchController.text = _recentSearches[index];
                    _performSearch(_recentSearches[index]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF1B2C4F),
                ),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Finding venues...",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_outlined, size: 90, color: Colors.grey[350]),
            const SizedBox(height: 20),
            Text(
              'No venues found',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try searching with different keywords',
              style: TextStyle(fontSize: 15, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 12, 24, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Venues (${_searchResults.length})",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2C4F),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  _showCustomSnackBar(context, "Filter options");
                },
                icon: const Icon(
                  Icons.filter_list_rounded,
                  size: 20,
                  color: Color(0xFF1B2C4F),
                ),
                label: const Text(
                  "Filter",
                  style: TextStyle(
                    color: Color(0xFF1B2C4F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            physics: const BouncingScrollPhysics(),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final venue = _searchResults[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section with modern overlay
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        color: Colors.grey[50],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: Image.network(
                              venue.imageUrl,
                              width: double.infinity,
                              height: 160,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[50],
                                  child: Center(
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 24,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Minimal favorite button
                          Positioned(
                            top: 16,
                            right: 16,
                            child: GestureDetector(
                              onTap: () {
                                // Handle favorite toggle
                              },
                              child: Icon(
                                Icons.favorite_border,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          // Rating badge on image
                          Positioned(
                            bottom: 12,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.orange[600],
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    venue.rating.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content Section with clean layout
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Venue name
                          Text(
                            venue.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B2C4F),
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          // Location
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  venue.location,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    height: 1.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Distance and Sports
                          Row(
                            children: [
                              // Distance
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B2C4F).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  venue.distance,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1B2C4F),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Opening status
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Open Now",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green[600],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 0),

                          // Sports tags and Book Now button
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Sports tags (up to 3)
                              Expanded(
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [venue.type].map((sport) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Colors.blue.withOpacity(0.2),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        sport,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              
                              // Book Now button
                              ElevatedButton(
                                onPressed: () {
                                  // Convert VenueResult to VenueModel and navigate to SlotsPage
                                  final venueModel = _convertToVenueModel(venue);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SlotsPage(
                                        selectedVenue: venueModel,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1B2C4F),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  elevation: 0,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Book Now',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
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
    );
  }

  // Helper function to convert VenueResult to VenueModel
  VenueModel _convertToVenueModel(VenueResult venueResult) {
    return VenueModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate unique ID
      title: venueResult.title,
      location: venueResult.location,
      rating: venueResult.rating,
      distance: double.tryParse(venueResult.distance.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0,
      imageUrl: venueResult.imageUrl,
      sports: [venueResult.type], // Convert single type to list
      openingHours: venueResult.timeSlot,
      ratePerHour: "Rs. ${venueResult.price}",
    );
  }

  void _showCustomSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFF1B2C4F),
      ),
    );
  }
}

// Updated venue result model
class VenueResult {
  final String title;
  final String location;
  final String type;
  final double rating;
  final String price;
  final String distance;
  final String timeSlot;
  final String imageUrl;

  VenueResult({
    required this.title,
    required this.location,
    required this.type,
    required this.rating,
    required this.price,
    required this.distance,
    required this.timeSlot,
    required this.imageUrl,
  });
}
