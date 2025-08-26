# Athlon User App - Database Integration

This document explains how to integrate the Athlon User app with the Supabase database.

## Prerequisites

1. Set up Supabase project
2. Run the SQL schema from the `database/` folder
3. Configure environment variables

## Setup Instructions

### 1. Supabase Project Setup

1. Go to [Supabase](https://supabase.com) and create a new project
2. Copy your project URL and anon key
3. Update the configuration in `lib/customers/config/supabase_config.dart`

### 2. Database Schema

Execute the SQL files in this order:

1. `database/schema.sql` - Main database schema
2. `database/business_hours_supabase_migration.sql` - Business hours functionality
3. `database/fix_profile_rls_policies.sql` - Row Level Security policies
4. `database/storage_setup.sql` - File storage setup (if needed)

### 3. Configuration

Update `lib/customers/config/supabase_config.dart` with your actual values:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project-id.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';
}
```

### 4. Row Level Security (RLS)

The database uses RLS for security. Key policies:

- `profiles` table: Users can CRUD their own data, public can view vendor profiles
- `facilities` table: Public read access, vendors can manage their facilities
- `bookings` table: Users can view/create their bookings, vendors can manage bookings for their facilities
- `customers` table: Public read for phone lookup, authenticated users can create/update

### 5. Features Integrated

#### Customer Features
- **Venue Discovery**: Browse sports facilities from the database
- **Search & Filter**: Search by location, sport type, rating
- **Bookings**: Create and manage court bookings
- **Reviews**: Leave reviews for facilities
- **Favorites**: Save favorite venues
- **User Profile**: Manage customer profile

#### Data Models
- `VenueModel`: Represents sports facilities with courts, images, amenities
- `Court`: Individual courts within facilities
- `Booking`: Customer bookings with payment status
- `Review`: Customer reviews and ratings
- `UserProfile`: Customer profile information

#### Services
- `SupabaseService`: Direct Supabase integration
- `DataService`: Data layer with fallback to mock data
- All services handle both authenticated and anonymous users

## Mock Data Fallback

The app includes comprehensive mock data that mirrors the database structure:
- Sample venues with realistic data
- Courts with pricing and amenities
- Proper image URLs and facility information

This ensures the app works even when:
- Supabase is not configured
- Database is unavailable
- Network connectivity issues

## Database Tables Used

### Core Tables
- `profiles` - User/vendor profiles
- `facilities` - Sports facilities
- `courts` - Individual courts within facilities
- `bookings` - Court reservations
- `customers` - Customer information
- `time_slots` - Available booking slots

### Supporting Tables
- `reviews` - Facility reviews and ratings
- `business_hours` - Facility operating hours
- `facility_images` - Facility photos
- `notifications` - User notifications
- `customer_favorites` - Saved venues

### Views and Functions
- `facility_stats` - Aggregated facility statistics
- `vendor_business_hours` - Business hours with formatting
- Various RPC functions for complex operations

## API Methods Available

### Authentication
- `signUp()` / `signIn()` / `signOut()`
- `resetPassword()`
- `createUserProfile()`

### Venues
- `getVenues()` - List all facilities
- `getVenueDetails()` - Detailed facility info
- `searchVenues()` - Search with filters

### Bookings
- `createBooking()` - Make a reservation
- `getUserBookings()` - Customer booking history
- `getTimeSlots()` - Available time slots

### Reviews & Favorites
- `createReview()` / `getVenueReviews()`
- `addToFavorites()` / `getUserFavorites()`

## Testing

1. **Without Supabase**: App uses mock data automatically
2. **With Supabase**: Update config and test with real data
3. **Mixed Mode**: Real data with mock fallback on errors

## Security Considerations

- All sensitive operations require authentication
- RLS policies enforce data access rules
- Customer data is protected with proper permissions
- Anonymous users can browse venues but not create bookings

## Future Enhancements

1. **Real-time Updates**: WebSocket integration for live booking updates
2. **Push Notifications**: Firebase integration for booking reminders
3. **Payment Integration**: Stripe or PayHere for online payments
4. **Map Integration**: Google Maps for facility locations
5. **Analytics**: Customer behavior tracking

## Troubleshooting

### Common Issues

1. **"Supabase not initialized"**: Check config values
2. **"Row Level Security" errors**: Verify RLS policies are applied
3. **Empty venue list**: Check database has sample data
4. **Booking failures**: Ensure time slots are generated

### Debug Mode

Enable debug logs in `SupabaseConfig.enableDebugLogs = true` to see detailed API calls.

### Support

For issues with database integration, check:
1. Supabase dashboard logs
2. Network connectivity
3. API key permissions
4. Database table structure matches schema

## 🎯 INTEGRATION PROGRESS UPDATE

### ✅ Recently Completed (Current Session)

#### Core Model Integration
- **Unified VenueModel**: All screens now use `models/venue_models.dart` instead of local models
- **Field Mapping**: Updated all field references (title→name, isAvailable→isActive, etc.)
- **Import Standardization**: Consistent imports across all screens

#### Screen Updates Completed
1. **Home Screen** - Real Supabase data integration ✅
2. **Bookings Screen** - Model updates and field mappings ✅
3. **Nearby Venues Screen** - DataService integration and real data loading ✅
4. **Court Details Screen** - Model cleanup and import updates ✅
5. **Available Sports Screen** - VenueModel conversion updates ✅
6. **Search Screen** - Model mapping and field fixes ✅

#### Compilation Status
- ✅ **No Critical Errors**: All major compilation errors resolved
- ✅ **Model Conflicts Fixed**: Removed duplicate VenueModel classes
- ✅ **Import Issues Resolved**: Updated all import statements
- ⚠️ **Minor Warnings**: Only unused import warnings remain

### 🔄 Next Priority Tasks

1. **Favorites Integration**: Update `favourites.dart` to use SupabaseService
2. **Profile Management**: Integrate user profile with Supabase auth
3. **History Screen**: Add real booking history from database
4. **Configuration**: Set up actual Supabase credentials
5. **Testing**: End-to-end testing of all integrated features

### 📊 Current Integration Status: ~80% Complete

The major architectural work is done. The app can now:
- Load venues from Supabase (with mock fallback)
- Use consistent data models across all screens
- Handle authentication and user management
- Process bookings and user interactions

**Ready for production setup and final testing phase.**
