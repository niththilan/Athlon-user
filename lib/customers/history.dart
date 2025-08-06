// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../customers/footer.dart';
import 'home.dart' as home;
import 'messages.dart';

/// Simplified History Screen with user-friendly design
class HistoryScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  HistoryScreenState createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  // ignore: unused_field
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // Date scroll and calendar state
  DateTime selectedDate = DateTime.now();
  bool showCalendar = false;
  late List<DateTime> dateList;
  int currentDateStartIndex = 5; // Place the current date in the middle

  List<BookingHistoryItem> bookingHistory = [];

  // Simplified color scheme
  static const Color primaryColor = Color(0xFF1B2C4F);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color successColor = Color(0xFF10B981);
  static const Color darkGreenColor = Color(0xFF065F46); // Added dark green
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _initializeDateList();
    _initializeMockData(); // Add mock data initialization
    _scrollController.addListener(_onScroll);

    // Set loading to false since we're using mock data
    _isLoading = false;
  }

  void _initializeDateList() {
    dateList = [];
    final today = DateTime.now();
    // Include past, current, and future dates, with today centered
    for (int i = -7; i <= 30; i++) {
      dateList.add(today.add(Duration(days: i)));
    }
  }

  // Add mock data for testing
  void _initializeMockData() {
    final now = DateTime.now();
    bookingHistory = [
      // Today's bookings
      BookingHistoryItem(
        id: '1',
        customerName: 'John Smith',
        courtName: 'Football Court A',
        courtType: 'Football',
        date: now,
        startTime: '6:00 PM',
        endTime: '7:00 PM',
        duration: 60,
        price: 2500.0,
        status: 'confirmed',
        customerPhone: '+94 77 123 4567',
      ),
      BookingHistoryItem(
        id: '2',
        customerName: 'Sarah Johnson',
        courtName: 'Basketball Court B',
        courtType: 'Basketball',
        date: now,
        startTime: '4:00 PM',
        endTime: '5:30 PM',
        duration: 90,
        price: 3000.0,
        status: 'confirmed',
        customerPhone: '+94 71 987 6543',
      ),
      BookingHistoryItem(
        id: '3',
        customerName: 'Mike Wilson',
        courtName: 'Tennis Court 1',
        courtType: 'Tennis',
        date: now,
        startTime: '8:00 PM',
        endTime: '9:00 PM',
        duration: 60,
        price: 2000.0,
        status: 'completed',
        customerPhone: '+94 76 555 7890',
      ),

      // Yesterday's bookings
      BookingHistoryItem(
        id: '4',
        customerName: 'Emma Davis',
        courtName: 'Football Court B',
        courtType: 'Football',
        date: now.subtract(Duration(days: 1)),
        startTime: '5:00 PM',
        endTime: '6:30 PM',
        duration: 90,
        price: 3500.0,
        status: 'completed',
        customerPhone: '+94 75 444 3210',
      ),
      BookingHistoryItem(
        id: '5',
        customerName: 'Alex Thompson',
        courtName: 'Badminton Court A',
        courtType: 'Badminton',
        date: now.subtract(Duration(days: 1)),
        startTime: '7:00 PM',
        endTime: '8:00 PM',
        duration: 60,
        price: 1500.0,
        status: 'completed',
        customerPhone: '+94 77 888 9999',
      ),
      BookingHistoryItem(
        id: '6',
        customerName: 'Lisa Brown',
        courtName: 'Football Court A',
        courtType: 'Football',
        date: now.subtract(Duration(days: 1)),
        startTime: '3:00 PM',
        endTime: '4:00 PM',
        duration: 60,
        price: 2500.0,
        status: 'cancelled',
        customerPhone: '+94 70 222 1111',
      ),

      // Two days ago
      BookingHistoryItem(
        id: '7',
        customerName: 'David Miller',
        courtName: 'Tennis Court 2',
        courtType: 'Tennis',
        date: now.subtract(Duration(days: 2)),
        startTime: '6:30 PM',
        endTime: '7:30 PM',
        duration: 60,
        price: 2000.0,
        status: 'completed',
        customerPhone: '+94 72 333 4444',
      ),
      BookingHistoryItem(
        id: '8',
        customerName: 'Jessica Taylor',
        courtName: 'Basketball Court A',
        courtType: 'Basketball',
        date: now.subtract(Duration(days: 2)),
        startTime: '8:00 PM',
        endTime: '9:30 PM',
        duration: 90,
        price: 3000.0,
        status: 'completed',
        customerPhone: '+94 78 666 7777',
      ),

      // Three days ago
      BookingHistoryItem(
        id: '9',
        customerName: 'Robert Anderson',
        courtName: 'Football Court C',
        courtType: 'Football',
        date: now.subtract(Duration(days: 3)),
        startTime: '4:30 PM',
        endTime: '6:00 PM',
        duration: 90,
        price: 3500.0,
        status: 'completed',
        customerPhone: '+94 74 111 2222',
      ),
      BookingHistoryItem(
        id: '10',
        customerName: 'Maria Garcia',
        courtName: 'Volleyball Court A',
        courtType: 'Volleyball',
        date: now.subtract(Duration(days: 3)),
        startTime: '7:00 PM',
        endTime: '8:30 PM',
        duration: 90,
        price: 2800.0,
        status: 'completed',
        customerPhone: '+94 73 555 6666',
      ),

      // A week ago
      BookingHistoryItem(
        id: '11',
        customerName: 'Kevin Lee',
        courtName: 'Badminton Court B',
        courtType: 'Badminton',
        date: now.subtract(Duration(days: 7)),
        startTime: '5:30 PM',
        endTime: '6:30 PM',
        duration: 60,
        price: 1500.0,
        status: 'completed',
        customerPhone: '+94 76 777 8888',
      ),
      BookingHistoryItem(
        id: '12',
        customerName: 'Amy Chen',
        courtName: 'Tennis Court 1',
        courtType: 'Tennis',
        date: now.subtract(Duration(days: 7)),
        startTime: '6:00 PM',
        endTime: '7:00 PM',
        duration: 60,
        price: 2000.0,
        status: 'completed',
        customerPhone: '+94 71 999 0000',
      ),

      // Future bookings
      BookingHistoryItem(
        id: '13',
        customerName: 'Tom Wilson',
        courtName: 'Football Court A',
        courtType: 'Football',
        date: now.add(Duration(days: 1)),
        startTime: '5:00 PM',
        endTime: '6:00 PM',
        duration: 60,
        price: 2500.0,
        status: 'confirmed',
        customerPhone: '+94 77 444 5555',
      ),
      BookingHistoryItem(
        id: '14',
        customerName: 'Rachel Green',
        courtName: 'Basketball Court B',
        courtType: 'Basketball',
        date: now.add(Duration(days: 2)),
        startTime: '7:00 PM',
        endTime: '8:30 PM',
        duration: 90,
        price: 3000.0,
        status: 'confirmed',
        customerPhone: '+94 75 666 7777',
      ),
      BookingHistoryItem(
        id: '15',
        customerName: 'Mark Johnson',
        courtName: 'Tennis Court 2',
        courtType: 'Tennis',
        date: now.add(Duration(days: 3)),
        startTime: '6:30 PM',
        endTime: '7:30 PM',
        duration: 60,
        price: 2000.0,
        status: 'pending',
        customerPhone: '+94 72 888 9999',
      ),
    ];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 10 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 10 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  // Future<void> _loadBookingHistory() async {
  //   // try {
  //   //   setState(() {
  //   //     _isLoading = true;
  //   //   });

  //   //   // Get all facilities first
  //   //   final facilities = await SupabaseService.getVendorFacilities();
  //   //   final List<BookingHistoryItem> loadedHistory = [];

  //   //   // Get bookings from all facilities
  //   //   for (final facility in facilities) {
  //   //     final facilityBookings = await SupabaseService.searchBookings(
  //   //       facilityId: facility['id'],
  //   //       limit: 100, // Get recent bookings
  //   //     );

  //   //     // Convert booking data to BookingHistoryItem
  //   //     for (final bookingData in facilityBookings) {
  //   //       try {
  //   //         final startTime = DateTime.parse(bookingData['start_time']);
  //   //         final endTime = DateTime.parse(bookingData['end_time']);

  //   //         loadedHistory.add(
  //   //           BookingHistoryItem(
  //   //             id: bookingData['id'] ?? '',
  //   //             customerName: bookingData['customer_name'] ?? 'Unknown Customer',
  //   //             courtName: bookingData['court_name'] ?? 'Unknown Court',
  //   //             courtType: bookingData['court_type'] ?? 'General',
  //   //             date: DateTime.parse(bookingData['booking_date']),
  //   //             startTime: DateFormat('h:mm a').format(startTime),
  //   //             endTime: DateFormat('h:mm a').format(endTime),
  //   //             duration: bookingData['duration'] ?? 60,
  //   //             price: (bookingData['price'] ?? 0.0).toDouble(),
  //   //             status: bookingData['status'] ?? 'confirmed',
  //   //             customerPhone: bookingData['customer_phone'] ?? 'N/A',
  //   //           ),
  //   //         );
  //   //       } catch (e) {
  //   //         // Skip malformed booking data
  //   //         print('Error parsing booking data: $e');
  //   //         continue;
  //   //       }
  //   //     }
  //   //   }

  //   //   // Sort by date (newest first)
  //   //   loadedHistory.sort((a, b) => b.date.compareTo(a.date));

  //   //   if (mounted) {
  //   //     setState(() {
  //   //       bookingHistory = loadedHistory;
  //   //       _isLoading = false;
  //   //     });
  //   //   }
  //   // } catch (e) {
  //   //   print('Error loading booking history: $e');
  //   //   if (mounted) {
  //   //     setState(() {
  //   //       // Fall back to empty list on error
  //   //       bookingHistory = [];
  //   //       _isLoading = false;
  //   //     });
  //   //   }
  //   // }
  // }

  @override
  Widget build(BuildContext context) {
    // if (_isLoading) {
    //   return const Scaffold(body: Center(child: FootballLoadingWidget()));
    // }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            elevation: _isScrolled ? 4 : 0,
            toolbarHeight: 50,
            floating: false,
            pinned: true,
            backgroundColor: primaryColor,
            centerTitle: false,
            title: const Text(
              "Booking Details",
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
                onPressed: () {
                  // Navigate to home page with no animation
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          home.HomeScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                tooltip: 'Back',
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildCalendarContent(),
                const SizedBox(height: 16),
                _buildHistoryContent(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: 0,
        onTabSelected: (int index) {
          if (index != 2) {
            // Home = 0, Favorites = 1, Bookings = 2, Chat = 3
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        home.HomeScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
                break;
              case 1:
                // Let the AppFooter handle navigation to favorites
                break;
              case 3:
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const MessagesScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
                break;
            }
          }
        },
      ),
    );
  }

  Widget _buildHistoryContent() {
    if (filteredBookings.isEmpty) {
      return _buildEmptyState();
    }

    return _buildBookingList();
  }

  List<BookingHistoryItem> get filteredBookings {
    return bookingHistory.where((booking) {
      return _isSameDay(booking.date, selectedDate);
    }).toList();
  }

  Widget _buildBookingList() {
    final filtered = filteredBookings;
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _buildSimpleBookingCard(filtered[index]);
      },
    );
  }

  Widget _buildSimpleBookingCard(BookingHistoryItem booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Court details above customer name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.courtName,
                  style: TextStyle(fontSize: 14, color: textSecondary),
                ),
                SizedBox(height: 2),
                Text(
                  booking.customerName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '${DateFormat('MMM d').format(booking.date)} • ${booking.startTime} - ${booking.endTime}',
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),
                SizedBox(height: 2),
                Text(
                  'Phone: ${booking.customerPhone}',
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ],
            ),
          ),
          // ...existing code for right side (price, icons)...
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'LKR ${booking.price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    margin: EdgeInsets.only(right: 4),
                    child: GestureDetector(
                      onTap: () => _makePhoneCall(booking.customerPhone),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 41, 107, 65),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.phone,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showBookingDetails(booking),
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Status box (right, below price, aligned with court details/time)
              if (booking.status.toLowerCase() != 'confirmed')
                Container(
                  margin: EdgeInsets.only(top: 6),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) {
    // Remove any formatting and ensure we have a valid number
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // For now, show a snackbar. In a real app, you would use url_launcher
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $cleanNumber...'),
        backgroundColor: darkGreenColor, // Changed to dark green
        duration: Duration(seconds: 2),
      ),
    );

    // Uncomment and add url_launcher dependency to actually make calls:
    // final url = 'tel:$cleanNumber';
    // if (await canLaunch(url)) {
    //   await launch(url);
    // }
  }

  void _showBookingDetails(BookingHistoryItem booking) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Booking Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Customer Information
                _buildDetailRow('Customer Name', booking.customerName),
                _buildDetailRow('Phone Number', booking.customerPhone),

                SizedBox(height: 16),

                // Court Information
                _buildDetailRow('Court Name', booking.courtName),
                _buildDetailRow('Court Type', booking.courtType),

                SizedBox(height: 16),

                // Booking Information
                _buildDetailRow(
                  'Date',
                  DateFormat('EEEE, MMM d, yyyy').format(booking.date),
                ),
                _buildDetailRow(
                  'Time',
                  '${booking.startTime} - ${booking.endTime}',
                ),
                _buildDetailRow('Duration', '${booking.duration} minutes'),
                _buildDetailRow('Status', booking.status.toUpperCase()),

                SizedBox(height: 16),

                // Price Information
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(fontSize: 14, color: textSecondary),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'LKR ${booking.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Action buttons in popup
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          _makePhoneCall(booking.customerPhone);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: darkGreenColor, // Changed to dark green
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.phone, size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Call Court',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isToday = _isSameDay(selectedDate, DateTime.now());
    final dateText = isToday
        ? 'today'
        : DateFormat('MMM d, yyyy').format(selectedDate);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              bookingHistory.isEmpty
                  ? 'No bookings yet'
                  : 'No bookings for $dateText',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              bookingHistory.isEmpty
                  ? 'Your booking history will appear here'
                  : 'Try selecting a different date',
              style: TextStyle(fontSize: 14, color: textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return successColor;
      case 'cancelled':
        return errorColor;
      case 'pending':
        return warningColor;
      default:
        return textSecondary;
    }
  }

  /// Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Updates the date view to the selected date
  void _updateDateView(DateTime newSelectedDate) {
    final selectedIndex = dateList.indexWhere(
      (date) => _isSameDay(date, newSelectedDate),
    );
    if (selectedIndex != -1) {
      final newStartIndex = (selectedIndex - 2).clamp(0, dateList.length - 5);
      setState(() {
        selectedDate = newSelectedDate;
        currentDateStartIndex = newStartIndex;
      });

      // Save to DateProvider for sharing with other screens
      // final dateProvider = Provider.of<DateProvider>(context, listen: false);
      // dateProvider.setDate(newSelectedDate);

      // No need to reload bookings - filtering will handle the display
    }
  }

  /// Builds the calendar grid with proper layout
  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    );
    final firstDayWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    List<Widget> dayWidgets = [];

    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstDayWeekday; i++) {
      dayWidgets.add(
        Expanded(child: Container(height: 36, margin: const EdgeInsets.all(2))),
      );
    }

    // Add day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(selectedDate.year, selectedDate.month, day);
      final isSelected = _isSameDay(date, selectedDate);
      final isToday = _isSameDay(date, DateTime.now());

      dayWidgets.add(
        Expanded(
          child: GestureDetector(
            onTap: () {
              _updateDateView(date);
            },
            child: Container(
              height: 36,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : null,
                shape: BoxShape.circle,
                border: isToday && !isSelected
                    ? Border.all(color: primaryColor, width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Colors.white
                        : isToday
                        ? primaryColor
                        : textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Build grid with 7 columns and proper spacing
    List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      final weekDays = dayWidgets.skip(i).take(7).toList();

      // Ensure we always have 7 items in each row
      while (weekDays.length < 7) {
        weekDays.add(
          Expanded(
            child: Container(height: 36, margin: const EdgeInsets.all(2)),
          ),
        );
      }

      rows.add(Row(children: weekDays));

      // Add spacing between rows except for the last row
      if (i + 7 < dayWidgets.length) {
        rows.add(const SizedBox(height: 4));
      }
    }

    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }

  /// Builds the date scroll and calendar content section (using bookings layout)
  Widget _buildCalendarContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with View Calendar button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // View Calendar button
              GestureDetector(
                onTap: () {
                  setState(() {
                    showCalendar = !showCalendar;
                  });
                },
                child: Text(
                  showCalendar ? 'Hide Calendar' : 'View Calendar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                    decoration: showCalendar ? TextDecoration.underline : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          showCalendar
              ? _buildCalendarContentExpanded()
              : _buildDateAndBookingsContent(),
        ],
      ),
    );
  }

  Widget _buildCalendarContentExpanded() {
    return Column(
      children: [
        // Calendar header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                final newDate = DateTime(
                  selectedDate.year,
                  selectedDate.month - 1,
                );
                _updateDateView(newDate);
              },
              icon: const Icon(Icons.chevron_left, color: primaryColor),
            ),
            Text(
              DateFormat('MMMM yyyy').format(selectedDate),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            IconButton(
              onPressed: () {
                final newDate = DateTime(
                  selectedDate.year,
                  selectedDate.month + 1,
                );
                _updateDateView(newDate);
              },
              icon: const Icon(Icons.chevron_right, color: primaryColor),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Week headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        // Calendar grid
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _buildCalendarGrid(),
        ),
      ],
    );
  }

  Widget _buildDateAndBookingsContent() {
    return Column(
      children: [
        // Date navigation
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (currentDateStartIndex > 0) {
                    currentDateStartIndex--;
                    selectedDate = dateList[currentDateStartIndex + 2];
                  }
                });
              },
              child: const Icon(
                Icons.chevron_left,
                color: primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int i = 0; i < 5; i++)
                    Flexible(child: _buildDateCircle(i)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  if (currentDateStartIndex + 5 < dateList.length) {
                    currentDateStartIndex++;
                    selectedDate = dateList[currentDateStartIndex + 2];
                  }
                });
              },
              child: const Icon(
                Icons.chevron_right,
                color: primaryColor,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Divider(color: Colors.grey[300], height: 1),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Builds individual date circle for the scroll section
  Widget _buildDateCircle(int index) {
    final dateIndex = currentDateStartIndex + index;
    if (dateIndex >= dateList.length) return const SizedBox();

    final date = dateList[dateIndex];
    final isSelected = _isSameDay(date, selectedDate);
    final isToday = _isSameDay(date, DateTime.now());
    final isPastDate = date.isBefore(
      DateTime.now()
          .subtract(Duration(days: 0))
          .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0),
    );

    return GestureDetector(
      onTap: () {
        _updateDateView(date);
      },
      child: Container(
        constraints: const BoxConstraints(minWidth: 48, maxWidth: 64),
        width: isSelected ? 60 : 48,
        height: isSelected ? 60 : 48,
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.grey[200],
          shape: BoxShape.circle,
          border: isToday && !isSelected
              ? Border.all(color: primaryColor, width: 2)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            DateFormat('d').format(date),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.white
                  : isPastDate
                  ? Colors.grey
                  : textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Simplified data model for booking history items
class BookingHistoryItem {
  final String id;
  final String customerName;
  final String courtName;
  final String courtType;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int duration;
  final double price;
  final String status;
  final String customerPhone;

  BookingHistoryItem({
    required this.id,
    required this.customerName,
    required this.courtName,
    required this.courtType,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.price,
    required this.status,
    required this.customerPhone,
  });
}
