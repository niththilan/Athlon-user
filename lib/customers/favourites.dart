// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'footer.dart';

import 'home.dart';
import 'courtDetails.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> favoriteVenues;
  final Function(Map<String, dynamic>) onRemoveFavorite;

  const FavoritesScreen({
    super.key,
    required this.favoriteVenues,
    required this.onRemoveFavorite,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _currentIndex = 2; // Set to favorites tab index
  late List<Map<String, dynamic>> _favoriteVenues;

  @override
  void initState() {
    super.initState();
    _favoriteVenues = List.from(widget.favoriteVenues);
  }

  // Improve the footer navigation to ensure we properly handle returning to venues
  void _onTabSelected(int index) {
    if (index == _currentIndex) return; // Avoid rebuilding if same tab

    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      // Navigate to home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (index == 1) {
      // Navigate to venues with explicit state preservation
    }
  }

  // Handle removing favorite
  void _handleRemoveFavorite(String? venueId) {
    if (venueId == null) {
      debugPrint('Warning: Attempted to remove a favorite with null ID');
      return;
    }

    // Find venue before removing it
    final venueToRemove = _favoriteVenues.firstWhere(
      (v) => v['id'] == venueId,
      orElse: () => {}, // Return empty map if venue not found
    );

    // Only proceed if we found a valid venue
    if (venueToRemove.isEmpty) {
      debugPrint('Warning: Could not find venue with ID: $venueId');
      return;
    }

    // Update UI immediately for better user experience
    setState(() {
      _favoriteVenues.removeWhere((v) => v['id'] == venueId);
    });

    // Call the provided callback
    widget.onRemoveFavorite(venueToRemove);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed from favorites: ${venueToRemove['title']}'),
        duration: const Duration(seconds: 1),
      ),
    );

    // If all favorites are removed, show a message and offer to go back to venues
    if (_favoriteVenues.isEmpty) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('All favorites removed. Browse more venues?'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(label: 'Browse', onPressed: () {}),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we have any favorites to display
    final hasNoFavorites = _favoriteVenues.isEmpty;

    // Debug info in build
    debugPrint(
      'Building FavoritesScreen with ${_favoriteVenues.length} favorites',
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2C4F),
        elevation: 2,
        toolbarHeight: 50,
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            "Favourite Venues (${_favoriteVenues.length})",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        leadingWidth: 20,
      ),
      body: hasNoFavorites
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favoriteVenues.length,
              itemBuilder: (context, index) {
                final venue = _favoriteVenues[index];
                return VenueCardFavorite(
                  title: venue['title'] ?? 'Unknown Venue',
                  location: venue['location'] ?? 'Unknown Location',
                  rating: venue['rating'] is double
                      ? venue['rating']
                      : double.tryParse(venue['rating'].toString()) ?? 0.0,
                  imagePath: venue['imagePath'] ?? 'assets/placeholder.jpg',
                  venueId: venue['id'] ?? '',
                  distance: venue['distance'] ?? 'Unknown Distance',
                  isFavorite: true,
                  onFavoriteToggle: () {
                    _handleRemoveFavorite(venue['id'] as String?);
                  },
                );
              },
            ),
      bottomNavigationBar: AppFooter(
        currentIndex: 1,
        onTabSelected: _onTabSelected,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No favorite venues yet",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your favorite venues will appear here",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B2C4F),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Browse Venues",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VenueCardFavorite extends StatelessWidget {
  final String title;
  final String location;
  final double rating;
  final String imagePath;
  final String venueId;
  final String distance;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const VenueCardFavorite({
    super.key,
    required this.title,
    required this.location,
    required this.rating,
    required this.imagePath,
    required this.venueId,
    this.distance = '2.5 km',
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with gradient overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.asset(
                  imagePath,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              // Favorite button - updated to make it more visible
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  iconSize: 28,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                    size: 28,
                  ),
                  onPressed: onFavoriteToggle,
                ),
              ),
            ],
          ),

          // Venue Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Venue Title and Distance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3142),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      distance,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Rating and Book Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Star Rating
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            Icons.star,
                            size: 20,
                            color: index < rating.floor()
                                ? Colors.amber
                                : Colors.grey[300],
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          rating.toString(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),

                    // View More Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CourtDetailScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B2C4F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 2,
                        ),
                      ),
                      child: const Text(
                        'View More',
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
    );
  }
}
