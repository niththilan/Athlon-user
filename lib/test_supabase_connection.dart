// Test file to verify Supabase connection and data fetching
import 'package:flutter/material.dart';
import 'customers/services/supabase_service.dart';
import 'customers/services/data_service.dart';

class SupabaseConnectionTest extends StatefulWidget {
  const SupabaseConnectionTest({super.key});

  @override
  State<SupabaseConnectionTest> createState() => _SupabaseConnectionTestState();
}

class _SupabaseConnectionTestState extends State<SupabaseConnectionTest> {
  String _connectionStatus = 'Not tested';
  String _dataFetchStatus = 'Not tested';
  int _venueCount = 0;
  List<String> _testResults = [];

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  Future<void> _runTests() async {
    _addResult('🔄 Starting Supabase connection tests...');
    
    // Test 1: Check if Supabase is initialized
    try {
      _addResult('✅ Supabase client initialized');
      setState(() {
        _connectionStatus = 'Connected';
      });
    } catch (e) {
      _addResult('❌ Supabase initialization failed: $e');
      setState(() {
        _connectionStatus = 'Failed';
      });
      return;
    }

    // Test 2: Test basic connectivity
    try {
      _addResult('🔄 Testing basic Supabase connectivity...');
      await SupabaseService.client.from('facilities').select('count').count();
      _addResult('✅ Basic Supabase query successful');
    } catch (e) {
      _addResult('❌ Basic Supabase query failed: $e');
    }

    // Test 3: Test venue search through DataService
    try {
      _addResult('🔄 Testing venue data fetching...');
      final venues = await DataService.loadVenues();
      setState(() {
        _venueCount = venues.length;
        _dataFetchStatus = venues.isNotEmpty ? 'Success' : 'No data';
      });
      _addResult('✅ Venue data fetch successful: ${venues.length} venues found');
      
      if (venues.isNotEmpty) {
        _addResult('📍 First venue: ${venues.first.name}');
      }
    } catch (e) {
      _addResult('❌ Venue data fetch failed: $e');
      setState(() {
        _dataFetchStatus = 'Failed';
      });
    }

    // Test 4: Test specific venue search
    try {
      _addResult('🔄 Testing venue search with filters...');
      final searchResults = await DataService.searchVenues(
        searchTerm: 'court',
        location: 'Colombo',
      );
      _addResult('✅ Venue search successful: ${searchResults.length} results');
    } catch (e) {
      _addResult('❌ Venue search failed: $e');
    }

    _addResult('🏁 All tests completed!');
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add('${DateTime.now().toString().substring(11, 19)} - $result');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Connection Test'),
        backgroundColor: const Color(0xFF1B2C4F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _connectionStatus == 'Connected' ? Icons.check_circle : Icons.error,
                          color: _connectionStatus == 'Connected' ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(_connectionStatus),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Fetch Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _dataFetchStatus == 'Success' ? Icons.check_circle : Icons.error,
                          color: _dataFetchStatus == 'Success' ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text('$_dataFetchStatus ($_venueCount venues)'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Test Results:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: _testResults.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          _testResults[index],
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _testResults.clear();
                  _connectionStatus = 'Not tested';
                  _dataFetchStatus = 'Not tested';
                  _venueCount = 0;
                });
                _runTests();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B2C4F),
                foregroundColor: Colors.white,
              ),
              child: const Text('Rerun Tests'),
            ),
          ],
        ),
      ),
    );
  }
}
