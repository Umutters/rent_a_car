import 'package:flutter/material.dart';
import 'package:rent_a_cart/pages/dashboard/models/car.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/dashboard_header.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/greeting_section.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/filter_bar.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/nearby_header.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/car_card.dart';
import 'package:rent_a_cart/pages/profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rent_a_cart/core/services/database_service.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  final SupabaseClient supabase = Supabase.instance.client;
  final DatabaseService _dbService = DatabaseService();
  String _selectedFilter = 'All';
  List<String> _filters = ['All']; // Dinamik olarak RPC'den çekecek

  List<Car> _cars = [];
  bool _isLoading = true;
  String _username = 'Driver';
  String _currentCity = 'Şehir Seç'; // Şehir bilgisi
  String? _errorMessage;

  // Lokasyon seçimi için
  List<Map<String, dynamic>> _locations = [];
  String? _selectedLocationId;

  @override
  void initState() {
    super.initState();
    _fetchTopBrands(); // İlk olarak top brands'ı çek
    _fetchLocations(); // Lokasyonları çek
    _fetchCars();
    _fetchUserProfile();
  }

  Future<void> _fetchLocations() async {
    try {
      final locations = await _dbService.getActiveLocations();
      if (mounted) {
        setState(() {
          _locations = locations;
          // İlk lokasyonu varsayılan seç
          if (locations.isNotEmpty) {
            _currentCity = locations.first['city'] ?? 'Şehir Seç';
          }
        });
      }
    } catch (e) {
      print("Lokasyon getirme hatası: $e");
    }
  }

  void _fetchUserProfile() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final metadata = user.userMetadata;
      if (metadata != null) {
        String fullName = metadata['full_name'] ?? metadata['name'] ?? '';
        if (fullName.isNotEmpty) {
          setState(() {
            _username = fullName.split(' ')[0];
          });
        }
      }
    }
  }

  Future<void> _fetchTopBrands() async {
    try {
      print("Top brands RPC'den getiriliyor...");
      final topBrandsData = await _dbService.getTopBrands();
      print("Top Brands Verisi: $topBrandsData");

      if (mounted) {
        setState(() {
          // RPC sonucundan brand isimleri çıkar
          List<String> brandNames = ['All'];
          for (var item in topBrandsData) {
            brandNames.add(item['brand']);
          }
          _filters = brandNames;
        });
      }
    } catch (e) {
      print("Top brands getirme hatası: $e");
      // Hata olursa varsayılan filtreleri kullan
      setState(() {
        _filters = ['All', 'Tesla', 'Mercedes', 'BMW'];
      });
    }
  }

  Future<void> _fetchCars() async {
    try {
      print("Araçlar getiriliyor... (Seçili Filter: $_selectedFilter)");

      late final response;

      // Araçları car_extras ile birlikte çek
      if (_selectedFilter == 'All') {
        response = await supabase.from('cars').select('*, car_extras(*)');
      } else {
        // Seçilen brand'a ait araçları getir
        response = await supabase
            .from('cars')
            .select('*, car_extras(*)')
            .eq('brand', _selectedFilter);
      }

      print("Gelen Araç Verisi: $response");

      if (mounted) {
        setState(() {
          _cars = (response as List)
              .map((carMap) => Car.fromMap(carMap))
              .toList();
          _isLoading = false;
          _errorMessage = null;

          // İlk araçtan şehir bilgisini al
          if (_cars.isNotEmpty && _cars.first.location.isNotEmpty) {
            _currentCity = _cars.first.location;
          }
        });
      }
    } catch (e) {
      print("Araç getirme hatası: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Veriler yüklenirken hata oluştu: $e";
        });
      }
    }
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lokasyon Seçin',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_locations.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _locations.length,
                  itemBuilder: (context, index) {
                    final loc = _locations[index];
                    final isSelected = _selectedLocationId == loc['id'];
                    return ListTile(
                      leading: Icon(
                        Icons.location_on,
                        color: isSelected ? Colors.blue : Colors.grey,
                      ),
                      title: Text(loc['name'] ?? ''),
                      subtitle: Text(
                        '${loc['city']} - ${loc['address'] ?? ''}',
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.blue)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedLocationId = loc['id'];
                          _currentCity = loc['city'] ?? 'Şehir Seç';
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
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
                onLocationTap: _showLocationPicker,
                onProfileTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              GreetingSection(username: _username),
              const SizedBox(height: 24),
              FilterBar(
                filters: _filters,
                selected: _selectedFilter,
                onSelected: (f) {
                  setState(() => _selectedFilter = f);
                  // Seçim değişince araçları yeniden çek
                  _fetchCars();
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
    );
  }
}
