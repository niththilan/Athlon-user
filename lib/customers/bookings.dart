// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Data models (matching homepage structure)
class Facility {
  final String id;
  final String name;
  final String location;
  final int pendingBookings;
  final int todayBookings;
  final int totalCourts;
  final double monthlyRevenue;
  final List<Court> courts;

  Facility({
    required this.id,
    required this.name,
    required this.location,
    required this.pendingBookings,
    required this.todayBookings,
    required this.totalCourts,
    required this.monthlyRevenue,
    required this.courts,
  });
}

class Court {
  final String id;
  final String name;
  final String type;
  final bool isAvailable;
  final double hourlyRate;

  Court({
    required this.id,
    required this.name,
    required this.type,
    required this.isAvailable,
    required this.hourlyRate,
  });
}

// TimeSlot class for venue opening hours
class TimeSlot {
  String open;
  String close;
  List<String> days;

  TimeSlot({this.open = '', this.close = '', List<String>? days})
    : days = days ?? [];
}

void main() {
  runApp(const SlotsBookingApp());
}

class SlotsBookingApp extends StatelessWidget {
  final String? selectedCourtId;

  const SlotsBookingApp({Key? key, this.selectedCourtId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slots Booking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: SlotsPage(selectedCourtId: selectedCourtId),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SlotsPage extends StatefulWidget {
  final String? selectedCourtId;

  const SlotsPage({Key? key, this.selectedCourtId}) : super(key: key);

  @override
  State<SlotsPage> createState() => _SlotsPageState();
}

class _SlotsPageState extends State<SlotsPage> with WidgetsBindingObserver {
  DateTime selectedDate = DateTime.now();
  Set<String> selectedSlots = {}; // For new reservations (available slots)
  String? selectedBookingId; // Track the currently selected booking for removal
  int currentFooterIndex = 1;
  bool showCalendar = false;

  late List<DateTime> dateList;
  int currentDateStartIndex =
      5; // This will place the current date in the middle of the visible dates

  // Mock courts data instead of loading from Supabase
  List<Court> courts = [
    Court(
      id: 'court_1',
      name: 'Court A',
      type: 'Football',
      isAvailable: true,
      hourlyRate: 2500.0,
    ),
    Court(
      id: 'court_2',
      name: 'Court B',
      type: 'Football',
      isAvailable: true,
      hourlyRate: 3000.0,
    ),
    Court(
      id: 'court_3',
      name: 'Court C',
      type: 'Basketball',
      isAvailable: true,
      hourlyRate: 2000.0,
    ),
  ];
  
  String? currentFacilityId = 'facility_1'; // Mock facility ID

  int selectedCourtIndex = 0;

  Court? get selectedCourt {
    // Safety check to prevent out of bounds and handle empty courts
    if (courts.isEmpty) return null;
    if (selectedCourtIndex >= courts.length) {
      selectedCourtIndex = 0;
    }
    return courts[selectedCourtIndex];
  }

  // Dynamic time slots based on venue opening hours
  List<BookingTimeSlot> timeSlots = [];
  List<TimeSlot> venueOpeningHours = [];
  bool _isRefreshing = false;

  // Mock booking data storage
  Map<String, Map<String, Map<String, String>>> mockBookings = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeDateList();
    _initializeFacilities();
    _initializeSelectedSlots();
    _loadVenueOpeningHours();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh time slots when app becomes active (user might have changed opening hours)
    if (state == AppLifecycleState.resumed) {
      refreshTimeSlotsAfterHoursUpdate();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh time slots when returning to this screen (e.g., from vendor profile)
    refreshTimeSlotsAfterHoursUpdate();
  }

  // Mock facilities initialization instead of Supabase
  void _initializeFacilities() {
    // Set the selected court if provided
    if (widget.selectedCourtId != null && courts.isNotEmpty) {
      final selectedIndex = courts.indexWhere(
        (court) => court.id == widget.selectedCourtId,
      );
      if (selectedIndex != -1) {
        selectedCourtIndex = selectedIndex;
      } else {
        selectedCourtIndex = 0; // Fallback to first court
      }
    } else if (courts.isNotEmpty) {
      selectedCourtIndex = 0; // Default to first court
    }

    // Load time slots after courts are loaded
    _updateTimeSlots();
  }

  void _initializeDateList() {
    dateList = [];
    final today = DateTime.now();
    // Include past, current, and future dates, with today centered
    for (int i = -7; i <= 30; i++) {
      dateList.add(today.add(Duration(days: i)));
    }
  }

  void _initializeSelectedSlots() {
    // Now this will result in an empty set since no slots are pre-selected
    selectedSlots = timeSlots
        .where((slot) => slot.status == SlotStatus.selected)
        .map((slot) => slot.time)
        .toSet();
  }

  // Load venue opening hours - using mock data instead of Supabase
  Future<void> _loadVenueOpeningHours() async {
    // Mock opening hours - venue open Monday to Sunday 7 AM to 11 PM
    venueOpeningHours = [
      TimeSlot(
        open: '7:00 AM',
        close: '11:00 PM',
        days: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
      ),
    ];
    _generateTimeSlotsForSelectedDate();
  }

  // Method to refresh time slots when opening hours are updated
  Future<void> refreshTimeSlotsAfterHoursUpdate() async {
    await _loadVenueOpeningHours();
    if (selectedCourt != null) {
      _updateTimeSlots();
    }
  }

  // Validation method to ensure time slots are properly synchronized with opening hours
  bool validateTimeSlotsSync() {
    String selectedDayName = _getDayName(selectedDate.weekday);

    // Find opening hours for the selected day
    TimeSlot? daySlot;
    for (TimeSlot slot in venueOpeningHours) {
      if (slot.days.contains(selectedDayName)) {
        daySlot = slot;
        break;
      }
    }

    if (daySlot != null &&
        daySlot.open.isNotEmpty &&
        daySlot.close.isNotEmpty) {
      // Venue should be open - verify time slots exist and are within opening hours
      if (timeSlots.isEmpty) return false;

      // Check that all available/selected slots are within opening hours
      TimeOfDay? openTime = _parseTimeStringToTimeOfDay(daySlot.open);
      TimeOfDay? closeTime = _parseTimeStringToTimeOfDay(daySlot.close);

      if (openTime == null || closeTime == null) return false;

      int openMinutes = openTime.hour * 60 + openTime.minute;
      int closeMinutes = closeTime.hour * 60 + closeTime.minute;
      if (closeMinutes < openMinutes)
        closeMinutes += 24 * 60; // Handle overnight

      for (var slot in timeSlots) {
        if (slot.status != SlotStatus.closed) {
          TimeOfDay? slotTime = _parseTimeStringToTimeOfDay(slot.time);
          if (slotTime == null) return false;

          int slotMinutes = slotTime.hour * 60 + slotTime.minute;
          if (slotMinutes < openMinutes || slotMinutes >= closeMinutes) {
            return false; // Slot is outside opening hours
          }
        }
      }
      return true;
    } else {
      // Venue should be closed - verify all slots are marked as closed
      return timeSlots.every((slot) => slot.status == SlotStatus.closed);
    }
  }

  // Refresh all booking data
  Future<void> _refreshBookingData() async {
    if (_isRefreshing) return; // Prevent multiple simultaneous refreshes

    setState(() {
      _isRefreshing = true;
    });

    try {
      // Reload all data
      await Future.wait([
        Future(() => _initializeFacilities()),
        _loadVenueOpeningHours(),
      ]);
    } catch (e) {
      print('Error refreshing booking data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  // Parse opening hours string into TimeSlot objects
  // Generate time slots based on venue opening hours for selected date
  void _generateTimeSlotsForSelectedDate() {
    String selectedDayName = _getDayName(selectedDate.weekday);

    // Find opening hours for the selected day
    TimeSlot? daySlot;
    for (TimeSlot slot in venueOpeningHours) {
      if (slot.days.contains(selectedDayName)) {
        daySlot = slot;
        break;
      }
    }

    if (daySlot != null &&
        daySlot.open.isNotEmpty &&
        daySlot.close.isNotEmpty) {
      // Generate time slots only within the defined opening hours
      timeSlots = _generateTimeSlotsBetween(daySlot.open, daySlot.close);
      if (mounted) {
        setState(() {});
      }
    } else {
      // No opening hours for this day - venue is closed, show all slots as closed
      timeSlots = _generateDefaultTimeSlots().map((slot) {
        return BookingTimeSlot(slot.time, SlotStatus.closed);
      }).toList();
      if (mounted) {
        setState(() {});
      }
    }
  }

  // Generate time slots between open and close times with 30-minute intervals
  List<BookingTimeSlot> _generateTimeSlotsBetween(
    String openTime,
    String closeTime,
  ) {
    List<BookingTimeSlot> slots = [];

    TimeOfDay? openTimeOfDay = _parseTimeStringToTimeOfDay(openTime);
    TimeOfDay? closeTimeOfDay = _parseTimeStringToTimeOfDay(closeTime);

    if (openTimeOfDay == null || closeTimeOfDay == null) {
      return _generateDefaultTimeSlots();
    }

    // Convert to minutes for easier calculation
    int openMinutes = openTimeOfDay.hour * 60 + openTimeOfDay.minute;
    int closeMinutes = closeTimeOfDay.hour * 60 + closeTimeOfDay.minute;

    // Handle overnight hours (e.g., 10:00 PM - 2:00 AM)
    if (closeMinutes < openMinutes) {
      closeMinutes += 24 * 60; // Add 24 hours
    }

    // Generate 30-minute intervals
    for (int minutes = openMinutes; minutes < closeMinutes; minutes += 30) {
      int hour = (minutes ~/ 60) % 24;
      int minute = minutes % 60;

      String timeString = _formatTimeOfDay(
        TimeOfDay(hour: hour, minute: minute),
      );
      slots.add(BookingTimeSlot(timeString, SlotStatus.available));
    }

    return slots;
  }

  // Parse time string to TimeOfDay
  TimeOfDay? _parseTimeStringToTimeOfDay(String timeString) {
    if (timeString.isEmpty) return null;

    String cleanTimeString = timeString.replaceAll(' ', '').toLowerCase();
    bool isPM = cleanTimeString.contains('pm');
    bool isAM = cleanTimeString.contains('am');

    cleanTimeString = cleanTimeString.replaceAll(RegExp(r'[ap]m'), '');
    final parts = cleanTimeString.split(':');
    if (parts.length != 2) return null;

    try {
      int hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (minute < 0 || minute >= 60) return null;

      if (isAM || isPM) {
        if (hour < 1 || hour > 12) return null;

        if (isPM && hour != 12) {
          hour += 12;
        } else if (isAM && hour == 12) {
          hour = 0;
        }
      } else {
        if (hour < 0 || hour > 24) return null;
        if (hour == 24) hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  // Format TimeOfDay to 12-hour string format
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // Get day name from weekday number
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }

  // Generate default time slots if no opening hours are available
  List<BookingTimeSlot> _generateDefaultTimeSlots() {
    return [
      BookingTimeSlot('07:00 AM', SlotStatus.available),
      BookingTimeSlot('07:30 AM', SlotStatus.available),
      BookingTimeSlot('08:00 AM', SlotStatus.available),
      BookingTimeSlot('08:30 AM', SlotStatus.available),
      BookingTimeSlot('09:00 AM', SlotStatus.available),
      BookingTimeSlot('09:30 AM', SlotStatus.available),
      BookingTimeSlot('10:00 AM', SlotStatus.available),
      BookingTimeSlot('10:30 AM', SlotStatus.available),
      BookingTimeSlot('11:00 AM', SlotStatus.available),
      BookingTimeSlot('11:30 AM', SlotStatus.available),
      BookingTimeSlot('12:00 PM', SlotStatus.available),
      BookingTimeSlot('12:30 PM', SlotStatus.available),
      BookingTimeSlot('01:00 PM', SlotStatus.available),
      BookingTimeSlot('01:30 PM', SlotStatus.available),
      BookingTimeSlot('02:00 PM', SlotStatus.available),
      BookingTimeSlot('02:30 PM', SlotStatus.available),
      BookingTimeSlot('03:00 PM', SlotStatus.available),
      BookingTimeSlot('03:30 PM', SlotStatus.available),
      BookingTimeSlot('04:00 PM', SlotStatus.available),
      BookingTimeSlot('04:30 PM', SlotStatus.available),
      BookingTimeSlot('05:00 PM', SlotStatus.available),
      BookingTimeSlot('05:30 PM', SlotStatus.available),
      BookingTimeSlot('06:00 PM', SlotStatus.available),
      BookingTimeSlot('06:30 PM', SlotStatus.available),
      BookingTimeSlot('07:00 PM', SlotStatus.available),
      BookingTimeSlot('07:30 PM', SlotStatus.available),
      BookingTimeSlot('08:00 PM', SlotStatus.available),
      BookingTimeSlot('08:30 PM', SlotStatus.available),
      BookingTimeSlot('09:00 PM', SlotStatus.available),
      BookingTimeSlot('09:30 PM', SlotStatus.available),
      BookingTimeSlot('10:00 PM', SlotStatus.available),
      BookingTimeSlot('10:30 PM', SlotStatus.available),
    ];
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Helper method to check if a date is in the past
  bool _isPastDate(DateTime date) {
    final today = DateTime.now();
    return date.year < today.year ||
        (date.year == today.year && date.month < today.month) ||
        (date.year == today.year &&
            date.month == today.month &&
            date.day < today.day);
  }

  void _updateDateView(DateTime newSelectedDate) {
    final selectedIndex = dateList.indexWhere(
      (date) => _isSameDay(date, newSelectedDate),
    );
    if (selectedIndex != -1) {
      final newStartIndex = (selectedIndex - 2).clamp(0, dateList.length - 5);
      setState(() {
        selectedDate = newSelectedDate;
        currentDateStartIndex = newStartIndex;
        _updateTimeSlots(); // This will regenerate time slots based on opening hours for the new date
      });
    }
  }

  // Handle clicking on occupied slots for booking group selection
  void _handleOccupiedSlotSelection(BookingTimeSlot slot) async {
    setState(() {
      if (slot.bookingId != null) {
        if (selectedBookingId == slot.bookingId) {
          // Clicking the same booking again - deselect it
          selectedBookingId = null;
          _updateSlotStatuses();
        } else {
          // Select this booking group
          selectedBookingId = slot.bookingId;
          // Clear any selected available slots when selecting a booking
          selectedSlots.clear();
          _updateSlotStatuses();
        }
      }
    });
  }

  // Helper method to update slot visual states based on current selections
  void _updateSlotStatuses() {
    for (var slot in timeSlots) {
      if (slot.status == SlotStatus.occupied) {
        // Keep occupied slots as occupied - the UI will handle the styling based on selectedBookingId
        continue;
      } else if (selectedSlots.contains(slot.time)) {
        slot.status = SlotStatus.selected;
      } else if (slot.status == SlotStatus.selected &&
          !selectedSlots.contains(slot.time)) {
        slot.status = SlotStatus.available;
      }
    }
  }

  // Helper method to clear all selections
  void _clearAllSelections() {
    selectedSlots.clear();
    selectedBookingId = null;
    _updateSlotStatuses();
  }

  void _handleTimeSlotSelection(BookingTimeSlot slot) {
    // Check if the selected date is in the past
    final isPastDate = _isPastDate(selectedDate);

    // Prevent selecting slots for past dates
    if (isPastDate) {
      // Show a message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bookings cannot be made for past dates'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Prevent selecting closed slots (venue is closed)
    if (slot.status == SlotStatus.closed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Venue is closed at this time'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (slot.status != SlotStatus.available &&
        slot.status != SlotStatus.selected) {
      return;
    }

    setState(() {
      // Clear any selected booking when working with available slots
      selectedBookingId = null;

      // If clicking a selected slot, deselect it
      if (slot.status == SlotStatus.selected) {
        slot.status = SlotStatus.available;
        selectedSlots.remove(slot.time);
        return;
      }

      // Regular selection logic for unselected slots
      if (selectedSlots.isEmpty) {
        slot.status = SlotStatus.selected;
        selectedSlots.add(slot.time);
      } else {
        // Simple continuous selection without splitting
        List<String> allTimes = timeSlots.map((s) => s.time).toList();
        int startIdx = allTimes.indexOf(selectedSlots.first);
        int currentIdx = allTimes.indexOf(slot.time);
        int start = startIdx < currentIdx ? startIdx : currentIdx;
        int end = startIdx < currentIdx ? currentIdx : startIdx;

        // Clear previous selections
        selectedSlots.clear();
        for (var s in timeSlots) {
          if (s.status == SlotStatus.selected) {
            s.status = SlotStatus.available;
          }
        }

        // Select continuous range only if all slots are available
        bool canSelectRange = true;
        for (int i = start; i <= end; i++) {
          if (timeSlots[i].status != SlotStatus.available) {
            canSelectRange = false;
            break;
          }
        }

        if (canSelectRange) {
          for (int i = start; i <= end; i++) {
            timeSlots[i].status = SlotStatus.selected;
            selectedSlots.add(timeSlots[i].time);
          }
        } else {
          // If can't select range, just select the clicked slot
          slot.status = SlotStatus.selected;
          selectedSlots.add(slot.time);
        }
      }
    });
  }

  // Updated to return more details including calculation of separate time ranges
  Map<String, dynamic> _getSelectedDuration() {
    if (selectedSlots.isEmpty) {
      return {'formatted': '', 'minutes': 0, 'splits': []};
    }

    // Get only the actually selected slots (green ones)
    var actuallySelectedTimes =
        timeSlots
            .where((slot) => slot.status == SlotStatus.selected)
            .map((slot) => slot.time)
            .toList()
          ..sort((a, b) => _parseTimeString(a).compareTo(_parseTimeString(b)));

    if (actuallySelectedTimes.isEmpty) {
      return {'formatted': '', 'minutes': 0, 'splits': []};
    }

    // Helper function to parse time strings
    DateTime parseTime(String timeStr) {
      try {
        final parsedTime = DateFormat('h:mm a').parse(timeStr);
        final now = DateTime.now();
        return DateTime(
          now.year,
          now.month,
          now.day,
          parsedTime.hour,
          parsedTime.minute,
        );
      } catch (e) {
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, 0, 0);
      }
    }

    // Find continuous ranges in selected slots
    List<List<String>> timeRanges = [];
    List<String> currentRange = [];

    for (int i = 0; i < timeSlots.length; i++) {
      if (timeSlots[i].status == SlotStatus.selected) {
        if (currentRange.isEmpty ||
            _parseTimeString(
                  timeSlots[i].time,
                ).difference(_parseTimeString(currentRange.last)).inMinutes ==
                30) {
          currentRange.add(timeSlots[i].time);
        } else {
          if (currentRange.isNotEmpty) {
            timeRanges.add([...currentRange]);
            currentRange = [timeSlots[i].time];
          }
        }
      }
    }

    if (currentRange.isNotEmpty) {
      timeRanges.add([...currentRange]);
    }

    // Format each range
    List<String> formattedRanges = [];
    for (var range in timeRanges) {
      final startDateTime = parseTime(range.first);
      final endTimeDateTime = parseTime(
        range.last,
      ).add(const Duration(minutes: 30));

      final startTimeStr = DateFormat('h:mm a').format(startDateTime);
      final endTimeStr = DateFormat('h:mm a').format(endTimeDateTime);

      formattedRanges.add('$startTimeStr - $endTimeStr');
    }

    // Calculate total minutes
    final totalMinutes = actuallySelectedTimes.length * 30;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    String durationText;
    if (hours > 0) {
      durationText = '$hours hour${hours > 1 ? 's' : ''}';
      if (minutes > 0) {
        durationText += ' $minutes min';
      }
    } else {
      durationText = '$minutes min';
    }

    // For a simple non-split slot
    if (timeRanges.length == 1) {
      final startDateTime = parseTime(actuallySelectedTimes.first);
      final endDateTime = parseTime(
        actuallySelectedTimes.last,
      ).add(const Duration(minutes: 30));

      final startTimeStr = DateFormat('h:mm a').format(startDateTime);
      final endTimeStr = DateFormat(
        'h:mm a',
      ).format(endDateTime); // Change from endTimeDateTime to endDateTime

      return {
        'formatted': '$startTimeStr - $endTimeStr ($durationText)',
        'minutes': totalMinutes,
        'splits': formattedRanges,
        'isSplit': false,
      };
    }
    // For split slots - only show duration part without time ranges
    else {
      return {
        'formatted':
            '($durationText)', // Only show duration in brackets for split slots
        'minutes': totalMinutes,
        'splits': formattedRanges,
        'isSplit': true,
      };
    }
  }

  // Get duration for any type of selection (free slots or selected booking)
  Map<String, dynamic> _getAnySelectedDuration() {
    // If there are free slots selected, show those
    if (selectedSlots.isNotEmpty) {
      return _getSelectedDuration();
    }

    // If a booking is selected
    if (selectedBookingId != null) {
      return _getSelectedBookingDuration();
    }

    return {'formatted': '', 'minutes': 0, 'splits': []};
  }

  // Get duration for selected booking
  Map<String, dynamic> _getSelectedBookingDuration() {
    var bookingSlots =
        timeSlots
            .where((slot) => slot.bookingId == selectedBookingId)
            .map((slot) => slot.time)
            .toList()
          ..sort((a, b) => _parseTimeString(a).compareTo(_parseTimeString(b)));

    if (bookingSlots.isEmpty) {
      return {'formatted': '', 'minutes': 0, 'splits': []};
    }

    return _calculateDurationFromSlots(bookingSlots);
  }

  // Helper method to calculate duration from a list of time slots
  Map<String, dynamic> _calculateDurationFromSlots(List<String> slots) {
    if (slots.isEmpty) {
      return {'formatted': '', 'minutes': 0, 'splits': []};
    }

    // Helper function to parse time strings
    DateTime parseTime(String timeStr) {
      try {
        final parsedTime = DateFormat('h:mm a').parse(timeStr);
        final now = DateTime.now();
        return DateTime(
          now.year,
          now.month,
          now.day,
          parsedTime.hour,
          parsedTime.minute,
        );
      } catch (e) {
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, 0, 0);
      }
    }

    // Find continuous ranges
    List<List<String>> timeRanges = [];
    List<String> currentRange = [];

    for (String timeSlot in slots) {
      if (currentRange.isEmpty) {
        currentRange.add(timeSlot);
      } else {
        // Check if this time is 30 minutes after the last time in current range
        final lastTime = _parseTimeString(currentRange.last);
        final currentTime = _parseTimeString(timeSlot);

        if (currentTime.difference(lastTime).inMinutes == 30) {
          currentRange.add(timeSlot);
        } else {
          // Start a new range
          if (currentRange.isNotEmpty) {
            timeRanges.add([...currentRange]);
          }
          currentRange = [timeSlot];
        }
      }
    }

    if (currentRange.isNotEmpty) {
      timeRanges.add([...currentRange]);
    }

    // Format each range
    List<String> formattedRanges = [];
    for (var range in timeRanges) {
      final startDateTime = parseTime(range.first);
      final endDateTime = parseTime(range.last).add(const Duration(minutes: 30));

      final startTimeStr = DateFormat('h:mm a').format(startDateTime);
      final endTimeStr = DateFormat('h:mm a').format(endDateTime);

      formattedRanges.add('$startTimeStr - $endTimeStr');
    }

    // Calculate total minutes
    final totalMinutes = slots.length * 30;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    String durationText;
    if (hours > 0) {
      durationText = '$hours hour${hours > 1 ? 's' : ''}';
      if (minutes > 0) {
        durationText += ' $minutes min';
      }
    } else {
      durationText = '$minutes min';
    }

    // For a simple non-split slot
    if (timeRanges.length == 1) {
      final startDateTime = parseTime(slots.first);
      final endDateTime = parseTime(slots.last).add(const Duration(minutes: 30));

      final startTimeStr = DateFormat('h:mm a').format(startDateTime);
      final endTimeStr = DateFormat('h:mm a').format(endDateTime);

      return {
        'formatted': '$startTimeStr - $endTimeStr ($durationText)',
        'minutes': totalMinutes,
        'splits': formattedRanges,
        'isSplit': false,
      };
    }
    // For split slots
    else {
      return {
        'formatted': '($durationText)',
        'minutes': totalMinutes,
        'splits': formattedRanges,
        'isSplit': true,
      };
    }
  }

  // Helper method to build styled text fields
  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required String? Function(String?) validator,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    String? hintText,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: const TextStyle(fontSize: 16, color: Color(0xFF2D3142)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF1B2C4F), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.grey[600], size: 20)
            : null,
      ),
    );
  }

  // NEW METHOD: Show customer details dialog
  void _showCustomerDetailsDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          elevation: 8,
          child: Container(
            // Make width responsive based on screen size
            width: MediaQuery.of(context).size.width > 500
                ? 480
                : MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxWidth: 480,
              minWidth: 280,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: EdgeInsets.all(
              MediaQuery.of(context).size.width < 400 ? 16 : 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Customer Details',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 400
                          ? 16
                          : 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B2C4F),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width < 400 ? 12 : 16,
                  ),
                  Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildStyledTextField(
                          controller: nameController,
                          label: 'Customer Name',
                          obscureText: false,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter customer name';
                            }
                            return null;
                          },
                          prefixIcon: Icons.person_outline,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 14),
                        _buildStyledTextField(
                          controller: phoneController,
                          label: 'Contact Number *',
                          obscureText: false,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter contact number';
                            }
                            if (!RegExp(
                              r'^[\+]?[0-9\-\(\)\s]{8,15}$',
                            ).hasMatch(value.trim())) {
                              return 'Please enter valid contact number';
                            }
                            return null;
                          },
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          hintText: '+94XXXXXXXXX',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please ensure customer details are accurate for booking confirmation.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width < 400 ? 16 : 24,
                  ),

