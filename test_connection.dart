import 'dart:io';
import 'package:http/http.dart' as http;

// Simple script to test Supabase connection
void main() async {
  const supabaseUrl = 'https://qbcrkavknxiypipxrlak.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFiY3JrYXZrbnhpeXBpcHhybGFrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzOTg5NzcsImV4cCI6MjA2MDk3NDk3N30.lN-lu02oLSzjBR4lBaazFBtp3uEkU1RVeszjxmi1qvI';

  print('🚀 Testing Supabase Connection...');
  print('URL: $supabaseUrl');
  print('Key: ${supabaseAnonKey.substring(0, 20)}...');
  print('');

  try {
    // Test 1: Basic connection to Supabase
    print('📡 Test 1: Basic Connection');
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
      },
    );

    if (response.statusCode == 200) {
      print('✅ Basic connection successful!');
    } else {
      print('❌ Basic connection failed: ${response.statusCode}');
      print('Response: ${response.body}');
    }

    // Test 2: Try to access profiles table
    print('');
    print('📊 Test 2: Profiles Table Access');
    final profilesResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/profiles?select=count'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
      },
    );

    print('Status: ${profilesResponse.statusCode}');
    if (profilesResponse.statusCode == 200) {
      print('✅ Profiles table accessible!');
      print('Response: ${profilesResponse.body}');
    } else {
      print('❌ Profiles table access failed');
      print('Response: ${profilesResponse.body}');
    }

    // Test 3: Try to access facilities table
    print('');
    print('🏢 Test 3: Facilities Table Access');
    final facilitiesResponse = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/facilities?select=id,name&limit=5'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
      },
    );

    print('Status: ${facilitiesResponse.statusCode}');
    if (facilitiesResponse.statusCode == 200) {
      print('✅ Facilities table accessible!');
      print('Response: ${facilitiesResponse.body}');
    } else {
      print('❌ Facilities table access failed');
      print('Response: ${facilitiesResponse.body}');
    }

    print('');
    print('🎯 Connection test completed!');

  } catch (e) {
    print('❌ Error during testing: $e');
  }
}
