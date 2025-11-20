import 'package:flutter/material.dart';
import 'package:rent_a_cart/pages/dashboard/models/car.dart';
import 'package:rent_a_cart/core/theme/app_colors.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/dashboard_header.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/greeting_section.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/filter_bar.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/nearby_header.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/car_card.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/app_bottom_nav.dart';

class DashboardMainPage extends StatefulWidget {
  const DashboardMainPage({super.key});

  @override
  State<DashboardMainPage> createState() => _DashboardMainPageState();
}

class _DashboardMainPageState extends State<DashboardMainPage> {
  int _selectedIndex = 0;
  String _selectedFilter = 'All';

  final List<String> _filters = const ['All', 'Tesla', 'Mercedes', 'BMW'];

  final List<Car> _cars = const [
    Car(
      brand: 'Range Rover',
      model: 'Sport',
      year: '2020',
      licensePlate: 'XYZ-123',
      dailyRate: 0,
      status: 'available',
      speed: '250 km/h',
      fuel: '8.9 L',
      location: 'Biscayne Boulevard',
      imageColor: AppColors.backgroundLight,
    ),
    Car(
      brand: 'Chevrolet',
      model: 'Tahoe',
      year: '2021',
      licensePlate: '123-ABC',
      dailyRate: 0,
      status: 'available',
      speed: '220 km/h',
      fuel: '7 L',
      location: 'Margaret Pace Park',
      imageColor: AppColors.backgroundLight,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryRadialGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  DashboardHeader(
                    location: 'Greenwood Drive, Miami',
                    onFilterTap: () {},
                    onProfileTap: () {},
                  ),
                  const SizedBox(height: 24),
                  const GreetingSection(username: 'Chris'),
                  const SizedBox(height: 24),
                  FilterBar(
                    filters: _filters,
                    selected: _selectedFilter,
                    onSelected: (f) => setState(() => _selectedFilter = f),
                  ),
                  const SizedBox(height: 24),
                  const NearbyHeader(),
                  const SizedBox(height: 16),
                  ..._cars.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CarCard(car: c),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedIndex,
        onChanged: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}
