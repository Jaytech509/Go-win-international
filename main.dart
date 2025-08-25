import 'package:flutter/material.dart';
import 'package:ascendant_reach/theme.dart';
import 'package:ascendant_reach/screens/auth_screen.dart';
import 'package:ascendant_reach/services/storage_service.dart';
import 'package:ascendant_reach/services/data_init_service.dart';
import 'package:ascendant_reach/supabase/supabase_config.dart';
import 'package:ascendant_reach/services/translation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🏆 Starting GO-WIN INTERNATIONAL - Winners Circle Platform...');
  
  try {
    // Initialize storage service first
    await StorageService.init();
    print('✅ Storage service initialized');
    
    // Initialize translation service
    await TranslationService.initialize();
    print('✅ Translation service initialized');
    
    // Initialize sample data if needed
    await DataInitService.initializeSampleData();
    print('✅ Sample data ready');
    
    // Initialize Supabase (optional - continues in offline mode if fails)
    try {
      await SupabaseConfig.initialize();
      print('✅ Supabase connected successfully');
    } catch (e) {
      print('⚠️ Supabase connection failed: $e');
      print('📦 Operating in offline mode with local storage');
    }
    
  } catch (e) {
    print('⚠️ Initialization warning: $e');
    print('🔄 App will continue with basic initialization');
  }
  
  print('🎆 GO-WIN INTERNATIONAL Winners Circle is ready!');
  print('🚀 Launching application interface...');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: TranslationService.translate('app_title') + ' - ' + TranslationService.translate('winners_circle'),
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthScreen(),
    );
  }
}
