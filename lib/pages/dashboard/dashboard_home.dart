import 'package:flutter/material.dart';
import 'package:rent_a_cart/pages/dashboard/models/car.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/dashboard_header.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/greeting_section.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/filter_bar.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/nearby_header.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/car_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  final SupabaseClient supabase = Supabase.instance.client;
  String _selectedFilter = 'All';
  List<String> _filters = ['All']; // Dinamik olarak RPC'den çekecek

  List<Car> _cars = [];
  bool _isLoading = true;
  String _username = 'Driver';
  String _currentCity = 'Şehir Seç'; // Şehir bilgisi
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTopBrands(); // İlk olarak top brands'ı çek
    _fetchCars();
    _fetchUserProfile();
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
      final topBrandsData = await supabase.rpc('get_top_brands');
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

      // Eğer "All" seçiliyse tüm araçları, değilse brand'a göre filtrelenmiş araçları çek
      if (_selectedFilter == 'All') {
        response = await supabase.from('cars').select();
      } else {
        // Seçilen brand'a ait araçları getir
        response = await supabase
            .from('cars')
            .select()
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
                onFilterTap: () {},
                onProfileTap: () {},
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
