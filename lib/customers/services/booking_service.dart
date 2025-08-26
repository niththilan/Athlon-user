// Enhanced Booking Service with Supabase Integration

import 'package:flutter/material.dart';
import '../models/customer_models.dart';
import '../models/venue_models.dart';
import '../services/customer_service.dart';
import '../services/auth_service.dart';

class BookingService extends ChangeNotifier {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  List<BookingModel> _userBookings = [];
  bool _isLoading = false;

  List<BookingModel> get userBookings => _userBookings;
  bool get isLoading => _isLoading;

  // Create a new booking
  Future<BookingResult> createBooking({
    required VenueModel venue,
    required Court court,
    required DateTime bookingDate,
    required String timeSlot,
    required DateTime startTime,
    required DateTime endTime,
    required int durationMinutes,
    required double price,
    required double totalAmount,
    String? specialRequests,
    String? paymentMethod = 'pending',
  }) async {
    if (!AuthService().isAuthenticated) {
      return BookingResult.error('Please sign in to make a booking.');
    }

    final customerProfile = AuthService().currentCustomerProfile;
    if (customerProfile == null) {
      return BookingResult.error('Customer profile not found. Please complete your profile.');
    }

    _setLoading(true);

    try {
      // Validate booking data
      final validationResult = _validateBookingData(
        bookingDate: bookingDate,
        startTime: startTime,
        endTime: endTime,
        durationMinutes: durationMinutes,
      );

      if (!validationResult.isSuccess) {
        return validationResult;
      }

      // Check if time slot is still available
      final isAvailable = await _checkTimeSlotAvailability(
        courtId: court.id,
        date: bookingDate,
        timeSlot: timeSlot,
      );

      if (!isAvailable) {
        return BookingResult.error('This time slot is no longer available. Please select another time.');
      }

      // Create booking in database
      final bookingId = await CustomerService.createBooking(
        facilityId: venue.id,
        courtId: court.id,
        customerName: customerProfile.name,
        customerPhone: customerProfile.phone,
        customerEmail: customerProfile.email,
        courtName: court.name,
        courtType: court.type,
        bookingDate: bookingDate,
        timeSlot: timeSlot,
        startTime: startTime,
        endTime: endTime,
        durationMinutes: durationMinutes,
        price: price,
        totalAmount: totalAmount,
        specialRequests: specialRequests,
        paymentMethod: paymentMethod,
      );

      // Refresh user bookings
      await loadUserBookings();

      return BookingResult.success(
        bookingId: bookingId,
        message: 'Booking created successfully!',
      );
    } catch (e) {
      print('Error creating booking: $e');
      return BookingResult.error('Failed to create booking. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  // Load user bookings
  Future<void> loadUserBookings() async {
    if (!AuthService().isAuthenticated) {
      _userBookings = [];
      notifyListeners();
      return;
    }

    _setLoading(true);

    try {
      _userBookings = await CustomerService.getCustomerBookings(limit: 100);
      notifyListeners();
    } catch (e) {
      print('Error loading user bookings: $e');
      _userBookings = [];
    } finally {
      _setLoading(false);
    }
  }

  // Get booking details
  Future<BookingModel?> getBookingDetails(String bookingId) async {
    try {
      return await CustomerService.getBookingDetails(bookingId);
    } catch (e) {
      print('Error getting booking details: $e');
      return null;
    }
  }

  // Cancel booking
  Future<BookingResult> cancelBooking(String bookingId, String reason) async {
    _setLoading(true);

    try {
      await CustomerService.cancelBooking(bookingId, reason);
      await loadUserBookings(); // Refresh bookings list

      return BookingResult.success(
        bookingId: bookingId,
        message: 'Booking cancelled successfully.',
      );
    } catch (e) {
      print('Error cancelling booking: $e');
      return BookingResult.error('Failed to cancel booking. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  // Check in to booking
  Future<BookingResult> checkInBooking(String bookingId) async {
    _setLoading(true);

    try {
      await CustomerService.checkInBooking(bookingId);
      await loadUserBookings(); // Refresh bookings list

      return BookingResult.success(
        bookingId: bookingId,
        message: 'Checked in successfully!',
      );
    } catch (e) {
      print('Error checking in: $e');
      return BookingResult.error('Failed to check in. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  // Get available time slots for a court
  Future<List<Map<String, dynamic>>> getAvailableTimeSlots({
    required String courtId,
    required DateTime date,
  }) async {
    try {
      return await CustomerService.getAvailableTimeSlots(
        courtId: courtId,
        date: date,
      );
    } catch (e) {
      print('Error getting available time slots: $e');
      return [];
    }
  }

  // Generate time slots for a court (if not already generated)
  Future<void> generateTimeSlots({
    required String courtId,
    required DateTime date,
  }) async {
    try {
      await CustomerService.generateTimeSlotsForCourt(
        courtId: courtId,
        date: date,
      );
    } catch (e) {
      print('Error generating time slots: $e');
    }
  }

  // Filter bookings by status
  List<BookingModel> getBookingsByStatus(BookingStatus status) {
    return _userBookings.where((booking) => booking.status == status).toList();
  }

  // Get upcoming bookings
  List<BookingModel> getUpcomingBookings() {
    final now = DateTime.now();
    return _userBookings
        .where((booking) => 
            booking.startTime.isAfter(now) && 
            booking.status == BookingStatus.confirmed)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Get past bookings
  List<BookingModel> getPastBookings() {
    final now = DateTime.now();
    return _userBookings
        .where((booking) => booking.endTime.isBefore(now))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  // Calculate total amount with any applicable discounts
  double calculateTotalAmount({
    required double basePrice,
    required int durationMinutes,
    CustomerProfile? customerProfile,
    VenueModel? venue,
  }) {
    double totalAmount = basePrice * (durationMinutes / 60.0);

    // Apply loyalty discounts if applicable
    if (customerProfile?.loyaltyStatus != null && venue != null) {
      final loyaltyStatus = customerProfile!.loyaltyStatus!;
      if (loyaltyStatus.facilityId == venue.id) {
        // Apply loyalty discount based on tier
        switch (loyaltyStatus.tierLevel) {
          case 'silver':
            totalAmount *= 0.95; // 5% discount
            break;
          case 'gold':
            totalAmount *= 0.90; // 10% discount
            break;
          case 'platinum':
            totalAmount *= 0.85; // 15% discount
            break;
        }
      }
    }

    return double.parse(totalAmount.toStringAsFixed(2));
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  BookingResult _validateBookingData({
    required DateTime bookingDate,
    required DateTime startTime,
    required DateTime endTime,
    required int durationMinutes,
  }) {
    final now = DateTime.now();

    // Check if booking date is in the past
    if (bookingDate.isBefore(DateTime(now.year, now.month, now.day))) {
      return BookingResult.error('Cannot book for past dates.');
    }

    // Check if start time is in the past
    if (startTime.isBefore(now)) {
      return BookingResult.error('Cannot book for past times.');
    }

    // Check if end time is after start time
    if (endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime)) {
      return BookingResult.error('End time must be after start time.');
    }

    // Check minimum booking duration (e.g., 30 minutes)
    if (durationMinutes < 30) {
      return BookingResult.error('Minimum booking duration is 30 minutes.');
    }

    // Check maximum booking duration (e.g., 8 hours)
    if (durationMinutes > 480) {
      return BookingResult.error('Maximum booking duration is 8 hours.');
    }

    // Check if booking is too far in advance (e.g., 30 days)
    final maxAdvanceDays = 30;
    final maxAdvanceDate = now.add(Duration(days: maxAdvanceDays));
    if (bookingDate.isAfter(maxAdvanceDate)) {
      return BookingResult.error('Cannot book more than $maxAdvanceDays days in advance.');
    }

    return BookingResult.success(message: 'Booking data is valid.');
  }

  Future<bool> _checkTimeSlotAvailability({
    required String courtId,
    required DateTime date,
    required String timeSlot,
  }) async {
    try {
      final timeSlots = await getAvailableTimeSlots(
        courtId: courtId,
        date: date,
      );

      final targetSlot = timeSlots.where((slot) => 
          slot['time_slot'] == timeSlot && 
          slot['status'] == 'available'
      ).firstOrNull;

      return targetSlot != null;
    } catch (e) {
      print('Error checking time slot availability: $e');
      return false;
    }
  }

  // Utility methods for UI
  String formatBookingTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String formatBookingDate(DateTime date) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  String getBookingStatusText(BookingStatus status) {
    return status.displayName;
  }

  Color getBookingStatusColor(BookingStatus status) {
    return status.color;
  }
}

class BookingResult {
  final bool isSuccess;
  final String message;
  final String? bookingId;

  BookingResult._({
    required this.isSuccess,
    required this.message,
    this.bookingId,
  });

  factory BookingResult.success({
    required String message,
    String? bookingId,
  }) {
    return BookingResult._(
      isSuccess: true,
      message: message,
      bookingId: bookingId,
    );
  }

  factory BookingResult.error(String message) {
    return BookingResult._(
      isSuccess: false,
      message: message,
    );
  }
}
