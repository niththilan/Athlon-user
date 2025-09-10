// Enhanced customer service for Athlon User App with Supabase integration

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer_models.dart';
import '../models/venue_models.dart';
import 'supabase_service.dart';

class CustomerService {
  static final _supabase = SupabaseService.client;

  // Customer Profile Management
  static Future<CustomerProfile?> getCurrentCustomerProfile() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('customers')
          .select('''
            *,
            customer_favorites(facility_id),
            customer_loyalty(*)
          ''')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        // Create customer profile if it doesn't exist
        return await createCustomerProfile(
          name: user.userMetadata?['name'] ?? 'Customer',
          phone: user.phone ?? '',
          email: user.email,
        );
      }

      return CustomerProfile.fromSupabase(response);
    } catch (e) {
      print('Error getting customer profile: $e');
      return null;
    }
  }

  static Future<CustomerProfile> createCustomerProfile({
    required String name,
    required String phone,
    String? email,
    String? location,
    List<String>? preferredSports,
  }) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create customer profile in customers table
      final customerData = {
        'id': user.id,
        'name': name,
        'phone': phone,
        'email': email ?? user.email,
        'location': location,
        'preferred_sports': preferredSports ?? [],
        'preferences': CustomerPreferences().toJson(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final customerResponse = await _supabase
          .from('customers')
          .insert(customerData)
          .select()
          .single();

      // Also create profile in profiles table with user_type = 'customer'
      final profileData = {
        'id': user.id,
        'name': name,
        'phone': phone,
        'user_type': 'customer',
        'location': location,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('profiles')
          .insert(profileData);

      return CustomerProfile.fromSupabase(customerResponse);
    } catch (e) {
      print('Error creating customer profile: $e');
      rethrow;
    }
  }

  static Future<void> updateCustomerProfile({
    String? name,
    String? phone,
    String? email,
    String? location,
    String? profileImageUrl,
    List<String>? preferredSports,
    CustomerPreferences? preferences,
  }) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (email != null) updates['email'] = email;
      if (location != null) updates['location'] = location;
      if (profileImageUrl != null) updates['profile_image_url'] = profileImageUrl;
      if (preferredSports != null) updates['preferred_sports'] = preferredSports;
      if (preferences != null) updates['preferences'] = preferences.toJson();

      await _supabase
          .from('customers')
          .update(updates)
          .eq('id', user.id);
    } catch (e) {
      print('Error updating customer profile: $e');
      rethrow;
    }
  }

  // Venue Search and Discovery
  static Future<List<VenueModel>> searchVenues({
    String? searchTerm,
    String? location,
    List<String>? sports,
    double? minRating,
    double? maxDistance,
    String? sortBy = 'distance', // distance, rating, price
  }) async {
    try {
      final venuesData = await SupabaseService.searchVenues(
        searchTerm: searchTerm,
        location: location,
        sports: sports,
        minRating: minRating,
        maxDistance: maxDistance,
      );

      final venues = venuesData.map((data) {
        try {
          return VenueModel.fromSupabase(data);
        } catch (e) {
          print('Warning: Failed to parse venue ${data['name']}: $e');
          return null;
        }
      }).where((venue) => venue != null).cast<VenueModel>().toList();

      // Sort venues
      switch (sortBy) {
        case 'rating':
          venues.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'price':
          venues.sort((a, b) {
            final aMinPrice = a.courts.isNotEmpty 
                ? a.courts.map((c) => c.hourlyRate).reduce((min, rate) => min < rate ? min : rate)
                : 0.0;
            final bMinPrice = b.courts.isNotEmpty 
                ? b.courts.map((c) => c.hourlyRate).reduce((min, rate) => min < rate ? min : rate)
                : 0.0;
            return aMinPrice.compareTo(bMinPrice);
          });
          break;
        case 'distance':
        default:
          venues.sort((a, b) => a.distance.compareTo(b.distance));
          break;
      }

      return venues;
    } catch (e) {
      print('Error searching venues: $e');
      return [];
    }
  }

  static Future<List<VenueModel>> getNearbyVenues({
    double? latitude,
    double? longitude,
    double radiusKm = 10.0,
    List<String>? sports,
  }) async {
    try {
      // For now, use the general search method
      // In future, can implement geospatial queries with PostGIS
      return await searchVenues(
        sports: sports,
        maxDistance: radiusKm,
      );
    } catch (e) {
      print('Error getting nearby venues: $e');
      return [];
    }
  }

  static Future<VenueModel?> getVenueDetails(String venueId) async {
    try {
      final venueData = await SupabaseService.getVenueDetails(venueId);
      if (venueData != null) {
        return VenueModel.fromSupabase(venueData);
      }
      return null;
    } catch (e) {
      print('Error getting venue details: $e');
      return null;
    }
  }

  // Booking Management
  static Future<String> createBooking({
    required String facilityId,
    required String courtId,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    required String courtName,
    required String courtType,
    required DateTime bookingDate,
    required String timeSlot,
    required DateTime startTime,
    required DateTime endTime,
    required int durationMinutes,
    required double price,
    required double totalAmount,
    String? specialRequests,
    String? paymentMethod,
  }) async {
    try {
      final bookingId = await SupabaseService.createBooking(
        facilityId: facilityId,
        courtId: courtId,
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        courtName: courtName,
        courtType: courtType,
        bookingDate: bookingDate.toIso8601String().split('T')[0],
        timeSlot: timeSlot,
        startTime: startTime,
        endTime: endTime,
        duration: durationMinutes,
        price: price,
        totalAmount: totalAmount,
        specialRequests: specialRequests,
        paymentMethod: paymentMethod,
      );

      return bookingId;
    } catch (e) {
      print('Error creating booking: $e');
      rethrow;
    }
  }

  static Future<List<BookingModel>> getCustomerBookings({
    String? status,
    int limit = 50,
  }) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return [];

      final bookingsData = await SupabaseService.getUserBookings(user.id);
      final bookings = bookingsData.map((data) => BookingModel.fromSupabase(data)).toList();

      if (status != null) {
        return bookings.where((booking) => booking.status.toString() == status).toList();
      }

      return bookings.take(limit).toList();
    } catch (e) {
      print('Error getting customer bookings: $e');
      return [];
    }
  }

  static Future<BookingModel?> getBookingDetails(String bookingId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('''
            *,
            facilities(name, location),
            courts(name, type)
          ''')
          .eq('id', bookingId)
          .single();

      return BookingModel.fromSupabase(response);
    } catch (e) {
      print('Error getting booking details: $e');
      return null;
    }
  }

  static Future<void> cancelBooking(String bookingId, String reason) async {
    try {
      await _supabase
          .from('bookings')
          .update({
            'status': 'cancelled',
            'cancellation_reason': reason,
            'cancelled_by': 'customer',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);

      // Free up the time slot
      await _supabase
          .from('time_slots')
          .update({
            'status': 'available',
            'booking_id': null,
          })
          .eq('booking_id', bookingId);
    } catch (e) {
      print('Error cancelling booking: $e');
      rethrow;
    }
  }

  static Future<void> checkInBooking(String bookingId) async {
    try {
      await _supabase
          .from('bookings')
          .update({
            'status': 'occupied',
            'check_in_time': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);
    } catch (e) {
      print('Error checking in booking: $e');
      rethrow;
    }
  }

  // Time Slots and Availability
  static Future<List<Map<String, dynamic>>> getAvailableTimeSlots({
    required String courtId,
    required DateTime date,
  }) async {
    try {
      return await SupabaseService.getTimeSlots(
        courtId: courtId,
        date: date.toIso8601String().split('T')[0],
      );
    } catch (e) {
      print('Error getting available time slots: $e');
      return [];
    }
  }

  static Future<void> generateTimeSlotsForCourt({
    required String courtId,
    required DateTime date,
  }) async {
    try {
      await SupabaseService.generateTimeSlots(
        courtId: courtId,
        date: date.toIso8601String().split('T')[0],
      );
    } catch (e) {
      print('Error generating time slots: $e');
      rethrow;
    }
  }

  // Favorites Management
  static Future<void> addToFavorites(String facilityId) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase.from('customer_favorites').insert({
        'customer_id': user.id,
        'facility_id': facilityId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (e.toString().contains('duplicate')) {
        // Already in favorites, ignore error
        return;
      }
      print('Error adding to favorites: $e');
      rethrow;
    }
  }

  static Future<void> removeFromFavorites(String facilityId) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase
          .from('customer_favorites')
          .delete()
          .eq('customer_id', user.id)
          .eq('facility_id', facilityId);
    } catch (e) {
      print('Error removing from favorites: $e');
      rethrow;
    }
  }

  static Future<List<VenueModel>> getFavoriteVenues() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return [];

      final favoritesData = await SupabaseService.getUserFavorites(user.id);
      return favoritesData
          .map((data) => VenueModel.fromSupabase(data['facilities']))
          .toList();
    } catch (e) {
      print('Error getting favorite venues: $e');
      return [];
    }
  }

  static Future<bool> isFavorite(String facilityId) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return false;

      final response = await _supabase
          .from('customer_favorites')
          .select()
          .eq('customer_id', user.id)
          .eq('facility_id', facilityId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking if favorite: $e');
      return false;
    }
  }

  // Reviews Management
  static Future<void> createReview({
    required String facilityId,
    required int rating,
    String? comment,
    String? reviewTitle,
    List<String>? pros,
    List<String>? cons,
    bool wouldRecommend = true,
    List<String>? photos,
    String? bookingId,
  }) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await SupabaseService.createReview(
        facilityId: facilityId,
        customerId: user.id,
        rating: rating,
        comment: comment,
        reviewTitle: reviewTitle,
        pros: pros,
        cons: cons,
        wouldRecommend: wouldRecommend,
        photos: photos,
        bookingId: bookingId,
      );
    } catch (e) {
      print('Error creating review: $e');
      rethrow;
    }
  }

  static Future<List<ReviewModel>> getVenueReviews(String facilityId) async {
    try {
      final reviewsData = await SupabaseService.getVenueReviews(facilityId);
      return reviewsData.map((data) => ReviewModel.fromSupabase(data)).toList();
    } catch (e) {
      print('Error getting venue reviews: $e');
      return [];
    }
  }

  // Notifications
  static Future<List<NotificationModel>> getNotifications() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return [];

      final notificationsData = await SupabaseService.getUserNotifications(user.id);
      return notificationsData.map((data) => NotificationModel.fromSupabase(data)).toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await SupabaseService.markNotificationAsRead(notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  static Future<int> getUnreadNotificationCount() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return 0;

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('recipient_id', user.id)
          .eq('is_read', false);

      return response.length;
    } catch (e) {
      print('Error getting unread notification count: $e');
      return 0;
    }
  }

  // Business Hours
  static Future<Map<String, dynamic>?> getVenueBusinessHours(String facilityId) async {
    try {
      final facility = await getVenueDetails(facilityId);
      if (facility == null) return null;

      // Get owner profile for business hours
      final response = await _supabase
          .from('facilities')
          .select('profiles!facilities_owner_id_fkey(id)')
          .eq('id', facilityId)
          .single();

      final ownerId = response['profiles']['id'];
      return await SupabaseService.getBusinessHours(ownerId);
    } catch (e) {
      print('Error getting venue business hours: $e');
      return null;
    }
  }

  // Utility Methods
  static bool get isAuthenticated => SupabaseService.isLoggedIn;
  static String? get currentUserId => SupabaseService.currentUserId;
  static User? get currentUser => SupabaseService.currentUser;

  // Authentication convenience methods
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final response = await SupabaseService.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create customer profile
        await createCustomerProfile(
          name: name,
          phone: phone,
          email: email,
        );
      }

      return response;
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await SupabaseService.signIn(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await SupabaseService.signOut();
  }

  static Future<void> resetPassword(String email) async {
    await SupabaseService.resetPassword(email);
  }
}
