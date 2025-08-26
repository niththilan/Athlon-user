# Customer App Database Integration Guide

This document outlines how all customer app pages have been enhanced to connect with the Supabase database.

## 🗄️ Database Schema Overview

The customer app uses the following main tables:
- `customers` - Customer profiles and preferences
- `facilities` - Sports venues/facilities
- `courts` - Individual courts within facilities
- `bookings` - Customer bookings
- `time_slots` - Available time slots for booking
- `reviews` - Customer reviews and ratings
- `customer_favorites` - Customer favorite venues
- `notifications` - App notifications
- `facility_images` - Venue photos

## 🔧 Setup Instructions

### 1. Run Database Migrations
Execute these SQL files in your Supabase SQL Editor in order:

1. `schema.sql` - Main database schema
2. `customer_app_enhancements.sql` - Customer-specific tables
3. `complete_customer_app_setup.sql` - RLS policies and functions

### 2. Verify Supabase Configuration
Check `lib/customers/config/supabase_config.dart`:
- Ensure correct Supabase URL and anon key
- Update any regional settings if needed

### 3. Update Dependencies
The app requires these dependencies (already in pubspec.yaml):
```yaml
dependencies:
  supabase_flutter: ^2.5.6
  http: ^1.2.0
```

## 📱 Enhanced Pages and Features

### Authentication & Profile Management

#### New Files Created:
- `lib/customers/services/auth_service.dart` - Authentication service
- `lib/customers/services/customer_service.dart` - Customer data operations
- `lib/customers/models/customer_models.dart` - Customer data models
- `lib/customers/profile/user_profile_screen.dart` - Enhanced profile screen

#### Features:
- User registration and login
- Profile management with preferences
- Favorites tracking
- Loyalty program integration
- Notification management

### Venue Discovery & Search

#### Enhanced Files:
- `lib/customers/services/data_service.dart` - Now uses CustomerService
- `lib/customers/home.dart` - Enhanced with database integration
- `lib/customers/nearbyVenues.dart` - Real-time venue data
- `lib/customers/search.dart` - Advanced search with filters

#### Features:
- Real-time venue search from database
- Location-based filtering
- Sports-specific filtering
- Rating and review integration
- Business hours display
- Dynamic pricing information

### Booking System

#### New Files Created:
- `lib/customers/services/booking_service.dart` - Complete booking management

#### Enhanced Features:
- Real-time availability checking
- Automated time slot generation
- Booking confirmation and tracking
- Payment status management
- Booking history
- Cancellation handling
- Check-in functionality

### Reviews & Ratings

#### Features:
- Create and manage reviews
- Photo uploads for reviews
- Vendor response integration
- Helpful votes tracking
- Verified booking reviews

### Favorites Management

#### Enhanced Files:
- `lib/customers/favourites.dart` - Database-backed favorites

#### Features:
- Add/remove favorites
- Sync across devices
- Quick access to favorite venues

## 🔄 Data Flow Architecture

### Authentication Flow:
1. User signs up/signs in via AuthService
2. CustomerService creates/loads customer profile
3. Profile data synced with Supabase customers table

### Venue Discovery Flow:
1. HomeScreen loads venues via DataService
2. DataService uses CustomerService for database queries
3. Real-time data from facilities, courts, and profiles tables

### Booking Flow:
1. User selects venue and time via UI
2. BookingService validates availability
3. Creates booking in database with proper relationships
4. Updates time_slots table status
5. Sends confirmation notifications

### Review Flow:
1. Customer creates review via ReviewService
2. Review saved to reviews table
3. Facility rating automatically updated
4. Notification sent to venue owner

## 🔐 Security & RLS Policies

### Row Level Security (RLS) Implemented:
- Customers can only access their own data
- Public can view venue information
- Bookings are restricted to customer and venue owner
- Reviews are publicly viewable but only editable by creator

### Key Policies:
- `Users can view their own customer profile`
- `Public can view vendor profiles`
- `Users can view their own bookings`
- `Public can view facilities and courts`
- `Users can add/remove their own favorites`

## 📊 Real-time Features

### Implemented:
- Live venue availability
- Real-time booking updates
- Instant favorite synchronization
- Live notification delivery

### Database Functions:
- `is_business_currently_open()` - Check venue hours
- `generate_time_slots_for_court_and_date()` - Create time slots
- `update_facility_rating()` - Recalculate ratings
- `get_customer_booking_stats()` - Customer analytics

## 🎯 Customer-Specific Enhancements

### Personalization:
- Preferred sports tracking
- Location-based recommendations
- Custom notification preferences
- Loyalty program integration

### User Experience:
- Seamless authentication flow
- Offline capability with sync
- Progressive loading
- Error handling with fallbacks

### Analytics & Insights:
- Booking history analysis
- Spending tracking
- Venue preference analytics
- Usage pattern insights

## 🔧 Implementation Status

### ✅ Completed:
- Database schema and RLS policies
- Authentication and customer management
- Venue discovery with real-time data
- Booking system with availability checking
- Reviews and ratings system
- Favorites management
- Notification system
- Profile management

### 🔄 Enhanced:
- Home screen with database integration
- Venue search with advanced filters
- Court details with real-time data
- Booking history with status tracking
- Settings with preference sync

### 📱 UI Integration:
- All existing UI components maintained
- Enhanced with real-time data
- Improved error handling
- Loading states for better UX
- Consistent data formatting

## 🚀 Usage Examples

### Creating a Booking:
```dart
final bookingService = BookingService();
final result = await bookingService.createBooking(
  venue: selectedVenue,
  court: selectedCourt,
  bookingDate: DateTime.now().add(Duration(days: 1)),
  timeSlot: "18:00",
  startTime: DateTime.now().add(Duration(days: 1, hours: 18)),
  endTime: DateTime.now().add(Duration(days: 1, hours: 19)),
  durationMinutes: 60,
  price: 2000.0,
  totalAmount: 2000.0,
);
```

### Adding to Favorites:
```dart
await CustomerService.addToFavorites(venueId);
```

### Creating a Review:
```dart
await CustomerService.createReview(
  facilityId: venue.id,
  rating: 5,
  comment: "Great facility!",
  wouldRecommend: true,
);
```

## 🔍 Testing Checklist

### Authentication:
- [ ] User can sign up with email and password
- [ ] User can sign in with existing credentials
- [ ] Profile creation after signup
- [ ] Profile data persistence

### Venue Discovery:
- [ ] Venues load from database
- [ ] Search filters work correctly
- [ ] Location-based results
- [ ] Real-time availability display

### Booking System:
- [ ] Time slots generate correctly
- [ ] Booking creation successful
- [ ] Booking history displays
- [ ] Cancellation workflow

### Data Sync:
- [ ] Favorites sync across sessions
- [ ] Profile updates save correctly
- [ ] Notifications display properly
- [ ] Real-time updates work

This integration ensures that the Athlon Customer App has a robust, scalable, and secure connection to the Supabase database while maintaining excellent user experience.
