class SupabaseConfig {
  // Supabase project credentials
  static const String supabaseUrl = 'https://qbcrkavknxiypipxrlak.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFiY3JrYXZrbnhpeXBpcHhybGFrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzOTg5NzcsImV4cCI6MjA2MDk3NDk3N30.lN-lu02oLSzjBR4lBaazFBtp3uEkU1RVeszjxmi1qvI';
  
  // Database configuration
  static const String databaseSchema = 'public';
  
  // Storage bucket names
  static const String profileImagesBucket = 'profile-images';
  static const String facilityImagesBucket = 'facility-images';
  static const String reviewImagesBucket = 'review-images';
  
  // Enable/disable features for testing
  static const bool enableRealTimeUpdates = true;
  static const bool enableOfflineMode = false;
  static const bool enableDebugLogs = true;
  
  // App configuration
  static const String defaultUserType = 'customer';
  static const String appVersion = '1.0.0';
  static const String appName = 'Athlon User';
  
  // Regional settings
  static const String defaultTimezone = 'Asia/Kolkata';
  static const String defaultCurrency = 'LKR';
  static const String defaultCountryCode = '+94';
  
  // Business rules
  static const int maxBookingsPerUser = 10;
  static const int bookingAdvanceDays = 30;
  static const int cancellationHours = 24;
  
  // Search and pagination
  static const int maxSearchResults = 50;
  static const int defaultPageSize = 20;
  static const int maxFavoritesPerUser = 100;
  
  // Cache settings
  static const Duration cacheTimeout = Duration(minutes: 30);
  static const Duration networkTimeout = Duration(seconds: 30);
  
  // UI settings
  static const int maxImageUploadSize = 5 * 1024 * 1024; // 5MB
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
}
