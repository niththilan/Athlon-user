// ignore_for_file: deprecated_member_use, library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:intl/intl.dart';
import 'proceedToPayment.dart' as payment;

// TimeSlot and SlotStatus definitions
class TimeSlot {
  final String time;
  SlotStatus status;

  TimeSlot(this.time, this.status);
}

enum SlotStatus { selected, occupied, available }

// Court model class
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

void main() {
  runApp(
    DevicePreview(
      enabled: true, // Set to false to disable preview
      builder: (context) => const MyApp(),
    ),
  );
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
          surface: const Color.fromARGB(255, 34, 51, 117),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      ),
      home: const BookNowScreen(),
    );
  }
}

class BookNowScreen extends StatefulWidget {
  final Map<String, dynamic>? venue;

  const BookNowScreen({super.key, this.venue});

  @override
  State<BookNowScreen> createState() => _BookNowScreenState();
}

class _BookNowScreenState extends State<BookNowScreen> {
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
            fontSize: 18,
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
        actions: const [],
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
                  VenueSelectionSection(venue: widget.venue),
                  const SizedBox(height: 20),
                  const BookingDateTimeSection(),
                  const SizedBox(height: 20),
                  const NumberOfPlayersSection(),
                  const SizedBox(height: 20),
                  const PricingSummarySection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
          Row(
            children: [
              Text(
                'Selected Venue',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2C4F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF1B2C4F),
                  size: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                      color: const Color(0xFF1B2C4F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getSportIcon(
                        venueData['sport']?.toString() ?? 'Football',
                      ),
                      color: const Color(0xFF1B2C4F),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              venueData['title']?.toString() ?? 'Venue',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B2C4F),
                              ),
                            ),
                          ),
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
                              venueData['rate_per_hour']?.toString() ??
                                  'Rs. 700/hr',
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
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              venueData['location']?.toString() ?? 'Location',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
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
                            '${venueData['rating'] ?? 4.8}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
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
      ),
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
      case 'swimming':
        return Icons.pool;
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

class BookingDateTimeSection extends StatefulWidget {
  const BookingDateTimeSection({super.key});

  @override
  State<BookingDateTimeSection> createState() => _BookingDateTimeSectionState();
}

class _BookingDateTimeSectionState extends State<BookingDateTimeSection> {
  DateTime selectedDate = DateTime.now();
  Set<String> selectedSlots = {};
  Set<String> selectedForRemoval = {};
  bool showCalendar = false;

  late List<DateTime> dateList;
  int currentDateStartIndex = 5;

  // Mock courts data for dropdown
  List<Court> courts = [
    Court(
      id: '101',
      name: "CR7 Futsal Arena",
      type: "Futsal",
      isAvailable: true,
      hourlyRate: 700.00,
    ),
  ];

  int selectedCourtIndex = 0;

  Court? get selectedCourt {
    if (courts.isEmpty) return null;
    if (selectedCourtIndex >= courts.length) {
      selectedCourtIndex = 0;
    }
    return courts[selectedCourtIndex];
  }

  List<TimeSlot> timeSlots = [
    TimeSlot('07:00 AM', SlotStatus.available),
    TimeSlot('07:30 AM', SlotStatus.available),
    TimeSlot('08:00 AM', SlotStatus.available),
    TimeSlot('08:30 AM', SlotStatus.available),
    TimeSlot('09:00 AM', SlotStatus.available),
    TimeSlot('09:30 AM', SlotStatus.available),
    TimeSlot('10:00 AM', SlotStatus.available),
    TimeSlot('10:30 AM', SlotStatus.available),
    TimeSlot('11:00 AM', SlotStatus.available),
    TimeSlot('11:30 AM', SlotStatus.available),
    TimeSlot('12:00 PM', SlotStatus.available),
    TimeSlot('12:30 PM', SlotStatus.available),
    TimeSlot('01:00 PM', SlotStatus.available),
    TimeSlot('01:30 PM', SlotStatus.available),
    TimeSlot('02:00 PM', SlotStatus.available),
    TimeSlot('02:30 PM', SlotStatus.available),
    TimeSlot('03:00 PM', SlotStatus.available),
    TimeSlot('03:30 PM', SlotStatus.available),
    TimeSlot('04:00 PM', SlotStatus.available),
    TimeSlot('04:30 PM', SlotStatus.available),
    TimeSlot('05:00 PM', SlotStatus.available),
    TimeSlot('05:30 PM', SlotStatus.available),
    TimeSlot('06:00 PM', SlotStatus.available),
    TimeSlot('06:30 PM', SlotStatus.available),
    TimeSlot('07:00 PM', SlotStatus.available),
    TimeSlot('07:30 PM', SlotStatus.available),
    TimeSlot('08:00 PM', SlotStatus.available),
    TimeSlot('08:30 PM', SlotStatus.available),
    TimeSlot('09:00 PM', SlotStatus.available),
    TimeSlot('09:30 PM', SlotStatus.available),
    TimeSlot('10:00 PM', SlotStatus.available),
    TimeSlot('10:30 PM', SlotStatus.available),
  ];

