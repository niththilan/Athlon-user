import 'package:flutter/material.dart';
import 'customers/services/supabase_service.dart';
import 'customers/services/data_service.dart';
import 'customers/services/customer_service.dart';

class SimpleSupabaseTest extends StatefulWidget {
  const SimpleSupabaseTest({super.key});

  @override
  State<SimpleSupabaseTest> createState() => _SimpleSupabaseTestState();
}

class _SimpleSupabaseTestState extends State<SimpleSupabaseTest> {
  List<String> logs = [];
  bool isLoading = false;

  void addLog(String message) {
    setState(() {
      logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
    print(message);
  }

  Future<void> testBasicConnection() async {
    setState(() {
      isLoading = true;
      logs.clear();
    });

    addLog('🔵 Starting basic Supabase test...');

    try {
      // Test 1: Check if client exists
      addLog('🔍 Checking Supabase client...');
      final client = SupabaseService.client;
      addLog('✅ Supabase client is available');

      // Test 2: Simple query
      addLog('🔍 Testing simple query...');
      final response = await client
          .from('facilities')
          .select('id, name')
          .limit(1);
      
      addLog('✅ Query successful');
      addLog('📊 Response: ${response.toString()}');

      // Test 3: Count facilities
      addLog('🔍 Counting total facilities...');
      final countResponse = await client
          .from('facilities')
          .select('id')
          .count();
      
      addLog('✅ Total facilities in database: ${countResponse.count}');

      // Test 4: Test facilities with profiles join
      addLog('🔍 Testing complex query with join...');
      final joinResponse = await client
          .from('facilities')
          .select('''
            id,
            name,
            location,
            profiles!facilities_owner_id_fkey(
              name,
              phone
            )
          ''')
          .limit(2);
      
      addLog('✅ Join query successful: ${joinResponse.length} records');
      for (var facility in joinResponse) {
        final ownerName = facility['profiles']?['name'] ?? 'Unknown';
        addLog('  🏢 ${facility['name']} (Owner: $ownerName)');
      }

    } catch (e) {
      addLog('❌ Error: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> testAppServices() async {
    setState(() {
      isLoading = true;
    });

    addLog('🔵 Testing app-level services...');

    try {
      // Test DataService
      addLog('🔍 Testing DataService.loadVenues()...');
      final venues = await DataService.loadVenues();
      addLog('✅ DataService loaded ${venues.length} venues');
      
      if (venues.isNotEmpty) {
        addLog('  🏟️ First venue: ${venues.first.name}');
        addLog('  📍 Location: ${venues.first.location}');
        addLog('  ⭐ Rating: ${venues.first.rating}');
      }

      // Test CustomerService
      addLog('🔍 Testing CustomerService.searchVenues()...');
      final searchResults = await CustomerService.searchVenues(
        searchTerm: 'facility',
      );
      addLog('✅ CustomerService found ${searchResults.length} venues');

    } catch (e) {
      addLog('❌ App services error: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Supabase Test'),
        backgroundColor: const Color(0xFF1B2C4F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: isLoading ? null : testBasicConnection,
              child: Text(isLoading ? 'Testing...' : 'Test Basic Connection'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading ? null : testAppServices,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(isLoading ? 'Testing...' : 'Test App Services'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    logs.isEmpty 
                        ? 'Click the button to test Supabase connection'
                        : logs.join('\n'),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
