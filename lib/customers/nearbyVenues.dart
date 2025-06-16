// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'home.dart';
import 'search.dart';
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
          primary: const Color(0xFF1B2C4F),
          secondary: const Color(0xFF3D5AF1),
          tertiary: const Color(0xFFFF8C42),
          background: Colors.white,
        ),
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B2C4F),
          elevation: 0,
          centerTitle: false,
          foregroundColor: Colors.white,
        ),
      ),
      home: const SportsVenueScreen(),
    );
  }
}

class SportsVenueScreen extends StatefulWidget {
  const SportsVenueScreen({super.key});

  @override
  State<SportsVenueScreen> createState() => _SportsVenueScreenState();
}

class _SportsVenueScreenState extends State<SportsVenueScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isScrolled = false;
  String _searchQuery = '';
  int _currentIndex = 0;
  late AnimationController _animationController;
  String _activeFilter = 'All';
  String _sortingMode = 'Nearest';
  double _distanceRadius = 10.0; // Default radius in km

  // Map to track favorite status for each venue
  final Map<String, bool> _favoriteStatus = {};

  // Sports filter list
  final List<String> _filterOptions = [
    'All',
    'Indoor',
    'Outdoor',
    'Cricket',
    'Futsal',
    'Tennis',
    'Swimming',
    'Basketball',
    'Golf',
    'Yoga',
  ];

  // List of all venues with distance
  final List<VenueModel> _allVenues = [
    VenueModel(
      id: '1',
      title: "CR7 FUTSAL & INDOOR CRICKET",
      location: "23 Mile Post Ave, Colombo 00300",
      rating: 4.75,
      distance: 1.2,
      imageUrl:
          "https://images.unsplash.com/photo-1575361204480-aadea25e6e68?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
      sports: ["Futsal", "Cricket", "Indoor Sports"],
    ),
    VenueModel(
      id: '2',
      title: "ARK SPORTS - INDOOR CRICKET & FUTSAL",
      location: "141/A, Wattala 11300",
      rating: 4.23,
      distance: 3.5,
      imageUrl:
          "https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
      sports: ["Futsal", "Cricket", "Indoor Sports"],
    ),
    VenueModel(
      id: '3',
      title: "CHAMPION'S ARENA",
      location: "45 Sports Complex Road, Rajagiriya 10100",
      rating: 4.89,
      distance: 0.8,
      imageUrl:
          "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
      sports: ["Badminton", "Tennis", "Squash"],
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
    ),
    VenueModel(
      id: '7',
      title: "COLOMBO TENNIS CLUB",
      location: "45 Racquet Road, Colombo 00500",
      rating: 4.82,
      distance: 1.5,
      imageUrl:
          "https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
      sports: ["Tennis", "Badminton"],
    ),
    VenueModel(
      id: '8',
      title: "OCEANSIDE SURFING SCHOOL",
      location: "Beach Front, Hikkaduwa 80240",
      rating: 4.78,
      distance: 12.3,
      imageUrl:
          "https://images.unsplash.com/photo-1502680390469-be75c86b636f?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
      sports: ["Surfing", "Swimming", "Beach Volleyball"],
    ),
    VenueModel(
      id: '9',
      title: "CENTRAL YOGA & FITNESS",
      location: "22 Wellness Street, Nawala 10107",
      rating: 4.65,
      distance: 1.9,
      imageUrl:
          "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
      sports: ["Yoga", "Pilates", "Fitness"],
    ),
    VenueModel(
      id: '10',
      title: "MOUNTAIN BIKING TRAILS",
      location: "Hanthana Mountain Range, Kandy 20000",
      rating: 4.91,
      distance: 10.5,
      imageUrl:
          "https://images.unsplash.com/photo-1541625602330-2277a4c46182?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
      sports: ["Mountain Biking", "Hiking", "Trail Running"],
    ),
    VenueModel(
      id: '11',
      title: "COLOMBO BOXING CLUB",
      location: "78 Fighter's Lane, Colombo 00700",
      rating: 4.56,
      distance: 4.3,
      imageUrl:
          "https://images.unsplash.com/photo-1549719386-74dfcbf7dbed?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
      sports: ["Boxing", "MMA", "Kickboxing"],
    ),
    VenueModel(
      id: '12',
      title: "GRAND SLAM CRICKET ACADEMY",
      location: "123 Boundary Road, Galle 80000",
      rating: 4.88,
      distance: 7.8,
      imageUrl:
          "https://images.unsplash.com/photo-1531415074968-036ba1b575da?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
      sports: ["Cricket", "Baseball"],
    ),
    VenueModel(
      id: '13',
      title: "KANDY HILLS ROCK CLIMBING",
      location: "Rock Face Avenue, Kandy 20100",
      rating: 4.70,
      distance: 9.2,
      imageUrl:
          "https://images.unsplash.com/photo-1522163182402-834f871fd851?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
      sports: ["Rock Climbing", "Bouldering", "Rappelling"],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Sort venues by distance (nearest first)
    _allVenues.sort((a, b) => a.distance.compareTo(b.distance));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Toggle favorite status for a venue
  void _toggleFavorite(String venueId) {
    setState(() {
      _favoriteStatus[venueId] = !(_favoriteStatus[venueId] ?? false);
    });

    // Add haptic feedback and animation
    _animationController.reset();
    _animationController.forward();
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

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  // Set active filter
  void _setFilter(String filter) {
    setState(() {
      _activeFilter = filter;
    });
  }

  // Handle tab selection
  void _handleTabSelection(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SearchScreen()),
      );
    }
  }

  // Filtered venues based on search and active filter
  List<VenueModel> get _filteredVenues {
    List<VenueModel> filtered = _allVenues;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((venue) {
        final titleMatches = venue.title.toLowerCase().contains(_searchQuery);
        final locationMatches = venue.location.toLowerCase().contains(
          _searchQuery,
        );
        final sportsMatches = venue.sports.any(
          (sport) => sport.toLowerCase().contains(_searchQuery),
        );
        return titleMatches || locationMatches || sportsMatches;
      }).toList();
    }

    // Apply category filter
    if (_activeFilter != 'All') {
      filtered = filtered.where((venue) {
        return venue.sports.any(
          (sport) => sport.toLowerCase() == _activeFilter.toLowerCase(),
        );
      }).toList();
    }

    // Apply distance radius filter
    filtered = filtered
        .where((venue) => venue.distance <= _distanceRadius)
        .toList();

    // Apply sorting based on selected mode
    switch (_sortingMode) {
      case 'Nearest':
        filtered.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case 'Farthest':
        filtered.sort((a, b) => b.distance.compareTo(a.distance));
        break;
      case 'Highest Rated':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Sports (A-Z)':
        filtered.sort((a, b) => a.sports.first.compareTo(b.sports.first));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2C4F),
        elevation: 2,
        toolbarHeight: 50,
        title: const Text(
          "Nearby Venues",
          style: TextStyle(
            fontSize: 16,
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
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        actions: [],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: _isScrolled
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 1),
                        blurRadius: 5,
                      ),
                    ]
                  : [],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E3E8), width: 1),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Find sports venues...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF1B2C4F),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: Color(0xFF1B2C4F),
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
          ),

          // Sport Filters
          Container(
            height: 50,
            padding: const EdgeInsets.only(left: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final option = _filterOptions[index];
                final isActive = _activeFilter == option;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(option),
                    labelStyle: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFF1B2C4F),
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                    backgroundColor: isActive
                        ? const Color(0xFF1B2C4F)
                        : Colors.white,
                    side: BorderSide(
                      color: isActive
                          ? const Color(0xFF1B2C4F)
                          : const Color(0xFFE0E3E8),
                    ),
                    selectedColor: const Color(0xFF1B2C4F),
                    showCheckmark: false,
                    selected: isActive,
                    onSelected: (selected) {
                      if (selected) {
                        _setFilter(option);
                      }
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                );
              },
            ),
          ),

          // Results header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                const SizedBox(width: 12), // Added spacing to move text right
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Found ",
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      TextSpan(
                        text: "${_filteredVenues.length} venues",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B2C4F),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Sort button
                TextButton.icon(
                  icon: const Icon(
                    Icons.sort,
                    size: 18,
                    color: Color(0xFF1B2C4F),
                  ),
                  label: Text(
                    _sortingMode,
                    style: const TextStyle(
                      color: Color(0xFF1B2C4F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF5F6FA),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    _showSortingOptions(context);
                  },
                ),
              ],
            ),
          ),

          // Venues list
          Expanded(
            child: _filteredVenues.isEmpty
                ? _buildEmptyState()
                : _buildVenuesList(),
          ),
        ],
      ),
      // Bottom navigation bar
      bottomNavigationBar: AppFooter(
        currentIndex: _currentIndex,
        onTabSelected: _handleTabSelection,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No venues found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your search or filters",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              _setFilter('All');
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Reset filters"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B2C4F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenuesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: _filteredVenues.length,
      itemBuilder: (context, index) {
        final venue = _filteredVenues[index];
        final isFavorite = _favoriteStatus[venue.id] ?? false;

        return _buildVenueCard(venue, isFavorite);
      },
    );
  }

  Widget _buildVenueCard(VenueModel venue, bool isFavorite) {
    // Format the rating to one decimal place
    String formattedRating = venue.rating.toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Venue image section
            Stack(
              children: [
                // Image
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: Image.network(
                    venue.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Gradient overlay
                Positioned.fill(
                  child: Container(
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
                ),

                // Sports type badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      venue.sports.first,
                      style: const TextStyle(
                        color: Color(0xFF1B2C4F),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                // Distance badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.directions_walk,
                          size: 14,
                          color: Color(0xFF1B2C4F),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${venue.distance.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            color: Color(0xFF1B2C4F),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Venue title at bottom
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Text(
                    venue.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Venue details section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          venue.location,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Sport tags and rating
                  Row(
                    children: [
                      // Sports tags
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: venue.sports.take(2).map((sport) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F6FA),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                sport,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1B2C4F),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedRating,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      // Favorite button
                      InkWell(
                        onTap: () => _toggleFavorite(venue.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isFavorite
                                ? const Color(0xFFFFEBEE)
                                : const Color(0xFFF5F6FA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Book button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Booking functionality
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B2C4F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
      ),
    );
  }

  void _showSortingOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                16.0,
                15.0,
                16.0,
                10.0,
              ), // Added top padding of 37 (16+21)
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      "Sort & Filter",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2C4F),
                      ),
                    ),
                  ),
                  const Divider(),

                  // Distance Range Slider
                  const Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Text(
                      "Distance Range",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      // Changed to show selected distance instead of fixed "0 km"
                      Text("${_distanceRadius.round()} km"),
                      Expanded(
                        child: Slider(
                          value: _distanceRadius,
                          min: 0.0,
                          max: 20.0, // Changed from 30.0 to 20.0
                          divisions: 19, // Changed from 29 to 19 (20-1 steps)
                          label: "${_distanceRadius.round()} km",
                          activeColor: const Color(0xFF1B2C4F),
                          onChanged: (value) {
                            setModalState(() {
                              _distanceRadius = value;
                            });
                          },
                        ),
                      ),
                      Text("20 km"), // Changed from 30 km to 20 km
                    ],
                  ),

                  // Sorting Options
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Sort By",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sorting Radio Buttons
                  _buildSortingOption(
                    "Nearest",
                    "Distance: Low to High",
                    setModalState,
                    bottomPadding: 2.0,
                  ),
                  _buildSortingOption(
                    "Farthest",
                    "Distance: High to Low",
                    setModalState,
                    topPadding: 2.0,
                    bottomPadding: 2.0,
                  ),
                  _buildSortingOption(
                    "Highest Rated",
                    "Rating: High to Low",
                    setModalState,
                    topPadding: 2.0,
                  ),

                  // Divider and Reset button
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Divider(),
                  ),

                  // Reset button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setModalState(() {
                          _distanceRadius = 10.0; // Reset to default
                          _sortingMode = 'Nearest'; // Reset to default
                        });
                      },
                      icon: const Icon(
                        Icons.refresh,
                        size: 18,
                        color: Color(0xFF1B2C4F),
                      ),
                      label: const Text(
                        "Reset Filters",
                        style: TextStyle(
                          color: Color(0xFF1B2C4F),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),

                  // Apply Button
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B2C4F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            // Update main state with modal values
                          });
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Apply",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortingOption(
    String value,
    String description,
    StateSetter setModalState, {
    double topPadding = 10.0,
    double bottomPadding = 10.0,
  }) {
    return InkWell(
      onTap: () {
        setModalState(() {
          _sortingMode = value;
        });
      },
      child: Padding(
        padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _sortingMode,
              activeColor: const Color(0xFF1B2C4F),
              onChanged: (newValue) {
                setModalState(() {
                  _sortingMode = newValue!;
                });
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Venue Model
class VenueModel {
  final String id;
  final String title;
  final String location;
  final double rating;
  final String imageUrl;
  final List<String> sports;
  final double distance;

  VenueModel({
    required this.id,
    required this.title,
    required this.location,
    required this.rating,
    required this.imageUrl,
    required this.sports,
    required this.distance,
  });
}
