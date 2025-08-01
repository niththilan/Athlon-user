// ignore_for_file: deprecated_member_use, file_names, avoid_print, use_build_context_synchronously, sized_box_for_whitespace, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'help_support.dart';
import 'settings.dart'; // Import the settings screen

// Constants for consistent styling - matching vendor screen
const Color primaryColor = Color(0xFF1B2C4F);
const Color backgroundColor = Color(0xFFF5F6FA);
const Color textDarkColor = Color(0xFF2D3142);
const Color cardColor = Colors.white;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'User Profile',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: backgroundColor,
        cardTheme: const CardThemeData(
          elevation: 4,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      home: const UserProfileScreen(),
    );
  }
}

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

// Mock Authentication Service
class MockAuthService {
  Future<Map<String, dynamic>> getCurrentUser() async {
    // Return mock user data immediately
    return {
      'id': '12345',
      'full_name': 'John Doe',
      'status': 'Cricket Enthusiast',
      'location': 'Colombo, Sri Lanka',
      'address': '123 Sports Avenue, Colombo',
      'email': 'john.doe@example.com',
      'phone': '+94 71 234 5678',
      'avatar_url': null, // No avatar URL, will use asset image
      'member_since': 'January 2023',
      'recent_activities': [
        {
          'title': 'Played Cricket',
          'location': 'CR7 Arena',
          'time': '2 hours ago',
          'icon': Icons.sports_cricket,
        },
        {
          'title': 'Booked Venue',
          'location': 'Ark Sports Complex',
          'time': 'Yesterday',
          'icon': Icons.calendar_today,
        },
        {
          'title': 'Joined Team',
          'location': 'Blue Dragons',
          'time': '2 days ago',
          'icon': Icons.group_add,
        },
      ],
      'favorite_venues': [
        {
          'name': 'CR7 Arena',
          'rating': '4.8',
          'image':
              'https://images.unsplash.com/photo-1531415074968-036ba1b575da?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2067&q=80',
        },
        {
          'name': 'Ark Sports',
          'rating': '4.6',
          'image':
              'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        },
        {
          'name': 'CHAMPION ARENA',
          'rating': '4.89',
          'image':
              'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        },
      ],
    };
  }
}

// Mock User Service
class MockUserService {
  Future<bool> updateUserProfile({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Simply return success (true) for mock implementation
    return true;
  }
}

// Country code data
class CountryCode {
  final String name;
  final String code;
  final String flag;

  CountryCode({required this.name, required this.code, required this.flag});
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // Scroll tracking
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // Mock repositories
  final MockAuthService _authRepository = MockAuthService();
  final MockUserService _userRepository = MockUserService();

  // User data and loading state
  Map<String, dynamic>? _user;
  bool _isLoading = false;

  // Country codes list
  final List<CountryCode> _countryCodes = [
    CountryCode(name: 'Sri Lanka', code: '+94', flag: '🇱🇰'),
    CountryCode(name: 'India', code: '+91', flag: '🇮🇳'),
    CountryCode(name: 'United States', code: '+1', flag: '🇺🇸'),
    CountryCode(name: 'United Kingdom', code: '+44', flag: '🇬🇧'),
    CountryCode(name: 'Australia', code: '+61', flag: '🇦🇺'),
    CountryCode(name: 'Canada', code: '+1', flag: '🇨🇦'),
    CountryCode(name: 'Germany', code: '+49', flag: '🇩🇪'),
    CountryCode(name: 'France', code: '+33', flag: '🇫🇷'),
    CountryCode(name: 'Japan', code: '+81', flag: '🇯🇵'),
    CountryCode(name: 'Singapore', code: '+65', flag: '🇸🇬'),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadUserProfile();
  }

  void _onScroll() {
    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Load user profile from repository
  Future<void> _loadUserProfile() async {
    try {
      final userData = await _authRepository.getCurrentUser();

      setState(() {
        _user = userData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Enhanced validation methods
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    if (value.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }
    // Check if name contains only letters and spaces
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    // Email regex pattern
    const emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(emailPattern).hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value, String countryCode) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (countryCode == '+94') {
      // Sri Lankan phone validation
      if (digitsOnly.length != 9) {
        return 'Sri Lankan phone number must be 9 digits';
      }
      // Check if it starts with valid prefixes for Sri Lanka
      List<String> validPrefixes = [
        '70',
        '71',
        '72',
        '74',
        '75',
        '76',
        '77',
        '78',
      ];
      String prefix = digitsOnly.substring(0, 2);
      if (!validPrefixes.contains(prefix)) {
        return 'Invalid Sri Lankan phone number';
      }
    } else if (countryCode == '+91') {
      // Indian phone validation
      if (digitsOnly.length != 10) {
        return 'Indian phone number must be 10 digits';
      }
    } else if (countryCode == '+1') {
      // US/Canada phone validation
      if (digitsOnly.length != 10) {
        return 'Phone number must be 10 digits';
      }
    } else {
      // Generic validation for other countries
      if (digitsOnly.length < 7 || digitsOnly.length > 15) {
        return 'Phone number must be between 7-15 digits';
      }
    }
    return null;
  }

  String? _validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Location is required';
    }
    if (value.trim().length < 2) {
      return 'Location must be at least 2 characters long';
    }
    if (value.trim().length > 100) {
      return 'Location must be less than 100 characters';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    if (value.trim().length < 5) {
      return 'Address must be at least 5 characters long';
    }
    if (value.trim().length > 200) {
      return 'Address must be less than 200 characters';
    }
    return null;
  }

  String? _validateStatus(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Status is required';
    }
    if (value.trim().length > 100) {
      return 'Status must be less than 100 characters';
    }
    return null;
  }

  // Helper method to format Sri Lankan phone number
  String _formatSriLankanNumber(String phone) {
    // Remove all non-digit characters
    String digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');

    // If it starts with 94, remove it
    if (digitsOnly.startsWith('94')) {
      digitsOnly = digitsOnly.substring(2);
    }

    // If it starts with 0, remove it
    if (digitsOnly.startsWith('0')) {
      digitsOnly = digitsOnly.substring(1);
    }

    return digitsOnly;
  }

  // Helper method to get country code from phone number
  CountryCode _getCountryCodeFromPhone(String phone) {
    if (phone.startsWith('+94')) {
      return _countryCodes.firstWhere((c) => c.code == '+94');
    }
    // Default to Sri Lanka
    return _countryCodes.firstWhere((c) => c.code == '+94');
  }

  // Helper method to build profile detail items
  Widget _buildProfileDetailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : "Not specified",
                style: TextStyle(
                  fontSize: 14,
                  color: value.isNotEmpty ? textDarkColor : Colors.grey[500],
                  fontWeight: value.isNotEmpty
                      ? FontWeight.w500
                      : FontWeight.normal,
                  fontStyle: value.isNotEmpty
                      ? FontStyle.normal
                      : FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Enhanced venue card with image loading
  Widget _buildVenueCard(String name, String rating, String imageUrl) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 100,
              width: double.infinity,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: primaryColor.withOpacity(0.1),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                              strokeWidth: 2,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: primaryColor.withOpacity(0.1),
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: primaryColor,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: primaryColor.withOpacity(0.1),
                      child: const Icon(
                        Icons.image,
                        size: 40,
                        color: primaryColor,
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textDarkColor,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build activity items
  Widget _buildActivityItem(
    String title,
    String location,
    String time,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textDarkColor,
                ),
              ),
              Text(
                location,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  // Helper method to build empty state message
  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Method to build action buttons
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? iconColor,
    Color? textColor,
  }) {
    return Expanded(
      child: Container(
        height: 85,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.white,
            foregroundColor: textColor ?? textDarkColor,
            elevation: 2,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: iconColor ?? primaryColor),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? textDarkColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Settings action
  void _showSettings() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SettingsScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  // Help and Support action
  void _showHelpAndSupport() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HelpSupportScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  // Logout action - Updated to match screenshot
  void _showLogoutConfirmation() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textDarkColor,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _showSuccessSnackBar(
                  'Logged out',
                  message: "You have been logged out successfully",
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
      ),
    );
  }

  // Enhanced form field builder with validation
  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    Widget? suffix,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          readOnly: readOnly,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.normal,
            ),
            suffixIcon: suffix,
            filled: true,
            fillColor: readOnly ? Colors.grey[100] : Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            counterText: '',
          ),
          validator: validator,
        ),
      ],
    );
  }

  // Enhanced edit profile dialog with validation and editable email
  void _showEditProfileDialog() {
    if (_user == null) {
      return;
    }

    // Create text controllers with current values
    final nameController = TextEditingController(
      text: _user!['full_name'] ?? '',
    );
    final statusController = TextEditingController(
      text: _user!['status'] ?? '',
    );
    final locationController = TextEditingController(
      text: _user!['location'] ?? '',
    );
    final addressController = TextEditingController(
      text: _user!['address'] ?? '',
    );
    final emailController = TextEditingController(text: _user!['email'] ?? '');

    // Extract country code and phone number
    final currentPhone = _user!['phone'] ?? '';
    CountryCode selectedCountryCode = _getCountryCodeFromPhone(currentPhone);
    final phoneController = TextEditingController(
      text: _formatSriLankanNumber(currentPhone),
    );

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.92,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Header with close button
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 24,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),

                      // Form content
                      Expanded(
                        child: Form(
                          key: formKey,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.only(
                              bottom:
                                  MediaQuery.of(context).viewInsets.bottom +
                                  100,
                              left: 20,
                              right: 20,
                              top: 24,
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Profile Image Section
                                    Center(
                                      child: Column(
                                        children: [
                                          Stack(
                                            children: [
                                              Container(
                                                width: 120,
                                                height: 120,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: primaryColor,
                                                    width: 3,
                                                  ),
                                                  color: primaryColor
                                                      .withOpacity(0.1),
                                                ),
                                                child: const Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: primaryColor,
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    color: primaryColor,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 3,
                                                    ),
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      // Handle image selection
                                                      _showImagePickerOptions(
                                                        context,
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      Icons.camera_alt,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Change Profile Picture',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 32),

                                    // Full Name with validation
                                    _buildModernField(
                                      controller: nameController,
                                      label: "Full Name",
                                      hint: "John Doe",
                                      validator: _validateName,
                                      maxLength: 50,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'[a-zA-Z\s]'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                    // Status with validation
                                    _buildModernField(
                                      controller: statusController,
                                      label: "Status",
                                      hint: "Cricket Enthusiast",
                                      validator: _validateStatus,
                                      maxLength: 100,
                                    ),
                                    const SizedBox(height: 20),

                                    // Location with validation
                                    _buildModernField(
                                      controller: locationController,
                                      label: "Country/City",
                                      hint: "Sri Lanka",
                                      validator: _validateLocation,
                                      maxLength: 100,
                                      suffix: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.location_on,
                                            size: 20,
                                            color: Colors.grey[600],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Address with validation
                                    _buildModernField(
                                      controller: addressController,
                                      label: "Address",
                                      hint: "123 Sports Avenue, Colombo",
                                      validator: _validateAddress,
                                      maxLength: 200,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 20),

                                    // Email Address (now editable with validation)
                                    _buildModernField(
                                      controller: emailController,
                                      label: "Email Address",
                                      hint: "john.doe@example.com",
                                      validator: _validateEmail,
                                      keyboardType: TextInputType.emailAddress,
                                      readOnly: false, // Changed to editable
                                      maxLength: 100,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                          RegExp(r'\s'), // No spaces allowed
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                    // Phone with country code dropdown and validation
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Phone",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            // Country code dropdown
                                            Container(
                                              height: 56,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[50],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<CountryCode>(
                                                  value: selectedCountryCode,
                                                  items: _countryCodes.map((
                                                    country,
                                                  ) {
                                                    return DropdownMenuItem<
                                                      CountryCode
                                                    >(
                                                      value: country,
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            country.flag,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 18,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Text(
                                                            country.code,
                                                            style:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                  onChanged: (CountryCode? newValue) {
                                                    if (newValue != null) {
                                                      setModalState(() {
                                                        selectedCountryCode =
                                                            newValue;
                                                        // Auto-format phone number when country changes
                                                        if (newValue.code ==
                                                            '+94') {
                                                          String currentText =
                                                              phoneController
                                                                  .text;
                                                          phoneController.text =
                                                              _formatSriLankanNumber(
                                                                currentText,
                                                              );
                                                        }
                                                      });
                                                    }
                                                  },
                                                  icon: const Icon(
                                                    Icons.arrow_drop_down,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Phone number field with enhanced validation
                                            Expanded(
                                              child: TextFormField(
                                                controller: phoneController,
                                                keyboardType:
                                                    TextInputType.phone,
                                                inputFormatters:
                                                    selectedCountryCode.code ==
                                                        '+94'
                                                    ? [
                                                        FilteringTextInputFormatter
                                                            .digitsOnly,
                                                        LengthLimitingTextInputFormatter(
                                                          9,
                                                        ),
                                                      ]
                                                    : selectedCountryCode
                                                              .code ==
                                                          '+91'
                                                    ? [
                                                        FilteringTextInputFormatter
                                                            .digitsOnly,
                                                        LengthLimitingTextInputFormatter(
                                                          10,
                                                        ),
                                                      ]
                                                    : [
                                                        FilteringTextInputFormatter
                                                            .digitsOnly,
                                                        LengthLimitingTextInputFormatter(
                                                          15,
                                                        ),
                                                      ],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText:
                                                      selectedCountryCode
                                                              .code ==
                                                          '+94'
                                                      ? "712345678"
                                                      : selectedCountryCode
                                                                .code ==
                                                            '+91'
                                                      ? "9876543210"
                                                      : "Phone number",
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey[400],
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.grey[50],
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 16,
                                                      ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    borderSide: BorderSide(
                                                      color: Colors.grey[300]!,
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color:
                                                              Colors.grey[300]!,
                                                        ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color:
                                                                  primaryColor,
                                                              width: 2,
                                                            ),
                                                      ),
                                                  errorBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    borderSide:
                                                        const BorderSide(
                                                          color: Colors.red,
                                                          width: 1,
                                                        ),
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color: Colors.red,
                                                              width: 2,
                                                            ),
                                                      ),
                                                ),
                                                onChanged: (value) {
                                                  // Auto-format Sri Lankan numbers
                                                  if (selectedCountryCode
                                                          .code ==
                                                      '+94') {
                                                    String formatted =
                                                        _formatSriLankanNumber(
                                                          value,
                                                        );
                                                    if (formatted != value) {
                                                      phoneController
                                                          .value = TextEditingValue(
                                                        text: formatted,
                                                        selection:
                                                            TextSelection.collapsed(
                                                              offset: formatted
                                                                  .length,
                                                            ),
                                                      );
                                                    }
                                                  }
                                                },
                                                validator: (value) {
                                                  return _validatePhone(
                                                    value,
                                                    selectedCountryCode.code,
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    // Save Changes Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 55,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (formKey.currentState!
                                              .validate()) {
                                            try {
                                              final userId = _user!['id'];

                                              // Format final phone number
                                              String finalPhone =
                                                  selectedCountryCode.code +
                                                  phoneController.text;

                                              final result =
                                                  await _userRepository
                                                      .updateUserProfile(
                                                        userId: userId,
                                                        userData: {
                                                          'full_name':
                                                              nameController
                                                                  .text
                                                                  .trim(),
                                                          'status':
                                                              statusController
                                                                  .text
                                                                  .trim(),
                                                          'location':
                                                              locationController
                                                                  .text
                                                                  .trim(),
                                                          'address':
                                                              addressController
                                                                  .text
                                                                  .trim(),
                                                          'email':
                                                              emailController
                                                                  .text
                                                                  .trim(),
                                                          'phone': finalPhone,
                                                        },
                                                      );

                                              if (result) {
                                                // Update local data
                                                setState(() {
                                                  _user!['full_name'] =
                                                      nameController.text
                                                          .trim();
                                                  _user!['status'] =
                                                      statusController.text
                                                          .trim();
                                                  _user!['location'] =
                                                      locationController.text
                                                          .trim();
                                                  _user!['address'] =
                                                      addressController.text
                                                          .trim();
                                                  _user!['email'] =
                                                      emailController.text
                                                          .trim();
                                                  _user!['phone'] = finalPhone;
                                                });

                                                // Close dialog
                                                Navigator.pop(context);

                                                // Show success message
                                                _showSuccessSnackBar(
                                                  'Profile Updated',
                                                  message:
                                                      "Profile updated successfully",
                                                );
                                              } else {
                                                _showErrorSnackBar(
                                                  'Failed to update profile',
                                                );
                                              }
                                            } catch (e) {
                                              _showErrorSnackBar(
                                                'Error: ${e.toString()}',
                                              );
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Save Changes',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    //const SizedBox(height: 40),
                                  ],
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
            );
          },
        );
      },
    );
  }

  // Method to show image picker options
  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Change Profile Picture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textDarkColor,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        // Handle camera selection
                        _showSuccessSnackBar('Camera selected');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 32,
                              color: primaryColor,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Camera',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: textDarkColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        // Handle gallery selection
                        _showSuccessSnackBar('Gallery selected');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.photo_library,
                              size: 32,
                              color: primaryColor,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Gallery',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: textDarkColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Snackbar helper methods
  void _showSuccessSnackBar(String title, {String? message}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(title)),
              ],
            ),
            if (message != null) ...[
              const SizedBox(height: 4),
              Text(message, style: const TextStyle(fontSize: 12)),
            ],
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while loading data
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    // Handle case where user data couldn't be loaded
    if (_user == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load user profile.'),
              ElevatedButton(
                onPressed: _loadUserProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Extract user data to variables for easy access
    final name = _user!['full_name'] ?? 'User';
    final status = _user!['status'] ?? 'Sports Enthusiast';
    final address = _user!['address'] ?? 'Address not set';
    final email = _user!['email'] ?? 'email@example.com';
    final phone = _user!['phone'] ?? 'Phone not set';
    final memberSince = _user!['member_since'] ?? 'January 2023';
    final recentActivities =
        _user!['recent_activities'] as List<Map<String, dynamic>>? ?? [];
    final favoriteVenues =
        _user!['favorite_venues'] as List<Map<String, dynamic>>? ?? [];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar - matching vendor screen style
          SliverAppBar(
            elevation: _isScrolled ? 4 : 0,
            toolbarHeight: 50,
            floating: false,
            pinned: true,
            backgroundColor: primaryColor,
            centerTitle: false,
            title: const Text(
              "My Profile",
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
                icon: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Back',
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _showEditProfileDialog,
                tooltip: 'Edit Profile',
              ),
              const SizedBox(width: 16),
            ],
          ),

          // PROFILE DETAILS BOX (MOVED UP)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(20),
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
                      children: [
                        // Profile Image with status indicator
                        Stack(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: primaryColor,
                                  width: 2,
                                ),
                                color: primaryColor.withOpacity(0.1),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 45,
                                color: primaryColor,
                              ),
                            ),
                            // Online status indicator
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: textDarkColor,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                status,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Action buttons row (Settings, Help & Support, Logout)
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.settings,
                          label: "Settings",
                          onPressed: _showSettings,
                        ),
                        _buildActionButton(
                          icon: Icons.help_outline,
                          label: "Help & Support",
                          onPressed: _showHelpAndSupport,
                        ),
                        _buildActionButton(
                          icon: Icons.logout,
                          label: "Logout",
                          onPressed: _showLogoutConfirmation,
                          iconColor: Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Additional Profile Details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildProfileDetailItem(
                            Icons.home,
                            "Address",
                            address,
                          ),
                          const Divider(height: 20, thickness: 1),
                          _buildProfileDetailItem(
                            Icons.email_outlined,
                            "Email",
                            email,
                          ),
                          const Divider(height: 20, thickness: 1),
                          _buildProfileDetailItem(
                            Icons.phone_outlined,
                            "Phone",
                            phone,
                          ),
                          const Divider(height: 20, thickness: 1),
                          _buildProfileDetailItem(
                            Icons.calendar_today_outlined,
                            "Member Since",
                            memberSince,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Recent Activities Section - Always visible, up to 3 activities
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(20),
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
                    const Text(
                      "Recent Activities",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textDarkColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (recentActivities.isEmpty)
                      _buildEmptyState(
                        "No recent activities found",
                        Icons.history,
                      )
                    else
                      ...recentActivities.take(3).map((activity) {
                        final index = recentActivities.indexOf(activity);
                        return Column(
                          children: [
                            if (index > 0) const SizedBox(height: 12),
                            _buildActivityItem(
                              activity['title'] ?? '',
                              activity['location'] ?? '',
                              activity['time'] ?? '',
                              activity['icon'] ?? Icons.sports,
                            ),
                          ],
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Favorite Venues Section - Always visible with images
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(20),
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
                    const Text(
                      "Favorite Venues",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textDarkColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (favoriteVenues.isEmpty)
                      _buildEmptyState(
                        "No favorite venues added yet",
                        Icons.location_on,
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: favoriteVenues.map((venue) {
                            final index = favoriteVenues.indexOf(venue);
                            return Row(
                              children: [
                                if (index > 0) const SizedBox(width: 12),
                                _buildVenueCard(
                                  venue['name'] ?? '',
                                  venue['rating'] ?? '0.0',
                                  venue['image'] ?? '',
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
