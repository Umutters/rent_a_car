import 'package:flutter/material.dart';
import 'package:rent_a_cart/core/theme/app_colors.dart';
import 'package:rent_a_cart/pages/dashboard/dashboard_home.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/app_bottom_nav.dart';
import 'package:rent_a_cart/pages/favorites_page.dart';

class DashboardMainPage extends StatefulWidget {
  const DashboardMainPage({super.key});

  @override
  State<DashboardMainPage> createState() => _DashboardMainPageState();
}

class _DashboardMainPageState extends State<DashboardMainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardHome(),
    const Center(
      child: Text("Arama Sayfası", style: TextStyle(color: Colors.white)),
    ), // Placeholder
    const FavoritesPage(),
    const Center(
      child: Text("Mesajlar Sayfası", style: TextStyle(color: Colors.white)),
    ), // Placeholder
    const Center(
      child: Text("Profil Sayfası", style: TextStyle(color: Colors.white)),
    ), // Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryRadialGradient,
        ),
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedIndex,
        onChanged: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}
