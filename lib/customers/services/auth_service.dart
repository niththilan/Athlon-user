// Customer Authentication Service for Athlon User App

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer_models.dart';
import 'customer_service.dart';
import 'supabase_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  CustomerProfile? _currentCustomerProfile;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  CustomerProfile? get currentCustomerProfile => _currentCustomerProfile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  // Initialize auth service
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      _currentUser = SupabaseService.currentUser;
      
      if (_currentUser != null) {
        await _loadCustomerProfile();
      }
      
      // Listen to auth state changes
      SupabaseService.client.auth.onAuthStateChange.listen((data) {
        _handleAuthStateChange(data.event, data.session);
      });
    } catch (e) {
      print('Error initializing auth service: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _handleAuthStateChange(AuthChangeEvent event, Session? session) async {
    print('Auth state changed: $event');
    
    switch (event) {
      case AuthChangeEvent.signedIn:
        _currentUser = session?.user;
        await _loadCustomerProfile();
        break;
      case AuthChangeEvent.signedOut:
        _currentUser = null;
        _currentCustomerProfile = null;
        break;
      case AuthChangeEvent.userUpdated:
        _currentUser = session?.user;
        await _loadCustomerProfile();
        break;
      default:
        break;
    }
    
    notifyListeners();
  }

  Future<void> _loadCustomerProfile() async {
    if (_currentUser == null) return;
    
    try {
      _currentCustomerProfile = await CustomerService.getCurrentCustomerProfile();
    } catch (e) {
      print('Error loading customer profile: $e');
      _currentCustomerProfile = null;
    }
  }

  // Sign up new customer
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    String? location,
  }) async {
    _setLoading(true);
    
    try {
      final response = await CustomerService.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      if (response.user != null) {
        _currentUser = response.user;
        await _loadCustomerProfile();
        
        return AuthResult.success(
          message: 'Account created successfully! Please check your email to verify your account.',
        );
      } else {
        return AuthResult.error('Failed to create account. Please try again.');
      }
    } on AuthException catch (e) {
      return AuthResult.error(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.error('An unexpected error occurred. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  // Sign in existing customer
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    
    try {
      final response = await CustomerService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;
        await _loadCustomerProfile();
        
        return AuthResult.success(message: 'Welcome back!');
      } else {
        return AuthResult.error('Failed to sign in. Please check your credentials.');
      }
    } on AuthException catch (e) {
      return AuthResult.error(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.error('An unexpected error occurred. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      await CustomerService.signOut();
      _currentUser = null;
      _currentCustomerProfile = null;
    } catch (e) {
      print('Error signing out: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<AuthResult> resetPassword(String email) async {
    _setLoading(true);
    
    try {
      await CustomerService.resetPassword(email);
      return AuthResult.success(
        message: 'Password reset instructions sent to your email.',
      );
    } on AuthException catch (e) {
      return AuthResult.error(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.error('Failed to send reset email. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  // Update customer profile
  Future<AuthResult> updateProfile({
    String? name,
    String? phone,
    String? email,
    String? location,
    List<String>? preferredSports,
    CustomerPreferences? preferences,
  }) async {
    if (!isAuthenticated) {
      return AuthResult.error('Please sign in to update your profile.');
    }

    _setLoading(true);
    
    try {
      await CustomerService.updateCustomerProfile(
        name: name,
        phone: phone,
        email: email,
        location: location,
        preferredSports: preferredSports,
        preferences: preferences,
      );

      await _loadCustomerProfile();
      
      return AuthResult.success(message: 'Profile updated successfully!');
    } catch (e) {
      return AuthResult.error('Failed to update profile. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  // Update password
  Future<AuthResult> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!isAuthenticated) {
      return AuthResult.error('Please sign in to update your password.');
    }

    _setLoading(true);
    
    try {
      // First verify current password by attempting to sign in
      final email = _currentUser!.email!;
      await SupabaseService.signIn(email: email, password: currentPassword);
      
      // Update password
      await SupabaseService.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      
      return AuthResult.success(message: 'Password updated successfully!');
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login')) {
        return AuthResult.error('Current password is incorrect.');
      }
      return AuthResult.error(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.error('Failed to update password. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  // Delete account
  Future<AuthResult> deleteAccount(String password) async {
    if (!isAuthenticated) {
      return AuthResult.error('Please sign in to delete your account.');
    }

    _setLoading(true);
    
    try {
      // Verify password first
      final email = _currentUser!.email!;
      await SupabaseService.signIn(email: email, password: password);
      
      // Note: Supabase doesn't have a direct delete user method for security
      // This would typically be handled server-side with an RPC function
      // For now, we'll sign out and show a message
      await signOut();
      
      return AuthResult.success(
        message: 'Account deletion requested. Please contact support to complete the process.',
      );
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login')) {
        return AuthResult.error('Password is incorrect.');
      }
      return AuthResult.error(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.error('Failed to delete account. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  // Get user-friendly error messages
  String _getAuthErrorMessage(AuthException exception) {
    switch (exception.message.toLowerCase()) {
      case 'invalid login credentials':
        return 'Invalid email or password. Please check your credentials.';
      case 'email not confirmed':
        return 'Please check your email and click the confirmation link.';
      case 'user already exists':
        return 'An account with this email already exists.';
      case 'invalid email':
        return 'Please enter a valid email address.';
      case 'password should be at least 6 characters':
        return 'Password must be at least 6 characters long.';
      case 'signup disabled':
        return 'New account registration is temporarily disabled.';
      case 'too many requests':
        return 'Too many attempts. Please wait a moment and try again.';
      default:
        return exception.message;
    }
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate password strength
  static String? validatePassword(String password) {
    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null; // Password is valid
  }

  // Validate phone number (Sri Lankan format)
  static bool isValidPhoneNumber(String phone) {
    // Remove any spaces, dashes, or other formatting
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Check Sri Lankan mobile numbers: +94xxxxxxxxx or 07xxxxxxxx
    return RegExp(r'^(\+94[1-9]\d{8}|0[1-9]\d{8})$').hasMatch(cleanPhone);
  }
}

class AuthResult {
  final bool isSuccess;
  final String message;

  AuthResult._({required this.isSuccess, required this.message});

  factory AuthResult.success({required String message}) {
    return AuthResult._(isSuccess: true, message: message);
  }

  factory AuthResult.error(String message) {
    return AuthResult._(isSuccess: false, message: message);
  }
}
