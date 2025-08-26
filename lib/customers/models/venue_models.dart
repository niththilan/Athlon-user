class VenueModel {
  final String id;
  final String name;
  final String location;
  final String? fullAddress;
  final double rating;
  final int reviewCount;
  final double distance;
  final String? imageUrl;
  final List<String> sports;
  final List<String> amenities;
  final String openingHours;
  final Map<String, dynamic>? businessHoursDisplay;
  final String? phone;
  final String? website;
  final String? bio;
  final List<Court> courts;
  final List<VenueImage> images;
  final Map<String, dynamic>? pricingInfo;
  final bool isCurrentlyOpen;

  VenueModel({
    required this.id,
    required this.name,
    required this.location,
    this.fullAddress,
    required this.rating,
    this.reviewCount = 0,
    this.distance = 0.0,
    this.imageUrl,
    this.sports = const [],
    this.amenities = const [],
    this.openingHours = '',
    this.businessHoursDisplay,
    this.phone,
    this.website,
    this.bio,
    this.courts = const [],
    this.images = const [],
    this.pricingInfo,
    this.isCurrentlyOpen = false,
  });

  factory VenueModel.fromSupabase(Map<String, dynamic> data) {
    final profile = data['profiles'] as Map<String, dynamic>?;
    final courtsData = data['courts'] as List<dynamic>? ?? [];
    final imagesData = data['facility_images'] as List<dynamic>? ?? [];

    return VenueModel(
      id: data['id'] as String,
      name: data['name'] as String? ?? profile?['name'] as String? ?? 'Unknown Venue',
      location: data['location'] as String? ?? profile?['location'] as String? ?? 'Unknown Location',
      fullAddress: profile?['full_address'] as String?,
      rating: (profile?['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: profile?['review_count'] as int? ?? 0,
      sports: _parseStringList(profile?['facilities_list']),
      amenities: _parseStringList(profile?['amenities_list']),
      openingHours: profile?['opening_hours'] as String? ?? '',
      businessHoursDisplay: profile?['business_hours_display'] as Map<String, dynamic>?,
      phone: profile?['phone'] as String?,
      website: profile?['website'] as String?,
      bio: profile?['bio'] as String?,
      courts: courtsData.map((court) => Court.fromSupabase(court as Map<String, dynamic>)).toList(),
      images: imagesData.map((image) => VenueImage.fromSupabase(image as Map<String, dynamic>)).toList(),
      pricingInfo: profile?['pricing_info'] as Map<String, dynamic>?,
    );
  }

  static List<String> _parseStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((item) => item.toString()).toList();
    }
    return [];
  }

  String get primaryImageUrl {
    final primaryImage = images.where((img) => img.isPrimary).firstOrNull;
    if (primaryImage != null) return primaryImage.imageUrl;
    
    final firstImage = images.firstOrNull;
    if (firstImage != null) return firstImage.imageUrl;
    
    return imageUrl ?? 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80';
  }

  String get ratePerHour {
    if (courts.isNotEmpty) {
      final minRate = courts.map((c) => c.hourlyRate).reduce((a, b) => a < b ? a : b);
      final maxRate = courts.map((c) => c.hourlyRate).reduce((a, b) => a > b ? a : b);
      
      if (minRate == maxRate) {
        return 'Rs. ${minRate.toStringAsFixed(0)}';
      } else {
        return 'Rs. ${minRate.toStringAsFixed(0)} - ${maxRate.toStringAsFixed(0)}';
      }
    }
    return 'Rs. 0';
  }

  String get title => name;
}

class Court {
  final String id;
  final String facilityId;
  final String name;
  final String type;
  final double hourlyRate;
  final bool isActive;
  final String? description;
  final int capacity;
  final List<String> equipmentProvided;
  final List<String> amenities;
  final String? maintenanceNotes;
  final DateTime? lastMaintenanceDate;

  Court({
    required this.id,
    required this.facilityId,
    required this.name,
    required this.type,
    required this.hourlyRate,
    this.isActive = true,
    this.description,
    this.capacity = 4,
    this.equipmentProvided = const [],
    this.amenities = const [],
    this.maintenanceNotes,
    this.lastMaintenanceDate,
  });

