import 'package:flutter/material.dart';
import 'package:rent_a_cart/pages/dashboarding_main_page.dart';
import 'package:rent_a_cart/core/theme/app_theme.dart';
import 'package:rent_a_cart/test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rent_a_cart/pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: '...',
    anonKey:'...'
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