  @override
  void initState() {
    super.initState();
    _initializeDateList();
    _resetTimeSlotsForDate();
  }

  void _initializeDateList() {
    dateList = [];
    final today = DateTime.now();
    for (int i = -7; i <= 30; i++) {
      dateList.add(today.add(Duration(days: i)));
    }
  }

  void _resetTimeSlotsForDate() {
    selectedSlots.clear();
    selectedForRemoval.clear();

    for (var slot in timeSlots) {
      slot.status = SlotStatus.available;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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
        _resetTimeSlotsForDate();
      });
    }
  }

  void _handleTimeSlotSelection(TimeSlot slot) {
    if (slot.status != SlotStatus.available &&
        slot.status != SlotStatus.selected) {
      return;
    }

    setState(() {
      List<String> allTimes = timeSlots.map((s) => s.time).toList();

      if (slot.status == SlotStatus.selected) {
        int clickedIndex = allTimes.indexOf(slot.time);
        int firstSelectedIndex = -1;
        int lastSelectedIndex = -1;

        for (int i = 0; i < timeSlots.length; i++) {
          if (timeSlots[i].status == SlotStatus.selected) {
            if (firstSelectedIndex == -1) firstSelectedIndex = i;
            lastSelectedIndex = i;
          } else if (firstSelectedIndex != -1 && i > clickedIndex) {
            break;
          }
        }

        if (clickedIndex > firstSelectedIndex &&
            clickedIndex < lastSelectedIndex) {
          for (int i = clickedIndex; i <= lastSelectedIndex; i++) {
            if (timeSlots[i].status == SlotStatus.selected) {
              timeSlots[i].status = SlotStatus.available;
              selectedSlots.remove(timeSlots[i].time);
            }
          }
        } else {
          selectedSlots.clear();
          for (var s in timeSlots) {
            if (s.status == SlotStatus.selected) {
              s.status = SlotStatus.available;
            }
          }
        }
        return;
      }

      if (selectedSlots.isEmpty) {
        slot.status = SlotStatus.selected;
        selectedSlots.add(slot.time);
      } else {
        List<String> allTimes = timeSlots.map((s) => s.time).toList();
        int startIdx = allTimes.indexOf(selectedSlots.first);
        int currentIdx = allTimes.indexOf(slot.time);
        int start = startIdx < currentIdx ? startIdx : currentIdx;
        int end = startIdx < currentIdx ? currentIdx : startIdx;

        List<List<int>> availableRanges = [];
        List<int> currentRange = [];

        for (int i = start; i <= end; i++) {
          if (timeSlots[i].status == SlotStatus.available ||
              timeSlots[i].status == SlotStatus.selected) {
            if (currentRange.isEmpty) currentRange = [i];
            if (i == end) {
              currentRange.add(i);
              availableRanges.add([...currentRange]);
            }
          } else {
            if (currentRange.isNotEmpty) {
              currentRange.add(i - 1);
              availableRanges.add([...currentRange]);
              currentRange = [];
            }
          }
        }

        if (availableRanges.length > 1) {
          _showSplitTimeSlotDialog(availableRanges);
          return;
        }

        selectedSlots.clear();
        for (var s in timeSlots) {
          if (s.status == SlotStatus.selected) {
            s.status = SlotStatus.available;
          }
        }

        for (int i = start; i <= end; i++) {
          if (timeSlots[i].status == SlotStatus.available) {
            timeSlots[i].status = SlotStatus.selected;
            selectedSlots.add(timeSlots[i].time);
          }
        }
      }
    });
  }

  void _showSplitTimeSlotDialog(List<List<int>> ranges) {
    String slotRangesText = ranges
        .map((range) {
          var startTime = timeSlots[range[0]].time;
          var endTime = _formatEndTime(timeSlots[range[1]].time);
          return '$startTime - $endTime';
        })
        .join('\n');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Split Time Slots'),
          content: Text(
            'Your selection will be divided into these time slots:\n\n$slotRangesText',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedSlots.clear();
                  for (var s in timeSlots) {
                    if (s.status == SlotStatus.selected) {
                      s.status = SlotStatus.available;
                    }
                  }

                  for (var range in ranges) {
                    for (int i = range[0]; i <= range[1]; i++) {
                      timeSlots[i].status = SlotStatus.selected;
                      selectedSlots.add(timeSlots[i].time);
                    }
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // Fixed: Add helper method for formatting end time
  String _formatEndTime(String timeStr) {
    try {
      final parsedTime = DateFormat('h:mm a').parse(timeStr);
      final endTime = parsedTime.add(const Duration(minutes: 30));
      return DateFormat('h:mm a').format(endTime);
    } catch (e) {
      return timeStr;
    }
  }

  Map<String, dynamic> _getSelectedDuration() {
    if (selectedSlots.isEmpty) {
      return {'formatted': '', 'minutes': 0, 'splits': []};
    }

    var actuallySelectedTimes =
        timeSlots
            .where((slot) => slot.status == SlotStatus.selected)
            .map((slot) => slot.time)
            .toList()
          ..sort((a, b) => _parseTimeString(a).compareTo(_parseTimeString(b)));

    if (actuallySelectedTimes.isEmpty) {
      return {'formatted': '', 'minutes': 0, 'splits': []};
    }

    // Fixed: Improved time parsing
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

    List<String> formattedRanges = [];
    for (var range in timeRanges) {
      final startDateTime = parseTime(range.first);
      final endDateTime = parseTime(
        range.last,
      ).add(const Duration(minutes: 30));

      final startTimeStr = DateFormat('h:mm a').format(startDateTime);
      final endTimeStr = DateFormat('h:mm a').format(endDateTime);

      formattedRanges.add('$startTimeStr - $endTimeStr');
    }

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

    if (timeRanges.length == 1) {
      final startDateTime = parseTime(actuallySelectedTimes.first);
      final endDateTime = parseTime(
        actuallySelectedTimes.last,
      ).add(const Duration(minutes: 30));

      final startTimeStr = DateFormat('h:mm a').format(startDateTime);
      final endTimeStr = DateFormat('h:mm a').format(endDateTime);

      return {
        'formatted': '$startTimeStr - $endTimeStr ($durationText)',
        'minutes': totalMinutes,
        'splits': formattedRanges,
        'isSplit': false,
      };
    } else {
      return {
        'formatted': '($durationText)',
        'minutes': totalMinutes,
        'splits': formattedRanges,
        'isSplit': true,
      };
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return _buildCombinedDateAndSlotsSection();
  }

  Widget _buildCombinedDateAndSlotsSection() {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    showCalendar = !showCalendar;
                  });
                },
                child: Text(
                  showCalendar ? 'Hide Calendar' : 'View Calendar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1B2C4F),
                    decoration: showCalendar ? TextDecoration.underline : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          showCalendar ? _buildCalendarContent() : _buildDateAndSlotsContent(),
        ],
      ),
    );
  }

  Widget _buildCalendarContent() {
    return Column(
      children: [
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
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (currentDateStartIndex > 0) {
                    currentDateStartIndex--;
                    selectedDate = dateList[currentDateStartIndex + 2];
                    _resetTimeSlotsForDate(); // Fixed: Reset slots when date changes
                  }
                });
              },
              child: const Icon(
                Icons.chevron_left,
                color: Color(0xFF1B2C4F),
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
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
                    _resetTimeSlotsForDate(); // Fixed: Reset slots when date changes
                  }
                });
              },
              child: const Icon(
                Icons.chevron_right,
                color: Color(0xFF1B2C4F),
                size: 24,
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
              color: isSelected ? Colors.white : const Color(0xFF2D3142),
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
    final firstDayWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    List<Widget> dayWidgets = [];

    for (int i = 0; i < firstDayWeekday; i++) {
      dayWidgets.add(const Expanded(child: SizedBox(height: 36)));
    }

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

    List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      final weekDays = dayWidgets.skip(i).take(7).toList();
      while (weekDays.length < 7) {
        weekDays.add(const Expanded(child: SizedBox(height: 36)));
      }

      rows.add(Row(children: weekDays));
      if (i + 7 < dayWidgets.length) {
        rows.add(const SizedBox(height: 4));
      }
    }

    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }

  Widget _buildSlotsSection() {
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
                  'Rs ${selectedCourt?.hourlyRate.toStringAsFixed(2) ?? '0.00'}/hr',
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
        _buildLegend(),
        const SizedBox(height: 20),
        _buildTimeSlotGrid(),
        if (selectedSlots.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 16, right: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Duration: ${_getSelectedDuration()['formatted']}',
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

  Widget _buildTimeSlotGrid() {
    final screenWidth = MediaQuery.of(context).size.width;

    double containerPadding = screenWidth < 350 ? 12 : 16;
    double availableWidth = screenWidth - (containerPadding * 4);

    double slotWidth;
    double smallSpacing;
    double largeSpacing;
    double fontSize;
    double smallFontSize;
    double slotHeight;

    if (screenWidth < 350) {
      slotWidth = (availableWidth - 40) / 4;
      smallSpacing = 4;
      largeSpacing = 16;
      fontSize = 10;
      smallFontSize = 8.5;
      slotHeight = 38;
    } else if (screenWidth < 400) {
      slotWidth = (availableWidth - 44) / 4;
      smallSpacing = 5;
      largeSpacing = 18;
      fontSize = 11;
      smallFontSize = 9;
      slotHeight = 40;
    } else {
      slotWidth = (availableWidth - 48) / 4;
      smallSpacing = 6;
      largeSpacing = 24;
      fontSize = 12;
      smallFontSize = 10.5;
      slotHeight = 43.3;
    }

    return SizedBox(
      height: 300,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (timeSlots.length / 4).ceil(),
          itemBuilder: (context, rowIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildResponsiveTimeSlot(
                    timeSlots[rowIndex * 4],
                    slotWidth,
                    slotHeight,
                    fontSize,
                    smallFontSize,
                  ),
                  SizedBox(width: smallSpacing),

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
          },
        ),
      ),
    );
  }

  Widget _buildResponsiveTimeSlot(
    TimeSlot slot,
    double width,
    double height,
    double fontSize,
    double smallFontSize,
  ) {
    Color backgroundColor;
    Color textColor;

    switch (slot.status) {
      case SlotStatus.selected:
        backgroundColor = const Color.fromARGB(255, 8, 89, 11);
        textColor = Colors.white;
        break;
      case SlotStatus.occupied:
        backgroundColor = selectedForRemoval.contains(slot.time)
            ? const Color.fromARGB(255, 255, 205, 210)
            : const Color.fromARGB(255, 150, 9, 7);
        textColor = selectedForRemoval.contains(slot.time)
            ? const Color.fromARGB(255, 150, 9, 7)
            : Colors.white;
        break;
      case SlotStatus.available:
        backgroundColor = const Color(0xFFE8E8E8);
        textColor = const Color(0xFF666666);
        break;
    }

    return GestureDetector(
      onTap: () {
        if (slot.status == SlotStatus.occupied) {
          setState(() {
            if (selectedForRemoval.contains(slot.time)) {
              selectedForRemoval.remove(slot.time);
            } else {
              selectedForRemoval.add(slot.time);
            }
          });
        } else {
          _handleTimeSlotSelection(slot);
        }
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(width < 70 ? 8 : 10),
          border: selectedForRemoval.contains(slot.time)
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

  Widget _buildLegend() {
    final screenWidth = MediaQuery.of(context).size.width;

    double iconSize = screenWidth < 350
        ? 20
        : screenWidth < 400
        ? 22
        : 26;
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
            label: 'Selected',
            color: const Color.fromARGB(255, 8, 89, 11),
            iconSize: iconSize,
            fontSize: fontSize,
            spacing: spacing,
          ),
          _buildResponsiveLegendItem(
            label: 'Occupied',
            color: const Color.fromARGB(255, 150, 9, 7),
            iconSize: iconSize,
            fontSize: fontSize,
            spacing: spacing,
          ),
          _buildResponsiveLegendItem(
            label: 'Available',
            color: const Color(0xFFE8E8E8),
            iconSize: iconSize,
            fontSize: fontSize,
            spacing: spacing,
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveLegendItem({
    required String label,
    required Color color,
    required double iconSize,
    required double fontSize,
    required double spacing,
  }) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sports_cricket,
            size: iconSize,
            color: label == 'Available' ? const Color(0xFF666666) : color,
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
}

// Number of Players Section as separate component
class NumberOfPlayersSection extends StatefulWidget {
  const NumberOfPlayersSection({super.key});

  @override
  State<NumberOfPlayersSection> createState() => _NumberOfPlayersSectionState();
}

class _NumberOfPlayersSectionState extends State<NumberOfPlayersSection> {
  int _numberOfPlayers = 1;

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
          Text(
            'Number of Players',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2C4F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.sports_soccer,
                    color: Color(0xFF1B2C4F),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Players',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1B2C4F),
                    ),
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
                              size: 18,
                              color: Color(0xFF1B2C4F),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              size: 18,
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
        ],
      ),
    );
  }
}

class PricingSummarySection extends StatelessWidget {
  const PricingSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock calculation - in real app, this would come from the booking state
    const double hourlyRate = 700.0;
    const double serviceFee = 50.0;
    const int selectedHours = 2; // Mock selected duration
    const double subtotal = hourlyRate * selectedHours;
    const double total = subtotal + serviceFee;

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
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const payment.InvoiceScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
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
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
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
                  const SizedBox(width: 8),
                  Text(
                    'Total: LKR ${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
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
