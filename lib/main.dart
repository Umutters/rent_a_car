import 'package:flutter/material.dart';
import 'package:rent_a_cart/pages/dashboarding_main_page.dart';
import 'package:rent_a_cart/core/theme/app_theme.dart';
import 'package:rent_a_cart/test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rent_a_cart/pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: TestPage(supabaseClient: supabase), // _getInitialPage(),
    );
  }

  Widget _getInitialPage() {
    // Uygulama açılışında session kontrolüS
    final session = supabase.auth.currentSession;

    if (session != null) {
      // Kullanıcı zaten giriş yapmış, direkt dashboard'a git
      return const DashboardMainPage();
    } else {
      // Giriş yapılmamış, login sayfasına git
      return const LoginPage();
    }
  }
}
