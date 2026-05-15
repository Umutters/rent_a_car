import 'package:flutter/material.dart';
import 'package:rent_a_cart/pages/dashboarding_main_page.dart';
import 'package:rent_a_cart/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rent_a_cart/pages/login_page.dart';
import 'package:rent_a_cart/pages/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  prefs = await SharedPreferences.getInstance();

  await Supabase.initialize(
    url: 'https://iwiyqhdohaxjkedkzgec.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml3aXlxaGRvaGF4amtlZGt6Z2VjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMyMzc0NDMsImV4cCI6MjA3ODgxMzQ0M30.qTweojcTKt8bNqpw-uzTVFxNH6joaKO7OrKH_HXAP6U',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rent a Cart',
      theme: AppTheme.lightTheme,
      home: _getInitialPage(),
    );
  }

  Widget _getInitialPage() {
    // Check if onboarding has been completed
    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!hasSeenOnboarding) {
      return const OnboardingPage();
    }

    final session = supabase.auth.currentSession;

    if (session != null) {
      return const DashboardMainPage();
    } else {
      return const LoginPage();
    }
  }
}
