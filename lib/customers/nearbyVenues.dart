// ignore_for_file: deprecated_member_use, file_names
import 'package:athlon_user/customers/courtDetails.dart';
import 'package:athlon_user/customers/footer.dart';
import 'package:athlon_user/customers/bookings.dart';
import 'package:flutter/material.dart';
//import 'bookNow.dart';
import 'filter_screen.dart';
import 'widgets/football_spinner.dart';
import 'models/venue_models.dart' as venue_models;
import 'services/data_service.dart';

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
          elevation: 2,
          centerTitle: false,
          foregroundColor: Colors.white,
        ),
      ),
      home: const NearByVenueScreen(),
    );
  }
}

class NearByVenueScreen extends StatefulWidget {
  const NearByVenueScreen({super.key});

  @override
  State<NearByVenueScreen> createState() => _NearByVenueScreenState();
}

class _NearByVenueScreenState extends State<NearByVenueScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isScrolled = false;
  String _searchQuery = '';
  late AnimationController _animationController;
  String _activeFilter = 'All';
  String _sortingMode = 'Nearest';
  double _distanceRadius = 10.0; // Default radius in km

  // Search history variables (simplified for home page style)
  List<String> _searchHistory = [];
  final int _maxHistoryItems = 5; // Limit history to 5 items

  // Map to track favorite status for each venue
  final Map<String, bool> _favoriteStatus = {};

  // Current tab index for footer navigation
  int _currentTabIndex = 0;

  // Sports filter list with icons - Only includes sports that are actually available in venues
  final Map<String, IconData> _filterOptionsWithIcons = {
    'All': Icons.grid_view_rounded,
    'Indoor': Icons.home_rounded,
    'Outdoor': Icons.nature_rounded,
    'Badminton': Icons.sports_tennis_rounded,
    'Tennis': Icons.sports_tennis_rounded,
    'Squash': Icons.sports_tennis_rounded,
    'Cricket': Icons.sports_cricket_rounded,
    'Futsal': Icons.sports_soccer_rounded,
    'Swimming': Icons.pool_rounded,
    'Water Polo': Icons.pool_rounded,
    'Diving': Icons.pool_rounded,
    'Basketball': Icons.sports_basketball_rounded,
    'Volleyball': Icons.sports_volleyball_rounded,
    'Beach Volleyball': Icons.sports_volleyball_rounded,
    'Golf': Icons.sports_golf_rounded,
    'Surfing': Icons.surfing_rounded,
    'Mountain Biking': Icons.directions_bike_rounded,
    'Boxing': Icons.sports_mma_rounded,
    'MMA': Icons.sports_mma_rounded,
    'Kickboxing': Icons.sports_mma_rounded,
    'Baseball': Icons.sports_baseball_rounded,
    'Rugby': Icons.sports_rugby_rounded,
    'Football': Icons.sports_soccer_rounded,
    'Rock Climbing': Icons.terrain_rounded,
    'Bouldering': Icons.terrain_rounded,
    'Table Tennis': Icons.table_bar_rounded,
    'Netball': Icons.sports_basketball_rounded,
  };

  // List of all venues - loaded from DataService
  List<venue_models.VenueModel> _allVenues = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Load venues from DataService
    _loadVenues();

    // Load search history
    _loadSearchHistory();

    // Simulate loading delay
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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Load venues from DataService
  Future<void> _loadVenues() async {
    try {
      final venues = await DataService.loadVenues();
      if (mounted) {
        setState(() {
          _allVenues = venues;
          // Sort venues by distance (nearest first)
          _allVenues.sort((a, b) => a.distance.compareTo(b.distance));
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading venues: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Load search history (placeholder - implement SharedPreferences later)
  void _loadSearchHistory() {
    // For now, we'll use a simple list
    // In a real app, load from SharedPreferences
    setState(() {
      _searchHistory = []; // Start with empty history
    });
  }

  // Save search history (placeholder - implement SharedPreferences later)
  void _saveSearchHistory() {
    // In a real app, save to SharedPreferences
    // For now, just keep in memory
  }

  // Handle search focus changes
  void _onSearchFocusChanged() {
    // Simplified for home page style search bar
    setState(() {
      // Focus handling simplified - no search history dropdown
    });
  }

  // Add search term to history
  void _addToSearchHistory(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      // Remove if already exists
      _searchHistory.remove(query);
      // Add to beginning
      _searchHistory.insert(0, query);
      // Keep only max items
      if (_searchHistory.length > _maxHistoryItems) {
        _searchHistory = _searchHistory.take(_maxHistoryItems).toList();
      }
    });
    _saveSearchHistory();
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

    // Add to history when user stops typing (you can implement debouncing)
    if (_searchQuery.isNotEmpty && _searchQuery.length > 2) {
      _addToSearchHistory(_searchController.text);
    }
  }

  // Set active filter
  void _setFilter(String filter) {
    setState(() {
      _activeFilter = filter;
    });
  }

  // Filtered venues based on search and active filter
  List<venue_models.VenueModel> get _filteredVenues {
    List<venue_models.VenueModel> filtered = _allVenues;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((venue) {
        final titleMatches = venue.name.toLowerCase().contains(_searchQuery);
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: FootballLoadingWidget()));
    }
    // Count favorites for badge display
    // final int favoriteCount = _favoriteStatus.values
    //     .where((isFavorite) => isFavorite == true)
    //     .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 50,
        backgroundColor: const Color(0xFF1B2C4F),
        centerTitle: false,
        title: const Text(
          "Nearby Venues",
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
      ),
      body: GestureDetector(
        onTap: () {
          _searchFocusNode.unfocus();
        },
        child: Column(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
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
              child: _buildSearchBar(),
            ),

            // Results header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Found ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
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
                  ),
                  // Sort & Filter button
                  TextButton.icon(
                    icon: const Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: Color(0xFF1B2C4F),
                    ),
                    label: Text(
                      _activeFilter != 'All'
                          ? '$_sortingMode | $_activeFilter'
                          : _sortingMode,
                      style: const TextStyle(
                        color: Color(0xFF1B2C4F),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                      _navigateToFilterScreen(context);
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

  // Search bar method - matches home page style
  Widget _buildSearchBar() {
    return Container(
      height: 48, // Fixed height to prevent expansion
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B2C4F).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.search_outlined, // outlined version
              color: Color(0xFF1B2C4F),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                maxLines: 1, // Ensure single line
                decoration: InputDecoration(
                  hintText: 'Search sports venues...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero, // Remove default padding
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1B2C4F),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _addToSearchHistory(value);
                  }
                  _searchFocusNode.unfocus();
                },
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: const Icon(
                  Icons.clear_rounded,
                  color: Color(0xFF1B2C4F),
                  size: 20,
                ),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
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
      padding: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16,
      ), // Reduced top padding from 4 to 0
      itemCount: _filteredVenues.length,
      itemBuilder: (context, index) {
        final venue = _filteredVenues[index];
        final isFavorite = _favoriteStatus[venue.id] ?? false;

        return _buildVenueCard(venue, isFavorite);
      },
    );
  }

  // MINIMAL & MODERN VENUE CARD DESIGN
  Widget _buildVenueCard(venue_models.VenueModel venue, bool isFavorite) {
    final Map<String, dynamic> courtData = {
      'id': venue.id,
      'name': venue.name,
      'type': venue.sports.isNotEmpty
          ? '${venue.sports.first} Court'
          : 'Sports Court',
      'location': venue.location,
      'distance': '${venue.distance.toStringAsFixed(1)} km away',
      'rating': venue.rating,
      'total_reviews': (venue.rating * 50).round(),
      'price_per_hour':
          double.tryParse(
            venue.ratePerHour.replaceAll(RegExp(r'[^\d.]'), ''),
          ) ??
          2500.0,
      'opening_hours': 'Open Now',
      'closing_time': venue.openingHours.contains('PM')
          ? 'Closes at ${venue.openingHours.split(' - ').last}'
          : 'Closes at 11:00 PM',
      'phone': '+94 77 123 4567',
      'email':
          'info@${venue.name.toLowerCase().replaceAll(' ', '').replaceAll(RegExp(r'[^\w]'), '')}.lk',
      'website':
          'www.${venue.name.toLowerCase().replaceAll(' ', '').replaceAll(RegExp(r'[^\w]'), '')}.lk',
      'description':
          'Premium ${venue.sports.join(', ')} facility with state-of-the-art equipment and professional-grade surfaces.',
      'images': [
        venue.imageUrl,
        if (venue.sports.contains('Futsal') || venue.sports.contains('Cricket'))
          'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80',
        if (venue.sports.contains('Tennis') ||
            venue.sports.contains('Badminton'))
          'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80',
        if (venue.sports.contains('Swimming'))
          'https://images.unsplash.com/photo-1576610616656-d3aa5d1f4534?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80',
        if (venue.sports.contains('Basketball'))
          'https://images.unsplash.com/photo-1546519638-68e109498ffc?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80',
        if (venue.sports.contains('Golf'))
          'https://images.unsplash.com/photo-1587174486073-ae5e5cff23aa?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80',
      ],
      'sports_available': venue.sports,
    };

    return GestureDetector(
      onTap: () {
        // Navigate to CourtDetailScreen when card is tapped
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                CourtDetailScreen(courtData: courtData),
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
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.network(
                      venue.imageUrl ?? 'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
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
                      onTap: () => _toggleFavorite(venue.id),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
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
                          Icon(Icons.star, color: Colors.orange[600], size: 12),
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
                    venue.name,
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
                          "${venue.distance.toStringAsFixed(1)} km",
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

                  // Sports tags and Book Now button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Sports tags (up to 3)
                      if (venue.sports.isNotEmpty)
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: venue.sports.take(3).map((sport) {
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
                        onPressed: () async {
                          try {
                            // Show loading indicator
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              barrierColor: Colors.white,
                              builder: (BuildContext context) {
                                return const FootballLoadingWidget();
                              },
                            );

                            // Simulate loading time
                            await Future.delayed(
                              const Duration(milliseconds: 400),
                            );

                            // Close loading dialog
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }

                            // Navigate to bookings screen with venue data (instant transition)
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        SlotsPage(selectedVenue: venue),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          } catch (e) {
                            // Handle any errors
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }

                            // Still navigate to bookings screen
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        SlotsPage(selectedVenue: venue),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          }
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
      ),
    );
  }

  // Navigate to filter screen
  void _navigateToFilterScreen(BuildContext context) async {
    // Show loading screen immediately when filter is tapped
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white,
      builder: (BuildContext context) {
        return const FootballLoadingWidget();
      },
    );

    // Loading delay
    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) {
      Navigator.pop(context); // Close loading dialog

      // Navigate to filter screen without animation
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => FilterScreen(
            currentSortingMode: _sortingMode,
            currentActiveFilter: _activeFilter,
            currentDistanceRadius: _distanceRadius,
            filterOptions: _filterOptionsWithIcons,
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );

      if (result != null) {
        // Show loading screen when sorting/filtering changes
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.white,
          builder: (BuildContext context) {
            return const FootballLoadingWidget();
          },
        );

        // Loading delay
        await Future.delayed(const Duration(milliseconds: 400));

        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          setState(() {
            _sortingMode = result['sortingMode'] ?? _sortingMode;
            _activeFilter = result['activeFilter'] ?? _activeFilter;
            _distanceRadius = result['distanceRadius'] ?? _distanceRadius;
          });
        }
      }
    }
  }
}

// Venue Model - Now using shared venue models
// The VenueModel class is now imported from models/venue_models.dart
