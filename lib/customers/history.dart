// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'footer.dart';

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
          background: const Color.fromARGB(255, 34, 51, 117),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      ),
      home: const BookingHistoryScreen(),
    );
  }
}

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // ignore: unused_field
  int _currentIndex = 3;

  // Add state variables to track bookings
  late List<Map<String, dynamic>> _upcomingBookings;
  late List<Map<String, dynamic>> _pastBookings;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize booking lists
    _upcomingBookings = [
      {
        'sport': 'Badminton',
        'venue': 'CR7 Futsal & Indoor Sports',
        'date': 'March 21, 2025',
        'time': '07:00 PM - 09:00 PM',
        'participants': 4,
        'totalSlots': 6,
        'status': 'Confirmed',
        'icon': Icons.sports_tennis,
      },
      {
        'sport': 'Football',
        'venue': 'Downtown Sports Center',
        'date': 'March 25, 2025',
        'time': '06:30 PM - 08:30 PM',
        'participants': 8,
        'totalSlots': 10,
        'status': 'Pending',
        'icon': Icons.sports_soccer,
      },
      {
        'sport': 'Cricket',
        'venue': 'Ark Sports - Indoor Cricket',
        'date': 'March 30, 2025',
        'time': '10:00 AM - 12:00 PM',
        'participants': 6,
        'totalSlots': 11,
        'status': 'Confirmed',
        'icon': Icons.sports_cricket,
      },
    ];

    _pastBookings = [
      {
        'sport': 'Tennis',
        'venue': 'University Stadium',
        'date': 'March 14, 2025',
        'time': '04:00 PM - 06:00 PM',
        'participants': 2,
        'totalSlots': 2,
        'status': 'Completed',
        'icon': Icons.sports_tennis,
      },
      {
        'sport': 'Basketball',
        'venue': 'Community Center',
        'date': 'March 10, 2025',
        'time': '07:00 PM - 09:00 PM',
        'participants': 8,
        'totalSlots': 10,
        'status': 'Completed',
        'icon': Icons.sports_basketball,
      },
      {
        'sport': 'Volleyball',
        'venue': 'Sports Club Alpha',
        'date': 'March 5, 2025',
        'time': '05:30 PM - 07:30 PM',
        'participants': 10,
        'totalSlots': 12,
        'status': 'Canceled',
        'icon': Icons.sports_volleyball,
      },
      {
        'sport': 'Table Tennis',
        'venue': 'Downtown Sports Center',
        'date': 'February 28, 2025',
        'time': '06:00 PM - 07:00 PM',
        'participants': 2,
        'totalSlots': 4,
        'status': 'Completed',
        'icon': Icons.table_bar,
      },
    ];
  }

  // Add a method to cancel a booking
  void _cancelBooking(int index) {
    setState(() {
      // Remove the booking from upcoming list
      _upcomingBookings.removeAt(index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SearchScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2C4F),
        elevation: 0,
        toolbarHeight: 50.0,
        title: const Padding(
          padding: EdgeInsets.only(
            left: 16,
          ), // Add left padding to match other screens
          child: Text(
            "Booking History",
            style: TextStyle(
              fontSize: 18, // Increased to match other screens
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false, // Prevent default back button
        leadingWidth: 56, // Adjusted for the back button

        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildUpcomingBookings(), _buildPastBookings()],
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: 2,
        onTabSelected: _onTabSelected,
      ),
    );
  }

  Widget _buildUpcomingBookings() {
    return _buildBookingsList(_upcomingBookings, true);
  }

  Widget _buildPastBookings() {
    return _buildBookingsList(_pastBookings, false);
  }

  Widget _buildBookingsList(
    List<Map<String, dynamic>> bookings,
    bool isUpcoming,
  ) {
    return bookings.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  isUpcoming ? 'No upcoming bookings' : 'No past bookings',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return BookingCard(
                sport: booking['sport'] as String,
                venue: booking['venue'] as String,
                date: booking['date'] as String,
                time: booking['time'] as String,
                participants: booking['participants'] as int,
                totalSlots: booking['totalSlots'] as int,
                status: booking['status'] as String,
                icon: booking['icon'] as IconData,
                isUpcoming: isUpcoming,
                index: index, // Add index parameter
                onCancel: isUpcoming
                    ? _cancelBooking
                    : null, // Pass cancel function
              );
            },
          );
  }
}

class BookingCard extends StatelessWidget {
  final String sport;
  final String venue;
  final String date;
  final String time;
  final int participants;
  final int totalSlots;
  final String status;
  final IconData icon;
  final bool isUpcoming;
  final int index;
  final Function(int)? onCancel;

