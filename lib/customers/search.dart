// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

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
            title: 'Elite Badminton Court',
            location: '23 Mile Post Ave, Colombo 00300',
            type: 'Indoor',
            rating: 4.7,
            price: '₹1200/hr',
            distance: '2.3 km',
          ),
          VenueResult(
            title: 'Aqua Sports Center',
            location: '78 Poolside Avenue, Mount Lavinia',
            type: 'Pool',
            rating: 4.5,
            price: '₹1800/hr',
            distance: '3.1 km',
          ),
          VenueResult(
            title: 'Victory Football Ground',
            location: '156 Greens Road, Kandy',
            type: 'Outdoor',
            rating: 4.9,
            price: '₹2500/hr',
            distance: '4.2 km',
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
      // Removed bottomNavigationBar - no footer on search screen
    );
  }

  // Clean search bar with sports placeholder
  // Updated search bar with fixed text alignment
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
          autofocus: true, // Auto focus when entering search screen
          style: const TextStyle(
            color: Color(0xFF2D3142),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlignVertical:
              TextAlignVertical.center, // Ensure text stays vertically centered
          decoration: InputDecoration(
            hintText: 'Search sports venues...',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.all(14),
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
              vertical: 16,
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
            // These properties prevent the text from shifting
            isDense: true, // Reduces the default height
            isCollapsed: false, // Don't collapse to minimum size
            floatingLabelBehavior:
                FloatingLabelBehavior.never, // Ensure label doesn't float
            alignLabelWithHint: true, // Align the hint and text properly
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

  // Clean recent searches layout
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            physics: const BouncingScrollPhysics(),
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
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

  // Simplified search results with updated positioning
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
          // Reduced bottom padding from 12 to 4
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
            // Reduced top padding from 8 to 2
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            physics: const BouncingScrollPhysics(),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final venue = _searchResults[index];
              return Container(
                // Reduced top margin from 6 to 0, and reduced bottom margin from 10 to 8
                margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B2C4F).withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () =>
                        _showCustomSnackBar(context, 'Selected ${venue.title}'),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left side - Icon/Type
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _getColorForVenueType(
                                venue.type,
                              ).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(
                                _getIconForVenueType(venue.type),
                                color: _getColorForVenueType(venue.type),
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Right side - Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        venue.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF2D3142),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 18,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          venue.rating.toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  venue.location,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Type badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getColorForVenueType(
                                          venue.type,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        venue.type,
                                        style: TextStyle(
                                          color: _getColorForVenueType(
                                            venue.type,
                                          ),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    // Distance
                                    Text(
                                      venue.distance,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween, // Fixed: removed underscore
                                  children: [
                                    // Price
                                    Text(
                                      venue.price,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B2C4F),
                                      ),
                                    ),
                                    // Book button
                                    ElevatedButton(
                                      onPressed: () => _showCustomSnackBar(
                                        context,
                                        'Booking ${venue.title}',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF1B2C4F,
                                        ),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "Book",
                                        style: TextStyle(
                                          color: Colors.white,
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
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Helper methods for venue styling
  IconData _getIconForVenueType(String type) {
    switch (type) {
      case 'Indoor':
        return Icons.sports_tennis;
      case 'Outdoor':
        return Icons.sports_soccer;
      case 'Pool':
        return Icons.pool;
      default:
        return Icons.sports;
    }
  }

  Color _getColorForVenueType(String type) {
    switch (type) {
      case 'Indoor':
        return const Color(0xFF3366FF);
      case 'Outdoor':
        return const Color(0xFF00C853);
      case 'Pool':
        return const Color(0xFF00BCD4);
      default:
        return const Color(0xFF1B2C4F);
    }
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

// Simplified venue result model
class VenueResult {
  final String title;
  final String location;
  final String type;
  final double rating;
  final String price;
  final String distance;

  VenueResult({
    required this.title,
    required this.location,
    required this.type,
    required this.rating,
    required this.price,
    required this.distance,
  });
}
