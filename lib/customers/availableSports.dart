import 'package:flutter/material.dart';
import 'footer.dart';
import 'favourites.dart';
import 'VenueCard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          background: const Color.fromARGB(255, 34, 51, 117),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      ),
      home: const SportsVenueScreen(),
    );
  }
}

class SportsVenueScreen extends StatefulWidget {
  final String initialSport;

  const SportsVenueScreen({
    super.key,
    this.initialSport = '', // Default to empty string if not provided
  });

  @override
  State<SportsVenueScreen> createState() => _SportsVenueScreenState();
}

class _SportsVenueScreenState extends State<SportsVenueScreen> {
  final ScrollController _venuesScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _isScrolled = false;
  bool _showVenues = false;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _selectedSport = '';
  String _searchQuery = '';
  int _currentIndex = 0;

  // Theme colors
  final Color _themeNavyBlue = const Color(0xFF1B2C4F);
  final Color _themeLightNavyBlue = const Color(0xFFF0F4FF);

  // Venue data - enhanced with opening hours and rates
  List<Map<String, dynamic>> _venues = [];
  List<Map<String, dynamic>> _filteredVenues = [];

  // Enhanced venue data with all required information
  final List<Map<String, dynamic>> _sampleVenues = [
    {
      'id': '1',
      'title': 'SportsCentral Stadium',
      'location': 'Downtown, Colombo 03',
      'sport': 'Football',
      'rating': 4.8,
      'image_path': 'assets/images/venue1.jpg',
      'distance': '2.3 km',
      'is_favorite': false,
      'opening_hours': '6:00 AM - 11:00 PM',
      'rate_per_hour': 'Rs. 2,500',
      'description': 'Professional football ground with modern facilities',
    },
    {
      'id': '2',
      'title': 'Galaxy Sports Complex',
      'location': 'North Avenue, Colombo 05',
      'sport': 'Basketball',
      'rating': 4.5,
      'image_path': 'assets/images/venue2.jpg',
      'distance': '3.7 km',
      'is_favorite': false,
      'opening_hours': '5:30 AM - 10:30 PM',
      'rate_per_hour': 'Rs. 1,800',
      'description': 'Indoor basketball court with air conditioning',
    },
    {
      'id': '3',
      'title': 'Olympic Swimming Center',
      'location': 'Lake View, Colombo 07',
      'sport': 'Swimming',
      'rating': 4.7,
      'image_path': 'assets/images/venue3.jpg',
      'distance': '5.2 km',
      'is_favorite': false,
      'opening_hours': '5:00 AM - 9:00 PM',
      'rate_per_hour': 'Rs. 1,200',
      'description': 'Olympic-size swimming pool with certified lifeguards',
    },
    {
      'id': '4',
      'title': 'Tennis Court Complex',
      'location': 'Green Hills, Colombo 04',
      'sport': 'Tennis',
      'rating': 4.4,
      'image_path': 'assets/images/venue4.jpg',
      'distance': '1.8 km',
      'is_favorite': false,
      'opening_hours': '6:00 AM - 10:00 PM',
      'rate_per_hour': 'Rs. 2,200',
      'description': 'Clay and hard courts available with equipment rental',
    },
    {
      'id': '5',
      'title': 'City Badminton Center',
      'location': 'Central Park, Colombo 02',
      'sport': 'Badminton',
      'rating': 4.6,
      'image_path': 'assets/images/venue5.jpg',
      'distance': '4.1 km',
      'is_favorite': false,
      'opening_hours': '5:30 AM - 11:30 PM',
      'rate_per_hour': 'Rs. 1,500',
      'description': '8 premium badminton courts with wooden flooring',
    },
    {
      'id': '6',
      'title': 'Cricket Ground Arena',
      'location': 'Sports District, Colombo 06',
      'sport': 'Cricket',
      'rating': 4.3,
      'image_path': 'assets/images/venue6.jpg',
      'distance': '6.5 km',
      'is_favorite': false,
      'opening_hours': '6:30 AM - 9:30 PM',
      'rate_per_hour': 'Rs. 3,000',
      'description': 'Full-size cricket ground with practice nets',
    },
    {
      'id': '7',
      'title': 'Table Tennis Hub',
      'location': 'City Center, Colombo 01',
      'sport': 'Table Tennis',
      'rating': 4.2,
      'image_path': 'assets/images/venue7.jpg',
      'distance': '3.0 km',
      'is_favorite': false,
      'opening_hours': '7:00 AM - 10:00 PM',
      'rate_per_hour': 'Rs. 800',
      'description': '12 professional table tennis tables available',
    },
    {
      'id': '8',
      'title': 'Baseball Diamond',
      'location': 'West End, Colombo 08',
      'sport': 'Baseball',
      'rating': 4.1,
      'image_path': 'assets/images/venue8.jpg',
      'distance': '7.2 km',
      'is_favorite': false,
      'opening_hours': '6:00 AM - 8:00 PM',
      'rate_per_hour': 'Rs. 2,800',
      'description': 'Regulation baseball field with dugouts',
    },
  ];