  const BookingCard({
    super.key,
    required this.sport,
    required this.venue,
    required this.date,
    required this.time,
    required this.participants,
    required this.totalSlots,
    required this.status,
    required this.icon,
    required this.isUpcoming,
    required this.index,
    this.onCancel,
  });

  Color _getStatusColor() {
    switch (status) {
      case 'Confirmed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Canceled':
        return Colors.red;
      case 'Completed':
        return const Color(0xFF1B2C4F);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50, // Slightly reduced width from 55
                  height: 50, // Slightly reduced height from 55
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      147,
                      173,
                      234,
                    ).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 28, // Slightly reduced size from 30
                    color: const Color(0xFF1B2C4F),
                  ),
                ),
                const SizedBox(width: 12), // Slightly reduced from 16
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              sport,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2D3142),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ), // Reduced horizontal padding from 10
                            decoration: BoxDecoration(
                              color: _getStatusColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        venue,
                        overflow:
                            TextOverflow.ellipsis, // Add overflow handling
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 12, // Reduced from 16
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize
                                .min, // Important to prevent expansion
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                date,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize
                                .min, // Important to prevent expansion
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                time,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ), // Reduced from 16,12
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize:
                      MainAxisSize.min, // Important to prevent expansion
                  children: [
                    const Icon(
                      Icons.people,
                      size: 16,
                      color: Color(0xFF1B2C4F),
                    ),
                    const SizedBox(width: 4), // Reduced from 6
                    Text(
                      '$participants/$totalSlots slots filled',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                  ],
                ),
                if (isUpcoming)
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingDetailsScreen(
                                sport: sport,
                                venue: venue,
                                date: date,
                                time: time,
                                participants: participants,
                                totalSlots: totalSlots,
                                status: status,
                                icon: icon,
                                isUpcoming: isUpcoming,
                                index: index,
                                onCancel:
                                    onCancel, // Pass the onCancel callback
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF1B2C4F),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text('Details'),
                      ),
                      if (status != 'Canceled')
                        OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Cancel Booking'),
                                  content: const Text(
                                    'Are you sure you want to cancel this booking?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        // Call the cancel function with the booking index
                                        if (onCancel != null) {
                                          onCancel!(index);
                                        }
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Booking canceled'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Yes, Cancel'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: const Text('Cancel'),
                        ),
                    ],
                  )
                else
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingDetailsScreen(
                            sport: sport,
                            venue: venue,
                            date: date,
                            time: time,
                            participants: participants,
                            totalSlots: totalSlots,
                            status: status,
                            icon: icon,
                            isUpcoming: isUpcoming,
                            index: index,
                            onCancel: onCancel, // Pass the onCancel callback
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1B2C4F),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('View Details'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookingDetailsScreen extends StatelessWidget {
  final String sport;
  final String venue;
  final String date;
  final String time;
  final int participants;
  final int totalSlots;
  final String status;
  final IconData icon;
  final bool isUpcoming;
  final int index;
  final Function(int)? onCancel;

  const BookingDetailsScreen({
    super.key,
    required this.sport,
    required this.venue,
    required this.date,
    required this.time,
    required this.participants,
    required this.totalSlots,
    required this.status,
    required this.icon,
    required this.isUpcoming,
    required this.index,
    this.onCancel,
  });

  Color _getStatusColor() {
    switch (status) {
      case 'Confirmed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Canceled':
        return Colors.red;
      case 'Completed':
        return const Color(0xFF1B2C4F);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2C4F),
        elevation: 0,
        title: const Text(
          "Booking Details",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card with basic info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            255,
                            147,
                            173,
                            234,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          size: 32,
                          color: const Color(0xFF1B2C4F),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sport,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3142),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              venue,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Details section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  const Text(
                    "Booking Information",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date & Time
                  _buildDetailRow(Icons.calendar_today, "Date", date),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.access_time, "Time", time),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.people,
                    "Participants",
                    "$participants out of $totalSlots slots filled",
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    "Additional Information",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.event_note,
                    "Booking Type",
                    "Regular Booking",
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.access_time,
                    "Booking Made On",
                    "March 15, 2025",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons for upcoming bookings
            if (isUpcoming && status != 'Canceled')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Cancel Booking'),
                          content: const Text(
                            'Are you sure you want to cancel this booking?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                // Call the cancel function with the booking index
                                if (onCancel != null) {
                                  onCancel!(index);
                                }
                                Navigator.pop(
                                  context,
                                ); // Go back to previous screen
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Booking canceled'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Yes, Cancel'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel Booking'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1B2C4F)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D3142),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BookingHistoryScreen(),
              ),
            );
          },
          child: const Text('Go to Booking History'),
        ),
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: const Center(child: Text('Search Screen')),
    );
  }
}
