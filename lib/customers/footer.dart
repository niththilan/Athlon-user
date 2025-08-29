// ignore_for_file: deprecated_member_use, file_names, duplicate_import, use_build_context_synchronously, avoid_print, unused_import

import 'package:athlon_user/customers/bookings.dart';
import 'package:flutter/material.dart';
import 'home.dart' as home;
import 'favourites.dart';
import 'history.dart';
import 'messages.dart';
import 'widgets/football_spinner.dart';

class AppFooter extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const AppFooter({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  Future<void> _navigateToFavorites(BuildContext context) async {
    try {
      List<Map<String, dynamic>> favoriteVenues = [];

      // Supabase integration removed. You may want to load favorites from another source here.
      // Example: favoriteVenues = await loadFavoritesFromLocalOrOtherApi();

      // Navigate using regular push instead of pushAndRemoveUntil
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => FavoritesScreen(
            favoriteVenues: favoriteVenues,
            onRemoveFavorite: (venue) async {
              // Supabase update removed. You may want to update favorites in another way here.
            },
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading favorites: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );

        // Navigate to empty favorites as fallback
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                FavoritesScreen(
                  favoriteVenues: const <Map<String, dynamic>>[],
                  onRemoveFavorite: (_) {},
                ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
    }
  }

  Future<void> _navigateToBookings(BuildContext context) async {
    print('Attempting to navigate to bookings...');
    try {
      print('Navigating to Bookings...');
      // Use regular push instead of pushAndRemoveUntil
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            print('Building BookingScreen...');
            return const HistoryScreen();
          },
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
      print('History navigation completed');
    } catch (e) {
      print('Error in history navigation: $e');

      // Show error to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error navigating to bookings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToMessages(BuildContext context) async {
    print('Attempting to navigate to messages...');
    try {
      if (context.mounted) {
        print('Context is mounted, navigating...');
        // Use regular push instead of pushAndRemoveUntil
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              print('Building MessagesScreen...');
              return const MessagesScreen();
            },
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        print('Navigation completed');
      } else {
        print('Context is not mounted!');
      }
    } catch (e) {
      print('Error navigating to messages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 4,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, 0, Icons.sports_basketball, 'Home'),
          _buildNavItem(context, 1, Icons.favorite, 'Favorites'),
          _buildNavItem(context, 2, Icons.history, 'History'),
          _buildNavItem(context, 3, Icons.chat_bubble_outline, 'Chat'),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final bool isSelected = currentIndex == index;
    const primaryColor = Color(0xFF1B2C4F);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // First call the original callback
          onTabSelected(index);

          // Only navigate if not already on the same screen
          if (currentIndex != index) {
            switch (index) {
              case 0:
                // Home: Use pushAndRemoveUntil to clear stack and go to home
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const home.HomeScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                  (route) => false,
                );
                break;
              case 1:
                _navigateToFavorites(context);
                break;
              case 2:
                _navigateToBookings(context);
                break;
              case 3:
                _navigateToMessages(context);
                break;
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: isSelected ? const EdgeInsets.all(5) : EdgeInsets.zero,
                decoration: isSelected
                    ? BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                child: Icon(
                  icon,
                  color: isSelected ? primaryColor : Colors.grey[600],
                  size: 24,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? primaryColor : Colors.grey[600],
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}