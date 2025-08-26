// ignore_for_file: avoid_print

import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static late SupabaseClient client;
  
  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
      debug: SupabaseConfig.enableDebugLogs,
    );
    client = Supabase.instance.client;
  }

  // User Authentication Methods
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
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
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  static Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }

  // Profile Management
  static Future<void> createUserProfile({
    required String userId,
    required String name,
    String? phone,
    String? facilityName,
    String userType = 'customer',
    String? location,
  }) async {
    try {
      await client.rpc('create_user_profile_on_signup', params: {
        'user_id': userId,
        'user_name': name,
        'user_phone': phone,
        'user_facility_name': facilityName,
        'user_type': userType,
        'user_location': location,
      });
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  static Future<void> updateUserProfile({
    required String userId,
    Map<String, dynamic>? updates,
  }) async {
    try {
      await client
          .from('profiles')
          .update(updates!)
          .eq('id', userId);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Venue/Facility Methods
  static Future<List<Map<String, dynamic>>> getVenues({
    String? location,
    List<String>? sports,
    double? maxDistance,
  }) async {
    try {
      var query = client
          .from('facilities')
          .select('''
            *,
            profiles!facilities_owner_id_fkey(
              name,
              location,
              full_address,
              phone,
              website,
              rating,
              review_count,
              opening_hours,
              business_hours_display,
              facilities_list,
              amenities_list,
              pricing_info
            ),
            courts(
              id,
              name,
              type,
              hourly_rate,
              is_active,
              description,
              capacity,
              equipment_provided,
              amenities
            ),
            facility_images(
              image_url,
              image_type,
              is_primary,
              display_order
            )
          ''');

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting venues: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getVenueDetails(String facilityId) async {
    try {
      final response = await client
          .from('facilities')
          .select('''
            *,
            profiles!facilities_owner_id_fkey(
              name,
              location,
              full_address,
              phone,
              website,
              rating,
              review_count,
              opening_hours,
              business_hours_display,
              facilities_list,
              amenities_list,
              pricing_info,
              bio
            ),
            courts(
              id,
              name,
              type,
              hourly_rate,
              is_active,
              description,
              capacity,
              equipment_provided,
              amenities
            ),
            facility_images(
              image_url,
              image_type,
              is_primary,
              display_order,
              caption
            ),
            reviews(
              id,
              rating,
              comment,
              review_title,
              pros,
              cons,
              would_recommend,
              photos,
              created_at,
              customers(name)
            )
          ''')
          .eq('id', facilityId)
          .single();
      return response;
    } catch (e) {
      print('Error getting venue details: $e');
      return null;
    }
  }

  // Court and Time Slot Methods
  static Future<List<Map<String, dynamic>>> getCourts(String facilityId) async {
    try {
      final response = await client
          .from('courts')
          .select()
          .eq('facility_id', facilityId)
          .eq('is_active', true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting courts: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getTimeSlots({
    required String courtId,
    required String date,
  }) async {
    try {
      final response = await client
          .from('time_slots')
          .select()
          .eq('court_id', courtId)
          .eq('slot_date', date)
          .order('time_slot');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting time slots: $e');
      return [];
    }
  }

  static Future<void> generateTimeSlots({
    required String courtId,
    required String date,
  }) async {
    try {
      await client.rpc('generate_time_slots_for_court_and_date', params: {
        'court_uuid': courtId,
        'target_date': date,
      });
    } catch (e) {
      print('Error generating time slots: $e');
      rethrow;
    }
  }

  // Booking Methods
  static Future<String> createBooking({
    required String facilityId,
    required String courtId,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    required String courtName,
    required String courtType,
    required String bookingDate,
    required String timeSlot,
    required DateTime startTime,
    required DateTime endTime,
    required int duration,
    required double price,
    required double totalAmount,
    String status = 'confirmed',
    String paymentStatus = 'pending',
    String? paymentMethod,
    String? specialRequests,
    String bookingSource = 'app',
  }) async {
    try {
      // Generate booking ID
      final bookingId = 'BK${DateTime.now().millisecondsSinceEpoch}';
      
      // Create or get customer
      String customerId;
      final existingCustomer = await client
          .from('customers')
          .select()
          .eq('phone', customerPhone)
          .maybeSingle();
      
      if (existingCustomer != null) {
        customerId = existingCustomer['id'];
        // Update customer info if needed
        await client
            .from('customers')
            .update({
              'name': customerName,
              'email': customerEmail,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', customerId);
      } else {
        // Create new customer
        final newCustomer = await client
            .from('customers')
            .insert({
              'name': customerName,
              'phone': customerPhone,
              'email': customerEmail,
            })
            .select()
            .single();
        customerId = newCustomer['id'];
      }

      // Create booking
      await client.from('bookings').insert({
        'id': bookingId,
        'customer_id': customerId,
        'facility_id': facilityId,
        'court_id': courtId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'customer_email': customerEmail,
        'court_name': courtName,
        'court_type': courtType,
        'booking_date': bookingDate,
        'time_slot': timeSlot,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'duration': duration,
        'duration_hours': duration / 60.0,
        'price': price,
        'total_amount': totalAmount,
        'status': status,
        'payment_status': paymentStatus,
        'payment_method': paymentMethod,
        'special_requests': specialRequests,
        'booking_source': bookingSource,
      });

      // Update time slot status
      await client
          .from('time_slots')
          .update({
            'status': 'occupied',
            'booking_id': bookingId,
          })
          .eq('court_id', courtId)
          .eq('slot_date', bookingDate)
          .eq('time_slot', timeSlot);

      return bookingId;
    } catch (e) {
      print('Error creating booking: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      // Get user profile to get phone number
      final profile = await getUserProfile(userId);
      if (profile == null || profile['phone'] == null) {
        return [];
      }

      final response = await client
          .from('bookings')
          .select('''
            *,
            facilities(
              name,
              location,
              profiles!facilities_owner_id_fkey(name, phone)
            ),
            courts(name, type)
          ''')
          .eq('customer_phone', profile['phone'])
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting user bookings: $e');
      return [];
    }
  }

  // Search Methods
  static Future<List<Map<String, dynamic>>> searchVenues({
    String? searchTerm,
    String? location,
    List<String>? sports,
    double? minRating,
    double? maxDistance,
  }) async {
    try {
      var query = client
          .from('facilities')
          .select('''
            *,
            profiles!facilities_owner_id_fkey(
              name,
              location,
              full_address,
              phone,
              website,
              rating,
              review_count,
              opening_hours,
              business_hours_display,
              facilities_list,
              amenities_list,
              pricing_info
            ),
            courts(
              id,
              name,
              type,
              hourly_rate,
              is_active
            ),
            facility_images(
              image_url,
              image_type,
              is_primary
            )
          ''');

      // Apply filters
      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.or('name.ilike.%$searchTerm%,profiles.name.ilike.%$searchTerm%,profiles.location.ilike.%$searchTerm%');
      }
      
      if (location != null && location.isNotEmpty) {
        query = query.or('location.ilike.%$location%,profiles.location.ilike.%$location%');
      }
      
      if (minRating != null) {
        query = query.gte('profiles.rating', minRating);
      }

      final response = await query;
      List<Map<String, dynamic>> venues = List<Map<String, dynamic>>.from(response);

      // Filter by sports if specified
      if (sports != null && sports.isNotEmpty) {
        venues = venues.where((venue) {
          final facilitiesList = venue['profiles']['facilities_list'] as List?;
          if (facilitiesList == null) return false;
          
          return sports.any((sport) =>
              facilitiesList.any((facility) =>
                  facility.toString().toLowerCase().contains(sport.toLowerCase())));
        }).toList();
      }

      return venues;
    } catch (e) {
      print('Error searching venues: $e');
      return [];
    }
  }

  // Reviews Methods
  static Future<List<Map<String, dynamic>>> getVenueReviews(String facilityId) async {
    try {
      final response = await client
          .from('reviews')
          .select('''
            *,
            customers(name)
          ''')
          .eq('facility_id', facilityId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting venue reviews: $e');
      return [];
    }
  }

  static Future<void> createReview({
    required String facilityId,
    required String customerId,
    required int rating,
    String? comment,
    String? reviewTitle,
    int? serviceRating,
    int? facilityRating,
    int? valueRating,
    int? cleanlinessRating,
    List<String>? pros,
    List<String>? cons,
    bool wouldRecommend = true,
    List<String>? photos,
    String? bookingId,
  }) async {
    try {
      await client.from('reviews').insert({
        'facility_id': facilityId,
        'customer_id': customerId,
        'rating': rating,
        'comment': comment,
        'review_title': reviewTitle,
        'service_rating': serviceRating,
        'facility_rating': facilityRating,
        'value_rating': valueRating,
        'cleanliness_rating': cleanlinessRating,
        'pros': pros,
        'cons': cons,
        'would_recommend': wouldRecommend,
        'photos': photos,
        'booking_id': bookingId,
        'is_verified': bookingId != null,
      });

      // Update facility rating
      await client.rpc('update_facility_rating', params: {
        'facility_uuid': facilityId,
      });
    } catch (e) {
      print('Error creating review: $e');
      rethrow;
    }
  }

  // Favorites Methods
  static Future<void> addToFavorites({
    required String userId,
    required String facilityId,
  }) async {
    try {
      await client.from('customer_favorites').insert({
        'customer_id': userId,
        'facility_id': facilityId,
      });
    } catch (e) {
      print('Error adding to favorites: $e');
      rethrow;
    }
  }

  static Future<void> removeFromFavorites({
    required String userId,
    required String facilityId,
  }) async {
    try {
      await client
          .from('customer_favorites')
          .delete()
          .eq('customer_id', userId)
          .eq('facility_id', facilityId);
    } catch (e) {
      print('Error removing from favorites: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getUserFavorites(String userId) async {
    try {
      final response = await client
          .from('customer_favorites')
          .select('''
            *,
            facilities(
              *,
              profiles!facilities_owner_id_fkey(
                name,
                location,
                rating,
                review_count,
                opening_hours,
                facilities_list
              ),
              facility_images(
                image_url,
                is_primary
              )
            )
          ''')
          .eq('customer_id', userId);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting user favorites: $e');
      return [];
    }
  }

  // Utility Methods
  static User? get currentUser => client.auth.currentUser;
  
  static bool get isLoggedIn => client.auth.currentUser != null;
  
  static String? get currentUserId => client.auth.currentUser?.id;

  // Business Hours Methods
  static Future<Map<String, dynamic>?> getBusinessHours(String profileId) async {
    try {
      final response = await client
          .from('business_hours')
          .select()
          .eq('profile_id', profileId)
          .order('day_of_week');
      
      return {
        'business_hours': response,
        'is_open': await isBusinessCurrentlyOpen(profileId),
      };
    } catch (e) {
      print('Error getting business hours: $e');
      return null;
    }
  }

  static Future<bool> isBusinessCurrentlyOpen(String profileId) async {
    try {
      final response = await client.rpc('is_business_currently_open', params: {
        'profile_uuid': profileId,
      });
      return response as bool;
    } catch (e) {
      print('Error checking if business is open: $e');
      return false;
    }
  }

  // Notifications Methods
  static Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final response = await client
          .from('notifications')
          .select()
          .eq('recipient_id', userId)
          .order('created_at', ascending: false)
          .limit(50);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }
}
