// ignore_for_file: deprecated_member_use, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'footer.dart';
import 'proceedToPayment.dart';

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
      home: const SportsVenueScreen(),
    );
  }
}

class SportsVenueScreen extends StatefulWidget {
  const SportsVenueScreen({super.key});

  @override
  State<SportsVenueScreen> createState() => _SportsVenueScreenState();
}

class _SportsVenueScreenState extends State<SportsVenueScreen> {
  int _currentIndex = 0; // Set to 0 for default tab

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2C4F),
        elevation: 0,
        toolbarHeight: 50.0,
        title: const Text(
          "Book Now",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        centerTitle: false,
        leading: Container(
          margin: const EdgeInsets.fromLTRB(16, 3, 8, 8),
          child: IconButton(
            icon: const Icon(
              Icons.chevron_left,
              color: Color.fromARGB(255, 255, 255, 255),
              size: 28,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        actions: [],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const VenueSelectionSection(),
                  const SizedBox(height: 20),
                  const BookingSection(),
                  const SizedBox(height: 20),
                  const PricingSummarySection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}

class VenueSelectionSection extends StatelessWidget {
  const VenueSelectionSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Only keeping the selected venue (CR7 Futsal Arena)
    final venue = {
      'name': 'CR7 Futsal Arena',
      'location': 'Downtown, 2.5 km',
      'isSelected': true,
      'image': 'assets/venue1.jpg',
      'rating': 4.8,
      'price': 'LKR 700/hr',
    };

    return Container(
      padding: const EdgeInsets.all(16),
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
          // Header with title and check icon
          Row(
            children: [
              const Text(
                'Selected Venue',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Display only the selected venue with modern card design
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1B2C4F).withOpacity(0.05),
                  const Color(0xFF1B2C4F).withOpacity(0.15),
                ],
              ),
            ),
            child: Row(
              children: [
                // Venue image/icon with updated styling
                Container(
                  height: 60,
                  width: 60,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.sports_soccer,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Venue details with improved layout
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            venue['name'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B2C4F),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B2C4F),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              venue['price'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Location and rating in a row
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            venue['location'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${venue['rating']}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),

                      // Amenities row
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildAmenityTag('5 vs 5'),
                          const SizedBox(width: 8),
                          _buildAmenityTag('Indoor'),
                          const SizedBox(width: 8),
                          _buildAmenityTag('Parking'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create amenity tags
  Widget _buildAmenityTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}

class BookingSection extends StatefulWidget {
  const BookingSection({super.key});

  @override
  _BookingSectionState createState() => _BookingSectionState();
}

class _BookingSectionState extends State<BookingSection>
    with SingleTickerProviderStateMixin {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int _numberOfPlayers = 1;
  DateTime _displayedMonth = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Theme colors
  final Color _themeNavyBlue = const Color(0xFF1B2C4F);
  final Color _themeLightNavyBlue = const Color(
    0xFFF0F4FF,
  ); // Very light navy blue for selection background
  final Color _themeLightGrey = Colors.grey.shade100;

  // Mock data: List of fully booked dates
  final List<DateTime> _fullyBookedDates = [
    DateTime.now().add(const Duration(days: 2)),
    DateTime.now().add(const Duration(days: 5)),
    DateTime.now().add(const Duration(days: 7)),
    DateTime.now().add(const Duration(days: 12)),
    DateTime.now().add(const Duration(days: 15)),
    DateTime.now().add(const Duration(days: 20)),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Check if a date is fully booked
  bool _isDateFullyBooked(DateTime date) {
    return _fullyBookedDates.any(
      (bookedDate) =>
          bookedDate.year == date.year &&
          bookedDate.month == date.month &&
          bookedDate.day == date.day,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    _animationController.reset();
    // Show a custom calendar dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        _animationController.forward();
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with title and close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Reduced font size from 18 to 15
                        const Text(
                          'Select Date',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B2C4F),
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 20,
                              color: Color(0xFF1B2C4F),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Calendar
                    SizedBox(
                      height: 360,
                      width: double.maxFinite,
                      child: StatefulBuilder(
                        builder: (context, setDialogState) {
                          return Column(
                            children: [
                              // Month navigation
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF1B2C4F,
                                  ).withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setDialogState(() {
                                          _displayedMonth = DateTime(
                                            _displayedMonth.year,
                                            _displayedMonth.month - 1,
                                            1,
                                          );
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.chevron_left,
                                          size: 24,
                                          color: Color(0xFF1B2C4F),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      DateFormat(
                                        'MMMM yyyy',
                                      ).format(_displayedMonth),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B2C4F),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setDialogState(() {
                                          _displayedMonth = DateTime(
                                            _displayedMonth.year,
                                            _displayedMonth.month + 1,
                                            1,
                                          );
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.chevron_right,
                                          size: 24,
                                          color: Color(0xFF1B2C4F),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Weekday headers
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: const [
                                    _WeekdayLabel('S'),
                                    _WeekdayLabel('M'),
                                    _WeekdayLabel('T'),
                                    _WeekdayLabel('W'),
                                    _WeekdayLabel('T'),
                                    _WeekdayLabel('F'),
                                    _WeekdayLabel('S'),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Calendar grid
                              Expanded(
                                child: _buildCalendarGrid(
                                  _displayedMonth,
                                  setDialogState,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Legend
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildLegendItem(Colors.grey.shade600, 'Available'),
                          _buildLegendItem(Colors.red, 'Fully Booked'),
                          _buildLegendItem(const Color(0xFF1B2C4F), 'Selected'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Select button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(_selectedDate);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B2C4F),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Select Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedDate = value;
        });
      }
    });
  }

  // Helper method to build the legend item
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: label == 'Fully Booked'
                ? Colors.red.shade50
                : label == 'Selected'
                ? const Color(0xFF1B2C4F)
                : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: label == 'Selected' ? 0 : 1,
            ),
          ),
          child: label != 'Selected'
              ? Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Build the calendar grid
  Widget _buildCalendarGrid(DateTime month, StateSetter setDialogState) {
    // Get the first day of the month
    final firstDayOfMonth = DateTime(month.year, month.month, 1);

    // Calculate the number of days in the month
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    // Calculate the day of week for the first day (0 = Sunday, 6 = Saturday)
    final firstWeekdayOfMonth = firstDayOfMonth.weekday % 7;

    // Calculate the total number of cells needed (days + empty cells)
    final totalCells = firstWeekdayOfMonth + daysInMonth;
    final totalRows = (totalCells / 7).ceil();

    // Create a list to hold all dates for the grid
    final List<DateTime?> calendarDays = List.filled(totalRows * 7, null);

    // Fill in the days of the current month
    for (int i = 0; i < daysInMonth; i++) {
      calendarDays[firstWeekdayOfMonth + i] = DateTime(
        month.year,
        month.month,
        i + 1,
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: calendarDays.length,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemBuilder: (context, index) {
        final date = calendarDays[index];

        if (date == null) {
          // Empty cell
          return const SizedBox();
        }

        final isFullyBooked = _isDateFullyBooked(date);
        final isSelected =
            _selectedDate != null &&
            _selectedDate!.year == date.year &&
            _selectedDate!.month == date.month &&
            _selectedDate!.day == date.day;

        // Check if date is before today
        final isBeforeToday =
            date.isBefore(DateTime.now()) &&
            !(date.day == DateTime.now().day &&
                date.month == DateTime.now().month &&
                date.year == DateTime.now().year);

        final isToday =
            date.day == DateTime.now().day &&
            date.month == DateTime.now().month &&
            date.year == DateTime.now().year;

        if (isBeforeToday) {
          // Past date - show as disabled
          return Center(
            child: Text(
              date.day.toString(),
              style: TextStyle(color: Colors.grey.shade300, fontSize: 14),
            ),
          );
        }

        // Custom styling for different date states
        return InkWell(
          onTap: isFullyBooked
              ? null
              : () {
                  setDialogState(() {
                    _selectedDate = date;
                  });
                },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? _themeNavyBlue
                  : isFullyBooked
                  ? Colors.red.shade50
                  : isToday
                  ? _themeLightNavyBlue.withOpacity(0.4)
                  : Colors.transparent,
              border: isSelected || isFullyBooked
                  ? null
                  : isToday
                  ? Border.all(
                      color: _themeNavyBlue.withOpacity(0.5),
                      width: 1.5,
                    )
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _themeNavyBlue.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                date.day.toString(),
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isFullyBooked
                      ? Colors.red.shade400
                      : isToday
                      ? _themeNavyBlue
                      : Colors.grey.shade700,
                  fontWeight: isSelected || isToday
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectStartTime(BuildContext context) async {
    _animationController.reset();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        _animationController.forward();
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FractionallySizedBox(
              heightFactor: 0.6 * _animationController.value,
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag indicator
                const SizedBox(height: 10),

                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Reduced font size from 16 to 14
                    const Text(
                      'Select Start Time',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2C4F),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Time slots grid
                Expanded(child: _buildTimeSlotGrid(context, true)),

                const SizedBox(height: 16),
                // Note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _themeLightNavyBlue,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _themeNavyBlue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: _themeNavyBlue, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Available time slots are shown with light background',
                          style: TextStyle(fontSize: 12, color: _themeNavyBlue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectEndTime(BuildContext context) async {
    _animationController.reset();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        _animationController.forward();
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FractionallySizedBox(
              heightFactor: 0.6 * _animationController.value,
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag indicator
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Reduced font size from 18 to 14
                    const Text(
                      'Select End Time',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2C4F),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Time slots grid
                Expanded(child: _buildTimeSlotGrid(context, false)),

                const SizedBox(height: 16),
                // Note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _themeLightNavyBlue,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _themeNavyBlue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: _themeNavyBlue, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'End time should be after start time: ${_startTime?.format(context) ?? 'Not selected'}',
                          style: TextStyle(fontSize: 12, color: _themeNavyBlue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeSlotGrid(BuildContext context, bool isStartTime) {
    // Generate a list of times from 8 AM to 10 PM
    final List<TimeOfDay> times = [];
    for (int hour = 8; hour <= 22; hour++) {
      times.add(TimeOfDay(hour: hour, minute: 0));
      if (hour < 22) {
        times.add(TimeOfDay(hour: hour, minute: 30));
      }
    }

    // Mock unavailable time slots
    final List<TimeOfDay> unavailableTimes = [
      const TimeOfDay(hour: 10, minute: 0),
      const TimeOfDay(hour: 10, minute: 30),
      const TimeOfDay(hour: 11, minute: 0),
      const TimeOfDay(hour: 14, minute: 30),
      const TimeOfDay(hour: 15, minute: 0),
      const TimeOfDay(hour: 19, minute: 0),
      const TimeOfDay(hour: 19, minute: 30),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: times.length,
      itemBuilder: (context, index) {
        final time = times[index];
        final isUnavailable = unavailableTimes.any(
          (t) => t.hour == time.hour && t.minute == time.minute,
        );

        final isSelected = isStartTime
            ? _startTime != null &&
                  _startTime!.hour == time.hour &&
                  _startTime!.minute == time.minute
            : _endTime != null &&
                  _endTime!.hour == time.hour &&
                  _endTime!.minute == time.minute;

        // For end time selection, disable times before start time
        final isDisabled =
            !isStartTime &&
            _startTime != null &&
            (time.hour < _startTime!.hour ||
                (time.hour == _startTime!.hour &&
                    time.minute <= _startTime!.minute));

        return InkWell(
          onTap: (isUnavailable || isDisabled)
              ? null
              : () {
                  setState(() {
                    if (isStartTime) {
                      _startTime = time;
                    } else {
                      _endTime = time;
                    }
                  });
                  Navigator.of(context).pop();
                },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? _themeNavyBlue
                  : isUnavailable || isDisabled
                  ? Colors.grey.shade200
                  : _themeLightNavyBlue,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? null
                  : Border.all(
                      color: isUnavailable || isDisabled
                          ? Colors.grey.shade300
                          : _themeNavyBlue.withOpacity(0.3),
                    ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _themeNavyBlue.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: isSelected
                      ? Colors.white
                      : isUnavailable || isDisabled
                      ? Colors.grey.shade500
                      : _themeNavyBlue,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimeOfDay(time),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? Colors.white
                        : isUnavailable || isDisabled
                        ? Colors.grey.shade500
                        : _themeNavyBlue,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _checkAvailability() {
    if (_selectedDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              const Text('Please fill in all booking details'),
            ],
          ),
          backgroundColor: const Color(0xFF1B2C4F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // Mock data for unavailable time slots
    final List<Map<String, TimeOfDay>> unavailableTimes = [
      {
        'start': const TimeOfDay(hour: 10, minute: 0),
        'end': const TimeOfDay(hour: 12, minute: 0),
      },
      {
        'start': const TimeOfDay(hour: 14, minute: 0),
        'end': const TimeOfDay(hour: 16, minute: 0),
      },
      {
        'start': const TimeOfDay(hour: 18, minute: 0),
        'end': const TimeOfDay(hour: 20, minute: 0),
      },
    ];

    // Mock data for alternative available time slots
    final List<Map<String, TimeOfDay>> availableTimes = [
      {
        'start': const TimeOfDay(hour: 8, minute: 0),
        'end': const TimeOfDay(hour: 10, minute: 0),
      },
      {
        'start': const TimeOfDay(hour: 12, minute: 0),
        'end': const TimeOfDay(hour: 14, minute: 0),
      },
      {
        'start': const TimeOfDay(hour: 16, minute: 0),
        'end': const TimeOfDay(hour: 18, minute: 0),
      },
      {
        'start': const TimeOfDay(hour: 20, minute: 0),
        'end': const TimeOfDay(hour: 22, minute: 0),
      },
    ];

    // Check if selected time slot conflicts with unavailable times
    bool isTimeSlotAvailable = true;
    for (var slot in unavailableTimes) {
      // Convert TimeOfDay to minutes for easier comparison
      int selectedStartMinutes = _startTime!.hour * 60 + _startTime!.minute;
      int selectedEndMinutes = _endTime!.hour * 60 + _endTime!.minute;
      int slotStartMinutes = slot['start']!.hour * 60 + slot['start']!.minute;
      int slotEndMinutes = slot['end']!.hour * 60 + slot['end']!.minute;

      // Check for overlap
      if ((selectedStartMinutes >= slotStartMinutes &&
              selectedStartMinutes < slotEndMinutes) ||
          (selectedEndMinutes > slotStartMinutes &&
              selectedEndMinutes <= slotEndMinutes) ||
          (selectedStartMinutes <= slotStartMinutes &&
              selectedEndMinutes >= slotEndMinutes)) {
        isTimeSlotAvailable = false;
        break;
      }
    }

    _animationController.reset();

    if (isTimeSlotAvailable) {
      // Selected time slot is available - show custom themed dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          _animationController.forward();
          return ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Updated: Success icon with new styling
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Slot Available!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2C4F),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Great! Your selected time slot is available.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Booking summary
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _themeLightNavyBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildBookingDetailRowStyled(
                            Icons.calendar_today_outlined,
                            'Date',
                            DateFormat('dd MMM yyyy').format(_selectedDate!),
                            Colors.blue,
                          ),
                          const SizedBox(height: 14),
                          _buildBookingDetailRowStyled(
                            Icons.access_time_outlined,
                            'Time',
                            '${_startTime!.format(context)} - ${_endTime!.format(context)}',
                            Colors.orange,
                          ),
                          const SizedBox(height: 14),
                          _buildBookingDetailRowStyled(
                            Icons.people_outline,
                            'Players',
                            _numberOfPlayers.toString(),
                            Colors.purple,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade400),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              // Add logic here to proceed to next step
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B2C4F),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Confirm Booking',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      // Selected time slot is not available, show alternatives with custom dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          _animationController.forward();
          return ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Updated: Error icon with new styling
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.schedule,
                        color: Colors.red,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Slot Unavailable',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2C4F),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sorry, the slot from ${_startTime!.format(context)} to ${_endTime!.format(context)} is not available.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.red.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Available slots
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _themeLightNavyBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Updated icon style
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _themeNavyBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.event_available,
                                  color: _themeNavyBlue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Available time slots',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _themeNavyBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 180,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: availableTimes.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      // Update the selected time slot
                                      setState(() {
                                        _startTime =
                                            availableTimes[index]['start'];
                                        _endTime = availableTimes[index]['end'];
                                      });
                                      Navigator.of(context).pop();

                                      // Show confirmation of the new selection
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Selected time: ${_startTime!.format(context)} - ${_endTime!.format(context)}',
                                              ),
                                            ],
                                          ),
                                          backgroundColor:
                                              Colors.green.shade600,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          margin: const EdgeInsets.all(16),
                                        ),
                                      );
                                    },
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    title: Row(
                                      children: [
                                        // Updated time icon style
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: _themeNavyBlue.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: _themeNavyBlue,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${availableTimes[index]['start']!.format(context)} - ${availableTimes[index]['end']!.format(context)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: _themeNavyBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _themeNavyBlue,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'Select',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Close button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  // Helper method to build detail rows for the booking summary with improved styling
  Widget _buildBookingDetailRowStyled(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      children: [
        // Updated icon style to match email notifications
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B2C4F),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _resetForm() {
    setState(() {
      _selectedDate = null;
      _startTime = null;
      _endTime = null;
      _numberOfPlayers = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Booking Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 24),

          // Date Selection
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ), // Reduced vertical padding
              decoration: BoxDecoration(
                color: _selectedDate != null
                    ? _themeLightNavyBlue
                    : _themeLightGrey,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _selectedDate != null
                      ? _themeNavyBlue.withOpacity(0.3)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Updated icon style with smaller size
                  Container(
                    padding: const EdgeInsets.all(6), // Reduced padding
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.blue,
                      size: 18, // Reduced size
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Removed SizedBox height
                        Text(
                          _selectedDate == null
                              ? 'Select Date'
                              : DateFormat(
                                  'EEEE, dd MMMM yyyy',
                                ).format(_selectedDate!),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: _selectedDate != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: _selectedDate != null
                                ? const Color(0xFF1B2C4F)
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade500,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Start Time Selection
          GestureDetector(
            onTap: () => _selectStartTime(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ), // Reduced vertical padding
              decoration: BoxDecoration(
                color: _startTime != null
                    ? _themeLightNavyBlue
                    : _themeLightGrey,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _startTime != null
                      ? _themeNavyBlue.withOpacity(0.3)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Updated icon style with smaller size
                  Container(
                    padding: const EdgeInsets.all(6), // Reduced padding
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.access_time_outlined,
                      color: Colors.orange,
                      size: 18, // Reduced size
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Removed SizedBox height
                        Text(
                          _startTime == null
                              ? 'Select Start Time'
                              : _startTime!.format(context),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: _startTime != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: _startTime != null
                                ? const Color(0xFF1B2C4F)
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade500,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // End Time Selection
          GestureDetector(
            onTap: () => _selectEndTime(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ), // Reduced vertical padding
              decoration: BoxDecoration(
                color: _endTime != null ? _themeLightNavyBlue : _themeLightGrey,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _endTime != null
                      ? _themeNavyBlue.withOpacity(0.3)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Updated icon style with smaller size
                  Container(
                    padding: const EdgeInsets.all(6), // Reduced padding
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.access_time_outlined,
                      color: Colors.green,
                      size: 18, // Reduced size
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Removed SizedBox height
                        Text(
                          _endTime == null
                              ? 'Select End Time'
                              : _endTime!.format(context),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: _endTime != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: _endTime != null
                                ? const Color(0xFF1B2C4F)
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade500,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Number of Players
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ), // Reduced vertical padding
            decoration: BoxDecoration(
              color: _themeLightGrey,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            child: Row(
              children: [
                // Updated icon style with smaller size
                Container(
                  padding: const EdgeInsets.all(6), // Reduced padding
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.people_outline,
                    color: Colors.purple,
                    size: 18, // Reduced size
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Players',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                      Material(
                        color: Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (_numberOfPlayers > 1) _numberOfPlayers--;
                            });
                          },
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: const Icon(
                              Icons.remove,
                              size: 16,
                              color: Color(0xFF1B2C4F),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '$_numberOfPlayers',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B2C4F),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (_numberOfPlayers < 10) _numberOfPlayers++;
                            });
                          },
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: const Icon(
                              Icons.add,
                              size: 16,
                              color: Color(0xFF1B2C4F),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Check Availability Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _checkAvailability,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B2C4F),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  const Text(
                    'Check Availability',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Reset Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _resetForm,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 8),
                  Text(
                    'Reset',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
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

// Small widget for weekday labels
class _WeekdayLabel extends StatelessWidget {
  final String text;

  const _WeekdayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class PricingSummarySection extends StatelessWidget {
  const PricingSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to InvoiceScreen from proceedToPayment.dart
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InvoiceScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B2C4F),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Updated icon style to match email notifications
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        255,
                        255,
                        255,
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.payment, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Continue to Payment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Updated icon style to match email notifications
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B2C4F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.security,
                      size: 14,
                      color: Color(0xFF1B2C4F),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Secure payment',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
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
