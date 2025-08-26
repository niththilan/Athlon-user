// Customer-specific data models for Athlon User App

import 'package:flutter/material.dart';

class CustomerProfile {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? profileImageUrl;
  final String? location;
  final List<String> favoriteVenues;
  final List<String> preferredSports;
  final CustomerPreferences preferences;
  final LoyaltyStatus? loyaltyStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerProfile({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.profileImageUrl,
    this.location,
    this.favoriteVenues = const [],
    this.preferredSports = const [],
    required this.preferences,
    this.loyaltyStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerProfile.fromSupabase(Map<String, dynamic> data) {
    return CustomerProfile(
      id: data['id'] as String,
      name: data['name'] as String,
      phone: data['phone'] as String,
      email: data['email'] as String?,
      profileImageUrl: data['profile_image_url'] as String?,
      location: data['location'] as String?,
      favoriteVenues: _parseStringList(data['favorite_venues']),
      preferredSports: _parseStringList(data['preferred_sports']),
      preferences: CustomerPreferences.fromJson(data['preferences'] ?? {}),
      loyaltyStatus: data['loyalty_status'] != null 
          ? LoyaltyStatus.fromJson(data['loyalty_status']) 
          : null,
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: DateTime.parse(data['updated_at']),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'profile_image_url': profileImageUrl,
      'location': location,
      'favorite_venues': favoriteVenues,
      'preferred_sports': preferredSports,
      'preferences': preferences.toJson(),
      'loyalty_status': loyaltyStatus?.toJson(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  static List<String> _parseStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((item) => item.toString()).toList();
    }
    return [];
  }
}

class CustomerPreferences {
  final String? preferredTimeSlot; // morning, afternoon, evening
  final double maxTravelDistance; // in km
  final List<String> preferredAmenities;
  final bool enableNotifications;
  final bool enableLocationServices;
  final String? preferredPaymentMethod;

  CustomerPreferences({
    this.preferredTimeSlot,
    this.maxTravelDistance = 10.0,
    this.preferredAmenities = const [],
    this.enableNotifications = true,
    this.enableLocationServices = true,
    this.preferredPaymentMethod,
  });

  factory CustomerPreferences.fromJson(Map<String, dynamic> json) {
    return CustomerPreferences(
      preferredTimeSlot: json['preferred_time_slot'] as String?,
      maxTravelDistance: (json['max_travel_distance'] as num?)?.toDouble() ?? 10.0,
      preferredAmenities: (json['preferred_amenities'] as List<dynamic>?)
          ?.map((e) => e.toString()).toList() ?? [],
      enableNotifications: json['enable_notifications'] as bool? ?? true,
      enableLocationServices: json['enable_location_services'] as bool? ?? true,
      preferredPaymentMethod: json['preferred_payment_method'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferred_time_slot': preferredTimeSlot,
      'max_travel_distance': maxTravelDistance,
      'preferred_amenities': preferredAmenities,
      'enable_notifications': enableNotifications,
      'enable_location_services': enableLocationServices,
      'preferred_payment_method': preferredPaymentMethod,
    };
  }
}

class LoyaltyStatus {
  final String facilityId;
  final String facilityName;
  final int pointsEarned;
  final int pointsRedeemed;
  final int totalVisits;
  final double totalSpent;
  final String tierLevel;
  final DateTime? lastActivity;

  LoyaltyStatus({
    required this.facilityId,
    required this.facilityName,
    this.pointsEarned = 0,
    this.pointsRedeemed = 0,
    this.totalVisits = 0,
    this.totalSpent = 0.0,
    this.tierLevel = 'bronze',
    this.lastActivity,
  });

  factory LoyaltyStatus.fromJson(Map<String, dynamic> json) {
    return LoyaltyStatus(
      facilityId: json['facility_id'] as String,
      facilityName: json['facility_name'] as String,
      pointsEarned: json['points_earned'] as int? ?? 0,
      pointsRedeemed: json['points_redeemed'] as int? ?? 0,
      totalVisits: json['total_visits'] as int? ?? 0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      tierLevel: json['tier_level'] as String? ?? 'bronze',
      lastActivity: json['last_activity'] != null 
          ? DateTime.parse(json['last_activity']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facility_id': facilityId,
      'facility_name': facilityName,
      'points_earned': pointsEarned,
      'points_redeemed': pointsRedeemed,
      'total_visits': totalVisits,
      'total_spent': totalSpent,
      'tier_level': tierLevel,
      'last_activity': lastActivity?.toIso8601String(),
    };
  }

  int get availablePoints => pointsEarned - pointsRedeemed;
}

class BookingModel {
  final String id;
  final String facilityId;
  final String facilityName;
  final String courtId;
  final String courtName;
  final String courtType;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final DateTime bookingDate;
  final String timeSlot;
  final DateTime startTime;
  final DateTime endTime;
  final int duration; // in minutes
  final double price;
  final double totalAmount;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String? paymentMethod;
  final String? specialRequests;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingModel({
    required this.id,
    required this.facilityId,
    required this.facilityName,
    required this.courtId,
    required this.courtName,
    required this.courtType,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.bookingDate,
    required this.timeSlot,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.price,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    this.specialRequests,
    this.checkInTime,
    this.checkOutTime,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromSupabase(Map<String, dynamic> data) {
    return BookingModel(
      id: data['id'] as String,
      facilityId: data['facility_id'] as String,
      facilityName: data['facility_name'] as String? ?? 'Unknown Facility',
      courtId: data['court_id'] as String,
      courtName: data['court_name'] as String,
      courtType: data['court_type'] as String,
      customerName: data['customer_name'] as String,
      customerPhone: data['customer_phone'] as String,
      customerEmail: data['customer_email'] as String?,
      bookingDate: DateTime.parse(data['booking_date']),
      timeSlot: data['time_slot'] as String,
      startTime: DateTime.parse(data['start_time']),
      endTime: DateTime.parse(data['end_time']),
      duration: data['duration'] as int,
      price: (data['price'] as num).toDouble(),
      totalAmount: (data['total_amount'] as num).toDouble(),
      status: BookingStatus.fromString(data['status'] as String),
      paymentStatus: PaymentStatus.fromString(data['payment_status'] as String),
      paymentMethod: data['payment_method'] as String?,
      specialRequests: data['special_requests'] as String?,
      checkInTime: data['check_in_time'] != null 
          ? DateTime.parse(data['check_in_time']) 
          : null,
      checkOutTime: data['check_out_time'] != null 
          ? DateTime.parse(data['check_out_time']) 
          : null,
      cancellationReason: data['cancellation_reason'] as String?,
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: DateTime.parse(data['updated_at']),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'facility_id': facilityId,
      'court_id': courtId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'court_name': courtName,
      'court_type': courtType,
      'booking_date': bookingDate.toIso8601String().split('T')[0],
      'time_slot': timeSlot,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'duration': duration,
      'price': price,
      'total_amount': totalAmount,
      'status': status.toString(),
      'payment_status': paymentStatus.toString(),
      'payment_method': paymentMethod,
      'special_requests': specialRequests,
      'check_in_time': checkInTime?.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  String get formattedDate {
    return '${bookingDate.day}/${bookingDate.month}/${bookingDate.year}';
  }

  String get formattedTimeRange {
    final startTimeFormatted = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final endTimeFormatted = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$startTimeFormatted - $endTimeFormatted';
  }

  bool get canCancel {
    final now = DateTime.now();
    final timeDifference = startTime.difference(now).inHours;
    return status == BookingStatus.confirmed && timeDifference >= 24;
  }

  bool get canCheckIn {
    final now = DateTime.now();
    final timeDifference = startTime.difference(now).inMinutes;
    return status == BookingStatus.confirmed && 
           timeDifference <= 15 && 
           timeDifference >= -30 && 
           checkInTime == null;
  }
}

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  occupied,
  noShow;

  factory BookingStatus.fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      case 'occupied':
        return BookingStatus.occupied;
      case 'no_show':
        return BookingStatus.noShow;
      default:
        return BookingStatus.pending;
    }
  }

  @override
  String toString() {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.occupied:
        return 'occupied';
      case BookingStatus.noShow:
        return 'no_show';
    }
  }

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.occupied:
        return 'In Progress';
      case BookingStatus.noShow:
        return 'No Show';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.pending:
        return const Color(0xFFFF8C42);
      case BookingStatus.confirmed:
        return const Color(0xFF2ECC71);
      case BookingStatus.cancelled:
        return const Color(0xFFE74C3C);
      case BookingStatus.completed:
        return const Color(0xFF3498DB);
      case BookingStatus.occupied:
        return const Color(0xFF9B59B6);
      case BookingStatus.noShow:
        return const Color(0xFF95A5A6);
    }
  }
}

enum PaymentStatus {
  pending,
  paid,
  refunded,
  failed;

  factory PaymentStatus.fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'paid':
        return PaymentStatus.paid;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'failed':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.pending;
    }
  }

  @override
  String toString() {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.refunded:
        return 'refunded';
      case PaymentStatus.failed:
        return 'failed';
    }
  }

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending Payment';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.failed:
        return 'Payment Failed';
    }
  }
}

