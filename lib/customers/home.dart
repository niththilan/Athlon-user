// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'user_profile_screen.dart';
import 'widgets/football_spinner.dart';
import 'availableSports.dart'; // Add this import
import 'courtDetails.dart'; // Add this import
import 'search.dart'; // Add search import
import 'UserLogin.dart'; // Add login import

import 'footer.dart';
import 'nearbyVenues.dart' as nearby_venues; // Import the nearbyVenues file
import 'services/navigation_service.dart';
import 'services/data_service.dart';
import 'services/customer_service.dart'; // Add customer service import
import 'models/venue_models.dart' as venue_models;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  String _selectedLocation = "Current Location";
  List<venue_models.VenueModel> _venues = [];
  bool _isLoadingVenues = false;

  final TextEditingController _searchController = TextEditingController();
  final List<String> _pastSearchLocations = [
    "Downtown Sports Complex",
    "Central Park Area",
    "University District",
    "Shopping Mall Area",
    "Riverside Stadium",
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Quick initialization for home screen (200ms)
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      // Load venues in background
      _loadVenues();
    }
  }

  Future<void> _loadVenues() async {
    if (_isLoadingVenues) return;
    
    setState(() {
      _isLoadingVenues = true;
    });

    try {
      final venues = await DataService.loadVenues();
      
      if (mounted) {
        setState(() {
          _venues = venues;
          _isLoadingVenues = false;
        });
      }
    } catch (e) {
      print('Error loading venues: $e');
      if (mounted) {
        setState(() {
          _isLoadingVenues = false;
          // Use fallback mock data if loading fails
          _venues = [];
        });
      }
    }
  }

  // ADD THIS METHOD - Reset current index when returning to home
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset current index to 0 when home screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _currentIndex != 0) {
        setState(() {
          _currentIndex = 0;
        });
      }
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Navigation methods to match facility owner's homepage
  Future<void> _navigateToNotifications() async {
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
      await Future.delayed(const Duration(milliseconds: 100));

      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Navigate to notification screen
      NavigationService.pushInstant(const NotificationScreen());
    } catch (e) {
      // Handle any errors
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Still navigate to notification screen
      NavigationService.pushInstant(const NotificationScreen());
    }
  }

  Future<void> _navigateToProfile() async {
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
      await Future.delayed(const Duration(milliseconds: 100));

      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Navigate to profile screen
      NavigationService.pushInstant(const UserProfileScreen());
    } catch (e) {
      // Handle any errors
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Still navigate to profile screen
      NavigationService.pushInstant(const UserProfileScreen());
    }
  }

  Future<void> _handleLogout() async {
    try {
      // Show confirmation dialog
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (shouldLogout == true) {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: Color(0xFF1B2C4F)),
          ),
        );

        // Logout from Supabase
        await CustomerService.signOut();

        // Close loading dialog
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Navigate back to login screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        // Navigate to search screen
        NavigationService.pushInstant(const SearchScreen());
      },
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              Text(
                'Search sports venues...',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: FootballLoadingWidget()));
    }
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 50.0,
          surfaceTintColor: Colors.white,
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Image.asset(
              'assets/Athlon1.png', // Match facility owner's path
              height: 50,
              fit: BoxFit.contain,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF1B2C4F),
                size: 28,
              ),
              onPressed: () =>
                  _navigateToNotifications(), // Match facility owner's behavior
              tooltip: 'Notifications',
            ),
            // Profile icon - direct navigation to profile
            IconButton(
              icon: const Icon(
                Icons.person_outline,
                color: Color(0xFF1B2C4F),
                size: 28,
              ),
              onPressed: () => _navigateToProfile(),
              tooltip: 'Profile',
            ),
            const SizedBox(width: 25),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Match vendor's padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                // Welcome text
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Welcome back, Sam!",
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B2C4F),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Location card
                GestureDetector(
                  onTap: () => _showLocationSelector(),
                  child: _buildLocationCard(textTheme),
                ),
                const SizedBox(height: 16),
                // Search bar
                _buildSearchBar(),
                const SizedBox(height: 24),
                FeatureSection(),
                const SizedBox(height: 24),
                SportsSection(),
                const SizedBox(height: 24),
                VenuesSection(
                  venues: _venues,
                  isLoading: _isLoadingVenues,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: 0,
        onTabSelected: (int index) {
          // Let the AppFooter handle all navigation
          // Remove the complex switch logic and just let footer handle it
        },
      ),
    );
  }

  Widget _buildLocationCard(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2C4F),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedLocation == "Current Location"
                      ? 'Colombo, Sri Lanka'
                      : _selectedLocation,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedLocation == "Current Location"
                      ? "Current Location"
                      : "Tap to change location",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 28),
        ],
      ),
    );
  }

  void _showLocationSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Header with close button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        const Text(
                          "Choose Location",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B2C4F),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, size: 24),
                        ),
                      ],
                    ),
                  ),

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search for area, street name...",
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[600],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        onChanged: (value) {
                          setModalState(() {});
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Current Location option
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildCurrentLocationOption(),
                  ),

                  const SizedBox(height: 20),

                  // Past searches section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              const SizedBox(width: 8),

                              Text(
                                "Recent searches",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _pastSearchLocations.length,
                            itemBuilder: (context, index) {
                              final location = _pastSearchLocations[index];
                              return _buildPastLocationOption(location);
                            },
                          ),
                        ),
                      ],
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

  Widget _buildCurrentLocationOption() {
    final isSelected = _selectedLocation == "Current Location";
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLocation = "Current Location";
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2C4F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.my_location,
                color: Color(0xFF1B2C4F),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Use current location",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2C4F),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Enable precise location",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF1B2C4F),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastLocationOption(String location) {
    final isSelected = _selectedLocation == location;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLocation = location;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            Icon(Icons.history, color: Colors.grey[600], size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                location,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? const Color(0xFF1B2C4F) : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF1B2C4F),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

/// Enhanced Notification Screen - Matching facility owner's implementation
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  bool _isScrolled = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _isScrolled = _scrollController.offset > 0;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            elevation: _isScrolled ? 4 : 0,
            toolbarHeight: 50,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1B2C4F),
            centerTitle: false,
            title: const Text(
              "Notifications",
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
                icon: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () async {
                  // Show loading screen
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    barrierColor: Colors.black.withOpacity(0.3),
                    builder: (BuildContext context) {
                      return const Center(child: FootballLoadingWidget());
                    },
                  );

                  // Loading delay
                  await Future.delayed(const Duration(milliseconds: 200));

                  // Navigate back to home and reset footer index
                  if (context.mounted) {
                    Navigator.pop(context); // Close loading dialog

                    // Use pushAndRemoveUntil to ensure home screen is fresh
                    Navigator.pushAndRemoveUntil(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const HomeScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                      (route) => false, // Remove all previous routes
                    );
                  }
                },
                tooltip: 'Back',
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B2C4F).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_none,
                      size: 60,
                      color: const Color(0xFF1B2C4F).withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'All caught up!',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have no new notifications',
                    style: Theme.of(context).textTheme.bodyMedium,
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

