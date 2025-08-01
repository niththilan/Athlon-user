import 'package:flutter/material.dart';

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
        toolbarHeight: 60,
        backgroundColor: const Color(0xFF1B2C4F),
        centerTitle: false,
        title: const Text(
          "Sort & Filter",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.fromLTRB(16, 3, 8, 8),
          child: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
          ),
        ),
        actions: [
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Distance Range Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Distance Range",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2C4F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        "0 km",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Expanded(
                        child: Slider(
                          value: _distanceRadius,
                          min: 0.0,
                          max: 20.0,
                          divisions: 20,
                          label: "${_distanceRadius.round()} km",
                          activeColor: const Color(0xFF1B2C4F),
                          onChanged: (value) {
                            setState(() {
                              _distanceRadius = value;
                            });
                          },
                        ),
                      ),
                      Text(
                        "20 km",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2C4F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Within ${_distanceRadius.round()} km",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B2C4F),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Sorting Options Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sort By",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2C4F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSortingOption("Nearest", "Distance: Low to High"),
                  _buildSortingOption("Farthest", "Distance: High to Low"),
                  _buildSortingOption("Highest Rated", "Rating: High to Low"),
                  _buildSortingOption("Sports (A-Z)", "Alphabetical Order"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Sports Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Filter by Sport",
                    style: TextStyle(
                      fontSize: 18,
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
                      return FilterChip(
                        label: Text(
                          sport,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF1B2C4F),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                        backgroundColor: isSelected
                            ? const Color(0xFF1B2C4F)
                            : Colors.grey[100],
                        selectedColor: const Color(0xFF1B2C4F),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF1B2C4F)
                              : Colors.grey[300]!,
                        ),
                        selected: isSelected,
                        showCheckmark: false,
                        onSelected: (selected) {
                          setState(() {
                            _activeFilter = selected ? sport : 'All';
                          });
                        },
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B2C4F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context, {
                'sortingMode': _sortingMode,
                'activeFilter': _activeFilter,
                'distanceRadius': _distanceRadius,
              });
            },
            child: const Text(
              "Apply Filters",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortingOption(String value, String description) {
    return InkWell(
      onTap: () {
        setState(() {
          _sortingMode = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _sortingMode,
              activeColor: const Color(0xFF1B2C4F),
              onChanged: (newValue) {
                setState(() {
                  _sortingMode = newValue!;
                });
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF1B2C4F),
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