class ReviewModel {
  final String id;
  final String facilityId;
  final String facilityName;
  final String customerId;
  final String customerName;
  final int rating;
  final String? comment;
  final String? reviewTitle;
  final List<String> pros;
  final List<String> cons;
  final bool wouldRecommend;
  final List<String> photos;
  final bool isVerified;
  final String? responseFromVendor;
  final DateTime? responseDate;
  final int helpfulCount;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.facilityId,
    required this.facilityName,
    required this.customerId,
    required this.customerName,
    required this.rating,
    this.comment,
    this.reviewTitle,
    this.pros = const [],
    this.cons = const [],
    this.wouldRecommend = true,
    this.photos = const [],
    this.isVerified = false,
    this.responseFromVendor,
    this.responseDate,
    this.helpfulCount = 0,
    required this.createdAt,
  });

  factory ReviewModel.fromSupabase(Map<String, dynamic> data) {
    return ReviewModel(
      id: data['id'] as String,
      facilityId: data['facility_id'] as String,
      facilityName: data['facility_name'] as String? ?? 'Unknown Facility',
      customerId: data['customer_id'] as String,
      customerName: data['customer_name'] as String? ?? 'Anonymous',
      rating: data['rating'] as int,
      comment: data['comment'] as String?,
      reviewTitle: data['review_title'] as String?,
      pros: _parseStringList(data['pros']),
      cons: _parseStringList(data['cons']),
      wouldRecommend: data['would_recommend'] as bool? ?? true,
      photos: _parseStringList(data['photos']),
      isVerified: data['is_verified'] as bool? ?? false,
      responseFromVendor: data['response_from_vendor'] as String?,
      responseDate: data['response_date'] != null 
          ? DateTime.parse(data['response_date']) 
          : null,
      helpfulCount: data['helpful_count'] as int? ?? 0,
      createdAt: DateTime.parse(data['created_at']),
    );
  }

  static List<String> _parseStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((item) => item.toString()).toList();
    }
    return [];
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String? entityId;
  final bool isRead;
  final String? actionUrl;
  final NotificationPriority priority;
  final DateTime? expiresAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.entityId,
    this.isRead = false,
    this.actionUrl,
    this.priority = NotificationPriority.normal,
    this.expiresAt,
    required this.createdAt,
  });

  factory NotificationModel.fromSupabase(Map<String, dynamic> data) {
    return NotificationModel(
      id: data['id'] as String,
      title: data['title'] as String,
      message: data['message'] as String,
      type: NotificationType.fromString(data['type'] as String),
      entityId: data['entity_id'] as String?,
      isRead: data['is_read'] as bool? ?? false,
      actionUrl: data['action_url'] as String?,
      priority: NotificationPriority.fromString(data['priority'] as String? ?? 'normal'),
      expiresAt: data['expires_at'] != null 
          ? DateTime.parse(data['expires_at']) 
          : null,
      createdAt: DateTime.parse(data['created_at']),
    );
  }
}

enum NotificationType {
  booking,
  payment,
  reminder,
  promotion,
  system,
  chat,
  review;

  factory NotificationType.fromString(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
        return NotificationType.booking;
      case 'payment':
        return NotificationType.payment;
      case 'reminder':
        return NotificationType.reminder;
      case 'promotion':
        return NotificationType.promotion;
      case 'system':
        return NotificationType.system;
      case 'chat':
        return NotificationType.chat;
      case 'review':
        return NotificationType.review;
      default:
        return NotificationType.system;
    }
  }
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent;

  factory NotificationPriority.fromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return NotificationPriority.low;
      case 'normal':
        return NotificationPriority.normal;
      case 'high':
        return NotificationPriority.high;
      case 'urgent':
        return NotificationPriority.urgent;
      default:
        return NotificationPriority.normal;
    }
  }
}