// ----------------- FeatureSection & FeatureCard -----------------
class FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const FeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Navigate to Nearby Venues screen
          NavigationService.pushInstant(const nearby_venues.NearByVenueScreen());
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B2C4F).withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: const Color(0xFF1B2C4F).withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background image with overlay
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
              // Gradient overlay for better text readability
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              // Content
              Positioned(
                bottom: 70,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Book Now Button
              Positioned(
                bottom: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Book Now',
                        style: TextStyle(
                          color: const Color(0xFF1B2C4F),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: const Color(0xFF1B2C4F),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Updated FeatureSection with only Book feature
class FeatureSection extends StatelessWidget {
  const FeatureSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureCard(
      title: "Book Venue",
      description: "Find and book your perfect sports venue nearby",
      imagePath: 'assets/courts4.jpg',
    );
  }
}

// ----------------- SportsSection & SportsCard -----------------
class SportsSection extends StatelessWidget {
  const SportsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).toInt()),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  "Available Sports",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to Available Sports screen
                  NavigationService.pushInstant(const SportsVenueScreen());
                },
                child: Text(
                  "See More",
                  style: TextStyle(
                    color: Color(0xFF2D3142),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SportsCard(sport: "Football", imagePath: "assets/football.jpg"),
                SportsCard(sport: "Basketball", imagePath: "assets/basket.jpg"),
                SportsCard(sport: "Tennis", imagePath: "assets/tennis.jpg"),
                SportsCard(sport: "Cricket", imagePath: "assets/crickett.jpg"),
                SportsCard(
                  sport: "Badminton",
                  imagePath: "assets/badminton.jpg",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SportsCard extends StatelessWidget {
  final String sport;
  final String imagePath;

  const SportsCard({super.key, required this.sport, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: () {
          // Navigate to Available Sports screen with the selected sport
          NavigationService.pushInstant(SportsVenueScreen(initialSport: sport));
        },
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              sport,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D3142),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- VenuesSection & VenueCard -----------------
class VenuesSection extends StatelessWidget {
  final List<venue_models.VenueModel> venues;
  final bool isLoading;

  const VenuesSection({
    super.key,
    required this.venues,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  "Venues",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to Nearby Venues screen with no transition
                  NavigationService.pushInstant(
                    const nearby_venues.NearByVenueScreen(),
                  );
                },
                child: Text(
                  "See More",
                  style: TextStyle(
                    color: Color(0xFF2D3142),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          SizedBox(
            height: 260, // Fixed height for horizontal scrolling
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1B2C4F),
                    ),
                  )
                : venues.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No venues found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: venues.length,
                        itemBuilder: (context, index) {
                          final venue = venues[index];
                          return Container(
                            width: 180, // Fixed width for each card
                            margin: EdgeInsets.only(
                              left: index == 0 ? 8 : 12,
                              right: index == venues.length - 1 ? 8 : 0,
                            ),
                            child: VenueCard(venue: venue),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class VenueCard extends StatelessWidget {
  final venue_models.VenueModel venue;

  const VenueCard({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180, // Fixed width for scrollable cards
      height: 240,
      child: GestureDetector(
        onTap: () {
          // Navigate to CourtDetailScreen when tapped with venue data
          NavigationService.pushInstant(
            CourtDetailScreen(
              courtData: {
                'id': venue.id,
                'name': venue.name,
                'type': venue.sports.isNotEmpty
                    ? venue.sports.first
                    : 'Sports Facility',
                'location': venue.location,
                'distance': '${venue.distance} km away',
                'rating': venue.rating,
                'total_reviews': venue.reviewCount,
                'price_per_hour': venue.courts.isNotEmpty
                    ? venue.courts.first.hourlyRate
                    : 0.0,
                'opening_hours': venue.openingHours,
                'closing_time': 'Closes at 11:00 PM',
                'phone': venue.phone ?? '+94 77 123 4567',
                'email': venue.website?.contains('@') == true 
                    ? venue.website
                    : 'info@${venue.name.toLowerCase().replaceAll(' ', '')}.lk',
                'website': venue.website ?? 
                    'www.${venue.name.toLowerCase().replaceAll(' ', '')}.lk',
                'description': venue.bio ?? 
                    'Premium sports facility with state-of-the-art equipment and professional-grade surfaces.',
                'images': [venue.primaryImageUrl],
                'sports_available': venue.sports,
              },
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).toInt()),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 110,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    venue.primaryImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[100],
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
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      venue.location,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          color: index < venue.rating
                              ? Colors.amber
                              : Colors.grey,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
