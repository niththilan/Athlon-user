import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';

class SupabaseConnectionTest extends StatefulWidget {
  const SupabaseConnectionTest({super.key});

  @override
  State<SupabaseConnectionTest> createState() => _SupabaseConnectionTestState();
}

class _SupabaseConnectionTestState extends State<SupabaseConnectionTest> {
  String _connectionStatus = 'Testing connection...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    try {
      // Test basic connection
      final client = Supabase.instance.client;
      
      // Try to query a simple system table to test connection
      final response = await client
          .from('profiles')
          .select('count')
          .limit(1);
      
      if (response.isEmpty) {
        // This is actually fine - empty table is still a valid connection
      }

      setState(() {
        _connectionStatus = '✅ Connection successful! Supabase is working.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _connectionStatus = '❌ Connection failed: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _testVenueData() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = 'Testing venue data...';
    });

    try {
      final client = Supabase.instance.client;
      
      // Try to fetch venues
      final response = await client
          .from('facilities')
          .select('id, name, location')
          .limit(5);

      final venues = response as List<dynamic>;
      setState(() {
        _connectionStatus = '✅ Venues loaded successfully! Found ${venues.length} venues.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _connectionStatus = '❌ Venue data test failed: ${e.toString()}';
        _isLoading = false;
      });
    }
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Supabase Configuration:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('URL: ${SupabaseConfig.supabaseUrl}'),
            Text('Key: ${SupabaseConfig.supabaseAnonKey.substring(0, 20)}...'),
            const SizedBox(height: 30),
            const Text(
              'Connection Status:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_isLoading)
              const Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 15),
                  Text('Testing...'),
                ],
              )
            else
              Text(
                _connectionStatus,
                style: TextStyle(
                  fontSize: 16,
                  color: _connectionStatus.startsWith('✅') ? Colors.green : Colors.red,
                ),
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              child: const Text('Test Connection'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _testVenueData,
              child: const Text('Test Venue Data'),
            ),
          ],
        ),
      ),
    );
  }
}
