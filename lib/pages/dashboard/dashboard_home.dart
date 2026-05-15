import 'package:flutter/material.dart';
import 'package:rent_a_cart/pages/dashboard/models/car.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/dashboard_header.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/greeting_section.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/filter_bar.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/nearby_header.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/car_card.dart';
import 'package:rent_a_cart/pages/location_picker_page.dart';
import 'package:rent_a_cart/services/car_service.dart';
import 'package:rent_a_cart/services/location_service.dart';
import 'package:rent_a_cart/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  final CarService _carService = CarService();
  final LocationService _locationService = LocationService();
  final UserService _userService = UserService();
  final _supabase = Supabase.instance.client;

  String _selectedFilter = 'All';
  List<String> _filters = ['All'];

  List<Car> _cars = [];
  bool _isLoading = true;
  String _username = 'Driver';
  String _currentCity = 'Şehir Seç';
  String? _selectedLocationId;
  String? _errorMessage;
  late final RealtimeChannel _favoritesChannel;

  @override
  void initState() {
    super.initState();
    _loadSelectedLocation();
    _fetchTopBrands();
    _fetchUserProfile();
    _subscribeToFavorites();
  }

  @override
  void dispose() {
    _supabase.removeChannel(_favoritesChannel);
    super.dispose();
  }

  void _subscribeToFavorites() {
    _favoritesChannel = _supabase
        .channel('dashboard:favorites')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'favorites',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _supabase.auth.currentUser?.id,
          ),
          callback: (payload) {
            debugPrint("Dashboard: Favorilerde değişiklik algılandı: $payload");
            if (mounted) {
              setState(() {});
            }
          },
        )
        .subscribe();
  }

  Future<void> _loadSelectedLocation() async {
    final location = await _locationService.getSelectedLocation();
    setState(() {
      _selectedLocationId = location['id'];
      _currentCity = location['city'] ?? 'Şehir Seç';
      _selectedFilter = 'All'; 
      _cars = []; 
    });
    await _fetchTopBrands();
    await _fetchCars(); 
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerPage()),
    );
    if (result == true) {
      await _loadSelectedLocation();
    }
  }

  void _fetchUserProfile() {
    final userMetadata = _userService.getCurrentUserMetadata();
    if (userMetadata != null) {
      String fullName = userMetadata['full_name'] ?? '';
      if (fullName.isNotEmpty) {
        setState(() {
          _username = fullName.split(' ')[0];
        });
      }
    }
  }

  Future<void> _fetchTopBrands() async {
    try {
      final brands = await _carService.getTopBrands();
      if (mounted) {
        setState(() {
          _filters = brands;
        });
      }
    } catch (e) {
      print("Top brands getirme hatası: $e");
      if (mounted) {
        setState(() {
          _filters = ['All', 'Tesla', 'Mercedes', 'BMW'];
        });
      }
    }
  }

  Future<void> _fetchCars() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _cars = []; // Eski verileri temizle
    });

    try {
      List<Car> cars;

      if (_selectedFilter == 'All') {
        cars = await _carService.getAllCars(locationId: _selectedLocationId);
      } else {
        cars = await _carService.getCarsByBrand(
          _selectedFilter,
          locationId: _selectedLocationId,
        );
      }

      if (mounted) {
        setState(() {
          _cars = cars;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      debugPrint("Araç getirme hatası: $e");
      if (mounted) {
        setState(() {
          _cars = [];
          _isLoading = false;
          _errorMessage = "Veriler yüklenirken hata oluştu: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              DashboardHeader(
                location: _currentCity.isEmpty ? 'Şehir Seç' : _currentCity,
                onFilterTap: _openLocationPicker,
                onProfileTap: () {},
              ),
              const SizedBox(height: 24),
              GreetingSection(username: _username),
              const SizedBox(height: 24),
              FilterBar(
                filters: _filters,
                selected: _selectedFilter,
                onSelected: (f) {
                  if (_selectedFilter != f) {
                    setState(() {
                      _selectedFilter = f;
                      _cars = []; // Eski verileri hemen temizle
                    });
                    // Seçim değişince araçları yeniden çek
                    _fetchCars();
                  }
                },
              ),
              const SizedBox(height: 24),
              const NearbyHeader(),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : _cars.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          _selectedFilter == 'All'
                              ? "Bu lokasyonda hiç araç bulunamadı."
                              : "Bu filtreye uygun araç bulunamadı.",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Column(
                      children: _cars
                          .map(
                            (c) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: CarCard(
                                key: ValueKey(
                                  '${c.id}_${_selectedLocationId}_${_selectedFilter}',
                                ),
                                car: c,
                                onFavoriteChanged: () {
                                  // Favori değiştiğinde UI'yı güncelle
                                  if (mounted) {
                                    setState(() {});
                                  }
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
