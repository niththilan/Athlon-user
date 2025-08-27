// Enhanced User Profile Screen with Supabase Integration

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/customer_models.dart';
import 'services/auth_service.dart';
import 'services/customer_service.dart';
import 'widgets/football_spinner.dart';
import 'settings.dart';

// Constants for consistent styling - matching vendor screen
const Color primaryColor = Color(0xFF1B2C4F);
const Color backgroundColor = Color(0xFFF5F6FA);
const Color textDarkColor = Color(0xFF2D3142);
const Color cardColor = Colors.white;

// Country code data
class CountryCode {
  final String name;
  final String code;
  final String flag;

  CountryCode({required this.name, required this.code, required this.flag});
}

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // Scroll tracking
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  final AuthService _authService = AuthService();
  CustomerProfile? _customerProfile;
  bool _isLoading = true;

  bool _isRecentActivitiesExpanded = false;
  bool _isFavoriteVenuesExpanded = false;

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

  // Add these additional variables for edit profile functionality
  String _selectedCountryCode = '+44'; // Default country code

  // Country code data
  final Map<String, Map<String, String>> _countryCodesMap = {
    '+1': {'maxDigits': '10', 'name': 'United States/Canada', 'flag': '🇺🇸'},
    '+44': {'maxDigits': '10', 'name': 'United Kingdom', 'flag': '🇬🇧'},
    '+91': {'maxDigits': '10', 'name': 'India', 'flag': '🇮🇳'},
    '+61': {'maxDigits': '10', 'name': 'Australia', 'flag': '🇦🇺'},
    '+86': {'maxDigits': '11', 'name': 'China', 'flag': '🇨🇳'},
    '+81': {'maxDigits': '11', 'name': 'Japan', 'flag': '🇯🇵'},
    '+49': {'maxDigits': '11', 'name': 'Germany', 'flag': '🇩🇪'},
    '+33': {'maxDigits': '10', 'name': 'France', 'flag': '🇫🇷'},
    '+39': {'maxDigits': '10', 'name': 'Italy', 'flag': '🇮🇹'},
    '+34': {'maxDigits': '9', 'name': 'Spain', 'flag': '🇪🇸'},
    '+7': {'maxDigits': '10', 'name': 'Russia', 'flag': '🇷🇺'},
    '+55': {'maxDigits': '11', 'name': 'Brazil', 'flag': '🇧🇷'},
    '+52': {'maxDigits': '10', 'name': 'Mexico', 'flag': '🇲🇽'},
    '+27': {'maxDigits': '9', 'name': 'South Africa', 'flag': '🇿🇦'},
    '+971': {'maxDigits': '9', 'name': 'UAE', 'flag': '🇦🇪'},
    '+65': {'maxDigits': '8', 'name': 'Singapore', 'flag': '🇸🇬'},
    '+60': {'maxDigits': '10', 'name': 'Malaysia', 'flag': '🇲🇾'},
    '+92': {'maxDigits': '10', 'name': 'Pakistan', 'flag': '🇵🇰'},
    '+880': {'maxDigits': '10', 'name': 'Bangladesh', 'flag': '🇧🇩'},
    '+94': {'maxDigits': '9', 'name': 'Sri Lanka', 'flag': '🇱🇰'},
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadUserData();
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

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      if (_authService.isAuthenticated) {
        _customerProfile = await CustomerService.getCurrentCustomerProfile();
      }
    } catch (e) {
      // Debug logging removed for production
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      if (mounted) {
        // Navigate back to home or show sign in dialog
        Navigator.pop(context);
      }
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
    // Navigate to help screen
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
                _signOut();
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

  // Method to show edit profile dialog - Matching vendor profile style exactly
  void _showEditProfileDialog() {
    if (!mounted) return;

    // Create text controllers with current values
    final nameController = TextEditingController(text: _customerProfile?.name ?? '');
    final statusController = TextEditingController(text: 'Sports Enthusiast'); // Default status
    final emailController = TextEditingController(text: _customerProfile?.email ?? '');
    final phoneController = TextEditingController(
      text: _getPhoneNumberWithoutCountryCode(_customerProfile?.phone ?? ''),
    );
    final locationController = TextEditingController(text: _customerProfile?.location ?? '');
    final addressController = TextEditingController(text: ''); // Address not in model yet

    // Extract country code from current phone number
    String tempSelectedCountryCode = _extractCountryCode(_customerProfile?.phone ?? '');
    
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) =>
              DraggableScrollableSheet(
                initialChildSize: 0.9,
                minChildSize: 0.5,
                maxChildSize: 0.95,
                builder: (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Simple Header - Matching vendor profile
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1B2C4F),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.pop(sheetContext),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Form Area
                      Expanded(
                        child: Form(
                          key: formKey,
                          child: SingleChildScrollView(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Basic Information
                                _buildSimpleFormField(
                                  controller: nameController,
                                  label: "Full Name",
                                  hint: "Enter your full name",
                                ),
                                const SizedBox(height: 16),

                                _buildSimpleFormField(
                                  controller: statusController,
                                  label: "Status",
                                  hint: "Sports Enthusiast",
                                  isRequired: false,
                                ),
                                const SizedBox(height: 16),

                                _buildSimpleFormField(
                                  controller: locationController,
                                  label: "Location",
                                  hint: "City, Country",
                                ),
                                const SizedBox(height: 16),

                                _buildSimpleFormField(
                                  controller: addressController,
                                  label: "Address",
                                  hint: "Enter your full address",
                                ),
                                const SizedBox(height: 16),

                                _buildSimpleFormField(
                                  controller: emailController,
                                  label: "Email",
                                  hint: "contact@email.com",
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 16),

                                _buildSimplePhoneField(
                                  controller: phoneController,
                                  countryCode: tempSelectedCountryCode,
                                  onCountryCodeChanged: (String newCode) {
                                    setDialogState(() {
                                      tempSelectedCountryCode = newCode;
                                    });
                                  },
                                ),
                                const SizedBox(height: 30),

                                // Save Button - Matching vendor style
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (formKey.currentState!.validate()) {
                                        await _saveUserProfileChanges(
                                          nameController,
                                          statusController,
                                          locationController,
                                          addressController,
                                          emailController,
                                          phoneController,
                                          tempSelectedCountryCode,
                                          sheetContext,
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1B2C4F),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 24,
                                      ),
                                      minimumSize: const Size(
                                        double.infinity,
                                        52,
                                      ),
                                    ),
                                    child: const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                // Add extra bottom padding to ensure button is visible
                                SizedBox(
                                  height: MediaQuery.of(context).viewInsets.bottom + 30,
                                ),
                              ],
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

  // Ultra Simple form field - Matching vendor profile style exactly
  Widget _buildSimpleFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D3142),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, color: Color(0xFF2D3142)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF8A8E99), fontSize: 15),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFE1E5E9)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFE1E5E9)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF1B2C4F), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) => _validateUserField(value, label, isRequired),
        ),
      ],
    );
  }

  // Ultra Simple phone field - Matching vendor profile style exactly
  Widget _buildSimplePhoneField({
    required TextEditingController controller,
    required String countryCode,
    required Function(String) onCountryCodeChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D3142),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            // Country code
            GestureDetector(
              onTap: () => _showCountryCodeDialog(onCountryCodeChanged),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE1E5E9)),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      countryCode,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 18,
                      color: Color(0xFF8A8E99),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Phone input
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                inputFormatters: _getPhoneInputFormatters(countryCode),
                style: const TextStyle(fontSize: 15, color: Color(0xFF2D3142)),
                decoration: InputDecoration(
                  hintText: 'Phone number',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8A8E99),
                    fontSize: 15,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFE1E5E9)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFE1E5E9)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(
                      color: Color(0xFF1B2C4F),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => _validateUserPhoneField(value, countryCode, true),
              ),
            ),
          ],
        ),
        // Helper text showing max digits
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Max ${_getMaxDigitsForCountryCode(countryCode)} digits',
            style: const TextStyle(fontSize: 12, color: Color(0xFF8A8E99)),
          ),
        ),
      ],
    );
  }

  // Helper method to get max digits for a country code
  int _getMaxDigitsForCountryCode(String countryCode) {
    final countryInfo = _countryCodesMap[countryCode];
    if (countryInfo != null && countryInfo.containsKey('maxDigits')) {
      return int.tryParse(countryInfo['maxDigits']!) ?? 10;
    }
    return 10; // Default max digits
  }

  // Custom phone input formatter with digit limit
  List<TextInputFormatter> _getPhoneInputFormatters(String countryCode) {
    final maxDigits = _getMaxDigitsForCountryCode(countryCode);
    return [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(maxDigits),
    ];
  }

  // Helper method to get phone number without country code for editing
  String _getPhoneNumberWithoutCountryCode(String fullPhoneNumber) {
    if (fullPhoneNumber.isEmpty) return '';

    // Remove all non-digit characters except spaces and common phone formatting
    String cleanPhone = fullPhoneNumber.replaceAll(
      RegExp(r'[^\d\s\-\(\)\+]'),
      '',
    );

    // If phone starts with +, try to remove the country code
    if (fullPhoneNumber.startsWith('+')) {
      for (String code in _countryCodesMap.keys) {
        if (fullPhoneNumber.startsWith(code)) {
          String remaining = fullPhoneNumber.substring(code.length).trim();
          return remaining.replaceAll(RegExp(r'[^\d]'), '');
        }
      }
    }

    // If no country code found, return the cleaned number
    return cleanPhone.replaceAll(RegExp(r'[^\d]'), '');
  }

  // Helper method to extract country code from phone number
  String _extractCountryCode(String phoneNumber) {
    if (phoneNumber.isEmpty) return '+44';

    // Remove all non-digit characters except +
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\+0-9]'), '');

    // Check if phone starts with + and try to match country codes
    if (cleanPhone.startsWith('+')) {
      // Sort by length (longest first) to match longer country codes first
      List<String> codes = _countryCodesMap.keys.toList();
      codes.sort((a, b) => b.length.compareTo(a.length));
      
      for (String code in codes) {
        if (cleanPhone.startsWith(code)) {
          return code;
        }
      }
    }

    // If no country code found, return default
    return '+44';
  }

  // Simplified country code selection dialog - Matching vendor profile style
  void _showCountryCodeDialog(Function(String) onCountryCodeChanged) {
    final countries = _countryCodesMap.keys.toList();
    List<String> filteredCountries = List.from(countries);
    final searchController = TextEditingController();

    // Sort countries alphabetically by name for better UX
    countries.sort(
      (a, b) =>
          _countryCodesMap[a]!['name']!.compareTo(_countryCodesMap[b]!['name']!),
    );
    filteredCountries = List.from(countries);

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          elevation: 8,
          child: Container(
            width: MediaQuery.of(context).size.width > 500
                ? 400
                : MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Select Country Code',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B2C4F),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF1B2C4F),
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search country...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF1B2C4F),
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        if (value.isEmpty) {
                          filteredCountries = List.from(countries);
                        } else {
                          filteredCountries = countries.where((code) {
                            final countryName = _countryCodesMap[code]!['name']!
                                .toLowerCase();
                            final searchTerm = value.toLowerCase();
                            return countryName.contains(searchTerm) ||
                                code.contains(searchTerm);
                          }).toList();
                        }
                      });
                    },
                  ),
                ),

                // Country List
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredCountries.length,
                    itemBuilder: (context, index) {
                      final code = filteredCountries[index];
                      final countryData = _countryCodesMap[code]!;
                      final isSelected = code == _selectedCountryCode;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1B2C4F).withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(
                                  color: const Color(0xFF1B2C4F),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          dense: true,
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey.withOpacity(0.1),
                            ),
                            child: Center(
                              child: Text(
                                countryData['flag']!,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  countryData['name']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? const Color(0xFF1B2C4F)
                                        : const Color(0xFF2D3142),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF1B2C4F)
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  code,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF1B2C4F),
                                  size: 20,
                                )
                              : null,
                          onTap: () {
                            onCountryCodeChanged(code);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced validation method for user profile fields
  String? _validateUserField(String? value, String label, bool isRequired) {
    // Check if field is required and empty
    if (isRequired && (value == null || value.trim().isEmpty)) {
      return 'This field is required';
    }

    // Skip validation for empty optional fields
    if (!isRequired && (value == null || value.trim().isEmpty)) {
      return null;
    }

    // Name validation
    if (label == "Full Name") {
      if (value!.trim().length < 2) {
        return 'Name must be at least 2 characters long';
      }
      if (value.trim().length > 50) {
        return 'Name cannot exceed 50 characters';
      }
      // Check if name contains only letters and spaces
      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
        return 'Name can only contain letters and spaces';
      }
    }

    // Email validation
    if (label == "Email") {
      const emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
      if (!RegExp(emailPattern).hasMatch(value!.trim())) {
        return 'Please enter a valid email address';
      }
    }

    // Location validation
    if (label == "Location") {
      if (value!.trim().length < 2) {
        return 'Location must be at least 2 characters long';
      }
      if (value.trim().length > 100) {
        return 'Location must be less than 100 characters';
      }
    }

    // Address validation
    if (label == "Address") {
      if (value!.trim().length < 5) {
        return 'Address must be at least 5 characters long';
      }
      if (value.trim().length > 200) {
        return 'Address must be less than 200 characters';
      }
    }

    // Status validation
    if (label == "Status") {
      if (value!.trim().length > 100) {
        return 'Status must be less than 100 characters';
      }
    }

    return null;
  }

  // Enhanced phone validation method
  String? _validateUserPhoneField(String? value, String countryCode, bool isRequired) {
    // Check if field is required and empty
    if (isRequired && (value == null || value.trim().isEmpty)) {
      return 'Phone number is required';
    }

    // Skip validation for empty optional fields
    if (!isRequired && (value == null || value.trim().isEmpty)) {
      return null;
    }

    String digitsOnly = value!.replaceAll(RegExp(r'[^\d]'), '');

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

  // Helper method to format phone number with country code
  String _formatPhoneWithCountryCode(String phoneNumber, String countryCode) {
    if (phoneNumber.trim().isEmpty) return '';

    // Remove any existing country code and non-digit characters
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Remove country code digits if they exist at the beginning
    String countryDigits = countryCode.replaceAll('+', '');
    if (cleanPhone.startsWith(countryDigits)) {
      cleanPhone = cleanPhone.substring(countryDigits.length);
    }

    // Remove leading zero for most countries (especially important for Sri Lanka and similar)
    if (cleanPhone.startsWith('0') && cleanPhone.length > 1) {
      cleanPhone = cleanPhone.substring(1);
    }

    // Return formatted phone number with country code
    return '$countryCode $cleanPhone';
  }

  // Save user profile changes method
  Future<void> _saveUserProfileChanges(
    TextEditingController nameController,
    TextEditingController statusController,
    TextEditingController locationController,
    TextEditingController addressController,
    TextEditingController emailController,
    TextEditingController phoneController,
    String tempSelectedCountryCode,
    BuildContext sheetContext,
  ) async {
    // Show loading with football spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: const Center(child: FootballSpinner(size: 60.0)),
        ),
      ),
    );

    try {
      // Create update data map
      final Map<String, dynamic> updateData = {};

      if (nameController.text.trim() != (_customerProfile?.name ?? '')) {
        updateData['name'] = nameController.text.trim();
      }
      if (locationController.text.trim() != (_customerProfile?.location ?? '')) {
        updateData['location'] = locationController.text.trim();
      }
      if (addressController.text.trim().isNotEmpty) {
        updateData['address'] = addressController.text.trim();
      }
      if (emailController.text.trim() != (_customerProfile?.email ?? '')) {
        updateData['email'] = emailController.text.trim();
      }
      if (phoneController.text.trim().isNotEmpty) {
        String formattedPhone = _formatPhoneWithCountryCode(
          phoneController.text.trim(),
          tempSelectedCountryCode,
        );
        if (formattedPhone != (_customerProfile?.phone ?? '')) {
          updateData['phone'] = formattedPhone;
        }
      }

      // Save to database if there are changes
      if (updateData.isNotEmpty) {
        try {
          await CustomerService.updateCustomerProfile(
            name: nameController.text.trim().isNotEmpty ? nameController.text.trim() : null,
            location: locationController.text.trim().isNotEmpty ? locationController.text.trim() : null,
            email: emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
            phone: phoneController.text.trim().isNotEmpty ? _formatPhoneWithCountryCode(
              phoneController.text.trim(),
              tempSelectedCountryCode,
            ) : null,
          );
        } catch (e) {
          // Close loading
          Navigator.pop(context);
          _showErrorSnackBar('Error saving changes: ${e.toString()}');
          return; // Exit early on profile update failure
        }
      }

      // Close loading
      Navigator.pop(context);

      // Update local state and reload user data
      if (mounted) {
        setState(() {
          _selectedCountryCode = tempSelectedCountryCode;
        });
        
        // Reload user data to get fresh data from database
        await _loadUserData();
      }

      // Close dialog and show success
      if (mounted) {
        Navigator.pop(sheetContext);
        _showSuccessSnackBar('Profile Updated', message: "Changes saved successfully");
      }
    } catch (e) {
      // Close loading if still open
      Navigator.pop(context);
      _showErrorSnackBar('Error saving changes: ${e.toString()}');
    }
  }

  // Helper methods for showing snackbars
  void _showSuccessSnackBar(String title, {String? message}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            if (message != null)
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while loading data
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: FootballSpinner()),
      );
    }

    // Handle case where user data couldn't be loaded or not authenticated
    if (!_authService.isAuthenticated) {
      return _buildSignInPrompt();
    }

    // Extract user data to variables for easy access
    final name = _customerProfile?.name ?? 'User';
    final status = 'Sports Enthusiast'; // Default status
    final location = _customerProfile?.location ?? 'Location not set';
    final email = _customerProfile?.email ?? 'email@example.com';
    final phone = _customerProfile?.phone ?? 'Phone not set';
    final favoriteVenues = _customerProfile?.favoriteVenues ?? [];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar - matching history screen style
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
                  Navigator.pop(context);
                },
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
                onPressed: () {
                  _showEditProfileDialog();
                },
                tooltip: 'Edit Profile',
              ),
              const SizedBox(width: 16),
            ],
          ),

          // USER NAME AND LOCATION SECTION - Matching home.dart styling
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  // Welcome text - matching home.dart
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "${name.split(' ').first} here",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B2C4F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Location card - matching home.dart style
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B2C4F),
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
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                location,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Current Location",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
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
            ),
          ),

          // ACTION BUTTONS ROW
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
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
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Profile Details Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16), // Reduced from 20
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
                  children: [
                    _buildCompactProfileDetailItem(
                      icon: Icons.person,
                      label: "Owner",
                      value: name.split(' ').first.toLowerCase(),
                    ),
                    Divider(
                      color: Colors.grey[200],
                      height: 12,
                    ), // Reduced height
                    _buildCompactProfileDetailItem(
                      icon: Icons.home,
                      label: "Address",
                      value: location,
                    ),
                    Divider(color: Colors.grey[200], height: 12),
                    _buildCompactProfileDetailItem(
                      icon: Icons.sports_soccer,
                      label: "Status Controller",
                      value: status, // or get from your data
                    ),
                    Divider(color: Colors.grey[200], height: 12),
                    _buildCompactProfileDetailItem(
                      icon: Icons.phone_outlined,
                      label: "Phone",
                      value: phone,
                      showPhoneFormatted: true,
                    ),
                    Divider(color: Colors.grey[200], height: 12),
                    _buildCompactProfileDetailItem(
                      icon: Icons.email_outlined,
                      label: "Email Address",
                      value: email,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Recent Activities Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16), // Reduced padding
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Recent Activities",
                          style: TextStyle(
                            fontSize: 16, // Reduced font size
                            fontWeight: FontWeight.w600,
                            color: textDarkColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isRecentActivitiesExpanded =
                                  !_isRecentActivitiesExpanded;
                            });
                          },
                          child: Icon(
                            _isRecentActivitiesExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.grey[600],
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    if (_isRecentActivitiesExpanded) ...[
                      const SizedBox(height: 16),
                      _buildEmptyState(
                        "No recent activities found",
                        Icons.history,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Favorite Venues Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16), // Reduced padding
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Favorite Venues",
                          style: TextStyle(
                            fontSize: 16, // Reduced font size
                            fontWeight: FontWeight.w600,
                            color: textDarkColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isFavoriteVenuesExpanded =
                                  !_isFavoriteVenuesExpanded;
                            });
                          },
                          child: Icon(
                            _isFavoriteVenuesExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.grey[600],
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    if (_isFavoriteVenuesExpanded) ...[
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
                            children: favoriteVenues.map((venueId) {
                              final index = favoriteVenues.indexOf(venueId);
                              return Row(
                                children: [
                                  if (index > 0) const SizedBox(width: 12),
                                  _buildVenueCard(
                                    'Venue $venueId',
                                    '4.5',
                                    '',
                                  ),
                                ],
                              );
                            }).toList(),
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

  Widget _buildSignInPrompt() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF1B2C4F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 100,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'Sign In Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please sign in to view your profile and manage your bookings.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // For now, show a simple dialog asking to sign in
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign In Required'),
                        content: const Text('Please create an account or sign in to access your profile.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B2C4F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactProfileDetailItem({
    required IconData icon,
    required String label,
    required String value,
    bool showPhoneFormatted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Reduced padding
      child: Row(
        children: [
          Icon(
            icon,
            size: 20, // Slightly smaller icon
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13, // Reduced font size
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                if (showPhoneFormatted && value.isNotEmpty)
                  _buildPhoneDisplay(value)
                else
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14, // Reduced font size
                      fontWeight: FontWeight.w500,
                      color: textDarkColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method to display phone number with country flag
  Widget _buildPhoneDisplay(String phoneNumber) {
    if (phoneNumber.startsWith('+44')) {
      return Row(
        children: [
          const Text('🇬🇧', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            phoneNumber.replaceFirst('+44 ', ''),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textDarkColor,
            ),
          ),
        ],
      );
    } else if (phoneNumber.startsWith('+94')) {
      return Row(
        children: [
          const Text('🇱🇰', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            phoneNumber.replaceFirst('+94 ', ''),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textDarkColor,
            ),
          ),
        ],
      );
    } else {
      return Text(
        phoneNumber,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textDarkColor,
        ),
      );
    }
  }
}
