// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../customers/footer.dart';
import 'home.dart' as home;
import 'messages.dart';
import 'widgets/football_spinner.dart'; // Add this import

/// Simplified History Screen with user-friendly design
class HistoryScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  HistoryScreenState createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // Date scroll and calendar state
  DateTime selectedDate = DateTime.now();
  bool showCalendar = false;
  bool showAllBookings = false; // Add this new state variable
  late List<DateTime> dateList;
  int currentDateStartIndex = 5; // Place the current date in the middle

  List<BookingHistoryItem> bookingHistory = [];

  // Simplified color scheme
  static const Color primaryColor = Color(0xFF1B2C4F);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color successColor = Color(0xFF10B981);
  static const Color darkGreenColor = Color(0xFF065F46); // Added dark green
  static const Color callColor = Color(
    0xFF065F46,
  ); // Darker green color for call button
  static const Color errorColor = Color(0xFFB91C1C); // Much darker red color
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _initializeDateList();
    _scrollController.addListener(_onScroll);
    
    // Initialize data immediately without delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  // Match home.dart initialization pattern exactly
  Future<void> _initializeData() async {
    // Quick initialization for history screen (200ms) - same as home
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (mounted) {
      // Load mock data first
      _initializeMockData();
      
      // Then set loading to false
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeDateList() {
    dateList = [];
    final today = DateTime.now();
    // Include past, current, and future dates, with today centered
    for (int i = -7; i <= 30; i++) {
      dateList.add(today.add(Duration(days: i)));
    }
  }

  // Move mock data initialization to be called before loading completes
  void _initializeMockData() {
    final now = DateTime.now();
    bookingHistory = [
      // Today's bookings - from player perspective
      BookingHistoryItem(
        id: '1',
        courtName: 'Football Court A',
        courtType: 'Football',
        facilityName: 'CR7 Arena',
        date: now,
        startTime: '6:00 PM',
        endTime: '7:00 PM',
        duration: 60,
        price: 2500.0,
        status: 'confirmed',
      ),
      BookingHistoryItem(
        id: '2',
        courtName: 'Basketball Court B',
        courtType: 'Basketball',
        facilityName: 'Champion\'s Arena',
        date: now,
        startTime: '4:00 PM',
        endTime: '5:30 PM',
        duration: 90,
        price: 3000.0,
        status: 'confirmed',
      ),
      BookingHistoryItem(
        id: '3',
        courtName: 'Tennis Court 1',
        courtType: 'Tennis',
        facilityName: 'Colombo Tennis Club',
        date: now,
        startTime: '8:00 PM',
        endTime: '9:00 PM',
        duration: 60,
        price: 2000.0,
        status: 'completed',
      ),

      // Yesterday's bookings
      BookingHistoryItem(
        id: '4',
        courtName: 'Football Court B',
        courtType: 'Football',
        facilityName: 'Sports Complex Central',
        date: now.subtract(Duration(days: 1)),
        startTime: '5:00 PM',
        endTime: '6:30 PM',
        duration: 90,
        price: 3500.0,
        status: 'completed',
      ),
      BookingHistoryItem(
        id: '5',
        courtName: 'Badminton Court A',
        courtType: 'Badminton',
        facilityName: 'Metro Sports Club',
        date: now.subtract(Duration(days: 1)),
        startTime: '7:00 PM',
        endTime: '8:00 PM',
        duration: 60,
        price: 1500.0,
        status: 'completed',
      ),
      BookingHistoryItem(
        id: '6',
        courtName: 'Football Court A',
        courtType: 'Football',
        facilityName: 'CR7 Arena',
        date: now.subtract(Duration(days: 1)),
        startTime: '3:00 PM',
        endTime: '4:00 PM',
        duration: 60,
        price: 2500.0,
        status: 'cancelled',
      ),

      // Two days ago
      BookingHistoryItem(
        id: '7',
        courtName: 'Tennis Court 2',
        courtType: 'Tennis',
        facilityName: 'Colombo Tennis Club',
        date: now.subtract(Duration(days: 2)),
        startTime: '6:30 PM',
        endTime: '7:30 PM',
        duration: 60,
        price: 2000.0,
        status: 'completed',
      ),
      BookingHistoryItem(
        id: '8',
        courtName: 'Basketball Court A',
        courtType: 'Basketball',
        facilityName: 'Champion\'s Arena',
        date: now.subtract(Duration(days: 2)),
        startTime: '8:00 PM',
        endTime: '9:30 PM',
        duration: 90,
        price: 3000.0,
        status: 'completed',
      ),

      // Three days ago
      BookingHistoryItem(
        id: '9',
        courtName: 'Football Court C',
        courtType: 'Football',
        facilityName: 'Elite Sports Arena',
        date: now.subtract(Duration(days: 3)),
        startTime: '4:30 PM',
        endTime: '6:00 PM',
        duration: 90,
        price: 3500.0,
        status: 'completed',
      ),
      BookingHistoryItem(
        id: '10',
        courtName: 'Volleyball Court A',
        courtType: 'Volleyball',
        facilityName: 'Volleyball Center',
        date: now.subtract(Duration(days: 3)),
        startTime: '7:00 PM',
        endTime: '8:30 PM',
        duration: 90,
        price: 2800.0,
        status: 'completed',
      ),

      // A week ago
      BookingHistoryItem(
        id: '11',
        courtName: 'Badminton Court B',
        courtType: 'Badminton',
        facilityName: 'Metro Sports Club',
        date: now.subtract(Duration(days: 7)),
        startTime: '5:30 PM',
        endTime: '6:30 PM',
        duration: 60,
        price: 1500.0,
        status: 'completed',
      ),
      BookingHistoryItem(
        id: '12',
        courtName: 'Tennis Court 1',
        courtType: 'Tennis',
        facilityName: 'Colombo Tennis Club',
        date: now.subtract(Duration(days: 7)),
        startTime: '6:00 PM',
        endTime: '7:00 PM',
        duration: 60,
        price: 2000.0,
        status: 'completed',
      ),

      // Future bookings
      BookingHistoryItem(
        id: '13',
        courtName: 'Football Court A',
        courtType: 'Football',
        facilityName: 'CR7 Arena',
        date: now.add(Duration(days: 1)),
        startTime: '5:00 PM',
        endTime: '6:00 PM',
        duration: 60,
        price: 2500.0,
        status: 'confirmed',
      ),
      BookingHistoryItem(
        id: '14',
        courtName: 'Basketball Court B',
        courtType: 'Basketball',
        facilityName: 'Champion\'s Arena',
        date: now.add(Duration(days: 2)),
        startTime: '7:00 PM',
        endTime: '8:30 PM',
        duration: 90,
        price: 3000.0,
        status: 'confirmed',
      ),
      BookingHistoryItem(
        id: '15',
        courtName: 'Tennis Court 2',
        courtType: 'Tennis',
        facilityName: 'Colombo Tennis Club',
        date: now.add(Duration(days: 3)),
        startTime: '6:30 PM',
        endTime: '7:30 PM',
        duration: 60,
        price: 2000.0,
        status: 'pending',
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA), // Match the background color
        body: Center(child: FootballLoadingWidget())
      );
    }

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
                  // Simply pop back - no complex logic needed
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                tooltip: 'Back',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Show calendar content only when not in "view all" mode
                if (!showAllBookings) _buildCalendarContent(),
                // Show just the "View All" button when in "view all" mode
                if (showAllBookings) _buildViewAllButton(),
                const SizedBox(height: 16),
                _buildHistoryContent(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: 2,
        onTabSelected: (int index) {
          // Let the AppFooter handle all navigation
          // Remove the complex switch logic and just let footer handle it
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
    if (showAllBookings) {
      // Show all bookings sorted by date (newest first)
      return bookingHistory..sort((a, b) => b.date.compareTo(a.date));
    }
    return bookingHistory.where((booking) {
      return _isSameDay(booking.date, selectedDate);
    }).toList();
  }

  Widget _buildBookingList() {
    final filtered = filteredBookings;
    
    return Column(
      children: [
        // Show selected date info when not in "view all" mode
        if (!showAllBookings) ...[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: primaryColor, size: 16),
                SizedBox(width: 8),
                Text(
                  'Bookings for ${DateFormat('EEEE, MMM d, yyyy').format(selectedDate)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
                Spacer(),
                Text(
                  '${filtered.length} booking${filtered.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
        
        // Show total count when in "view all" mode
        if (showAllBookings) ...[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.list_alt, color: successColor, size: 16),
                SizedBox(width: 8),
                Text(
                  'All Bookings',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: successColor,
                  ),
                ),
                Spacer(),
                Text(
                  '${filtered.length} total booking${filtered.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],

        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return _buildEnhancedBookingCard(filtered[index]);
          },
        ),
      ],
    );
  }

  Widget _buildEnhancedBookingCard(BookingHistoryItem booking) {
    final isToday = _isSameDay(booking.date, DateTime.now());
    final isFuture = booking.date.isAfter(DateTime.now());
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Court details and facility name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.courtName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      booking.facilityName,
                      style: TextStyle(fontSize: 14, color: textSecondary),
                    ),
                    SizedBox(height: 4),
                    // Enhanced date/time display for "view all" mode
                    if (showAllBookings) ...[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isToday 
                            ? primaryColor.withOpacity(0.1)
                            : isFuture 
                              ? successColor.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isToday 
                            ? 'Today • ${booking.startTime} - ${booking.endTime}'
                            : '${DateFormat('MMM d, yyyy').format(booking.date)} • ${booking.startTime} - ${booking.endTime}',
                          style: TextStyle(
                            fontSize: 12, 
                            color: isToday 
                              ? primaryColor
                              : isFuture 
                                ? successColor
                                : textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ] else ...[
                      Text(
                        '${DateFormat('MMM d').format(booking.date)} • ${booking.startTime} - ${booking.endTime}',
                        style: TextStyle(fontSize: 13, color: textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              // Right: Price and action buttons
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
                      // Call button
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => _makeCall(booking),
                          child: Container(
                            decoration: BoxDecoration(
                              color: callColor,
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
                      SizedBox(width: 8),
                      // Details button
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
                  // Status badge
                  if (booking.status.toLowerCase() != 'confirmed') ...[
                    SizedBox(height: 6),
                    Container(
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
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(BookingHistoryItem booking) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Booking Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(Icons.close, size: 24, color: textSecondary),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Booking ID
                _buildDetailRow('Booking ID', booking.id),

                // Court and facility info
                _buildDetailRow('Court', booking.courtName),
                _buildDetailRow('Court Type', booking.courtType),
                _buildDetailRow('Facility', booking.facilityName),

                SizedBox(height: 12),

                // Date and time details
                _buildDetailRow(
                  'Date',
                  DateFormat('EEEE, MMM d, yyyy').format(booking.date),
                ),
                _buildDetailRow('Start Time', booking.startTime),
                _buildDetailRow('End Time', booking.endTime),
                _buildDetailRow('Duration', '${booking.duration} minutes'),

                SizedBox(height: 12),

                // Status and price
                _buildDetailRow('Status', booking.status.toUpperCase()),
                _buildDetailRow(
                  'Total Amount',
                  'LKR ${booking.price.toStringAsFixed(0)}',
                ),

                SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    // Cancel booking button (only show for confirmed/pending bookings)
                    if (booking.status.toLowerCase() == 'confirmed' ||
                        booking.status.toLowerCase() == 'pending')
                      Expanded(
                        child: Container(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showCancelConfirmation(booking);
                            },
                            child: Text(
                              'Cancel Booking',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: errorColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Add spacing if cancel button exists
                    if (booking.status.toLowerCase() == 'confirmed' ||
                        booking.status.toLowerCase() == 'pending')
                      SizedBox(width: 12),

                    // Close button
                    Expanded(
                      child: Container(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryColor, width: 1.5),
                            foregroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
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

  void _showCancelConfirmation(BookingHistoryItem booking) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: warningColor,
                ),
                SizedBox(height: 16),
                Text(
                  'Cancel Booking',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Are you sure you want to cancel this booking?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: textSecondary),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.courtName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '${DateFormat('MMM d, yyyy').format(booking.date)} • ${booking.startTime} - ${booking.endTime}',
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'This action cannot be undone. Refund policies may apply.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.grey[400]!,
                              width: 1.5,
                            ),
                            foregroundColor: textSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Keep Booking',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _cancelBooking(booking);
                          },
                          label: Text(
                            'Yes, Cancel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: errorColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
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

  void _cancelBooking(BookingHistoryItem booking) {
    // Find the booking in the list and update its status
    setState(() {
      final index = bookingHistory.indexWhere((b) => b.id == booking.id);
      if (index != -1) {
        // Create a new booking item with cancelled status
        bookingHistory[index] = BookingHistoryItem(
          id: booking.id,
          courtName: booking.courtName,
          courtType: booking.courtType,
          facilityName: booking.facilityName,
          date: booking.date,
          startTime: booking.startTime,
          endTime: booking.endTime,
          duration: booking.duration,
          price: booking.price,
          status: 'cancelled',
        );
      }
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking cancelled successfully'),
        backgroundColor: successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    // In a real app, you would also make an API call here to cancel the booking
    // await SupabaseService.cancelBooking(booking.id);
  }

  void _makeCall(BookingHistoryItem booking) {
    // For now, show a simple dialog. In a real app, you would use url_launcher
    // to make an actual phone call: launch('tel:+1234567890')
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone, size: 48, color: callColor),
                SizedBox(height: 16),
                Text(
                  'Contact Facility',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  booking.facilityName,
                  style: TextStyle(fontSize: 16, color: textSecondary),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Here you would implement the actual call functionality
                        // For example: launch('tel:+1234567890')
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: callColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Call Now'),
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
              showAllBookings
                  ? 'No bookings yet'
                  : bookingHistory.isEmpty
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
              showAllBookings
                  ? 'Your booking history will appear here'
                  : bookingHistory.isEmpty
                      ? 'Your booking history will appear here'
                      : 'Try selecting a different date or view all bookings',
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
          // Header row with View Calendar and View All buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // View All button
              GestureDetector(
                onTap: () {
                  setState(() {
                    showAllBookings = !showAllBookings;
                    if (showAllBookings) {
                      showCalendar = false; // Hide calendar when viewing all
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: showAllBookings 
                      ? primaryColor 
                      : primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    showAllBookings ? 'View by Date' : 'View All',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: showAllBookings 
                        ? Colors.white 
                        : primaryColor,
                    ),
                  ),
                ),
              ),

              // View Calendar button (only show when not in view all mode)
              if (!showAllBookings)
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

          // Show different content based on the current mode
          if (showAllBookings)
            _buildViewAllContent()
          else if (showCalendar)
            _buildCalendarContentExpanded()
          else
            _buildDateAndBookingsContent(),
        ],
      ),
    );
  }

  Widget _buildViewAllContent() {
    return Column(
      children: [
        SizedBox(height: 24),
        Divider(color: Colors.grey[300], height: 1),
        SizedBox(height: 24),
      ],
    );
  }

  /// Builds the calendar header and grid for expanded view
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

  Widget _buildViewAllButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                showAllBookings = false;
                showCalendar = false;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'View by Date',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
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

/// Simplified data model for booking history items (player-focused)
class BookingHistoryItem {
  final String id;
  final String courtName;
  final String courtType;
  final String facilityName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int duration;
  final double price;
  final String status;

  BookingHistoryItem({
    required this.id,
    required this.courtName,
    required this.courtType,
    required this.facilityName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.price,
    required this.status,
  });
}