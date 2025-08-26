import 'package:flutter/material.dart';
import 'lib/customers/services/supabase_service.dart';
import 'lib/customers/services/customer_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('Testing Supabase connection...');
  
  try {
    // Initialize Supabase
    await SupabaseService.initialize();
    print('✅ Supabase initialized successfully');
    
    // Test if we can connect
    final currentUser = SupabaseService.currentUser;
    print('Current user: ${currentUser?.email ?? 'Not logged in'}');
    
    // Test basic query
    final response = await SupabaseService.client
        .from('profiles')
        .select('id')
        .limit(1);
    
    print('✅ Database connection successful');
    print('Sample query result: $response');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}
