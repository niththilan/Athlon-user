// ignore_for_file: deprecated_member_use, file_names, avoid_print, use_build_context_synchronously

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

  // Add dropdown functionality
  bool _activitiesExpanded = false;
  bool _venuesExpanded = false;

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

  // Helper method to build venue cards
  Widget _buildVenueCard(String name, String rating, String imagePath) {
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
              color: primaryColor.withOpacity(0.1),
              child: const Icon(Icons.image, size: 40, color: primaryColor),
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

  // Logout action
  void _showLogoutConfirmation() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showSuccessSnackBar(
                'Logged out',
                message: "You have been logged out successfully",
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // Helper method for modern form fields
  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    Widget? suffix,
    List<TextInputFormatter>? inputFormatters,
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
            fillColor: Colors.grey[50],
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
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Method to show edit profile dialog with new UI
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
              child: Column(
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
                          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                          left: 20,
                          right: 20,
                          top: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Description (Status)
                            _buildModernField(
                              controller: nameController,
                              label: "Full Name",
                              hint: "Jhon Doe",
                              maxLines: 1,
                            ),
                            const SizedBox(height: 8),

                            _buildModernField(
                              controller: statusController,
                              label: "Stats",
                              hint: "Cricket Enthusiastic",
                              maxLines: 1,
                            ),
                            const SizedBox(height: 8),

                            // Location with icon
                            _buildModernField(
                              controller: locationController,
                              label: "Country/City",
                              hint: "Srilanka",
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
                            const SizedBox(height: 24),

                            // Address
                            _buildModernField(
                              controller: addressController,
                              label: "Address",
                              hint: "Sagara lane",
                            ),
                            const SizedBox(height: 24),

                            // Email Address (read-only)
                            _buildModernField(
                              controller: emailController,
                              label: "Email Address",
                              hint: "knishvaraj@gmail.com",
                              keyboardType: TextInputType.emailAddress,
                              readOnly: true,
                            ),
                            const SizedBox(height: 24),

                            // Phone with country code dropdown
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<CountryCode>(
                                          value: selectedCountryCode,
                                          items: _countryCodes.map((country) {
                                            return DropdownMenuItem<
                                              CountryCode
                                            >(
                                              value: country,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    country.flag,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    country.code,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (CountryCode? newValue) {
                                            if (newValue != null) {
                                              setModalState(() {
                                                selectedCountryCode = newValue;
                                                // Auto-format phone number when country changes
                                                if (newValue.code == '+94') {
                                                  String currentText =
                                                      phoneController.text;
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
                                    // Phone number field
                                    Expanded(
                                      child: TextFormField(
                                        controller: phoneController,
                                        keyboardType: TextInputType.phone,
                                        inputFormatters:
                                            selectedCountryCode.code == '+94'
                                            ? [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                  9,
                                                ),
                                              ]
                                            : [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          hintText:
                                              selectedCountryCode.code == '+94'
                                              ? "75 7288154"
                                              : "Phone number",
                                          hintStyle: TextStyle(
                                            color: Colors.grey[400],
                                            fontWeight: FontWeight.normal,
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 16,
                                              ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: primaryColor,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          // Auto-format Sri Lankan numbers
                                          if (selectedCountryCode.code ==
                                              '+94') {
                                            String formatted =
                                                _formatSriLankanNumber(value);
                                            if (formatted != value) {
                                              phoneController
                                                  .value = TextEditingValue(
                                                text: formatted,
                                                selection:
                                                    TextSelection.collapsed(
                                                      offset: formatted.length,
                                                    ),
                                              );
                                            }
                                          }
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Phone number is required';
                                          }
                                          if (selectedCountryCode.code ==
                                                  '+94' &&
                                              value.length != 9) {
                                            return 'Invalid Sri Lankan phone number';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            //const SizedBox(height: 24),

                            // // Website field (optional)
                            // _buildModernField(
                            //   controller: TextEditingController(
                            //     text: "https://wed.lk",
                            //   ),
                            //   label: "Website",
                            //   hint: "https://wed.lk",
                            //   keyboardType: TextInputType.url,
                            // ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Save button at bottom
                  Container(
                    padding: const EdgeInsets.all(20),
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
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            try {
                              final userId = _user!['id'];

                              // Format final phone number
                              String finalPhone =
                                  selectedCountryCode.code +
                                  phoneController.text;

                              final result = await _userRepository
                                  .updateUserProfile(
                                    userId: userId,
                                    userData: {
                                      'full_name': nameController.text,
                                      'status': statusController.text,
                                      'location': locationController.text,
                                      'address': addressController.text,
                                      'phone': finalPhone,
                                    },
                                  );

                              if (result) {
                                // Update local data
                                setState(() {
                                  _user!['full_name'] = nameController.text;
                                  _user!['status'] = statusController.text;
                                  _user!['location'] = locationController.text;
                                  _user!['address'] = addressController.text;
                                  _user!['phone'] = finalPhone;
                                });

                                // Close dialog
                                Navigator.pop(context);

                                // Show success message
                                _showSuccessSnackBar(
                                  'Profile Updated',
                                  message: "Profile updated successfully",
                                );
                              } else {
                                _showErrorSnackBar('Failed to update profile');
                              }
                            } catch (e) {
                              _showErrorSnackBar('Error: ${e.toString()}');
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
                  ),
                ],
              ),
            );
          },
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

          // Recent Activities Section - with dropdown
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
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _activitiesExpanded = !_activitiesExpanded;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Recent Activities",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textDarkColor,
                            ),
                          ),
                          Icon(
                            _activitiesExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: primaryColor,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                    if (_activitiesExpanded) ...[
                      const SizedBox(height: 16),
                      _buildActivityItem(
                        "Played Cricket",
                        "CR7 Arena",
                        "2 hours ago",
                        Icons.sports_cricket,
                      ),
                      const SizedBox(height: 12),
                      _buildActivityItem(
                        "Booked Venue",
                        "Ark Sports Complex",
                        "Yesterday",
                        Icons.calendar_today,
                      ),
                      const SizedBox(height: 12),
                      _buildActivityItem(
                        "Joined Team",
                        "Blue Dragons",
                        "2 days ago",
                        Icons.group_add,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Favorite Venues Section - with dropdown
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
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _venuesExpanded = !_venuesExpanded;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Favorite Venues",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textDarkColor,
                            ),
                          ),
                          Icon(
                            _venuesExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: primaryColor,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                    if (_venuesExpanded) ...[
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildVenueCard(
                              "CR7 Arena",
                              "4.8",
                              "assets/cr7.jpg",
                            ),
                            const SizedBox(width: 12),
                            _buildVenueCard(
                              "Ark Sports",
                              "4.6",
                              "assets/ark.jpg",
                            ),
                            const SizedBox(width: 12),
                            _buildVenueCard(
                              "SportHub",
                              "4.7",
                              "assets/Ark Sport 2.jpg",
                            ),
                          ],
                        ),
                      ),
                    ],
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
