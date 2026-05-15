import 'package:flutter/material.dart';
import 'package:rent_a_cart/core/theme/app_colors.dart';
import 'package:rent_a_cart/pages/dashboard/models/car.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/car_card.dart';
import 'package:rent_a_cart/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final UserService _userService = UserService();
  final _supabase = Supabase.instance.client;
  List<Car> _favoriteCars = [];
  bool _isLoading = true;
  String? _errorMessage;
  late final RealtimeChannel _favoritesChannel;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
    _subscribeToFavorites();
  }

  @override
  void dispose() {
    _supabase.removeChannel(_favoritesChannel);
    super.dispose();
  }

  void _subscribeToFavorites() {
    _favoritesChannel = _supabase
        .channel('public:favorites')
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
            print("Favorilerde değişiklik algılandı: $payload");
            _fetchFavorites();
          },
        )
        .subscribe();
  }

  Future<void> _fetchFavorites() async {
    print("Favoriler getiriliyor...");
    try {
      final userId = _userService.getCurrentUserId();
      if (userId == null) {
        print("Kullanıcı oturumu yok.");
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = "Kullanıcı oturumu bulunamadı.";
          });
        }
        return;
      }

      // Her bir favori için car bilgilerini al (locations ile birlikte)
      final response = await _supabase
          .from('favorites')
          .select('car_id, cars(*, locations(*))')
          .eq('user_id', userId);

      print("Favoriler response: ${response.length} adet");

      final List<Car> cars = [];
      for (var item in response) {
        if (item['cars'] != null) {
          print(
            "Favori araç: ${item['cars']['brand']} ${item['cars']['model']}",
          );
          cars.add(Car.fromMap(item['cars']));
        }
      }

      if (mounted) {
        setState(() {
          _favoriteCars = cars;
          _isLoading = false;
        });
        print("Favoriler güncellendi: ${cars.length} adet araç");
      }
    } catch (e) {
      print("Favoriler yüklenirken hata: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Favoriler yüklenirken hata oluştu: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryRadialGradient,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Favorilerim',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : _favoriteCars.isEmpty
                  ? const Center(
                      child: Text(
                        "Henüz favori araç eklemediniz.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _favoriteCars.length,
                      itemBuilder: (context, index) {
                        final car = _favoriteCars[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CarCard(
                            key: ValueKey('fav_${car.id}'),
                            car: car,
                            onFavoriteChanged: () {
                              // Favoriden çıkarıldığında listeyi yeniden çek
                              print("Favori değişti, liste yenileniyor...");
                              _fetchFavorites();
                            },
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 80), // Bottom nav bar space
          ],
        ),
      ),
    );
  }
}
