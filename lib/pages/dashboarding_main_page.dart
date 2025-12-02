import 'package:flutter/material.dart';
//import 'package:rent_a_cart/main.dart';
import 'package:rent_a_cart/pages/dashboard/models/car.dart';
import 'package:rent_a_cart/core/theme/app_colors.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/dashboard_header.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/greeting_section.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/filter_bar.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/nearby_header.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/car_card.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/app_bottom_nav.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardMainPage extends StatefulWidget {
  const DashboardMainPage({super.key});

  @override
  State<DashboardMainPage> createState() => _DashboardMainPageState();
}

class _DashboardMainPageState extends State<DashboardMainPage> {
  SupabaseClient supabase = Supabase.instance.client;
  int _selectedIndex = 0;
  String _selectedFilter = 'All';
  final List<String> _filters = const ['All', 'Tesla', 'Mercedes', 'BMW'];

  List<Car> _cars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCars();
  }

  Future<void> _fetchCars() async {
    try {
      final response = await supabase.from('cars').select();
      print("GELEN VERİ: $response");

      if (mounted) {
        setState(() {
          _cars = response.map((carMap) => Car.fromMap(carMap)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("HATA: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _cars.isEmpty
                      ? const Center(child: Text("Hiç araç bulunamadı."))
                      : Column(
                          children: _cars
                              .map(
                                (c) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: CarCard(car: c),
                                ),
                              )
                              .toList(),
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