  factory Court.fromSupabase(Map<String, dynamic> data) {
    return Court(
      id: data['id'] as String,
      facilityId: data['facility_id'] as String,
      name: data['name'] as String,
      type: data['type'] as String,
      hourlyRate: (data['hourly_rate'] as num?)?.toDouble() ?? 0.0,
      isActive: data['is_active'] as bool? ?? true,
      description: data['description'] as String?,
      capacity: data['capacity'] as int? ?? 4,
      equipmentProvided: VenueModel._parseStringList(data['equipment_provided']),
      amenities: VenueModel._parseStringList(data['amenities']),
      maintenanceNotes: data['maintenance_notes'] as String?,
      lastMaintenanceDate: data['last_maintenance_date'] != null 
          ? DateTime.parse(data['last_maintenance_date'] as String)
          : null,
    );
  }
}

class VenueImage {
  final String id;
  final String facilityId;
  final String? courtId;
  final String imageUrl;
  final String imageType;
  final String? caption;
  final String? altText;
  final int displayOrder;
  final bool isPrimary;
  final bool isActive;

  VenueImage({
    required this.id,
    required this.facilityId,
    this.courtId,
    required this.imageUrl,
    this.imageType = 'general',
    this.caption,
    this.altText,
    this.displayOrder = 0,
    this.isPrimary = false,
    this.isActive = true,
  });

  factory VenueImage.fromSupabase(Map<String, dynamic> data) {
    return VenueImage(
      id: data['id'] as String,
      facilityId: data['facility_id'] as String,
      courtId: data['court_id'] as String?,
      imageUrl: data['image_url'] as String,
      imageType: data['image_type'] as String? ?? 'general',
      caption: data['caption'] as String?,
      altText: data['alt_text'] as String?,
      displayOrder: data['display_order'] as int? ?? 0,
      isPrimary: data['is_primary'] as bool? ?? false,
      isActive: data['is_active'] as bool? ?? true,
    );
  }
}

class TimeSlot {
  final String id;
  final String courtId;
  final DateTime slotDate;
  final String timeSlot;
  final String status;
  final String? bookingId;
  final double? price;

  TimeSlot({
    required this.id,
    required this.courtId,
    required this.slotDate,
    required this.timeSlot,
    required this.status,
    this.bookingId,
    this.price,
  });

  factory TimeSlot.fromSupabase(Map<String, dynamic> data) {
    return TimeSlot(
      id: data['id'] as String,
      courtId: data['court_id'] as String,
      slotDate: DateTime.parse(data['slot_date'] as String),
      timeSlot: data['time_slot'] as String,
      status: data['status'] as String,
      bookingId: data['booking_id'] as String?,
      price: (data['price'] as num?)?.toDouble(),
    );
  }

  bool get isAvailable => status == 'available';
  bool get isOccupied => status == 'occupied';
  bool get isSelected => status == 'selected';
  bool get isBlocked => status == 'blocked';
}

class Booking {
  final String id;
  final String? customerId;
  final String facilityId;
  final String courtId;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String courtName;
  final String courtType;
  final DateTime bookingDate;
  final String timeSlot;
  final DateTime startTime;
  final DateTime endTime;
  final int duration;
  final double durationHours;
  final double price;
  final double totalAmount;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final String? specialRequests;
  final String bookingSource;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String? cancellationReason;
  final String? cancelledBy;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data
  final VenueModel? facility;
  final Court? court;

  Booking({
    required this.id,
    this.customerId,
    required this.facilityId,
    required this.courtId,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.courtName,
    required this.courtType,
    required this.bookingDate,
    required this.timeSlot,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.durationHours,
    required this.price,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    this.specialRequests,
    required this.bookingSource,
    this.checkInTime,
    this.checkOutTime,
    this.cancellationReason,
    this.cancelledBy,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.facility,
    this.court,
  });

