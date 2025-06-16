// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'favourites.dart';
import 'bookNow.dart';

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
  String _selectedSport = '';
  String _searchQuery = '';

  // Theme colors
  final Color _themeNavyBlue = const Color(0xFF1B2C4F);
  final Color _themeLightNavyBlue = const Color(0xFFF0F4FF);

  // Venue data - now using hardcoded data instead of Supabase
  List<Map<String, dynamic>> _venues = [];
  List<Map<String, dynamic>> _filteredVenues = [];

  // Hardcoded venue data with additional fields
  final List<Map<String, dynamic>> _sampleVenues = [
    {
      'id': '1',
      'title': 'SportsCentral Stadium',
      'location': 'Downtown, Colombo 00200',
      'sport': 'Football',
      'rating': 4.8,
      'image_path':
          'https://images.unsplash.com/photo-1459865264687-595d652de67e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2069&q=80',
      'distance': '2.3 km',
      'is_favorite': false,
      'opening_hours': '6:00 AM - 10:00 PM',
      'rate_per_hour': 'Rs. 2,500',
    },
    {
      'id': '2',
      'title': 'Galaxy Sports Complex',
      'location': 'North Avenue, Colombo 00300',
      'sport': 'Basketball',
      'rating': 4.5,
      'image_path':
          'https://images.unsplash.com/photo-1546519638-68e109498ffc?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2060&q=80',
      'distance': '3.7 km',
      'is_favorite': false,
      'opening_hours': '7:00 AM - 11:00 PM',
      'rate_per_hour': 'Rs. 1,800',
    },
    {
      'id': '3',
      'title': 'Olympic Swimming Center',
      'location': 'Lake View, Colombo 00400',
      'sport': 'Swimming',
      'rating': 4.7,
      'image_path':
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      'distance': '5.2 km',
      'is_favorite': false,
      'opening_hours': '5:30 AM - 9:30 PM',
      'rate_per_hour': 'Rs. 1,200',
    },
    {
      'id': '4',
      'title': 'Tennis Court Complex',
      'location': 'Green Hills, Colombo 00500',
      'sport': 'Tennis',
      'rating': 4.4,
      'image_path':
          'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      'distance': '1.8 km',
      'is_favorite': false,
      'opening_hours': '6:00 AM - 8:00 PM',
      'rate_per_hour': 'Rs. 2,000',
    },
    {
      'id': '5',
      'title': 'City Badminton Center',
      'location': 'Central Park, Colombo 00600',
      'sport': 'Badminton',
      'rating': 4.6,
      'image_path':
          'https://images.unsplash.com/photo-1594736797933-d0201ba2fe65?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2073&q=80',
      'distance': '4.1 km',
      'is_favorite': false,
      'opening_hours': '6:30 AM - 10:30 PM',
      'rate_per_hour': 'Rs. 1,500',
    },
    {
      'id': '6',
      'title': 'CR7 FUTSAL & INDOOR CRICKET',
      'location': '23 Mile Post Ave, Colombo 00300',
      'sport': 'Cricket',
      'rating': 4.75,
      'image_path':
          'https://images.unsplash.com/photo-1531415074968-036ba1b575da?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2067&q=80',
      'distance': '2.5 km',
      'is_favorite': false,
      'opening_hours': '6:00 AM - 11:00 PM',
      'rate_per_hour': 'Rs. 3,000',
    },
    {
      'id': '7',
      'title': 'Table Tennis Hub',
      'location': 'City Center, Colombo 00100',
      'sport': 'Table Tennis',
      'rating': 4.2,
      'image_path':
          'https://images.unsplash.com/photo-1609710228159-0fa9bd7c0827?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      'distance': '3.0 km',
      'is_favorite': false,
      'opening_hours': '7:00 AM - 10:00 PM',
      'rate_per_hour': 'Rs. 800',
    },
    {
      'id': '8',
      'title': 'Baseball Diamond',
      'location': 'West End, Colombo 00700',
      'sport': 'Baseball',
      'rating': 4.1,
      'image_path':
          'https://images.unsplash.com/photo-1566577739112-5180d4bf9390?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      'distance': '7.2 km',
      'is_favorite': false,
      'opening_hours': '6:00 AM - 8:00 PM',
      'rate_per_hour': 'Rs. 2,200',
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

  // Load venues from local data instead of Supabase
  Future<void> _loadVenues() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate loading delay for better UX
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    try {
      setState(() {
        _venues = List<Map<String, dynamic>>.from(_sampleVenues);
        debugPrint('🏟️ Venues loaded: ${_venues.length}');

        // Filter venues based on initial sport if provided
        if (widget.initialSport.isNotEmpty) {
          _filteredVenues = _venues
              .where((venue) => venue['sport'] == widget.initialSport)
              .toList();
          debugPrint(
            '🎯 Filtered for ${widget.initialSport}: ${_filteredVenues.length} venues',
          );
        } else {
          _filteredVenues = _venues;
        }

        _isLoading = false;
        _showVenues = _filteredVenues.isNotEmpty;

        if (_filteredVenues.isEmpty && widget.initialSport.isNotEmpty) {
          debugPrint('⚠️ No venues found for sport: ${widget.initialSport}');
        }
      });
    } catch (error) {
      if (!mounted) return;

      debugPrint('❌ Error loading venues: $error');
      setState(() {
        _isLoading = false;
      });
    }
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

      // Start with all venues or filtered by sport
      List<Map<String, dynamic>> baseVenues = _selectedSport.isEmpty
          ? _venues
          : _venues.where((venue) => venue['sport'] == _selectedSport).toList();

      // Apply search filter
      _filteredVenues = baseVenues.where((venue) {
        final titleMatch =
            venue['title']?.toString().toLowerCase().contains(_searchQuery) ??
            false;
        final locationMatch =
            venue['location']?.toString().toLowerCase().contains(
              _searchQuery,
            ) ??
            false;

        return titleMatch || locationMatch;
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
        // Add debug logs to trace favorites
        debugPrint('Adding to favorites: ${venue['title']}');
      }
    }
    // Add count debug log
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

      // Debug log for toggling
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

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.orange, size: 16);
        } else if (index < rating) {
          return const Icon(Icons.star_half, color: Colors.orange, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.grey, size: 16);
        }
      }),
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
                fontSize: 18,
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

                // Nearby Venues Section
                if (_showVenues && _filteredVenues.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nearby Venues',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _themeNavyBlue,
                          ),
                        ),
                        Text(
                          '${_filteredVenues.length} venues',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Venues List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _filteredVenues.length,
                    itemBuilder: (context, index) {
                      final venue = _filteredVenues[index];
                      final bool isFavorite = venue['is_favorite'] ?? false;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
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
                            // Image with favorite button
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  child: Container(
                                    height: 200,
                                    width: double.infinity,
                                    color: Colors.grey[200],
                                    child: Image.network(
                                      venue['image_path'] ?? '',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[300],
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
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: () => _toggleFavorite(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isFavorite
                                            ? Colors.red
                                            : Colors.grey,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Venue details
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Venue name and distance
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          venue['title'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF2D3142),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        venue['distance'] ?? '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  // Location
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          venue['location'] ?? '',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  // Opening hours and rate
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        venue['opening_hours'] ?? '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.monetization_on,
                                        size: 16,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        venue['rate_per_hour'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 2),

                                  // Rating and Book Now button
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          _buildStarRating(
                                            venue['rating']?.toDouble() ?? 0.0,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            venue['rating']?.toString() ??
                                                '0.0',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder:
                                                  (
                                                    context,
                                                    animation,
                                                    secondaryAnimation,
                                                  ) => BookNowScreen(
                                                    venue: venue,
                                                  ),
                                              transitionDuration: Duration.zero,
                                              reverseTransitionDuration:
                                                  Duration.zero,
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _themeNavyBlue,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 8,
                                          ),
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

                  const SizedBox(height: 20),
                ],

                // Loading state
                if (_isLoading)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _themeNavyBlue,
                        ),
                      ),
                    ),
                  ),

                // Empty state when no venues found
                if (!_isLoading && _showVenues && _filteredVenues.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No venues found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedSport.isNotEmpty
                                ? 'No ${_selectedSport.toLowerCase()} venues available'
                                : 'Try adjusting your search',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Empty space to fill remaining area
                Container(
                  height: MediaQuery.of(context).size.height - 400,
                  color: const Color(0xFFF5F6FA),
                ),
              ],
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

  // Helper function to prioritize selected sport and filter based on search
  List<Map<String, dynamic>> _getOrderedSports() {
    // Filter sports based on search query if available
    List<Map<String, dynamic>> filteredSports = widget.searchQuery.isEmpty
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

    // If a sport is selected and no search query, prioritize the selected sport
    if (widget.selectedSport.isNotEmpty && widget.searchQuery.isEmpty) {
      // Find the selected sport
      final selectedSportIndex = filteredSports.indexWhere(
        (sport) => sport['name'] == widget.selectedSport,
      );

      if (selectedSportIndex != -1) {
        // Remove the selected sport from its current position
        final selectedSport = filteredSports.removeAt(selectedSportIndex);
        // Insert it at the beginning
        filteredSports.insert(0, selectedSport);
      }
    }

    return filteredSports;
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

    // Get ordered sports with selected sport prioritized
    final orderedSports = _getOrderedSports();

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
          orderedSports.isEmpty
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
                      // Add "All Sports" option at beginning only if a sport is selected
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
                      // Map through the ordered sports list
                      ...orderedSports.map((sport) {
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
                      }),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
