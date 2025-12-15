import 'package:flutter/material.dart';
import 'package:rent_a_cart/core/theme/app_colors.dart';
import 'package:rent_a_cart/core/services/database_service.dart';
import 'package:rent_a_cart/core/widgets/common_states.dart';
import 'package:rent_a_cart/pages/dashboard/models/car.dart';
import 'package:rent_a_cart/pages/dashboard/widgets/car_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final DatabaseService _dbService = DatabaseService();

  List<Car> _favoriteCars = [];
  bool _isLoading = true;
  String? _errorMessage;
  RealtimeChannel? _favoritesChannel;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
    _subscribeToFavorites();
  }

  @override
  void dispose() {
    if (_favoritesChannel != null) {
      supabase.removeChannel(_favoritesChannel!);
    }
    super.dispose();
  }

  void _subscribeToFavorites() {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    _favoritesChannel = _dbService.subscribeFavorites(
      userId: userId,
      onChanged: (payload) {
        print("Favorilerde değişiklik algılandı: $payload");
        _fetchFavorites();
      },
    );
  }

  Future<void> _fetchFavorites() async {
    print("Favoriler getiriliyor...");
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        print("Kullanıcı oturumu yok.");
        setState(() {
          _isLoading = false;
          _errorMessage = "Kullanıcı oturumu bulunamadı.";
        });
        return;
      }

      final cars = await _dbService.getUserFavorites(userId);

      if (mounted) {
        setState(() {
          _favoriteCars = cars;
          _isLoading = false;
        });
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
                  ? const LoadingIndicator(message: 'Favoriler yükleniyor...')
                  : _errorMessage != null
                  ? ErrorMessage(
                      message: _errorMessage!,
                      onRetry: _fetchFavorites,
                    )
                  : _favoriteCars.isEmpty
                  ? const EmptyState(
                      message: "Henüz favori araç eklemediniz.",
                      icon: Icons.favorite_outline,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _favoriteCars.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CarCard(
                            car: _favoriteCars[index],
                            onFavoriteChanged: () {
                              // Anlık olarak listeden kaldır
                              setState(() {
                                _favoriteCars.removeAt(index);
                              });
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