                  // Responsive button layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 300) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  final customerName = nameController.text
                                      .trim();
                                  final customerPhone = phoneController.text
                                      .trim();

                                  Navigator.of(context).pop();

                                  _showReservationDialog(
                                    customerName: customerName,
                                    customerPhone: customerPhone,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B2C4F),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width < 400
                                      ? 14
                                      : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize:
                                      MediaQuery.of(context).size.width < 400
                                      ? 14
                                      : 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize:
                                        MediaQuery.of(context).size.width < 400
                                        ? 14
                                        : 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    final customerName = nameController.text
                                        .trim();
                                    final customerPhone = phoneController.text
                                        .trim();

                                    Navigator.of(context).pop();

                                    _showReservationDialog(
                                      customerName: customerName,
                                      customerPhone: customerPhone,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1B2C4F),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width < 400
                                          ? 14
                                          : 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // UPDATED METHOD: Show reservation dialog with customer details
  void _showReservationDialog({String? customerName, String? customerPhone}) {
    final court = selectedCourt;
    if (court == null) return;

    final durationDetails = _getSelectedDuration();
    final totalMinutes = durationDetails['minutes'] as int;
    final totalHours = totalMinutes / 60;
    final totalRate = totalHours * court.hourlyRate;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          elevation: 8,
          child: Container(
            width: MediaQuery.of(context).size.width > 500
                ? 480
                : MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxWidth: 480,
              minWidth: 280,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: EdgeInsets.all(
              MediaQuery.of(context).size.width < 400 ? 16 : 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirm Reservation',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 400
                          ? 16
                          : 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B2C4F),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width < 400 ? 12 : 16,
                  ),

                  // Customer Details Section
                  if (customerName != null && customerPhone != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE9ECEF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer Details',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF495057),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                size: 16,
                                color: Color(0xFF6C757D),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  customerName,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                size: 16,
                                color: Color(0xFF6C757D),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  customerPhone,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Booking Details Section
                  Text(
                    'Court: ${selectedCourt!.name}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${DateFormat('EEEE, MMMM d, y').format(selectedDate)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (durationDetails['isSplit'] == true) ...[
                    Text(
                      'Selected Time Slots',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...durationDetails['splits']
                        .map(
                          (slot) => Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 2),
                            child: Text(
                              '• $slot',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF495057),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    const SizedBox(height: 8),
                    Text(
                      'Total Duration: $totalMinutes minutes',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Duration: ${durationDetails['formatted']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF1B5E20).withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      'Total Amount: LKR ${totalRate.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.width < 400 ? 16 : 24,
                  ),

                  // Responsive button layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 300) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _confirmBooking(
                                  rate: totalRate,
                                  customerName:
                                      customerName ?? 'Walk-in Customer',
                                  customerPhone:
                                      customerPhone ?? '+94000000000',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B5E20),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Confirm',
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width < 400
                                      ? 14
                                      : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize:
                                      MediaQuery.of(context).size.width < 400
                                      ? 14
                                      : 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize:
                                        MediaQuery.of(context).size.width < 400
                                        ? 14
                                        : 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _confirmBooking(
                                    rate: totalRate,
                                    customerName:
                                        customerName ?? 'Walk-in Customer',
                                    customerPhone:
                                        customerPhone ?? '+94000000000',
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1B5E20),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Confirm',
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                              400
                                          ? 14
                                          : 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // UPDATED METHOD: Confirm booking with customer details (using mock storage)
  void _confirmBooking({
    double? rate,
    String? customerName,
    String? customerPhone,
  }) async {
    if (selectedCourt == null) return; // Guard clause

    // Check if the selected date is in the past
    final isPastDate = _isPastDate(selectedDate);

    // Prevent bookings for past dates
    if (isPastDate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bookings cannot be made for past dates'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      // Get selected time slots data
      final selectedTimeSlots = selectedSlots.toList();
      if (selectedTimeSlots.isEmpty) return;

      // Parse first and last time slots to get start and end times
      selectedTimeSlots.sort(
        (a, b) => _parseTimeString(a).compareTo(_parseTimeString(b)),
      );
      // final startTime = _parseTimeString(selectedTimeSlots.first);
      // final endTime = _parseTimeString(selectedTimeSlots.last).add(const Duration(minutes: 30));

      // Calculate duration and price
      // final duration = selectedTimeSlots.length * 30; // 30 minutes per slot
      // final totalPrice = (rate ?? selectedCourt!.hourlyRate) * (duration / 60.0);

      // Note: DateTime objects would be used for database storage
      // final bookingStartTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, startTime.hour, startTime.minute);
      // final bookingEndTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, endTime.hour, endTime.minute);

      // Generate booking ID
      final bookingId = 'booking_${DateTime.now().millisecondsSinceEpoch}';

      // Store booking in mock storage
      final courtId = selectedCourt!.id;
      final dateStr = selectedDate.toIso8601String().split('T')[0];
      
      if (mockBookings[courtId] == null) {
        mockBookings[courtId] = {};
      }
      if (mockBookings[courtId]![dateStr] == null) {
        mockBookings[courtId]![dateStr] = {};
      }

      // Store booking details for each time slot
      for (final timeSlot in selectedTimeSlots) {
        mockBookings[courtId]![dateStr]![timeSlot] = bookingId;
      }

      // Update UI
      setState(() {
        // Convert selected slots to occupied (red) status
        for (var slot in timeSlots) {
          if (selectedSlots.contains(slot.time)) {
            slot.status = SlotStatus.occupied;
            slot.bookingId = bookingId;
          }
        }
        // Clear selected slots
        selectedSlots.clear();
      });

      // Show success dialog with rate and customer details
      _showSuccessDialog(rate: rate, customerName: customerName);
    } catch (e) {
      print('Error confirming booking: $e');
      // Still update UI even if storage fails
      setState(() {
        // Convert selected slots to occupied (red) status
        for (var slot in timeSlots) {
          if (selectedSlots.contains(slot.time)) {
            slot.status = SlotStatus.occupied;
          }
        }
        // Clear selected slots
        selectedSlots.clear();
      });

      // Show success dialog with rate and customer details
      _showSuccessDialog(rate: rate, customerName: customerName);
    }
  }

  // Helper method to parse time strings for sorting
  DateTime _parseTimeString(String timeStr) {
    try {
      final parsedTime = DateFormat('h:mm a').parse(timeStr);
      final now = DateTime.now();
      return DateTime(
        now.year,
        now.month,
        now.day,
        parsedTime.hour,
        parsedTime.minute,
      );
    } catch (e) {
      return DateTime.now();
    }
  }

  // Add this method to update time slots based on selected court and date (using mock data)
  void _updateTimeSlots() async {
    if (selectedCourt == null) return; // Guard clause

    // First, regenerate time slots based on opening hours for the selected date
    _generateTimeSlotsForSelectedDate();

    setState(() {
      // Reset all slots to available first
      for (var slot in timeSlots) {
        slot.status = SlotStatus.available;
        slot.bookingId = null;
      }
    });

    try {
      // Load time slots from mock storage
      final courtId = selectedCourt!.id;
      final dateStr = selectedDate.toIso8601String().split('T')[0];
      
      if (mounted) {
        setState(() {
          // Update slots based on mock data
          if (mockBookings[courtId] != null && mockBookings[courtId]![dateStr] != null) {
            for (var slot in timeSlots) {
              final bookingId = mockBookings[courtId]![dateStr]![slot.time];
              if (bookingId != null) {
                slot.status = SlotStatus.occupied;
                slot.bookingId = bookingId;
              }
            }
          }

          // Clear any existing selections
          selectedSlots.clear();
          selectedBookingId = null;
        });
      }
    } catch (e) {
      print('Error loading time slots: $e');
      // Fall back to empty pattern if mock storage fails - all slots available
      if (mounted) {
        setState(() {
          // Reset all slots to available status (no mock bookings)
          for (var slot in timeSlots) {
            slot.status = SlotStatus.available;
            slot.bookingId = null;
          }

          // Clear any existing selections
          selectedSlots.clear();
          selectedBookingId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show empty state if no courts are available
    if (courts.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1B2C4F),
          elevation: 2,
          toolbarHeight: 50,
          leading: Container(
            margin: const EdgeInsets.fromLTRB(8, 3, 0, 8),
            child: IconButton(
              icon: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: const Text(
            'Bookings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
          centerTitle: false,
          leadingWidth: 56,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sports_basketball_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'No courts available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please check back later',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(height: 60, color: Colors.white),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2C4F),
        elevation: 2,
        toolbarHeight: 50,
        leading: Container(
          margin: const EdgeInsets.fromLTRB(8, 3, 0, 8),
          child: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                // If there's no previous route, just pop the current route
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        title: const Text(
          'Bookings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        leadingWidth: 56,
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
            onPressed: _isRefreshing ? null : () => _refreshBookingData(),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 16), // Spacing between header and content
            // Add venue selection section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: VenueSelectionSection(
                venue: {
                  'title': selectedCourt?.name ?? 'Selected Court',
                  'location': 'Sports Complex, 1.2 km',
                  'sport': selectedCourt?.type ?? 'Football',
                  'rating': 4.8,
                  'rate_per_hour': 'Rs. ${selectedCourt?.hourlyRate ?? 700}',
                  'distance': '1.2 km',
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildCombinedDateAndSlotsSection(), // Direct call without the outer container
            const SizedBox(height: 20),
            // Single button that changes based on context with info button for bookings
            if (courts.isNotEmpty &&
                (selectedSlots.isNotEmpty || selectedBookingId != null))
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Only show Reserve/Remove button for current/future dates
                    if (!_isPastDate(selectedDate)) ...[
                      ElevatedButton(
                        onPressed: () {
                          if (selectedSlots.isNotEmpty) {
                            // Free slots selected - show reservation dialog
                            _showCustomerDetailsDialog();
                          } else if (selectedBookingId != null) {
                            // Existing booking selected - show remove dialog
                            _showBulkRemoveDialog();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedSlots.isNotEmpty
                              ? const Color(0xFF1B5E20) // Green for Reserve
                              : const Color(0xFFB71C1C), // Red for Remove
                          minimumSize: const Size(200, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          selectedSlots.isNotEmpty
                              ? 'Reserve'
                              : 'Remove',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    // Info button - show when a booking is selected (for all dates)
                    if (selectedBookingId != null) ...[
                      // Add spacing only if Reserve/Remove button is also shown
                      if (!_isPastDate(selectedDate)) const SizedBox(width: 12),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2C4F),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: () {
                            _showBookingDetailsDialog();
                          },
                          icon: const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 24,
                          ),
                          tooltip: 'View Booking Details',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      // Removed UnifiedAppFooter - replace with empty container or implement your own footer
      bottomNavigationBar: Container(height: 60, color: Colors.white),
    );
  }

  // Updated combined date and slots section (matching homepage calendar)
  Widget _buildCombinedDateAndSlotsSection() {
    // Show "No courts available" message when no courts are found
    // This prevents showing time slots with mock occupied data when no courts exist
    if (courts.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_basketball_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Courts Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are currently no courts set up in your facility. Please add courts to start managing bookings.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16), // Reduced from 24
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
          // Header row with dropdown and View Calendar button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Courts dropdown with popup box styling
              Container(
                height: 36,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF1B2C4F).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: courts.isNotEmpty ? (selectedCourt?.name ?? '') : '',
                    icon: Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF1B2C4F),
                        size: 20,
                      ),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF1B2C4F),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 8,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemHeight: 48,
                    items: courts.isNotEmpty
                        ? courts
                              .map(
                                (court) => DropdownMenuItem<String>(
                                  value: court.name,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.sports_tennis,
                                          size: 16,
                                          color: const Color(0xFF1B2C4F),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            court.name,
                                            style: const TextStyle(
                                              color: Color(0xFF2D3142),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          court.type,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .toList()
                        : [
                            DropdownMenuItem<String>(
                              value: '',
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.sports_outlined,
                                      size: 16,
                                      color: Color(0xFF999999),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'No courts available',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF999999),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                    onChanged: courts.isNotEmpty
                        ? (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                for (int i = 0; i < courts.length; i++) {
                                  if (courts[i].name == newValue) {
                                    selectedCourtIndex = i;
                                    _updateTimeSlots(); // Add this line to update time slots
                                    return;
                                  }
                                }
                              });
                            }
                          }
                        : null,
                  ),
                ),
              ),
              // View Calendar button
              GestureDetector(
                onTap: () {
                  setState(() {
                    showCalendar = !showCalendar;
                  });
                },
                child: Text(
                  showCalendar
                      ? 'Hide Calendar'
                      : 'View Calendar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1B2C4F),
                    decoration: showCalendar ? TextDecoration.underline : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          showCalendar ? _buildCalendarContent() : _buildDateAndSlotsContent(),
        ],
      ),
    );
  }

  Widget _buildCalendarContent() {
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
              icon: const Icon(Icons.chevron_left, color: Color(0xFF1B2C4F)),
            ),
            Text(
              DateFormat('MMMM yyyy').format(selectedDate),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
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
              icon: const Icon(Icons.chevron_right, color: Color(0xFF1B2C4F)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Week headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
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
        const SizedBox(height: 20),
        Divider(color: Colors.grey[300], height: 1),
        const SizedBox(height: 20),
        _buildSlotsSection(),
      ],
    );
  }

  Widget _buildDateAndSlotsContent() {
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
                color: Color(0xFF1B2C4F),
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
                color: Color(0xFF1B2C4F),
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Divider(color: Colors.grey[300], height: 1),
        const SizedBox(height: 24),
        _buildSlotsSection(),
      ],
    );
  }

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
          color: isSelected ? const Color(0xFF1B2C4F) : Colors.grey[200],
          shape: BoxShape.circle,
          border: isToday && !isSelected
              ? Border.all(color: const Color(0xFF1B2C4F), width: 2)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1B2C4F).withOpacity(0.3),
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
                  : const Color(0xFF2D3142),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    );
    // Adjust for Monday-first calendar: Monday=0, Tuesday=1, ..., Sunday=6
    final firstDayWeekday = (firstDayOfMonth.weekday - 1) % 7;
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
                color: isSelected ? const Color(0xFF1B2C4F) : null,
                shape: BoxShape.circle,
                border: isToday && !isSelected
                    ? Border.all(color: const Color(0xFF1B2C4F), width: 2)
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
                        ? const Color(0xFF1B2C4F)
                        : const Color(0xFF2D3142),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Build grid with 7 columns
    List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      final weekDays = dayWidgets.skip(i).take(7).toList();
      while (weekDays.length < 7) {
        weekDays.add(
          Expanded(
            child: Container(height: 36, margin: const EdgeInsets.all(2)),
          ),
        );
      }

      rows.add(Row(children: weekDays));
      if (i + 7 < dayWidgets.length) {
        rows.add(const SizedBox(height: 4));
      }
    }

    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }

  /// Builds responsive time slot grid that adapts to screen size
  Widget _buildTimeSlotGrid() {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive values
    double containerPadding = screenWidth < 350
        ? 12
        : 16; // Padding from container
    double availableWidth =
        screenWidth -
        (containerPadding * 4); // Account for container margins and padding

    // Calculate slot width and spacing
    double slotWidth;
    double smallSpacing;
    double largeSpacing;
    double fontSize;
    double smallFontSize;
    double slotHeight;

    if (screenWidth < 350) {
      // Very small screens (iPhone SE)
      slotWidth = (availableWidth - 40) / 4; // 40px total for spacing
      smallSpacing = 4;
      largeSpacing = 16;
      fontSize = 10;
      smallFontSize = 8.5;
      slotHeight = 32;
    } else if (screenWidth < 400) {
      // Small screens
      slotWidth = (availableWidth - 44) / 4; // 44px total for spacing
      smallSpacing = 5;
      largeSpacing = 18;
      fontSize = 11;
      smallFontSize = 9;
      slotHeight = 34;
    } else {
      // Normal and large screens
      slotWidth = (availableWidth - 48) / 4; // 48px total for spacing
      smallSpacing = 6;
      largeSpacing = 24;
      fontSize = 12;
      smallFontSize = 10.5;
      slotHeight = 36;
    }

    return SizedBox(
      child: Column(
        children: List.generate((timeSlots.length / 4).ceil(), (rowIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // First slot
                _buildResponsiveTimeSlot(
                  timeSlots[rowIndex * 4],
                  slotWidth,
                  slotHeight,
                  fontSize,
                  smallFontSize,
                ),
                SizedBox(width: smallSpacing),

                // Second slot (if exists)
                if (rowIndex * 4 + 1 < timeSlots.length)
                  _buildResponsiveTimeSlot(
                    timeSlots[rowIndex * 4 + 1],
                    slotWidth,
                    slotHeight,
                    fontSize,
                    smallFontSize,
                  )
                else
                  SizedBox(width: slotWidth),

                SizedBox(width: largeSpacing),

                // Third slot (if exists)
                if (rowIndex * 4 + 2 < timeSlots.length)
                  _buildResponsiveTimeSlot(
                    timeSlots[rowIndex * 4 + 2],
                    slotWidth,
                    slotHeight,
                    fontSize,
                    smallFontSize,
                  )
                else
                  SizedBox(width: slotWidth),

                SizedBox(width: smallSpacing),

                // Fourth slot (if exists)
                if (rowIndex * 4 + 3 < timeSlots.length)
                  _buildResponsiveTimeSlot(
                    timeSlots[rowIndex * 4 + 3],
                    slotWidth,
                    slotHeight,
                    fontSize,
                    smallFontSize,
                  )
                else
                  SizedBox(width: slotWidth),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// Builds responsive time slot with dynamic sizing
  Widget _buildResponsiveTimeSlot(
    BookingTimeSlot slot,
    double width,
    double height,
    double fontSize,
    double smallFontSize,
  ) {
    Color backgroundColor;
    Color textColor;
    bool hasRedBorder = false;

    switch (slot.status) {
      case SlotStatus.selected:
        backgroundColor = const Color.fromARGB(255, 8, 89, 11);
        textColor = Colors.white;
        break;
      case SlotStatus.occupied:
        // Check if this slot belongs to the selected booking
        bool isSelectedForRemoval =
            selectedBookingId != null && slot.bookingId == selectedBookingId;

        if (isSelectedForRemoval) {
          // Light red background with red border for selected booking
          backgroundColor = const Color.fromARGB(255, 255, 205, 210);
          textColor = const Color.fromARGB(255, 150, 9, 7);
          hasRedBorder = true;
        } else {
          // Dark red for unselected occupied slots
          backgroundColor = const Color.fromARGB(255, 150, 9, 7);
          textColor = Colors.white;
        }
        break;
      case SlotStatus.available:
        backgroundColor = const Color(0xFFE8E8E8);
        textColor = const Color(0xFF666666);
        break;
      case SlotStatus.closed:
        backgroundColor = const Color(0xFFBDBDBD); // Light gray for closed
        textColor = const Color(0xFF9E9E9E); // Darker gray text
        break;
      case SlotStatus.groupSelected:
        // This case should no longer be used but included for completeness
        backgroundColor = const Color.fromARGB(255, 255, 205, 210);
        textColor = const Color.fromARGB(255, 150, 9, 7);
        hasRedBorder = true;
        break;
      case SlotStatus.individualSelected:
        // This case should no longer be used but included for completeness
        backgroundColor = const Color.fromARGB(255, 255, 205, 210);
        textColor = const Color.fromARGB(255, 150, 9, 7);
        hasRedBorder = true;
        break;
    }

    // Check if the selected date is in the past
    final isPastDate = _isPastDate(selectedDate);

    // If it's a past date, show available/closed/selected slots as disabled
    // but keep occupied slots interactive for viewing booking details
    if (isPastDate && slot.status != SlotStatus.occupied) {
      backgroundColor = Colors.grey[300]!;
      textColor = Colors.grey[500]!;
    }

    return GestureDetector(
      onTap: () {
        if (slot.status == SlotStatus.occupied) {
          // Handle occupied slot selection - works for all dates (past, present, future)
          _handleOccupiedSlotSelection(slot);
        } else {
          // For available slots, prevent interactions on past dates
          final isPastDate = _isPastDate(selectedDate);
          if (isPastDate) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bookings cannot be made for past dates'),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }
          _handleTimeSlotSelection(slot);
        }
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            width < 70 ? 8 : 10,
          ), // Smaller radius for smaller slots
          border: hasRedBorder
              ? Border.all(color: const Color(0xFFB71C1C), width: 2)
              : null,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  slot.time,
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (slot.status == SlotStatus.selected)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '30 min',
                    style: TextStyle(
                      color: textColor,
                      fontSize: smallFontSize,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds responsive legend with dynamic sizing
  Widget _buildLegend() {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing
    double iconSize = screenWidth < 350
        ? 16
        : screenWidth < 400
        ? 18
        : 20;
    double fontSize = screenWidth < 350
        ? 10
        : screenWidth < 400
        ? 11
        : 12;
    double spacing = screenWidth < 350
        ? 4
        : screenWidth < 400
        ? 6
        : 8;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildResponsiveLegendItem(
            'Selected',
            const Color.fromARGB(255, 8, 89, 11),
            iconSize,
            fontSize,
            spacing,
          ),
          _buildResponsiveLegendItem(
            'Occupied',
            const Color.fromARGB(255, 150, 9, 7),
            iconSize,
            fontSize,
            spacing,
          ),
          _buildResponsiveLegendItem(
            'Available',
            const Color(0xFFE8E8E8),
            iconSize,
            fontSize,
            spacing,
            isAvailable: true,
          ),
        ],
      ),
    );
  }

  /// Builds responsive legend item
  Widget _buildResponsiveLegendItem(
    String label,
    Color color,
    double iconSize,
    double fontSize,
    double spacing, {
    bool isAvailable = false,
  }) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sports_soccer,
            size: iconSize,
            color: isAvailable ? const Color(0xFF666666) : color,
          ),
          SizedBox(width: spacing),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF666666),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Update the slots section to use responsive legend
  Widget _buildSlotsSection() {
    // If no courts are available, don't show slots section
    if (courts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Available Time Slots',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2C4F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'LKR ${selectedCourt?.hourlyRate.toStringAsFixed(2) ?? '0.00'}/hr',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1B2C4F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildLegend(), // Now uses the responsive version
        const SizedBox(height: 20),
        _buildTimeSlotGrid(), // Now uses the responsive version
        if (selectedSlots.isNotEmpty ||
            selectedSlots.isNotEmpty ||
            selectedBookingId != null)
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Duration: ${_getAnySelectedDuration()['formatted']}',
                  style: const TextStyle(
                    color: Color(0xFF1B2C4F),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Updated method for bulk removal success
  void _showRemovedSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: MediaQuery.of(context).size.width > 500
                ? 400
                : MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 400, minWidth: 280),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, const Color(0xFFFFF5F5)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB71C1C).withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFB71C1C).withOpacity(0.1),
                width: 1,
              ),
            ),
            padding: EdgeInsets.all(
              MediaQuery.of(context).size.width < 400 ? 24 : 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFB71C1C),
                        const Color(0xFFD32F2F),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB71C1C).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.event_busy,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Booking Removed!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFB71C1C),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selected bookings have been cancelled',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB71C1C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadowColor: const Color(0xFFB71C1C).withOpacity(0.3),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // UPDATED METHOD: Show success dialog with customer details
  void _showSuccessDialog({double? rate, String? customerName}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          elevation: 8,
          child: Container(
            width: MediaQuery.of(context).size.width > 500
                ? 400
                : MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 400, minWidth: 280),
            padding: EdgeInsets.all(
              MediaQuery.of(context).size.width < 400 ? 20 : 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1B2C4F).withOpacity(0.1),
                    border: Border.all(
                      color: const Color(0xFF1B2C4F),
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF1B2C4F),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Successfully Booked!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2C4F),
                  ),
                ),
                const SizedBox(height: 16),

                // Show customer name if provided
                if (customerName != null &&
                    customerName != 'Walk-in Customer') ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 20,
                          color: Color(0xFF6C757D),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Booked for: $customerName',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                if (rate != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF1B5E20).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Amount to collect: LKR ${rate.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Don\'t forget to collect the cash!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B2C4F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to get formatted time ranges for removal
  List<String> _getRemovalTimeRanges() {
    Set<String> allSelectedTimes = <String>{};

    // Add times from selected booking
    if (selectedBookingId != null) {
      for (var slot in timeSlots) {
        if (slot.bookingId == selectedBookingId) {
          allSelectedTimes.add(slot.time);
        }
      }
    }

    if (allSelectedTimes.isEmpty) {
      return [];
    }

    // Sort the selected removal times
    var sortedTimes = allSelectedTimes.toList()
      ..sort((a, b) => _parseTimeString(a).compareTo(_parseTimeString(b)));

    // Helper function to parse time strings
    DateTime parseTime(String timeStr) {
      try {
        final parsedTime = DateFormat('h:mm a').parse(timeStr);
        final now = DateTime.now();
        return DateTime(
          now.year,
          now.month,
          now.day,
          parsedTime.hour,
          parsedTime.minute,
        );
      } catch (e) {
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, 0, 0);
      }
    }

    // Find continuous ranges in selected removal slots
    List<List<String>> timeRanges = [];
    List<String> currentRange = [];

    for (String time in sortedTimes) {
      if (currentRange.isEmpty) {
        currentRange.add(time);
      } else {
        // Check if this time is 30 minutes after the last time in current range
        final lastTime = _parseTimeString(currentRange.last);
        final currentTime = _parseTimeString(time);

        if (currentTime.difference(lastTime).inMinutes == 30) {
          currentRange.add(time);
        } else {
          // Start a new range
          if (currentRange.isNotEmpty) {
            timeRanges.add([...currentRange]);
          }
          currentRange = [time];
        }
      }
    }

    if (currentRange.isNotEmpty) {
      timeRanges.add([...currentRange]);
    }

    // Format each range
    List<String> formattedRanges = [];
    for (var range in timeRanges) {
      if (range.length == 1) {
        // Single slot - show as range (e.g., "8:00 AM - 8:30 AM")
        final startDateTime = parseTime(range.first);
        final endDateTime = startDateTime.add(const Duration(minutes: 30));
        final startTimeStr = DateFormat('h:mm a').format(startDateTime);
        final endTimeStr = DateFormat('h:mm a').format(endDateTime);
        formattedRanges.add('$startTimeStr - $endTimeStr');
      } else {
        // Multiple consecutive slots
        final startDateTime = parseTime(range.first);
        final endDateTime = parseTime(
          range.last,
        ).add(const Duration(minutes: 30));
        final startTimeStr = DateFormat('h:mm a').format(startDateTime);
        final endTimeStr = DateFormat('h:mm a').format(endDateTime);
        formattedRanges.add('$startTimeStr - $endTimeStr');
      }
    }

    return formattedRanges;
  }

  // Add new method for bulk removal
  void _showBulkRemoveDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          elevation: 8,
          child: Container(
            width: MediaQuery.of(context).size.width > 500
                ? 480
                : MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxWidth: 480,
              minWidth: 280,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: EdgeInsets.all(
              MediaQuery.of(context).size.width < 400 ? 16 : 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remove Multiple Bookings',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 400
                          ? 16
                          : 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFB71C1C),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width < 400 ? 12 : 16,
                  ),

                  Text(
                    'Court: ${selectedCourt?.name ?? 'Unknown'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${DateFormat('EEEE, MMMM d, y').format(selectedDate)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Selected time ranges:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2D3142),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFFB74D).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _getRemovalTimeRanges()
                          .map(
                            (timeRange) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• $timeRange',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF495057),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFB71C1C).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_outlined,
                          color: const Color(0xFFB71C1C),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Are you sure you want to remove these bookings? This action cannot be undone.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF495057),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.width < 400 ? 16 : 24,
                  ),

                  // Responsive button layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 300) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _removeSelectedBookings();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB71C1C),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Remove',
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width < 400
                                      ? 14
                                      : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize:
                                      MediaQuery.of(context).size.width < 400
                                      ? 14
                                      : 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize:
                                        MediaQuery.of(context).size.width < 400
                                        ? 14
                                        : 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _removeSelectedBookings();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB71C1C),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Remove',
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                              400
                                          ? 14
                                          : 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // New method to show booking details dialog
  void _showBookingDetailsDialog() async {
    if (selectedBookingId == null) return;

    try {
      // Get booking details from the time slots that have this booking ID
      final bookingSlots = timeSlots
          .where((slot) => slot.bookingId == selectedBookingId)
          .toList();

      if (bookingSlots.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load booking details'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create mock booking details
      Map<String, dynamic> bookingDetails = {
        'customer_name': 'John Doe',
        'customer_phone': '+94771234567',
        'price': bookingSlots.length * 30 / 60.0 * selectedCourt!.hourlyRate,
        'status': 'confirmed',
        'cash_collected': false,
      };

      // Calculate duration from slots
      final durationMinutes = bookingSlots.length * 30;
      final durationHours = durationMinutes / 60.0;

      // Sort slots by time to get start and end times
      bookingSlots.sort(
        (a, b) => _parseTimeString(a.time).compareTo(_parseTimeString(b.time)),
      );
      final startTime = bookingSlots.first.time;
      final endTime = _parseTimeString(
        bookingSlots.last.time,
      ).add(const Duration(minutes: 30));
      final endTimeStr = DateFormat('h:mm a').format(endTime);

      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.4),
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: Colors.white,
            elevation: 8,
            child: Container(
              width: MediaQuery.of(context).size.width > 500
                  ? 480
                  : MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(
                maxWidth: 480,
                minWidth: 280,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.width < 400 ? 16 : 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.event_note,
                          color: const Color(0xFF1B2C4F),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Booking Details',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 400
                                  ? 16
                                  : 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1B2C4F),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.grey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Booking details container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE9ECEF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            'Customer Name',
                            bookingDetails['customer_name'] ?? 'Unknown',
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'Phone Number',
                            bookingDetails['customer_phone'] ?? 'Not provided',
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('Court', selectedCourt!.name),
                          const SizedBox(height: 12),
                          _buildDetailRow('Court Type', selectedCourt!.type),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'Date',
                            DateFormat('EEEE, MMMM d, y').format(selectedDate),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('Time', '$startTime - $endTimeStr'),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'Duration',
                            _formatDuration(durationHours),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'Total Amount',
                            'LKR ${NumberFormat('#,##0.00').format(bookingDetails['price'] ?? (durationHours * selectedCourt!.hourlyRate))}',
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'Status',
                            _formatStatus(
                              bookingDetails['status'] ?? 'confirmed',
                            ),
                          ),
                          if (bookingDetails['cash_collected'] != null) ...[
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              'Payment',
                              bookingDetails['cash_collected'] == true
                                  ? 'Cash Collected'
                                  : 'Pending',
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B2C4F),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 16,
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
        },
      );
    } catch (e) {
      print('Error loading booking details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error loading booking details'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper method to build detail rows
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF2D3142),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to format duration
  String _formatDuration(dynamic durationHours) {
    if (durationHours == null) return 'Unknown';
    try {
      double hours = double.parse(durationHours.toString());
      if (hours >= 1) {
        if (hours == hours.truncate()) {
          return '${hours.truncate()} hour${hours > 1 ? 's' : ''}';
        } else {
          int wholeHours = hours.truncate();
          int minutes = ((hours - wholeHours) * 60).round();
          return '${wholeHours}h ${minutes}m';
        }
      } else {
        int minutes = (hours * 60).round();
        return '${minutes} minutes';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  // Helper method to format status
  String _formatStatus(dynamic status) {
    if (status == null) return 'Unknown';
    String statusStr = status.toString();
    return statusStr
        .split('_')
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .join(' ');
  }

  void _removeSelectedBookings() async {
    if (selectedCourt == null) return;

    // Check if the selected date is in the past
    final today = DateTime.now();
    final isPastDate =
        selectedDate.year < today.year ||
        (selectedDate.year == today.year && selectedDate.month < today.month) ||
        (selectedDate.year == today.year &&
            selectedDate.month == today.month &&
            selectedDate.day < today.day);

    // Prevent removing bookings for past dates
    if (isPastDate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bookings cannot be removed for past dates'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      Set<String> allSelectedTimes = <String>{};

      // Add times from selected booking
      if (selectedBookingId != null) {
        for (var slot in timeSlots) {
          if (slot.bookingId == selectedBookingId) {
            allSelectedTimes.add(slot.time);
          }
        }
      }

      allSelectedTimes.addAll(selectedSlots);

      // Remove bookings from mock storage
      final courtId = selectedCourt!.id;
      final dateStr = selectedDate.toIso8601String().split('T')[0];
      
      if (mockBookings[courtId] != null && mockBookings[courtId]![dateStr] != null) {
        for (final timeSlot in allSelectedTimes) {
          mockBookings[courtId]![dateStr]!.remove(timeSlot);
        }
      }

      // Update UI state
      setState(() {
        for (var slot in timeSlots) {
          if (allSelectedTimes.contains(slot.time)) {
            slot.status = SlotStatus.available;
            slot.bookingId = null;
          }
        }
        _clearAllSelections();
      });

      _showRemovedSuccessDialog();
    } catch (e) {
      print('Error removing bookings: $e');
      // Show error dialog to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing bookings: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// VenueSelectionSection class
class VenueSelectionSection extends StatelessWidget {
  final Map<String, dynamic>? venue;

  const VenueSelectionSection({super.key, this.venue});

  @override
  Widget build(BuildContext context) {
    final venueData =
        venue ??
        {
          'title': 'CR7 Futsal Arena',
          'location': 'Downtown, 2.5 km',
          'sport': 'Football',
          'rating': 4.8,
          'rate_per_hour': 'Rs. 700',
          'distance': '2.5 km',
        };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selected Venue',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    _getCourtImage(
                      venueData['sport']?.toString() ?? 'Football',
                    ),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getSportIcon(
                            venueData['sport']?.toString() ?? 'Football',
                          ),
                          color: const Color(0xFF1B2C4F),
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venueData['title']?.toString() ?? 'Venue',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            venueData['location']?.toString() ?? 'Location',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${venueData['rating'] ?? 4.8}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildAmenityTag(
                          _getSportFormat(
                            venueData['sport']?.toString() ?? 'Football',
                          ),
                        ),
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
    );
  }

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'football':
        return Icons.sports_soccer;
      case 'basketball':
        return Icons.sports_basketball;
      case 'tennis':
        return Icons.sports_tennis;
      case 'badminton':
        return Icons.sports_tennis;
      case 'cricket':
        return Icons.sports_cricket;
      case 'baseball':
        return Icons.sports_baseball;
      case 'table tennis':
        return Icons.table_bar;
      default:
        return Icons.sports_soccer;
    }
  }

  String _getCourtImage(String sport) {
    switch (sport.toLowerCase()) {
      case 'football':
        return 'assets/football.jpg';
      case 'basketball':
        return 'assets/basket.jpg';
      case 'tennis':
        return 'assets/tennis.jpg';
      case 'badminton':
        return 'assets/badminton.jpg';
      case 'cricket':
        return 'assets/cricket.jpg';
      case 'table tennis':
        return 'assets/tabletennis.jpg';
      default:
        return 'assets/football.jpg';
    }
  }

  String _getSportFormat(String sport) {
    switch (sport.toLowerCase()) {
      case 'football':
        return '5 vs 5';
      case 'basketball':
        return '5 vs 5';
      case 'tennis':
        return '1 vs 1';
      case 'badminton':
        return '2 vs 2';
      case 'table tennis':
        return '1 vs 1';
      default:
        return '5 vs 5';
    }
  }

  Widget _buildAmenityTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }
}

class BookingTimeSlot {
  final String time;
  SlotStatus status;
  String? bookingId; // Track which booking this slot belongs to

  BookingTimeSlot(this.time, this.status, {this.bookingId});
}

enum SlotStatus {
  selected,
  occupied,
  available,
  closed,
  groupSelected,
  individualSelected,
}