// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'favourites.dart';
import 'bookings.dart';
import 'footer.dart';
import 'widgets/football_spinner.dart';
import 'nearbyVenues.dart';
import 'courtDetails.dart' as court;

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

class _SportsVenueScreenState extends State<SportsVenueScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _venuesScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  bool _showVenues = false;
  String _selectedSport = '';
  String _searchQuery = '';

  // Footer state
  int _currentFooterIndex = 0;

  // Enhanced favorite system - matching nearbyVenues.dart
  late AnimationController _animationController;

  // Map to track favorite status for each venue
  final Map<String, bool> _favoriteStatus = {};

  // List to store favorite venues data
  final List<Map<String, dynamic>> _favoriteVenues = [];

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
    _searchController.addListener(_onSearchChanged);

    // Initialize animation controller for favorites
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Set the initial sport if provided and load venues
    if (widget.initialSport.isNotEmpty) {
      _selectedSport = widget.initialSport;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadVenuesForSport(widget.initialSport);
      });
    } else {
      // Just load the venues data but don't show them until sport is selected
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadVenuesData();
      });
    }
  }

  @override
  void dispose() {
    _venuesScrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _animationController.dispose(); // Dispose animation controller
    super.dispose();
  }

  // Load venues data from local data without showing them
  Future<void> _loadVenuesData() async {
    if (!mounted) return;

    try {
      setState(() {
        _venues = List<Map<String, dynamic>>.from(_sampleVenues);
        debugPrint('🏟️ Venues data loaded: ${_venues.length}');
      });
    } catch (error) {
      debugPrint('❌ Error loading venues data: $error');
    }
  }

  // Load and show venues for a specific sport
  Future<void> _loadVenuesForSport(String sportName) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _showVenues = false;
    });

    // Simulate loading delay for better UX
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    try {
      // Ensure venues data is loaded
      if (_venues.isEmpty) {
        _venues = List<Map<String, dynamic>>.from(_sampleVenues);
      }

      setState(() {
        debugPrint('🏟️ Loading venues for sport: $sportName');

        // Filter venues based on selected sport
        if (sportName.isEmpty) {
          _filteredVenues = _venues;
        } else {
          _filteredVenues = _venues
              .where((venue) => venue['sport'] == sportName)
              .toList();
          debugPrint(
            '🎯 Filtered for $sportName: ${_filteredVenues.length} venues',
          );
        }

        _isLoading = false;
        _showVenues = true;

        if (_filteredVenues.isEmpty) {
          debugPrint('⚠️ No venues found for sport: $sportName');
        }
      });
    } catch (error) {
      if (!mounted) return;

      debugPrint('❌ Error loading venues for sport: $error');
      setState(() {
        _isLoading = false;
        _showVenues = false;
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
    });
  }

  void _onSportSelected(String sportName) {
    setState(() {
      _selectedSport = sportName;
    });

    // Load venues for the selected sport
    _loadVenuesForSport(sportName);
  }

  // Enhanced toggle favorite function - matching nearbyVenues.dart
  void _toggleFavorite(String venueId) {
    setState(() {
      bool isCurrentlyFavorite = _favoriteStatus[venueId] ?? false;
      _favoriteStatus[venueId] = !isCurrentlyFavorite;

      if (!isCurrentlyFavorite) {
        // Adding to favorites
        Map<String, dynamic> venue = _venues.firstWhere(
          (v) => v['id'] == venueId,
        );
        Map<String, dynamic> favoriteVenue = {
          'id': venue['id'],
          'title': venue['title'],
          'location': venue['location'],
          'rating': venue['rating'],
          'imagePath': venue['image_path'],
          'distance': venue['distance'],
        };
        _favoriteVenues.add(favoriteVenue);

        // Show confirmation snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added to favorites: ${venue['title']}'),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'View Favorites',
                onPressed: () => _navigateToFavorites(),
              ),
            ),
          );
        }
      } else {
        // Removing from favorites
        _favoriteVenues.removeWhere((venue) => venue['id'] == venueId);
      }
    });

    // Add haptic feedback and animation
    _animationController.reset();
    _animationController.forward();
  }

  // Enhanced favorites navigation - matching nearbyVenues.dart
  void _navigateToFavorites() {
    // Navigate to favorites with current data and proper callback
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FavoritesScreen(
          favoriteVenues: List.from(_favoriteVenues), // Create a copy
          onRemoveFavorite: _handleRemoveFavorite, // Use enhanced callback
        ),
      ),
    );
  }

  // Handle removing favorite from favorites screen - matching nearbyVenues.dart
  void _handleRemoveFavorite(Map<String, dynamic> venue) {
    setState(() {
      _favoriteStatus[venue['id']] = false;
      _favoriteVenues.removeWhere((v) => v['id'] == venue['id']);
    });

    debugPrint('Removed from favorites: ${venue['title']}');
  }

  void _onFooterTabSelected(int index) {
    setState(() {
      _currentFooterIndex = index;
    });

    // Navigate to favorites screen when favorites tab is selected
    if (index == 1) {
      _navigateToFavorites();
    }
  }

  // Helper function to convert venue Map to VenueModel
  VenueModel _convertToVenueModel(Map<String, dynamic> venue) {
    return VenueModel(
      id: venue['id'] ?? '',
      title: venue['title'] ?? '',
      location: venue['location'] ?? '',
      rating: (venue['rating'] as num?)?.toDouble() ?? 0.0,
      imageUrl: venue['image_path'] ?? '',
      sports: [venue['sport'] ?? ''], // Convert single sport to List
      distance:
          double.tryParse(
            venue['distance']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ??
                '0',
          ) ??
          0.0,
      openingHours: venue['opening_hours'] ?? '',
      ratePerHour: venue['rate_per_hour'] ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Count favorites for badge display - matching nearbyVenues.dart
    final int favoriteCount = _favoriteStatus.values
        .where((isFavorite) => isFavorite == true)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 50,
        backgroundColor: const Color(0xFF1B2C4F),
        centerTitle: false,
        title: const Text(
          "Available Sports",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.fromLTRB(16, 3, 8, 8),
          child: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
          ),
        ),
        actions: [
          // Enhanced favorites indicator with count - matching nearbyVenues.dart
          if (favoriteCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.white),
                    onPressed: () => _navigateToFavorites(),
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
      body: Column(
        children: [
          // Fixed Header Section - Search Bar and Sports Categories
          Container(
            color: const Color(0xFFF5F6FA),
            child: Column(
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
              ],
            ),
          ),

          // Scrollable Venues Section
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FootballSpinner(size: 50.0, color: _themeNavyBlue),
                        const SizedBox(height: 16),
                        Text(
                          'Loading venues...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : !_showVenues
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sports, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Select a Sport',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose a sport from above to view available venues',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : _filteredVenues.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                  )
                : Column(
                    children: [
                      // Section Header
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedSport.isNotEmpty
                                  ? '$_selectedSport Venues'
                                  : 'All Venues',
                              style: TextStyle(
                                fontSize: 16,
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

                      // Scrollable Venues List
                      Expanded(
                        child: ListView.builder(
                          controller: _venuesScrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _filteredVenues.length,
                          itemBuilder: (context, index) {
                            final venue = _filteredVenues[index];
                            // Use enhanced favorite system - matching nearbyVenues.dart
                            final bool isFavorite =
                                _favoriteStatus[venue['id']] ?? false;

                            return GestureDetector(
                              onTap: () {
                                // Convert venue data to VenueModel and pass to SlotsPage
                                final venueModel = _convertToVenueModel(venue);
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => SlotsPage(
                                          selectedVenue: venueModel,
                                        ),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                );
                              },
                              child: Container(
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
                                          GestureDetector(
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
                                              await Future.delayed(
                                                const Duration(
                                                  milliseconds: 300,
                                                ),
                                              );

                                              // Navigate to court details page without animation
                                              if (context.mounted) {
                                                Navigator.pop(
                                                  context,
                                                ); // Close loading dialog
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder:
                                                        (
                                                          context,
                                                          animation,
                                                          secondaryAnimation,
                                                        ) => court.CourtDetailScreen(
                                                          courtData: {
                                                            'id': venue['id'],
                                                            'name':
                                                                venue['title'],
                                                            'type':
                                                                venue['sport'],
                                                            'location':
                                                                venue['location'],
                                                            'distance':
                                                                venue['distance'],
                                                            'rating':
                                                                venue['rating'],
                                                            'total_reviews':
                                                                124,
                                                            'price_per_hour':
                                                                double.tryParse(
                                                                  venue['rate_per_hour']
                                                                          ?.toString()
                                                                          .replaceAll(
                                                                            RegExp(
                                                                              r'[^\d.]',
                                                                            ),
                                                                            '',
                                                                          ) ??
                                                                      '0',
                                                                ) ??
                                                                0.0,
                                                            'opening_hours':
                                                                venue['opening_hours'] ??
                                                                'Open Now',
                                                            'closing_time':
                                                                'Closes at 11:00 PM',
                                                            'phone':
                                                                '+94 77 123 4567',
                                                            'email':
                                                                'info@venue.lk',
                                                            'website':
                                                                'www.venue.lk',
                                                            'description':
                                                                'Premium sports facility with state-of-the-art equipment.',
                                                            'images': [
                                                              venue['image_path'] ??
                                                                  '',
                                                            ],
                                                            'sports_available': [
                                                              venue['sport'],
                                                            ],
                                                          },
                                                        ),
                                                    transitionDuration:
                                                        Duration.zero,
                                                    reverseTransitionDuration:
                                                        Duration.zero,
                                                  ),
                                                );
                                              }
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                      16,
                                                    ),
                                                    topRight: Radius.circular(
                                                      16,
                                                    ),
                                                  ),
                                              child: Image.network(
                                                venue['image_path'] ?? '',
                                                width: double.infinity,
                                                height: 160,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Container(
                                                        color: Colors.grey[50],
                                                        child: Center(
                                                          child: Icon(
                                                            Icons
                                                                .image_outlined,
                                                            size: 24,
                                                            color: Colors
                                                                .grey[400],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                              ),
                                            ),
                                          ),
                                          // Enhanced favorite button - matching nearbyVenues.dart
                                          Positioned(
                                            top: 16,
                                            right: 16,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  _toggleFavorite(venue['id']),
                                              child: Icon(
                                                isFavorite
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: isFavorite
                                                    ? Colors.red
                                                    : Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                          // Rating badge on image
                                          Positioned(
                                            bottom: 12,
                                            left: 16,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.95,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
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
                                                    venue['rating']
                                                            ?.toString() ??
                                                        '4.5',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Venue name
                                          Text(
                                            venue['title'] ?? '',
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
                                                  venue['location'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                    height: 1.3,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 12),

                                          // Distance and Opening status
                                          Row(
                                            children: [
                                              // Distance
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFF1B2C4F,
                                                  ).withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  venue['distance'] ?? '2.5 km',
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              // Sports tags (up to 3)
                                              Expanded(
                                                child: Wrap(
                                                  spacing: 6,
                                                  runSpacing: 6,
                                                  children: [venue['sport'] ?? 'Football']
                                                      .where(
                                                        (sport) =>
                                                            sport.isNotEmpty,
                                                      )
                                                      .take(3)
                                                      .map((sport) {
                                                        return Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 3,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.blue
                                                                .withOpacity(
                                                                  0.08,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  6,
                                                                ),
                                                            border: Border.all(
                                                              color: Colors.blue
                                                                  .withOpacity(
                                                                    0.2,
                                                                  ),
                                                              width: 0.5,
                                                            ),
                                                          ),
                                                          child: Text(
                                                            sport,
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Colors
                                                                  .blue[700],
                                                            ),
                                                          ),
                                                        );
                                                      })
                                                      .toList(),
                                                ),
                                              ),

                                              // Book Now button
                                              ElevatedButton(
                                                onPressed: () async {
                                                  // Show loading screen immediately
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    barrierColor: Colors.white,
                                                    builder:
                                                        (BuildContext context) {
                                                          return const FootballLoadingWidget();
                                                        },
                                                  );

                                                  // Loading delay
                                                  await Future.delayed(
                                                    const Duration(
                                                      milliseconds: 300,
                                                    ),
                                                  );

                                                  // Convert venue data to VenueModel and pass to SlotsPage
                                                  final venueModel =
                                                      _convertToVenueModel(
                                                        venue,
                                                      );

                                                  // Navigate without animation
                                                  if (context.mounted) {
                                                    Navigator.pop(
                                                      context,
                                                    ); // Close loading dialog
                                                    Navigator.push(
                                                      context,
                                                      PageRouteBuilder(
                                                        pageBuilder:
                                                            (
                                                              context,
                                                              animation,
                                                              secondaryAnimation,
                                                            ) => SlotsPage(
                                                              selectedVenue:
                                                                  venueModel,
                                                            ),
                                                        transitionDuration:
                                                            Duration.zero,
                                                        reverseTransitionDuration:
                                                            Duration.zero,
                                                      ),
                                                    );
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                    0xFF1B2C4F,
                                                  ),
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 12,
                                                      ),
                                                  elevation: 0,
                                                  minimumSize: Size.zero,
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
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
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: _currentFooterIndex,
        onTabSelected: _onFooterTabSelected,
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
        child: FootballSpinner(size: 30.0, color: widget.themeNavyBlue),
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
                        // ignore: unnecessary_to_list_in_spreads
                      }).toList(),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
