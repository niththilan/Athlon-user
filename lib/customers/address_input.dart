// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class AddressInputScreen extends StatefulWidget {
  final String initialAddress;

  const AddressInputScreen({super.key, required this.initialAddress});

  @override
  State<AddressInputScreen> createState() => _AddressInputScreenState();
}

class _AddressInputScreenState extends State<AddressInputScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _addressController;
  String _selectedAddress = "";
  bool _isSearching = false;
  List<String> _searchResults = [];
  late AnimationController _mapPinController;
  late Animation<double> _mapPinAnimation;

  // Add some recent addresses for quick selection
  final List<String> _recentAddresses = [
    "123 Main Street, New York, USA",
    "456 Park Avenue, London, UK",
    "78 Oxford Street, Sydney, Australia",
  ];

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(
      text:
          widget.initialAddress != "Getting location..." &&
              widget.initialAddress != "Error getting location" &&
              widget.initialAddress != "Location permissions are denied" &&
              widget.initialAddress !=
                  "Location permissions are permanently denied"
          ? widget.initialAddress
          : "",
    );
    _selectedAddress = widget.initialAddress;

    // Simplified animation
    _mapPinController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _mapPinAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(parent: _mapPinController, curve: Curves.easeOutBack),
    );

    _mapPinController.forward();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _mapPinController.dispose();
    super.dispose();
  }

  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Simulate address search results
      await Future.delayed(Duration(milliseconds: 500));

      setState(() {
        _searchResults = [
          "$query, Main Street, City",
          "$query, Central Avenue, Town",
          "$query, Park Road, District",
          "$query, Broadway, Metro City",
          "$query, Highland Avenue, Uptown",
        ];
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _selectAddress(String address) {
    setState(() {
      _selectedAddress = address;
      _addressController.text = address;
      _searchResults = [];
    });
    // Reset and play the pin drop animation when a new address is selected
    _mapPinController.reset();
    _mapPinController.forward();
  }

  Future<void> _useCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar("Location permissions are denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar("Location permissions are permanently denied");
        return;
      }

      setState(() {
        _isSearching = true;
      });

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = "${place.street}, ${place.locality}, ${place.country}";

        setState(() {
          _selectedAddress = address;
          _addressController.text = address;
          _isSearching = false;
        });

        // Reset and play the pin drop animation
        _mapPinController.reset();
        _mapPinController.forward();
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      _showSnackBar("Error getting location");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2C4F),
        title: Text(
          'Location',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Map container
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF1B2C4F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Map image
                Positioned.fill(
                  child: Container(
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: AssetImage('assets/map.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // Animated pin
                Center(
                  child: AnimatedBuilder(
                    animation: _mapPinAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _mapPinAnimation.value),
                        child: child,
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pin icon
                        Icon(Icons.location_on, color: Colors.red, size: 36),
                        SizedBox(height: 4),
                        // Address label
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            _addressController.text.isNotEmpty
                                ? (_addressController.text.length > 25
                                      ? '${_addressController.text.substring(0, 25)}...'
                                      : _addressController.text)
                                : 'Select location',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1B2C4F),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search and content area
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                // Search field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: 'Search for address',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF1B2C4F)),
                      suffixIcon: _addressController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _addressController.clear();
                                setState(() {
                                  _searchResults = [];
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                    ),
                    onChanged: _searchAddress,
                  ),
                ),

                SizedBox(height: 20),

                // Current location button
                ElevatedButton.icon(
                  onPressed: _useCurrentLocation,
                  icon: Icon(Icons.my_location, color: Colors.white),
                  label: Text(
                    'Use my current location',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1B2C4F),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),

                SizedBox(height: 24),

                // Recent locations section
                if (_searchResults.isEmpty && !_isSearching)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Recent Locations',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1B2C4F),
                          ),
                        ),
                      ),
                      ...List.generate(
                        _recentAddresses.length,
                        (index) => _buildAddressItem(
                          _recentAddresses[index],
                          Icons.history,
                          () => _selectAddress(_recentAddresses[index]),
                        ),
                      ),
                    ],
                  ),

                // Loading indicator
                if (_isSearching)
                  SizedBox(
                    height: 80,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1B2C4F),
                        strokeWidth: 3,
                      ),
                    ),
                  ),

                // Search results
                if (_searchResults.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Search Results',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1B2C4F),
                          ),
                        ),
                      ),
                      ...List.generate(
                        _searchResults.length,
                        (index) => _buildAddressItem(
                          _searchResults[index],
                          Icons.location_on_outlined,
                          () => _selectAddress(_searchResults[index]),
                        ),
                      ),
                    ],
                  ),

                SizedBox(height: 16),
              ],
            ),
          ),

          // Save button at the bottom
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _selectedAddress);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1B2C4F),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Save Location',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Simple address item
  Widget _buildAddressItem(String address, IconData icon, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF1B2C4F)),
        title: Text(
          address,
          style: TextStyle(fontSize: 14, color: Colors.black87),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        onTap: onTap,
      ),
    );
  }
}
