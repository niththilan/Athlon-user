import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/customers/config/supabase_config.dart';
import 'lib/customers/services/data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Initializing Supabase...');
  
  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    
    print('✅ Supabase initialized successfully!');
    
    // Test venue loading
    print('');
    print('🏢 Loading venues from DataService...');
    
    final venues = await DataService.loadVenues();
    
    print('✅ Venues loaded successfully!');
    print('Found ${venues.length} venues:');
    
    for (int i = 0; i < venues.length && i < 5; i++) {
      final venue = venues[i];
      print('  ${i + 1}. ${venue.name} (${venue.location})');
      print('     Rating: ${venue.rating} | Sports: ${venue.sports.join(", ")}');
    }
    
    if (venues.length > 5) {
      print('  ... and ${venues.length - 5} more venues');
    }
    
    print('');
    print('🎯 Test completed successfully! App is ready to use real Supabase data.');
    
  } catch (e) {
    print('❌ Error during initialization or testing: $e');
  }
}