  @override
  void initState() {
    super.initState();
    _venuesScrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);

    // Set the initial sport if provided
    if (widget.initialSport.isNotEmpty) {
      _selectedSport = widget.initialSport;
    }

    // Initialize with local data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVenues();
    });
  }

  // Load venues from local data
  Future<void> _loadVenues() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    // Simulate loading delay for better UX
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    try {
      setState(() {
        _venues = List<Map<String, dynamic>>.from(_sampleVenues);
        debugPrint('🏟️ Venues loaded: ${_venues.length}');

        // Initialize filtered venues with all venues
        _filteredVenues = _venues;
        _isLoading = false;
        _showVenues = _venues.isNotEmpty;

        if (_venues.isEmpty) {
          _hasError = true;
          _errorMessage = 'No venues available';
        }
      });
    } catch (error) {
      if (!mounted) return;

      debugPrint('❌ Error loading venues: $error');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load venues: ${error.toString()}';
      });
    }
  }

  // Refresh venues list
  Future<void> _refreshVenues() async {
    await _loadVenues();
    return;
  }

  @override
  void dispose() {
    _venuesScrollController.removeListener(_onScroll);
    _venuesScrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_venuesScrollController.offset > 0 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_venuesScrollController.offset <= 0 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filteredVenues = _selectedSport.isEmpty
          ? _venues
          : _venues.where((venue) => venue['sport'] == _selectedSport).toList();

      _filteredVenues = _filteredVenues.where((venue) {
        final titleMatch =
            venue['title']?.toString().toLowerCase().contains(_searchQuery) ??
            false;
        final locationMatch =
            venue['location']?.toString().toLowerCase().contains(
              _searchQuery,
            ) ??
            false;
        final sportMatch =
            venue['sport']?.toString().toLowerCase().contains(_searchQuery) ??
            false;

        // If a sport is selected, only show venues for that sport
        if (_selectedSport.isNotEmpty) {
          return venue['sport'] == _selectedSport &&
              (titleMatch || locationMatch);
        }

        return titleMatch || locationMatch || sportMatch;
      }).toList();

      // Show venues section if we have search results
      _showVenues = _filteredVenues.isNotEmpty;
    });
  }

  void _filterVenuesBySport(String sportName) {
    setState(() {
      if (sportName.isEmpty) {
        _filteredVenues = _venues;
      } else {
        _filteredVenues = _venues
            .where((venue) => venue['sport'] == sportName)
            .toList();
      }
    });
  }

  void _onSportSelected(String sportName) {
    setState(() {
      _selectedSport = sportName;
      _isLoading = true;
      _showVenues = false;
    });

    // Using a slight delay to improve UX by showing loading state
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoading = false;
        _showVenues = true;

        // Filter venues by selected sport
        _filterVenuesBySport(sportName);
      });
    });
  }

  void _navigateToFavorites() {
    // Force rebuild favorites list before navigating
    List<Map<String, dynamic>> currentFavorites = [];

    // Create deep copies to avoid reference issues
    for (var venue in _venues) {
      if (venue['is_favorite'] == true) {
        currentFavorites.add(Map<String, dynamic>.from(venue));
        debugPrint('Adding to favorites: ${venue['title']}');
      }
    }
    debugPrint('Total favorites count: ${currentFavorites.length}');

    // Show a message if no favorites are found
    if (currentFavorites.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No favorites yet! Heart some venues to add them.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Navigate to favorites with current data
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FavoritesScreen(
          favoriteVenues: currentFavorites,
          onRemoveFavorite: _removeFavorite,
        ),
      ),
    );
  }

  void _toggleFavorite(int index) {
    // Find the venue in the original list
    int originalIndex = _venues.indexWhere(
      (venue) => venue['title'] == _filteredVenues[index]['title'],
    );

    if (originalIndex != -1) {
      // Toggle favorite status locally
      setState(() {
        _venues[originalIndex]['is_favorite'] =
            !(_venues[originalIndex]['is_favorite'] ?? false);
        _filteredVenues[index]['is_favorite'] =
            _venues[originalIndex]['is_favorite'];
      });

      debugPrint(
        'Toggled favorite for: ${_venues[originalIndex]['title']} to ${_venues[originalIndex]['is_favorite']}',
      );

      // If user just made it a favorite, show a confirmation
      if (_venues[originalIndex]['is_favorite'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Added to favorites: ${_venues[originalIndex]['title']}',
              ),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'View Favorites',
                onPressed: () {
                  _navigateToFavorites();
                },
              ),
            ),
          );
        }
      }
    }
  }

  void _removeFavorite(Map<String, dynamic> venue) {
    setState(() {
      int index = _venues.indexWhere((v) => v['title'] == venue['title']);
      if (index != -1) {
        _venues[index]['is_favorite'] = false;

        // Update filtered venues if needed
        int filteredIndex = _filteredVenues.indexWhere(
          (v) => v['title'] == venue['title'],
        );
        if (filteredIndex != -1) {
          _filteredVenues[filteredIndex]['is_favorite'] = false;
        }
      }
    });

    debugPrint('Removed from favorites: ${venue['title']}');
  }

  // Book now functionality
  void _bookVenue(Map<String, dynamic> venue) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingBottomSheet(venue: venue),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Count favorites for badge display
    final int favoriteCount = _venues
        .where((venue) => venue['is_favorite'] == true)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        controller: _venuesScrollController,
        slivers: [
          SliverAppBar(
            elevation: _isScrolled ? 4 : 0,
            toolbarHeight: 50,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1B2C4F),
            centerTitle: false,
            title: const Text(
              "Available Sports",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.fromLTRB(16, 3, 8, 8),
              child: IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Back',
              ),
            ),
            actions: [
              // Add a favorites indicator with count in the app bar
              if (favoriteCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.white),
                        onPressed: () {
                          _navigateToFavorites();
                        },
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$favoriteCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    left: 16.0,
                    right: 16.0,
                    bottom: 8.0,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0),
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            child: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF1B2C4F),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText:
                                    'Search venues by name or location...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF2D3142),
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.clear,
                                  color: Colors.grey[400],
                                  size: 18,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Sports Categories
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SportsCategories(
                    onSportSelected: _onSportSelected,
                    searchQuery: _searchQuery,
                    selectedSport: _selectedSport,
                    themeNavyBlue: _themeNavyBlue,
                    themeLightNavyBlue: _themeLightNavyBlue,
                  ),
                ),

                // Venues Section
                if (_showVenues) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedSport.isEmpty
                                  ? 'All Venues (${_filteredVenues.length})'
                                  : '$_selectedSport Venues (${_filteredVenues.length})',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B2C4F),
                              ),
                            ),
                            if (_selectedSport.isNotEmpty)
                              TextButton(
                                onPressed: () => _onSportSelected(''),
                                child: const Text(
                                  'View All',
                                  style: TextStyle(
                                    color: Color(0xFF1B2C4F),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 0),

                        // Venues List
                        if (_isLoading)
                          const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF1B2C4F),
                            ),
                          )
                        else if (_filteredVenues.isEmpty)
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.sports,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _selectedSport.isEmpty
                                      ? 'No venues found'
                                      : 'No $_selectedSport venues found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try searching for a different location or sport',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredVenues.length,
                            itemBuilder: (context, index) {
                              final venue = _filteredVenues[index];
                              return EnhancedVenueCard(
                                venue: venue,
                                onFavoriteToggle: () => _toggleFavorite(index),
                                onBookNow: () => _bookVenue(venue),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Empty state when no sport is selected
                  Container(
                    height: MediaQuery.of(context).size.height - 400,
                    color: const Color(0xFFF5F6FA),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sports, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Select a sport to view venues',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Choose from the sports categories above',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Venue Card Widget
class EnhancedVenueCard extends StatelessWidget {
  final Map<String, dynamic> venue;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onBookNow;

  const EnhancedVenueCard({
    super.key,
    required this.venue,
    required this.onFavoriteToggle,
    required this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFavorite = venue['is_favorite'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Image Section
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: venue['image_path'] != null
                      ? Image.asset(
                          venue['image_path'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFF1B2C4F).withOpacity(0.1),
                              child: const Center(
                                child: Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Color(0xFF1B2C4F),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: const Color(0xFF1B2C4F).withOpacity(0.1),
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              size: 50,
                              color: Color(0xFF1B2C4F),
                            ),
                          ),
                        ),
                ),
              ),
              // Favorite Button
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: onFavoriteToggle,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ),
              ),
              // Sport Tag
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2C4F),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    venue['sport'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Rating
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        venue['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          venue['rating']?.toString() ?? '0.0',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        venue['location'] ?? '',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                    Text(
                      venue['distance'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Opening Hours and Rate
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Open',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            venue['opening_hours'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2D3142),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          venue['rate_per_hour'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B2C4F),
                          ),
                        ),
                        Text(
                          'per hour',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Book Now Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onBookNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B2C4F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Booking Bottom Sheet
class BookingBottomSheet extends StatefulWidget {
  final Map<String, dynamic> venue;

  const BookingBottomSheet({super.key, required this.venue});

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  int duration = 1; // hours

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Book ${widget.venue['title']}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B2C4F),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.venue['location'] ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Booking Form
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Selection
                  const Text(
                    'Select Date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Time Selection
                  const Text(
                    'Select Time',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setState(() {
                          selectedTime = time;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            selectedTime.format(context),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Duration Selection
                  const Text(
                    'Duration (hours)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [1, 2, 3, 4]
                        .map(
                          (hours) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: InkWell(
                                onTap: () => setState(() => duration = hours),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: duration == hours
                                        ? const Color(0xFF1B2C4F)
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: duration == hours
                                          ? const Color(0xFF1B2C4F)
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Text(
                                    '$hours hr${hours > 1 ? 's' : ''}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: duration == hours
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 32),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Booking confirmed for ${widget.venue['title']}!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B2C4F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirm Booking',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
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
    );
  }
}

// Sports Categories without Supabase
class SportsCategories extends StatefulWidget {
  final Function(String) onSportSelected;
  final String searchQuery;
  final String selectedSport;
  final Color themeNavyBlue;
  final Color themeLightNavyBlue;

  const SportsCategories({
    super.key,
    required this.onSportSelected,
    required this.searchQuery,
    required this.selectedSport,
    required this.themeNavyBlue,
    required this.themeLightNavyBlue,
  });

  @override
  State<SportsCategories> createState() => _SportsCategoriesState();
}

class _SportsCategoriesState extends State<SportsCategories> {
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> sports = [];
  bool _isLoading = false;
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadSports();
  }

  void _loadSports() {
    // Using hardcoded sports data with comprehensive list
    setState(() {
      sports = [
        {'name': 'Badminton', 'icon': 'sports_tennis'},
        {'name': 'Table Tennis', 'icon': 'table_bar'},
        {'name': 'Football', 'icon': 'sports_soccer'},
        {'name': 'Cricket', 'icon': 'sports_cricket'},
        {'name': 'Basketball', 'icon': 'sports_basketball'},
        {'name': 'Swimming', 'icon': 'pool'},
        {'name': 'Baseball', 'icon': 'sports_baseball'},
        {'name': 'Boxing', 'icon': 'sports_mma'},
        {'name': 'Golf', 'icon': 'sports_golf'},
        {'name': 'Tennis', 'icon': 'sports_tennis'},
        {'name': 'Volleyball', 'icon': 'sports_volleyball'},
        {'name': 'Rugby', 'icon': 'sports_rugby'},
        {'name': 'Hockey', 'icon': 'sports_hockey'},
        {'name': 'Wrestling', 'icon': 'sports_mma'},
        {'name': 'Martial Arts', 'icon': 'sports_kabaddi'},
        {'name': 'Running', 'icon': 'directions_run'},
        {'name': 'Cycling', 'icon': 'directions_bike'},
        {'name': 'Gym', 'icon': 'fitness_center'},
        {'name': 'Yoga', 'icon': 'self_improvement'},
        {'name': 'Dance', 'icon': 'music_note'},
        {'name': 'Rock Climbing', 'icon': 'terrain'},
        {'name': 'Skateboarding', 'icon': 'skateboarding'},
        {'name': 'Surfing', 'icon': 'surfing'},
        {'name': 'Skiing', 'icon': 'downhill_skiing'},
        {'name': 'Snowboarding', 'icon': 'snowboarding'},
        {'name': 'Ice Hockey', 'icon': 'sports_hockey'},
        {'name': 'Figure Skating', 'icon': 'ice_skating'},
        {'name': 'Track & Field', 'icon': 'sports'},
        {'name': 'Archery', 'icon': 'sports'},
        {'name': 'Shooting', 'icon': 'sports'},
        {'name': 'Equestrian', 'icon': 'sports'},
        {'name': 'Rowing', 'icon': 'rowing'},
        {'name': 'Sailing', 'icon': 'sailing'},
        {'name': 'Diving', 'icon': 'pool'},
        {'name': 'Water Polo', 'icon': 'pool'},
        {'name': 'Squash', 'icon': 'sports_tennis'},
        {'name': 'Racquetball', 'icon': 'sports_tennis'},
        {'name': 'Handball', 'icon': 'sports_handball'},
        {'name': 'Softball', 'icon': 'sports_baseball'},
        {'name': 'American Football', 'icon': 'sports_football'},
        {'name': 'Australian Football', 'icon': 'sports_football'},
        {'name': 'Netball', 'icon': 'sports_basketball'},
        {'name': 'Lacrosse', 'icon': 'sports'},
        {'name': 'Field Hockey', 'icon': 'sports_hockey'},
        {'name': 'Polo', 'icon': 'sports'},
        {'name': 'Fencing', 'icon': 'sports'},
        {'name': 'Judo', 'icon': 'sports_mma'},
        {'name': 'Karate', 'icon': 'sports_mma'},
        {'name': 'Taekwondo', 'icon': 'sports_mma'},
        {'name': 'Weightlifting', 'icon': 'fitness_center'},
        {'name': 'Powerlifting', 'icon': 'fitness_center'},
        {'name': 'CrossFit', 'icon': 'fitness_center'},
        {'name': 'Pilates', 'icon': 'self_improvement'},
        {'name': 'Zumba', 'icon': 'music_note'},
        {'name': 'Aerobics', 'icon': 'fitness_center'},
        {'name': 'Parkour', 'icon': 'terrain'},
        {'name': 'Bouldering', 'icon': 'terrain'},
        {'name': 'Kayaking', 'icon': 'kayaking'},
        {'name': 'Canoeing', 'icon': 'kayaking'},
        {'name': 'Stand-up Paddling', 'icon': 'surfing'},
        {'name': 'Windsurfing', 'icon': 'surfing'},
        {'name': 'Kitesurfing', 'icon': 'surfing'},
        {'name': 'Triathlon', 'icon': 'sports'},
        {'name': 'Marathon', 'icon': 'directions_run'},
        {'name': 'Pentathlon', 'icon': 'sports'},
        {'name': 'Decathlon', 'icon': 'sports'},
      ];
      _isLoading = false;
    });
  }

  IconData _getIconFromString(String iconName) {
    // Map icon names to Flutter Icons
    switch (iconName) {
      case 'sports_tennis':
        return Icons.sports_tennis;
      case 'sports_volleyball':
        return Icons.sports_volleyball;
      case 'table_bar':
        return Icons.table_bar;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'sports_cricket':
        return Icons.sports_cricket;
      case 'sports_basketball':
        return Icons.sports_basketball;
      case 'pool':
        return Icons.pool;
      case 'sports_baseball':
        return Icons.sports_baseball;
      case 'sports_mma':
        return Icons.sports_mma;
      case 'sports_golf':
        return Icons.sports_golf;
      case 'sports_rugby':
        return Icons.sports_rugby;
      case 'sports_hockey':
        return Icons.sports_hockey;
      case 'sports_kabaddi':
        return Icons.sports_kabaddi;
      case 'directions_run':
        return Icons.directions_run;
      case 'directions_bike':
        return Icons.directions_bike;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'music_note':
        return Icons.music_note;
      case 'terrain':
        return Icons.terrain;
      case 'skateboarding':
        return Icons.skateboarding;
      case 'surfing':
        return Icons.surfing;
      case 'downhill_skiing':
        return Icons.downhill_skiing;
      case 'snowboarding':
        return Icons.snowboarding;
      case 'ice_skating':
        return Icons.ice_skating;
      case 'rowing':
        return Icons.rowing;
      case 'sailing':
        return Icons.sailing;
      case 'sports_handball':
        return Icons.sports_handball;
      case 'sports_football':
        return Icons.sports_football;
      case 'kayaking':
        return Icons.kayaking;
      default:
        return Icons.sports;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(widget.themeNavyBlue),
        ),
      );
    }

    // Filter sports based on search query if available
    final filteredSports = widget.searchQuery.isEmpty
        ? sports
        : () {
            final query = widget.searchQuery.toLowerCase();
            final matchingSports = sports
                .where(
                  (sport) =>
                      sport['name'].toString().toLowerCase().contains(query),
                )
                .toList();

            // Sort the filtered sports to show best matches first
            matchingSports.sort((a, b) {
              final aName = a['name'].toString().toLowerCase();
              final bName = b['name'].toString().toLowerCase();

              // Exact match comes first
              if (aName == query && bName != query) return -1;
              if (bName == query && aName != query) return 1;

              // Sports that start with the query come next
              final aStartsWith = aName.startsWith(query);
              final bStartsWith = bName.startsWith(query);

              if (aStartsWith && !bStartsWith) return -1;
              if (bStartsWith && !aStartsWith) return 1;

              // If both start with query or both don't, sort alphabetically
              return aName.compareTo(bName);
            });

            return matchingSports;
          }();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Header with a styled title and count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    'Select Sport',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.themeNavyBlue,
                    ),
                  ),
                  if (widget.selectedSport.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: widget.themeNavyBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.selectedSport,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: widget.themeNavyBlue,
                        ),
                      ),
                    ),
                ],
              ),
              // View All button moved next to title for better space usage
              if (widget.selectedSport.isNotEmpty)
                InkWell(
                  onTap: () {
                    widget.onSportSelected('');
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.themeNavyBlue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list_off,
                          size: 14,
                          color: widget.themeNavyBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'All',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: widget.themeNavyBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          filteredSports.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Text(
                      "No sports found matching '${widget.searchQuery}'",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  child: Row(
                    children: [
                      // Add "All Sports" option at beginning
                      if (widget.selectedSport.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            widget.onSportSelected('');
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 65,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: Colors.grey.shade100,
                                    border: Border.all(
                                      color: widget.themeNavyBlue.withOpacity(
                                        0.3,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      splashColor: widget.themeNavyBlue
                                          .withOpacity(0.1),
                                      onTap: () {
                                        widget.onSportSelected('');
                                      },
                                      child: Container(
                                        width: 65,
                                        height: 65,
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.filter_list_off,
                                          size: 32,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "All Sports",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Map through the filtered sports list
                      ...filteredSports.map((sport) {
                        final sportName = sport['name'] as String;
                        final bool isSelected =
                            sportName == widget.selectedSport;
                        final IconData iconData = _getIconFromString(
                          sport['icon'] as String,
                        );

                        return GestureDetector(
                          onTap: () {
                            widget.onSportSelected(sportName);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 65,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: isSelected
                                        ? widget.themeNavyBlue
                                        : Colors.grey.shade100,
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      splashColor: widget.themeNavyBlue
                                          .withOpacity(0.1),
                                      onTap: () {
                                        widget.onSportSelected(sportName);
                                      },
                                      child: Container(
                                        width: 65,
                                        height: 65,
                                        alignment: Alignment.center,
                                        child: AnimatedScale(
                                          scale: isSelected ? 1.1 : 1.0,
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          child: Icon(
                                            iconData,
                                            size: 32,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  sportName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? widget.themeNavyBlue
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
