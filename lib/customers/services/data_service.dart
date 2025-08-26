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
      // Try to load from Supabase using CustomerService
      final venues = await CustomerService.searchVenues(
        location: location,
        sports: sports,
        sortBy: sortBy,
      );
      
      if (venues.isNotEmpty) {
        return venues;
      }
    } catch (e) {
      print('Failed to load venues from Supabase: $e');
    }
    
    // Fallback to mock data
    return _getMockVenues();
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
    }
    
    // Fallback to filtered mock data
    final mockVenues = _getMockVenues();
    List<VenueModel> filteredVenues = mockVenues;
    
    if (searchTerm != null && searchTerm.isNotEmpty) {
      filteredVenues = filteredVenues.where((venue) =>
          venue.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
          venue.location.toLowerCase().contains(searchTerm.toLowerCase()) ||
          venue.sports.any((sport) => sport.toLowerCase().contains(searchTerm.toLowerCase()))
      ).toList();
    }
    
    if (location != null && location.isNotEmpty) {
      filteredVenues = filteredVenues.where((venue) =>
          venue.location.toLowerCase().contains(location.toLowerCase())
      ).toList();
    }
    
    if (sports != null && sports.isNotEmpty) {
      filteredVenues = filteredVenues.where((venue) =>
          sports.any((sport) => venue.sports.any((venueSport) =>
              venueSport.toLowerCase().contains(sport.toLowerCase())))
      ).toList();
    }
    
    if (minRating != null) {
      filteredVenues = filteredVenues.where((venue) =>
          venue.rating >= minRating
      ).toList();
    }
    
    return filteredVenues;
  }

  static Future<VenueModel?> getVenueDetails(String venueId) async {
    try {
      return await CustomerService.getVenueDetails(venueId);
    } catch (e) {
      print('Failed to load venue details from Supabase: $e');
    }
    
    // Fallback to mock data
    final mockVenues = _getMockVenues();
    return mockVenues.where((venue) => venue.id == venueId).firstOrNull;
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
      return _getMockVenues();
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

  static List<VenueModel> _getMockVenues() {
    return [
      VenueModel(
        id: '1',
        name: "CR7 FUTSAL & INDOOR CRICKET",
        location: "23 Mile Post Ave, Colombo 00300",
        rating: 4.75,
        reviewCount: 148,
        distance: 1.2,
        imageUrl: "https://images.unsplash.com/photo-1575361204480-aadea25e6e68?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
        sports: ["Futsal", "Cricket", "Indoor"],
        amenities: ["Air Conditioning", "Parking", "Changing Rooms", "Equipment Rental"],
        openingHours: "6:00 AM - 11:00 PM",
        phone: "+94 77 123 4567",
        website: "www.cr7futsal.lk",
        bio: "Premier futsal and indoor cricket facility with international-standard surfaces and professional coaching.",
        courts: [
          Court(
            id: "CR7-F1",
            facilityId: "1",
            name: "Futsal Court 1",
            type: "Futsal",
            hourlyRate: 3000.0,
            description: "FIFA-approved futsal court with artificial turf",
            capacity: 10,
            amenities: ["Air Conditioning", "Professional Lighting"],
            equipmentProvided: ["Balls", "Goals", "Jerseys"],
          ),
          Court(
            id: "CR7-C1",
            facilityId: "1",
            name: "Indoor Cricket Court",
            type: "Cricket",
            hourlyRate: 3500.0,
            description: "Full-size indoor cricket facility",
            capacity: 22,
            amenities: ["Air Conditioning", "Scoreboard"],
            equipmentProvided: ["Balls", "Stumps", "Pads"],
          ),
        ],
        images: [
          VenueImage(
            id: "img1",
            facilityId: "1",
            imageUrl: "https://images.unsplash.com/photo-1575361204480-aadea25e6e68?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
            isPrimary: true,
            imageType: "general",
          ),
        ],
      ),
      VenueModel(
        id: '2',
        name: "ARK SPORTS - INDOOR CRICKET & FUTSAL",
        location: "141/A, Wattala 11300",
        rating: 4.23,
        reviewCount: 96,
        distance: 3.5,
        imageUrl: "https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
        sports: ["Futsal", "Cricket", "Indoor"],
        amenities: ["Parking", "Changing Rooms", "Cafeteria"],
        openingHours: "7:00 AM - 10:00 PM",
        phone: "+94 77 234 5678",
        website: "www.arksports.lk",
        bio: "Modern sports complex offering indoor cricket and futsal with competitive rates.",
        courts: [
          Court(
            id: "ARK-F1",
            facilityId: "2",
            name: "Futsal Arena",
            type: "Futsal",
            hourlyRate: 2500.0,
            description: "Standard futsal court with synthetic grass",
            capacity: 10,
            amenities: ["Changing Rooms", "Spectator Area"],
            equipmentProvided: ["Balls", "Goals"],
          ),
          Court(
            id: "ARK-C1",
            facilityId: "2",
            name: "Cricket Hall",
            type: "Cricket",
            hourlyRate: 2800.0,
            description: "Indoor cricket with professional setup",
            capacity: 16,
            amenities: ["Scoreboard", "Equipment Storage"],
            equipmentProvided: ["Balls", "Stumps"],
          ),
        ],
        images: [
          VenueImage(
            id: "img2",
            facilityId: "2",
            imageUrl: "https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
            isPrimary: true,
            imageType: "general",
          ),
        ],
      ),
      VenueModel(
        id: '3',
        name: "CHAMPION'S ARENA",
        location: "45 Sports Complex Road, Rajagiriya 10100",
        rating: 4.89,
        reviewCount: 203,
        distance: 0.8,
        imageUrl: "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
        sports: ["Badminton", "Tennis", "Squash", "Outdoor"],
        amenities: ["Air Conditioning", "Pro Shop", "Locker Rooms", "Coaching Available"],
        openingHours: "6:00 AM - 10:00 PM",
        phone: "+94 77 345 6789",
        website: "www.championsarena.lk",
        bio: "Multi-sport facility with professional courts for badminton, tennis, and squash.",
        courts: [
          Court(
            id: "CA-B1",
            facilityId: "3",
            name: "Badminton Court 1",
            type: "Badminton",
            hourlyRate: 2000.0,
            description: "Professional badminton court with wooden flooring",
            capacity: 4,
            amenities: ["Air Conditioning", "Professional Lighting"],
            equipmentProvided: ["Shuttlecocks", "Nets"],
          ),
          Court(
            id: "CA-T1",
            facilityId: "3",
            name: "Tennis Court",
            type: "Tennis",
            hourlyRate: 2500.0,
            description: "Outdoor tennis court with synthetic surface",
            capacity: 4,
            amenities: ["Floodlights", "Ball Machine"],
            equipmentProvided: ["Tennis Balls", "Nets"],
          ),
        ],
        images: [
          VenueImage(
            id: "img3",
            facilityId: "3",
            imageUrl: "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
            isPrimary: true,
            imageType: "general",
          ),
        ],
      ),
      VenueModel(
        id: '4',
        name: "AQUA SPORTS CENTER",
        location: "78 Poolside Avenue, Mount Lavinia 10370",
        rating: 4.67,
        reviewCount: 178,
        distance: 5.2,
        imageUrl: "https://images.unsplash.com/photo-1576610616656-d3aa5d1f4534?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
        sports: ["Swimming", "Water Polo", "Diving"],
        amenities: ["Olympic Pool", "Kids Pool", "Changing Rooms", "Cafeteria"],
        openingHours: "5:30 AM - 9:30 PM",
        phone: "+94 77 456 7890",
        website: "www.aquasports.lk",
        bio: "State-of-the-art aquatic center with Olympic-size pool and professional coaching.",
        courts: [
          Court(
            id: "AQ-P1",
            facilityId: "4",
            name: "Olympic Pool",
            type: "Swimming",
            hourlyRate: 1200.0,
            description: "50m Olympic-standard swimming pool",
            capacity: 50,
            amenities: ["Lane Ropes", "Starting Blocks", "Timing System"],
            equipmentProvided: ["Lane Markers", "Safety Equipment"],
          ),
        ],
        images: [
          VenueImage(
            id: "img4",
            facilityId: "4",
            imageUrl: "https://images.unsplash.com/photo-1576610616656-d3aa5d1f4534?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
            isPrimary: true,
            imageType: "general",
          ),
        ],
      ),
      VenueModel(
        id: '5',
        name: "ELITE BASKETBALL ACADEMY",
        location: "92 Court Lane, Dehiwala 10350",
        rating: 4.45,
        reviewCount: 134,
        distance: 2.7,
        imageUrl: "https://images.unsplash.com/photo-1546519638-68e109498ffc?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
        sports: ["Basketball", "Volleyball"],
        amenities: ["Indoor Courts", "Coaching", "Equipment Rental", "Spectator Seating"],
        openingHours: "7:00 AM - 11:00 PM",
        phone: "+94 77 567 8901",
        website: "www.elitebasketball.lk",
        bio: "Professional basketball and volleyball training facility with expert coaching staff.",
        courts: [
          Court(
            id: "EB-B1",
            facilityId: "5",
            name: "Basketball Court 1",
            type: "Basketball",
            hourlyRate: 1800.0,
            description: "Full-size basketball court with wooden flooring",
            capacity: 10,
            amenities: ["Air Conditioning", "Scoreboard", "Spectator Seating"],
            equipmentProvided: ["Basketballs", "Hoops"],
          ),
        ],
        images: [
          VenueImage(
            id: "img5",
            facilityId: "5",
            imageUrl: "https://images.unsplash.com/photo-1546519638-68e109498ffc?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
            isPrimary: true,
            imageType: "general",
          ),
        ],
      ),
    ];
  }
}
