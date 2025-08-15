// ignore_for_file: deprecated_member_use, file_names, duplicate_import, use_build_context_synchronously, avoid_print

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
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.white,
        builder: (BuildContext context) {
          return const FootballLoadingWidget();
        },
      );

      // Simulate loading time - much shorter
      await Future.delayed(const Duration(milliseconds: 300));

      List<Map<String, dynamic>> favoriteVenues = [];

      // Supabase integration removed. You may want to load favorites from another source here.
      // Example: favoriteVenues = await loadFavoritesFromLocalOrOtherApi();

      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Navigate to favorites screen with push instead of pushReplacement
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
      // Handle any errors in the main try block
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

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

  Future<void> _navigateToBookings(BuildContext context) async {
    print('Attempting to navigate to bookings...');
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

      await Future.delayed(const Duration(milliseconds: 300));

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      print('Navigating to Bookings...');
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

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

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
          _buildNavItem(context, 2, Icons.history, 'Bookings'),
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

          // Handle navigation if index is different from current
          if (index != currentIndex) {
            switch (index) {
              case 0:
                // For home, we might want to pop back to home instead of pushing
                // This prevents building up a large navigation stack
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const home.HomeScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                  (route) => false, // This removes all previous routes
                );
                break;
              case 1:
                // Navigate to favorites
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
