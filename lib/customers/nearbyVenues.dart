// ignore_for_file: deprecated_member_use, file_names
import 'package:athlon_user/customers/courtDetails.dart';
import 'package:flutter/material.dart';
//import 'bookNow.dart';

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

  // Search history variables
  List<String> _searchHistory = [];
  bool _showSearchHistory = false;
  final int _maxHistoryItems = 5; // Limit history to 5 items

  // Map to track favorite status for each venue
  final Map<String, bool> _favoriteStatus = {};

  // Sports filter list with icons - Comprehensive list based on venue data
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
    'Yoga': Icons.self_improvement_rounded,
    'Pilates': Icons.self_improvement_rounded,
    'Fitness': Icons.fitness_center_rounded,
    'Mountain Biking': Icons.directions_bike_rounded,
    'Hiking': Icons.hiking_rounded,
    'Trail Running': Icons.directions_run_rounded,
    'Boxing': Icons.sports_mma_rounded,
    'MMA': Icons.sports_mma_rounded,
    'Kickboxing': Icons.sports_mma_rounded,
    'Baseball': Icons.sports_baseball_rounded,
    'Rock Climbing': Icons.terrain_rounded,
    'Bouldering': Icons.terrain_rounded,
    'Rappelling': Icons.terrain_rounded,
  };

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
    VenueModel(
      id: '7',
      title: "COLOMBO TENNIS CLUB",
      location: "45 Racquet Road, Colombo 00500",
      rating: 4.82,
      distance: 1.5,
      imageUrl:
          "https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
      sports: ["Tennis", "Badminton"],
      openingHours: "6:00 AM - 8:00 PM",
      ratePerHour: "Rs. 2,000",
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
      openingHours: "7:00 AM - 6:00 PM",
      ratePerHour: "Rs. 1,500",
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
      openingHours: "6:30 AM - 10:30 PM",
      ratePerHour: "Rs. 1,000",
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
      openingHours: "6:00 AM - 6:00 PM",
      ratePerHour: "Rs. 800",
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
      openingHours: "7:00 AM - 10:00 PM",
      ratePerHour: "Rs. 1,500",
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
      openingHours: "6:00 AM - 9:00 PM",
      ratePerHour: "Rs. 2,500",
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
      openingHours: "7:00 AM - 5:00 PM",
      ratePerHour: "Rs. 2,000",
    ),
  ];

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

    // Sort venues by distance (nearest first)
    _allVenues.sort((a, b) => a.distance.compareTo(b.distance));

    // Load search history
    _loadSearchHistory();
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
    setState(() {
      _showSearchHistory = _searchFocusNode.hasFocus && _searchQuery.isEmpty;
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

  // Select search history item
  void _selectSearchHistoryItem(String query) {
    _searchController.text = query;
    _searchFocusNode.unfocus();
    setState(() {
      _showSearchHistory = false;
    });
  }

  // Clear search history
  void _clearSearchHistory() {
    setState(() {
      _searchHistory.clear();
      _showSearchHistory = false;
    });
    _saveSearchHistory();
  }

  // Remove single history item
  void _removeSearchHistoryItem(String query) {
    setState(() {
      _searchHistory.remove(query);
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
      _showSearchHistory = _searchFocusNode.hasFocus && _searchQuery.isEmpty;
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
    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenWidth < 360;
    
    // Calculate responsive values
    final appBarHeight = isSmallScreen ? 45.0 : 50.0;
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final iconSize = isSmallScreen ? 24.0 : 28.0;
    
    // Count favorites for badge display
    final int favoriteCount = _favoriteStatus.values
        .where((isFavorite) => isFavorite == true)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2C4F),
        elevation: 1,
        toolbarHeight: appBarHeight,
        title: Text(
          "Nearby Venues",
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white, size: iconSize),
          onPressed: () => Navigator.of(context).pop(),
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
                      // Navigate to favorites
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$favoriteCount favorites saved'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
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
      body: GestureDetector(
        onTap: () {
          _searchFocusNode.unfocus();
          setState(() {
            _showSearchHistory = false;
          });
        },
        child: Column(
          children: [
            // Search bar with history - Updated for responsive design
            Container(
              padding: EdgeInsets.fromLTRB(
                isSmallScreen ? 12 : 16, 
                isSmallScreen ? 12 : 16, 
                isSmallScreen ? 12 : 16, 
                8
              ),
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
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE0E3E8),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Find sports venues...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: isSmallScreen ? 14 : 15,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: const Color(0xFF1B2C4F),
                          size: isSmallScreen ? 20 : 24,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: const Color(0xFF1B2C4F),
                                  size: isSmallScreen ? 20 : 24,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _showSearchHistory =
                                        _searchFocusNode.hasFocus;
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 10 : 12,
                          horizontal: isSmallScreen ? 12 : 16,
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          _addToSearchHistory(value);
                        }
                        _searchFocusNode.unfocus();
                      },
                    ),
                  ),

                  // Search History Dropdown
                  if (_showSearchHistory && _searchHistory.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE0E3E8),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.history,
                                  size: 16,
                                  color: Color(0xFF1B2C4F),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Recent searches',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1B2C4F),
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: _clearSearchHistory,
                                  child: Text(
                                    'Clear all',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _searchHistory.length,
                            itemBuilder: (context, index) {
                              final historyItem = _searchHistory[index];
                              return ListTile(
                                dense: true,
                                leading: const Icon(
                                  Icons.history,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                title: Text(
                                  historyItem,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                trailing: GestureDetector(
                                  onTap: () =>
                                      _removeSearchHistoryItem(historyItem),
                                  child: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                onTap: () =>
                                    _selectSearchHistoryItem(historyItem),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Sport Filters with Icons - REMOVED FROM UI
            // Container(
            //   height: 50,
            //   padding: const EdgeInsets.only(left: 8),
            //   child: ListView.builder(
            //     scrollDirection: Axis.horizontal,
            //     itemCount: _filterOptionsWithIcons.length,
            //     itemBuilder: (context, index) {
            //       final option = _filterOptionsWithIcons.keys.elementAt(index);
            //       final icon = _filterOptionsWithIcons[option]!;
            //       final isActive = _activeFilter == option;

            //       return Padding(
            //         padding: const EdgeInsets.only(right: 8),
            //         child: FilterChip(
            //           avatar: Icon(
            //             icon,
            //             size: 18,
            //             color: isActive
            //                 ? Colors.white
            //                 : const Color(0xFF1B2C4F),
            //           ),
            //           label: Text(option),
            //           labelStyle: TextStyle(
            //             color: isActive
            //                 ? Colors.white
            //                 : const Color(0xFF1B2C4F),
            //             fontWeight: isActive
            //                 ? FontWeight.w600
            //                 : FontWeight.w500,
            //           ),
            //           backgroundColor: isActive
            //               ? const Color(0xFF1B2C4F)
            //               : Colors.white,
            //           side: BorderSide(
            //             color: isActive
            //                 ? const Color(0xFF1B2C4F)
            //                 : const Color(0xFFE0E3E8),
            //           ),
            //           selectedColor: const Color(0xFF1B2C4F),
            //           showCheckmark: false,
            //           selected: isActive,
            //           onSelected: (selected) {
            //             if (selected) {
            //               _setFilter(option);
            //             }
            //           },
            //           padding: const EdgeInsets.symmetric(
            //             horizontal: 16,
            //             vertical: 8.0,
            //           ),
            //           labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            //         ),
            //       );
            //     },
            //   ),
            // ),

            // Results header - Responsive
            Padding(
              padding: EdgeInsets.fromLTRB(
                isSmallScreen ? 12 : 16, 
                8, 
                isSmallScreen ? 12 : 16, 
                8
              ),
              child: Row(
                children: [
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Found ",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          TextSpan(
                            text: "${_filteredVenues.length} venues",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1B2C4F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Sort & Filter button - Responsive
                  TextButton.icon(
                    icon: Icon(
                      Icons.tune_rounded,
                      size: isSmallScreen ? 16 : 18,
                      color: const Color(0xFF1B2C4F),
                    ),
                    label: Text(
                      _activeFilter != 'All' 
                          ? (isSmallScreen ? _activeFilter : '$_sortingMode | $_activeFilter')
                          : _sortingMode,
                      style: TextStyle(
                        color: const Color(0xFF1B2C4F),
                        fontWeight: FontWeight.w500,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F6FA),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 8 : 12,
                        vertical: isSmallScreen ? 6 : 8,
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
    // Get screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 12 : 16, 
        4, 
        isSmallScreen ? 12 : 16, 
        isSmallScreen ? 12 : 16
      ),
      itemCount: _filteredVenues.length,
      itemBuilder: (context, index) {
        final venue = _filteredVenues[index];
        final isFavorite = _favoriteStatus[venue.id] ?? false;

        return _buildVenueCard(venue, isFavorite);
      },
    );
  }

  Widget _buildVenueCard(VenueModel venue, bool isFavorite) {
    // Get screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    // Calculate responsive values
    final cardPadding = isSmallScreen ? 12.0 : 16.0;
    final imageHeight = isSmallScreen ? 160.0 : 200.0;
    final titleFontSize = isSmallScreen ? 14.0 : 16.0;
    final subtitleFontSize = isSmallScreen ? 12.0 : 14.0;
    final iconSize = isSmallScreen ? 14.0 : 16.0;
    final buttonPadding = isSmallScreen ? 12.0 : 20.0;
    
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
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
                  height: imageHeight,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Image.network(
                    venue.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: isSmallScreen ? 32 : 40,
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
                  onTap: () => _toggleFavorite(venue.id),
                  child: Container(
                    padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                      size: isSmallScreen ? 18 : 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Venue details
          Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Venue name and distance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        venue.title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3142),
                        ),
                        maxLines: isSmallScreen ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 4 : 8),
                    Text(
                      "${venue.distance.toStringAsFixed(1)} km",
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isSmallScreen ? 6 : 8),

                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: iconSize,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        venue.location,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.grey[600],
                        ),
                        maxLines: isSmallScreen ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isSmallScreen ? 6 : 8),

                // Opening hours and rate - Stack on small screens
                if (isSmallScreen) ...[
                  // Stack vertically on small screens
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: iconSize,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          venue.openingHours,
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: iconSize,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        venue.ratePerHour,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Side by side on larger screens
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: iconSize,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          venue.openingHours,
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.monetization_on,
                        size: iconSize,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        venue.ratePerHour,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 2),

                // Rating and Book Now button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _buildStarRating(venue.rating, isSmallScreen),
                          SizedBox(width: isSmallScreen ? 4 : 8),
                          Text(
                            venue.rating.toString(),
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                CourtDetailScreen(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B2C4F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: buttonPadding,
                          vertical: isSmallScreen ? 6 : 8,
                        ),
                      ),
                      child: Text(
                        'Book Now',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
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
  }

  void _showSortingOptions(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isSmallScreen = screenWidth < 360;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow custom height
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.8, // Max 80% of screen height
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isSmallScreen ? 12.0 : 16.0, 
                  4.0, 
                  isSmallScreen ? 12.0 : 16.0, 
                  8.0
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Text(
                        "Sort & Filter",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1B2C4F),
                        ),
                      ),
                    ),
                    const Divider(),

                    // Distance Range Slider
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        "Distance Range",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "${_distanceRadius.round()} km",
                          style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                        ),
                        Expanded(
                          child: Slider(
                            value: _distanceRadius,
                            min: 0.0,
                            max: 20.0,
                            divisions: 20,
                            label: "${_distanceRadius.round()} km",
                            activeColor: const Color(0xFF1B2C4F),
                            onChanged: (value) {
                              setModalState(() {
                                _distanceRadius = value;
                              });
                              setState(() {
                                _distanceRadius = value;
                              });
                            },
                          ),
                        ),
                        Text(
                          "20 km",
                          style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                        ),
                      ],
                    ),
                    // Sorting Options
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        "Sort By",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Sorting Radio Buttons
                    _buildSortingOption(
                      "Nearest",
                      "Distance: Low to High",
                      setModalState,
                      bottomPadding: 1.0,
                      isSmallScreen: isSmallScreen,
                    ),
                    _buildSortingOption(
                      "Farthest",
                      "Distance: High to Low",
                      setModalState,
                      topPadding: 1.0,
                      bottomPadding: 1.0,
                      isSmallScreen: isSmallScreen,
                    ),
                    _buildSortingOption(
                      "Highest Rated",
                      "Rating: High to Low",
                      setModalState,
                      topPadding: 1.0,
                      isSmallScreen: isSmallScreen,
                    ),

                    // Sports Filter Section
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        "Filter by Sport",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Sports Filter Chips in a Wrap - Responsive
                    Wrap(
                      spacing: isSmallScreen ? 6.0 : 8.0,
                      runSpacing: isSmallScreen ? 2.0 : 4.0,
                      children: _filterOptionsWithIcons.keys.map((sport) {
                        final isSelected = _activeFilter == sport;
                        return FilterChip(
                          label: Text(
                            sport,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 10 : 12,
                              color: isSelected ? Colors.white : const Color(0xFF1B2C4F),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                          backgroundColor: isSelected 
                              ? const Color(0xFF1B2C4F) 
                              : Colors.grey[100],
                          selectedColor: const Color(0xFF1B2C4F),
                          side: BorderSide(
                            color: isSelected 
                                ? const Color(0xFF1B2C4F) 
                                : Colors.grey[300]!,
                          ),
                          selected: isSelected,
                          showCheckmark: false,
                          onSelected: (selected) {
                            setModalState(() {
                              _activeFilter = selected ? sport : 'All';
                            });
                            setState(() {
                              _activeFilter = selected ? sport : 'All';
                            });
                          },
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 6 : 8, 
                            vertical: isSmallScreen ? 2 : 4
                          ),
                        );
                      }).toList(),
                    ),

                    // Divider and Reset button
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Divider(),
                    ),

                    // Reset button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          setModalState(() {
                            _distanceRadius = 10.0;
                            _sortingMode = 'Nearest';
                            _activeFilter = 'All';
                          });
                          setState(() {
                            _distanceRadius = 10.0;
                            _sortingMode = 'Nearest';
                            _activeFilter = 'All';
                          });
                        },
                        icon: Icon(
                          Icons.refresh,
                          size: isSmallScreen ? 18 : 20,
                          color: const Color(0xFF1B2C4F),
                        ),
                        label: Text(
                          "Reset Filters",
                          style: TextStyle(
                            color: const Color(0xFF1B2C4F),
                            fontWeight: FontWeight.w500,
                            fontSize: isSmallScreen ? 12 : 14,
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
                      padding: const EdgeInsets.only(top: 2.0, bottom: 12.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B2C4F),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 12 : 14
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              // The distance is already updated in real-time via slider onChange
                              // Just ensure sorting mode is applied
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Apply",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Add safe area padding at bottom for devices with notches
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
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
    bool isSmallScreen = false,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 13 : 15,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600], 
                      fontSize: isSmallScreen ? 11 : 13,
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

  Widget _buildStarRating(double rating, [bool isSmallScreen = false]) {
    final starSize = isSmallScreen ? 14.0 : 16.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, color: Colors.orange, size: starSize);
        } else if (index < rating) {
          return Icon(Icons.star_half, color: Colors.orange, size: starSize);
        } else {
          return Icon(Icons.star_border, color: Colors.grey, size: starSize);
        }
      }),
    );
  }
}

// Venue Model - Enhanced to match first file data structure
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
