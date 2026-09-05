import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  print('🔍 Testing Supabase Connection...\n');
  
  try {
    // Load .env
    await dotenv.load(fileName: '.env');
    print('✅ .env file loaded');
    
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    
    print('📊 Configuration:');
    print('   URL: $url');
    print('   Key Length: ${key.length} characters');
    print('   Key Preview: ${key.substring(0, key.length > 50 ? 50 : key.length)}...\n');
    
    if (url.isEmpty || key.isEmpty) {
      print('❌ ERROR: URL or Key is empty!');
      return;
    }
    
    // Initialize Supabase
    print('🔄 Initializing Supabase...');
    await Supabase.initialize(
      url: url,
      anonKey: key,
    );
    print('✅ Supabase initialized successfully\n');
    
    final supabase = Supabase.instance.client;
    
    // Test 1: Check connection
    print('🧪 Test 1: Fetching events...');
    final eventsResponse = await supabase
        .from('events')
        .select('id, title')
        .limit(5);
    
    print('✅ Events fetched successfully!');
    print('   Found ${eventsResponse.length} events:');
    for (var event in eventsResponse) {
      print('   - ${event['title']}');
    }
    print('');
    
    // Test 2: Check profiles
    print('🧪 Test 2: Fetching user Varo...');
    final profileResponse = await supabase
        .from('profiles')
        .select('full_name, student_id, class, role')
        .eq('student_id', '12345')
        .single();
    
    print('✅ User Varo found!');
    print('   Name: ${profileResponse['full_name']}');
    print('   NIS: ${profileResponse['student_id']}');
    print('   Class: ${profileResponse['class']}');
    print('   Role: ${profileResponse['role']}');
    print('');
    
    print('🎉 ALL TESTS PASSED!');
    print('✅ Supabase connection is working perfectly!');
    
  } catch (e) {
    print('❌ ERROR: $e');
    print('\n💡 Possible issues:');
    print('   1. Anon key might be incorrect or incomplete');
    print('   2. SQL script not run yet in Supabase');
    print('   3. URL is wrong');
    print('   4. Network connection issue');
  }
}