  factory Booking.fromSupabase(Map<String, dynamic> data) {
    final facilityData = data['facilities'] as Map<String, dynamic>?;
    final courtData = data['courts'] as Map<String, dynamic>?;

    return Booking(
      id: data['id'] as String,
      customerId: data['customer_id'] as String?,
      facilityId: data['facility_id'] as String,
      courtId: data['court_id'] as String,
      customerName: data['customer_name'] as String,
      customerPhone: data['customer_phone'] as String,
      customerEmail: data['customer_email'] as String?,
      courtName: data['court_name'] as String,
      courtType: data['court_type'] as String,
      bookingDate: DateTime.parse(data['booking_date'] as String),
      timeSlot: data['time_slot'] as String,
      startTime: DateTime.parse(data['start_time'] as String),
      endTime: DateTime.parse(data['end_time'] as String),
      duration: data['duration'] as int,
      durationHours: (data['duration_hours'] as num).toDouble(),
      price: (data['price'] as num).toDouble(),
      totalAmount: (data['total_amount'] as num).toDouble(),
      status: data['status'] as String,
      paymentStatus: data['payment_status'] as String,
      paymentMethod: data['payment_method'] as String?,
      specialRequests: data['special_requests'] as String?,
      bookingSource: data['booking_source'] as String,
      checkInTime: data['check_in_time'] != null ? DateTime.parse(data['check_in_time'] as String) : null,
      checkOutTime: data['check_out_time'] != null ? DateTime.parse(data['check_out_time'] as String) : null,
      cancellationReason: data['cancellation_reason'] as String?,
      cancelledBy: data['cancelled_by'] as String?,
      notes: data['notes'] as String?,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
      facility: facilityData != null ? VenueModel.fromSupabase(facilityData) : null,
      court: courtData != null ? Court.fromSupabase(courtData) : null,
    );
  }

  bool get isActive => status == 'confirmed' || status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isPaid => paymentStatus == 'paid';
}

class Review {
  final String id;
  final String facilityId;
  final String customerId;
  final int rating;
  final String? comment;
  final String? reviewTitle;
  final int? serviceRating;
  final int? facilityRating;
  final int? valueRating;
  final int? cleanlinessRating;
  final List<String> pros;
  final List<String> cons;
  final bool wouldRecommend;
  final List<String> photos;
  final bool isVerified;
  final String? responseFromVendor;
  final DateTime? responseDate;
  final bool isFeatured;
  final int helpfulCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data
  final String? customerName;

  Review({
    required this.id,
    required this.facilityId,
    required this.customerId,
    required this.rating,
    this.comment,
    this.reviewTitle,
    this.serviceRating,
    this.facilityRating,
    this.valueRating,
    this.cleanlinessRating,
    this.pros = const [],
    this.cons = const [],
    this.wouldRecommend = true,
    this.photos = const [],
    this.isVerified = false,
    this.responseFromVendor,
    this.responseDate,
    this.isFeatured = false,
    this.helpfulCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.customerName,
  });

  factory Review.fromSupabase(Map<String, dynamic> data) {
    final customerData = data['customers'] as Map<String, dynamic>?;

    return Review(
      id: data['id'] as String,
      facilityId: data['facility_id'] as String,
      customerId: data['customer_id'] as String,
      rating: data['rating'] as int,
      comment: data['comment'] as String?,
      reviewTitle: data['review_title'] as String?,
      serviceRating: data['service_rating'] as int?,
      facilityRating: data['facility_rating'] as int?,
      valueRating: data['value_rating'] as int?,
      cleanlinessRating: data['cleanliness_rating'] as int?,
      pros: VenueModel._parseStringList(data['pros']),
      cons: VenueModel._parseStringList(data['cons']),
      wouldRecommend: data['would_recommend'] as bool? ?? true,
      photos: VenueModel._parseStringList(data['photos']),
      isVerified: data['is_verified'] as bool? ?? false,
      responseFromVendor: data['response_from_vendor'] as String?,
      responseDate: data['response_date'] != null ? DateTime.parse(data['response_date'] as String) : null,
      isFeatured: data['is_featured'] as bool? ?? false,
      helpfulCount: data['helpful_count'] as int? ?? 0,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
      customerName: customerData?['name'] as String?,
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String? phone;
  final String? facilityName;
  final String userType;
  final String? location;
  final String? fullAddress;
  final String? website;
  final String? bio;
  final String? profileImageUrl;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    this.phone,
    this.facilityName,
    required this.userType,
    this.location,
    this.fullAddress,
    this.website,
    this.bio,
    this.profileImageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromSupabase(Map<String, dynamic> data) {
    return UserProfile(
      id: data['id'] as String,
      name: data['name'] as String,
      phone: data['phone'] as String?,
      facilityName: data['facility_name'] as String?,
      userType: data['user_type'] as String? ?? 'customer',
      location: data['location'] as String?,
      fullAddress: data['full_address'] as String?,
      website: data['website'] as String?,
      bio: data['bio'] as String?,
      profileImageUrl: data['profile_image_url'] as String?,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['review_count'] as int? ?? 0,
      isVerified: data['is_verified'] as bool? ?? false,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }
}

// Extension to add convenience methods
extension ListExtensions<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
