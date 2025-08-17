// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'widgets/football_spinner.dart';

// New Filter Screen
class FilterScreen extends StatefulWidget {
  final String currentSortingMode;
  final String currentActiveFilter;
  final double currentDistanceRadius;
  final Map<String, IconData> filterOptions;

  const FilterScreen({
    super.key,
    required this.currentSortingMode,
    required this.currentActiveFilter,
    required this.currentDistanceRadius,
    required this.filterOptions,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late String _sortingMode;
  late String _activeFilter;
  late double _distanceRadius;
  String _selectedLocation = "Current Location";

  @override
  void initState() {
    super.initState();
    _sortingMode = widget.currentSortingMode;
    _activeFilter = widget.currentActiveFilter;
    _distanceRadius = widget.currentDistanceRadius;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 4,
        toolbarHeight: 50,
        backgroundColor: const Color(0xFF1B2C4F),
        centerTitle: false,
        title: Row(
          children: [
            const Text(
              "Sort & Filter",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 180),
            TextButton(
              onPressed: () {
                setState(() {
                  _distanceRadius = 10.0;
                  _sortingMode = 'Nearest';
                  _activeFilter = 'All';
                });
              },
              child: const Text(
                'Reset',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        leading: Container(
          margin: const EdgeInsets.fromLTRB(16, 3, 8, 8),
          child: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Location Section
            GestureDetector(
              onTap: () => _showLocationSelector(),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF1B2C4F),
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedLocation,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B2C4F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedLocation == "Current Location"
                                ? "Getting your location..."
                                : "Tap to change location",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF1B2C4F),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Distance Range Section - Simplified
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Distance",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2C4F),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: _distanceRadius,
                    min: 0.0,
                    max: 20.0,
                    divisions: 20,
                    label: "${_distanceRadius.round()} km",
                    activeColor: const Color(0xFF1B2C4F),
                    inactiveColor: Colors.grey[300],
                    onChanged: (value) {
                      setState(() {
                        _distanceRadius = value;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "0 km",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        "Within ${_distanceRadius.round()} km",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1B2C4F),
                        ),
                      ),
                      Text(
                        "20 km",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Sorting Options Section - Simplified
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sort By",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2C4F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSimpleSortingOption("Nearest"),
                  _buildSimpleSortingOption("Farthest"),
                  _buildSimpleSortingOption("Highest Rated"),
                  _buildSimpleSortingOption("Sports (A-Z)"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Sports Filter Section - Simplified
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sports",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2C4F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: widget.filterOptions.keys.map((sport) {
                      final isSelected = _activeFilter == sport;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _activeFilter = isSelected ? 'All' : sport;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1B2C4F)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF1B2C4F)
                                  : Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            sport,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1B2C4F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B2C4F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () async {
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

                // Simulate processing time
                await Future.delayed(const Duration(milliseconds: 300));

                // Close loading dialog
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }

                // Return filter results
                Navigator.pop(context, {
                  'sortingMode': _sortingMode,
                  'activeFilter': _activeFilter,
                  'distanceRadius': _distanceRadius,
                });
              } catch (e) {
                // Handle any errors
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }

                // Still return filter results
                Navigator.pop(context, {
                  'sortingMode': _sortingMode,
                  'activeFilter': _activeFilter,
                  'distanceRadius': _distanceRadius,
                });
              }
            },
            child: const Text(
              "Apply Filters",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  void _showLocationSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Select Location",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B2C4F),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildLocationOption(
                      "Current Location",
                      "Use my current location",
                      Icons.my_location,
                    ),
                    _buildLocationOption(
                      "Downtown Sports Complex",
                      "123 Main St, Downtown",
                      Icons.location_city,
                    ),
                    _buildLocationOption(
                      "Central Park Area",
                      "456 Park Ave, Central",
                      Icons.park,
                    ),
                    _buildLocationOption(
                      "University District",
                      "789 College Rd, University",
                      Icons.school,
                    ),
                    _buildLocationOption(
                      "Shopping Mall Area",
                      "321 Mall Dr, Shopping District",
                      Icons.shopping_bag,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationOption(String title, String subtitle, IconData icon) {
    final isSelected = _selectedLocation == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLocation = title;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1B2C4F).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF1B2C4F) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1B2C4F) : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF1B2C4F)
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

  Widget _buildSimpleSortingOption(String value) {
    final isSelected = _sortingMode == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortingMode = value;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1B2C4F).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF1B2C4F) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF1B2C4F)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1B2C4F)
                      : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: isSelected ? const Color(0xFF1B2C4F) : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
