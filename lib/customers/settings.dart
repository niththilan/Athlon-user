// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'payment_methods.dart'; // Import the PaymentMethods screen

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings state variables
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2C4F),
        elevation: _isScrolled ? 2 : 0,
        toolbarHeight: 50,
        title: const Text(
          "Settings",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        leading: Container(
          margin: const EdgeInsets.fromLTRB(16, 3, 8, 8),
          child: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        actions: [],
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        children: [
          // Account Settings Section
          _buildSettingsCategory(
            title: 'Account',
            tiles: [
              _buildSettingsTile(
                icon: Icons.payment,
                iconColor: Colors.green,
                title: 'Payment Methods',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentMethodsScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.lock_outline,
                iconColor: Colors.orange,
                title: 'Change Password',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Notifications Section
          _buildSettingsCategory(
            title: 'Notifications',
            tiles: [
              _buildToggleTile(
                icon: Icons.notifications_outlined,
                iconColor: Colors.red,
                title: 'Push Notifications',
                subtitle: 'Receive alerts for bookings and events',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              _buildSettingsTile(
                icon: Icons.email_outlined,
                iconColor: Colors.purple,
                title: 'Email Notifications',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Privacy & Location Section
          _buildSettingsCategory(
            title: 'Privacy & Location',
            tiles: [
              _buildToggleTile(
                icon: Icons.location_on_outlined,
                iconColor: Colors.indigo,
                title: 'Location Services',
                subtitle: 'Allow app to access your location',
                value: _locationEnabled,
                onChanged: (value) {
                  setState(() {
                    _locationEnabled = value;
                  });
                },
              ),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                iconColor: Colors.teal,
                title: 'Privacy Policy',
                onTap: () {
                  _showFeatureNotImplemented(context, 'Privacy Policy');
                },
              ),
              _buildSettingsTile(
                icon: Icons.description_outlined,
                iconColor: Colors.blueGrey,
                title: 'Terms of Service',
                onTap: () {
                  _showFeatureNotImplemented(context, 'Terms of Service');
                },
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Appearance Section
          _buildSettingsCategory(
            title: 'Appearance',
            tiles: [
              _buildToggleTile(
                icon: Icons.dark_mode_outlined,
                iconColor: Colors.deepPurple,
                title: 'Dark Mode',
                subtitle: 'Change app theme',
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                },
              ),
              _buildSettingsTile(
                icon: Icons.language,
                iconColor: Colors.cyan,
                title: 'Language',
                subtitle: _selectedLanguage,
                onTap: () {
                  _showLanguageDialog(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Support Section
          _buildSettingsCategory(
            title: 'Support',
            tiles: [
              _buildSettingsTile(
                icon: Icons.help_outline,
                iconColor: Colors.amber,
                title: 'Help Center',
                onTap: () {
                  _showFeatureNotImplemented(context, 'Help Center');
                },
              ),
              _buildSettingsTile(
                icon: Icons.report_problem_outlined,
                iconColor: Colors.red,
                title: 'Report a Problem',
                onTap: () {
                  _showFeatureNotImplemented(context, 'Report a Problem');
                },
              ),
              _buildSettingsTile(
                icon: Icons.support_agent,
                iconColor: Colors.green,
                title: 'Contact Us',
                onTap: () {
                  _showFeatureNotImplemented(context, 'Contact Us');
                },
              ),
            ],
          ),

          const SizedBox(height: 18),

          // About Section
          _buildSettingsCategory(
            title: 'About',
            tiles: [
              _buildSettingsTile(
                icon: Icons.info_outline,
                iconColor: Colors.blue,
                title: 'App Version',
                subtitle: 'v1.0.0',
                onTap: () {},
              ),
            ],
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B2C4F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: () {
                _showLogoutDialog(context);
              },
              child: const Text(
                'Logout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCategory({
    required String title,
    required List<Widget> tiles,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B2C4F),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF1B2C4F),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1B2C4F),
          ),
        ],
      ),
    );
  }

  void _showFeatureNotImplemented(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature will be implemented soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFF1B2C4F),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption('English'),
                _buildLanguageOption('Sinhala'),
                _buildLanguageOption('Tamil'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language) {
    return ListTile(
      title: Text(language),
      trailing: _selectedLanguage == language
          ? const Icon(Icons.check, color: Color(0xFF1B2C4F))
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B2C4F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Implement logout functionality
                Navigator.of(context).pop();
                _showFeatureNotImplemented(context, 'Logout');
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}

// Add main function to run the file independently
void main() {
  runApp(const SettingsApp());
}

// Standalone app wrapper for SettingsScreen
class SettingsApp extends StatelessWidget {
  const SettingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Settings',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B2C4F),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      ),
      home: const SettingsScreen(),
    );
  }
}
