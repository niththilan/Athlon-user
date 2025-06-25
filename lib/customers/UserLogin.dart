// ignore: file_names
// ignore_for_file: deprecated_member_use, file_names, duplicate_ignore, use_build_context_synchronously, use_super_parameters

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import '../services/supabase_service.dart'; // Uncomment when you have Supabase service
// import 'homepage.dart'; // Import your homepage

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF1B2C4F),
          secondary: const Color(0xFF6B8AFE),
          surface: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF1B2C4F),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true; // Toggle between login and signup
  // Toggle between player and complex owner
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = false;
  bool _agreeToTerms = false; // Checkbox for terms in signup
  bool _attemptedSubmission = false; // Track submission attempts

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _facilityNameController = TextEditingController(); // For facility name
  final _locationController = TextEditingController(); // For location

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _facilityNameController.dispose();
    _locationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _attemptedSubmission = false; // Reset submission attempt when toggling
      // Reset fields when toggling
      if (!_isLogin) {
        // When switching to signup
        _passwordController.clear();
      } else {
        // When switching to login
        _confirmPasswordController.clear();
        _nameController.clear();
        _phoneController.clear();
        _facilityNameController.clear();
        _locationController.clear();
      }
    });
    // Play animation when switching modes
    _animationController.reset();
    _animationController.forward();
  }

  void _showForgotPasswordModal() {
    final forgotEmailController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Forgot Password',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2C4F),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: forgotEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email address',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF6B8AFE),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final email = forgotEmailController.text.trim();
                    if (email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter your email'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      // TO DO: Implement password reset logic with Supabase
                      // await SupabaseService.client.auth.resetPasswordForEmail(email);

                      // Close the modal
                      Navigator.pop(context);

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Password reset link sent to $email (mock)',
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${error.toString()}'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B2C4F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('SEND RESET LINK'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // New method to show Terms and Conditions
  void _showTermsAndConditions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Terms and Conditions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2C4F),
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(
                height: 300,
                child: SingleChildScrollView(
                  child: Text(
                    'By creating an account as a Complex Owner, you agree to our Terms of Service and Privacy Policy. '
                    'These terms govern your use of our sports complex management platform.\n\n'
                    '1. ACCOUNT REQUIREMENTS\n'
                    '• You must be the legal owner or authorized representative of the sports facility\n'
                    '• All facility and contact information must be accurate and up-to-date\n'
                    '• You are responsible for maintaining the security of your account credentials\n\n'
                    '2. PLATFORM USAGE\n'
                    '• Use the platform solely for legitimate sports complex management purposes\n'
                    '• Ensure all bookings and transactions comply with local laws and regulations\n'
                    '• Maintain appropriate insurance coverage for your facility\n\n'
                    '3. DATA AND PRIVACY\n'
                    '• We collect facility data, booking information, and customer details to provide our services\n'
                    '• Customer payment information is processed securely through certified payment processors\n'
                    '• You maintain ownership of your facility data and can export it at any time\n\n'
                    '4. RESPONSIBILITIES\n'
                    '• Ensure your facility meets all safety standards and regulations\n'
                    '• Handle customer disputes and refunds according to your published policies\n'
                    '• Notify us immediately of any security breaches or unauthorized access\n\n'
                    'By proceeding, you acknowledge that you have read and agree to these terms.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B2C4F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('I UNDERSTAND'),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  void _handleLogin() async {
    // Set attempted submission to true
    setState(() {
      _attemptedSubmission = true;
    });

    // Validate form
    if (_formKey.currentState!.validate()) {
      // For signup, check if terms are agreed to
      if (!_isLogin && !_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please agree to Terms and Conditions'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF1B2C4F)),
        ),
      );

      try {
        if (_isLogin) {
          // TO DO: Login with Supabase
          // final response = await SupabaseService.signIn(
          //   email: _emailController.text.trim(),
          //   password: _passwordController.text,
          // );

          // Close loading dialog
          if (mounted) {
            Navigator.of(context).pop();
          }

          // Mock successful login
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login successful! (mock)'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            // Navigate to appropriate homepage
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const FacilityOwnerHomePage(),
              ),
            );
          }
        } else {
          // TO DO: Sign up with Supabase
          // final response = await SupabaseService.signUp(
          //   email: _emailController.text.trim(),
          //   password: _passwordController.text,
          // );

          // Mock signup success
          if (mounted) {
            Navigator.of(context).pop(); // Close loading dialog

            // For facility owners, create profile
            // TO DO: Implement profile creation with Supabase
            // await SupabaseService.createUserProfile(
            //   userId: response.user!.id,
            //   name: _nameController.text.trim(),
            //   phone: _phoneController.text.trim(),
            //   facilityName: _facilityNameController.text.trim(),
            //   userType: 'vendor',
            //   location: _locationController.text.trim().isNotEmpty
            //       ? _locationController.text.trim()
            //       : null,
            // );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Account and profile created successfully! Please check your email to verify your account. (mock)',
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 4),
              ),
            );

            // Switch to login mode after successful signup
            setState(() {
              _isLogin = true;
              _attemptedSubmission = false;
              _emailController.clear();
              _passwordController.clear();
              _confirmPasswordController.clear();
              _nameController.clear();
              _phoneController.clear();
              _facilityNameController.clear();
              _locationController.clear();
              _agreeToTerms = false;
            });
          }
        }
      } catch (error) {
        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo Image
                      SizedBox(
                        height: 60,
                        child: Image.asset(
                          'assets/Athlon.png',
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Show debug info but no fallback text
                            // ignore: avoid_print
                            print('Error loading Athlon.png: $error');
                            return const SizedBox(
                              height: 60,
                            ); // Empty space if image fails
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _isLogin ? 'Welcome Back!' : 'Create Account',
                        style: const TextStyle(
                          color: Color(0xFF1B2C4F),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isLogin
                            ? 'Sign in to your account'
                            : 'Register as a User',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 35),

                      // Name Field (Sign up only)
                      if (!_isLogin) ...[
                        _buildInputField(
                          controller: _nameController,
                          hintText: 'Full Name',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Location Field (Sign up only)
                        _buildInputField(
                          controller: _locationController,
                          hintText: 'Location (Optional)',
                          icon: Icons.location_on_outlined,
                          validator: null, // Optional field
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email Field
                      _buildInputField(
                        controller: _emailController,
                        hintText: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone Field (Sign up only)
                      if (!_isLogin) ...[
                        _buildInputField(
                          controller: _phoneController,
                          hintText: 'Phone Number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Password Field
                      _buildPasswordField(
                        controller: _passwordController,
                        hintText: 'Password',
                        obscureText: _obscurePassword,
                        toggleObscure: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (!_isLogin && value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Field (Sign up only)
                      if (!_isLogin) ...[
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm Password',
                          obscureText: _obscureConfirmPassword,
                          toggleObscure: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords don\'t match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Remember Me & Forgot Password (Login only)
                      if (_isLogin)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Remember Me
                            Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                    activeColor: const Color(0xFF6B8AFE),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(
                                    color: Color(0xFF1B2C4F),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),

                            // Forgot Password
                            TextButton(
                              onPressed: _showForgotPasswordModal,
                              style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Color(0xFF6B8AFE),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                      // Terms & Conditions (Sign up only)
                      if (!_isLogin)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Agree to Terms
                              Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _agreeToTerms,
                                      onChanged: (value) {
                                        setState(() {
                                          _agreeToTerms = value ?? false;
                                        });
                                      },
                                      activeColor: const Color(0xFF6B8AFE),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'I agree to the',
                                    style: TextStyle(
                                      color: Color(0xFF1B2C4F),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),

                              // Terms and Conditions Link
                              TextButton(
                                onPressed: _showTermsAndConditions,
                                style: TextButton.styleFrom(
                                  minimumSize: Size.zero,
                                  padding: EdgeInsets.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Terms & Conditions',
                                  style: TextStyle(
                                    color: Color(0xFF6B8AFE),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Login/Signup Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B2C4F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _isLogin ? 'LOGIN' : 'SIGN UP',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFAFAFA),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // OR continue with
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey[400],
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey[400],
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Google Login Button (centered)
                      Center(
                        child: _buildSocialButton(
                          icon: FontAwesomeIcons.google,
                          color: const Color(0xFF4285F4),
                          size: 28,
                          onPressed: () {
                            // Google login
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Google login will be implemented',
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Toggle Login/Signup
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin
                                ? 'Don\'t have an account?'
                                : 'Already have an account?',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: _toggleMode,
                            child: Text(
                              _isLogin ? 'Sign Up' : 'Login',
                              style: const TextStyle(
                                color: Color(0xFF6B8AFE),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1B2C4F)),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Icon(icon, color: const Color(0xFF6B8AFE), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              errorStyle: const TextStyle(
                color: Colors.transparent,
                fontSize: 0,
              ),
            ),
            validator: (value) {
              // Only show validation error if submission was attempted
              if (_attemptedSubmission) {
                return validator?.call(value);
              }
              return null;
            },
            onChanged: (value) {
              // If field is filled after error was shown, update state to remove error
              if (_attemptedSubmission && _formKey.currentState != null) {
                _formKey.currentState!.validate();
              }
            },
          ),
        ),
        if (_attemptedSubmission)
          Builder(
            builder: (context) {
              String? errorText = validator?.call(controller.text);
              if (errorText != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 6, left: 12),
                  child: Text(
                    errorText,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback toggleObscure,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1B2C4F)),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Color(0xFF6B8AFE),
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: toggleObscure,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              errorStyle: const TextStyle(
                color: Colors.transparent,
                fontSize: 0,
              ),
            ),
            validator: (value) {
              // Only show validation error if submission was attempted
              if (_attemptedSubmission) {
                return validator?.call(value);
              }
              return null;
            },
            onChanged: (value) {
              // If field is filled after error was shown, update state to remove error
              if (_attemptedSubmission && _formKey.currentState != null) {
                _formKey.currentState!.validate();
              }
            },
          ),
        ),
        if (_attemptedSubmission)
          Builder(
            builder: (context) {
              String? errorText = validator?.call(controller.text);
              if (errorText != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 6, left: 12),
                  child: Text(
                    errorText,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double size = 30,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: size),
        onPressed: onPressed,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Welcome to the Home Screen!')),
    );
  }
}

class FacilityOwnerHomePage extends StatelessWidget {
  const FacilityOwnerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Facility Owner Home')),
      body: const Center(child: Text('Welcome, Facility Owner!')),
    );
  }
}
