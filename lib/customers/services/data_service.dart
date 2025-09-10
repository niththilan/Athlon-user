import '../models/venue_models.dart';
import '../models/customer_models.dart';
import '../services/customer_service.dart';

class DataService {
  static Future<List<VenueModel>> loadVenues({
    String? location,
    List<String>? sports,
    String? sortBy = 'distance',
  }) async {
    try {
      // Load from Supabase using CustomerService
      final venues = await CustomerService.searchVenues(
        location: location,
        sports: sports,
        sortBy: sortBy,
      );
      
      return venues;
    } catch (e) {
      print('Failed to load venues from Supabase: $e');
      rethrow; // Don't fallback to mock data anymore
    }
  }

  static Future<List<VenueModel>> searchVenues({
    String? searchTerm,
    String? location,
    List<String>? sports,
    double? minRating,
    String? sortBy = 'distance',
  }) async {
    try {
      return await CustomerService.searchVenues(
        searchTerm: searchTerm,
        location: location,
        sports: sports,
        minRating: minRating,
        sortBy: sortBy,
      );
    } catch (e) {
      print('Failed to search venues from Supabase: $e');
      rethrow; // Don't fallback to mock data anymore
    }
  }

  static Future<VenueModel?> getVenueDetails(String venueId) async {
    try {
      return await CustomerService.getVenueDetails(venueId);
    } catch (e) {
      print('Failed to load venue details from Supabase: $e');
      rethrow; // Don't fallback to mock data anymore
    }
  }

  static Future<List<VenueModel>> getNearbyVenues({
    double? latitude,
    double? longitude,
    double radiusKm = 10.0,
    List<String>? sports,
  }) async {
    try {
      return await CustomerService.getNearbyVenues(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        sports: sports,
      );
    } catch (e) {
      print('Failed to load nearby venues from Supabase: $e');
      rethrow; // Don't fallback to mock data anymore
    }
  }

  static Future<List<VenueModel>> getFavoriteVenues() async {
    try {
      return await CustomerService.getFavoriteVenues();
    } catch (e) {
      print('Failed to load favorite venues from Supabase: $e');
      return [];
    }
  }

  static Future<List<BookingModel>> getCustomerBookings({
    String? status,
    int limit = 50,
  }) async {
    try {
      return await CustomerService.getCustomerBookings(
        status: status,
        limit: limit,
      );
    } catch (e) {
      print('Failed to load customer bookings from Supabase: $e');
      return [];
    }
  }

  static Future<CustomerProfile?> getCurrentCustomerProfile() async {
    try {
      return await CustomerService.getCurrentCustomerProfile();
    } catch (e) {
      print('Failed to load customer profile from Supabase: $e');
      return null;
    }
  }

  static Future<List<ReviewModel>> getVenueReviews(String venueId) async {
    try {
      return await CustomerService.getVenueReviews(venueId);
    } catch (e) {
      print('Failed to load venue reviews from Supabase: $e');
      return [];
    }
  }

}
