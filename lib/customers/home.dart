// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'userProfile.dart';
import 'nearbyVenues.dart';

import 'availableSports.dart'; // Add this import
import 'courtDetails.dart'; // Add this import

import 'footer.dart';
import 'nearbyVenues.dart' as venues; // Import the nearbyVenues file

// Add a custom route with no animation
class NoAnimationRoute<T> extends PageRoute<T> {
  NoAnimationRoute({
    required this.builder,
    super.settings,
    this.maintainState = true,
  }) : super(fullscreenDialog: false);

  final WidgetBuilder builder;

  @override
  final bool maintainState;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get opaque => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  bool get barrierDismissible => false;
}

void main() {
  runApp(MyApp());
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
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Navigation methods to match facility owner's homepage
  void _navigateToNotifications() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NotificationScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        // Navigate to search screen
        Navigator.push(
          context,
          NoAnimationRoute(builder: (context) => const NearByVenueScreen()),
        );
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
            // 2. Then replace the profile IconButton in your AppBar actions with this:
            IconButton(
              icon: const Icon(
                Icons.person_outline,
                color: Color(0xFF1B2C4F),
                size: 28,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const UserProfileScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
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
                // Welcome/location card
                _buildWelcomeWithLocationCard(textTheme),
                const SizedBox(height: 16),
                // Search bar
                _buildSearchBar(),
                const SizedBox(height: 24),
                FeatureSection(),
                const SizedBox(height: 24),
                SportsSection(),
                const SizedBox(height: 24),
                VenuesSection(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }

  Widget _buildWelcomeWithLocationCard(TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2C4F),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Welcome and location text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back, Sam!",
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Current Location',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  'Colombo, Sri Lanka',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: GestureDetector(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    172,
                    172,
                    172,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
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
    // Check if this is the Find Players card to disable it
    bool isDisabled = title == "Find Players";

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled
            ? null
            : () {
                // Navigation only for enabled cards
                if (title == "Book") {
                  // Navigate to Nearby Venues screen
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const venues.NearByVenueScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }
              },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: isDisabled ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.08 * 255).toInt()),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                        colorFilter: isDisabled
                            ? ColorFilter.mode(
                                Colors.grey.withOpacity(0.7),
                                BlendMode.srcOver,
                              )
                            : null,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDisabled
                                ? Colors.grey.shade600
                                : Color(0xFF2D3142),
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          isDisabled ? "Coming soon..." : description,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDisabled
                                ? Colors.grey.shade500
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Add "Coming Soon" overlay for disabled cards
              if (isDisabled)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade600,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Coming Soon',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
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

// Update FeatureSection to include onTap handlers
class FeatureSection extends StatelessWidget {
  const FeatureSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FeatureCard(
            title: "Find Players",
            description: "Find players and join their activities",
            imagePath: 'assets/findplay.jpg',
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: FeatureCard(
            title: "Book",
            description: "Book your slots in venues nearby",
            imagePath: 'assets/courts.jpg',
          ),
        ),
      ],
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
                  Navigator.push(
                    context,
                    NoAnimationRoute(
                      builder: (context) => const SportsVenueScreen(),
                    ),
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
          Navigator.push(
            context,
            NoAnimationRoute(
              builder: (context) => SportsVenueScreen(initialSport: sport),
            ),
          );
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
  const VenuesSection({super.key});

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
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const venues.NearByVenueScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
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
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _sampleVenues.length,
              itemBuilder: (context, index) {
                final venue = _sampleVenues[index];
                return Container(
                  width: 180, // Fixed width for each card
                  margin: EdgeInsets.only(
                    left: index == 0 ? 8 : 12,
                    right: index == _sampleVenues.length - 1 ? 8 : 0,
                  ),
                  child: VenueCard(
                    venue: venue,
                  ),
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
  final VenueModel venue;

  const VenueCard({
    super.key,
    required this.venue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180, // Fixed width for scrollable cards
      height: 240,
      child: GestureDetector(
        onTap: () {
          // Navigate to CourtDetailScreen when tapped
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const CourtDetailScreen(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
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
                    venue.imageUrl,
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
                      venue.title,
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
                          color: index < venue.rating ? Colors.amber : Colors.grey,
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

// VenueModel class for venue data
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

// Sample venue data from nearbyVenues.dart
final List<VenueModel> _sampleVenues = [
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
];
