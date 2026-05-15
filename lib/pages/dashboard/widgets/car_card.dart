import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_a_cart/core/theme/app_colors.dart';
import 'package:rent_a_cart/pages/dashboard/car_details_page.dart';
import 'package:rent_a_cart/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:rent_a_cart/core/widgets/animations/scale_button.dart';
import '../models/car.dart';

class CarCard extends StatefulWidget {
  final Car car;
  final VoidCallback?
  onFavoriteChanged; // Callback for instant UI update in parent

  const CarCard({super.key, required this.car, this.onFavoriteChanged});

  @override
  State<CarCard> createState() => _CarCardState();
}

class _CarCardState extends State<CarCard> {
  final UserService _userService = UserService();
  final _supabase = Supabase.instance.client;
  bool isFavorite = false;
  late final RealtimeChannel _favoritesChannel;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _subscribeToFavorites();
  }

  @override
  void dispose() {
    _supabase.removeChannel(_favoritesChannel);
    super.dispose();
  }

  void _subscribeToFavorites() {
    _favoritesChannel = _supabase
        .channel('carcard:${widget.car.id}')
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
            debugPrint(
              "CarCard ${widget.car.id}: Favori değişikliği algılandı",
            );
            _checkIfFavorite();
          },
        )
        .subscribe();
  }

  @override
  void didUpdateWidget(CarCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sadece araç ID değiştiyse yeniden kontrol et
    if (oldWidget.car.id != widget.car.id ||
        oldWidget.car.brand != widget.car.brand ||
        oldWidget.car.model != widget.car.model) {
      _checkIfFavorite();
    }
  }

  Future<void> _checkIfFavorite() async {
    if (widget.car.id.isEmpty || widget.car.id == '0') return;

    try {
      final userId = _userService.getCurrentUserId();
      if (userId == null) return;

      final favoriteIds = await _userService.getUserFavorites(userId);
      if (mounted) {
        setState(() {
          isFavorite = favoriteIds.contains(widget.car.id);
        });
      }
    } catch (e) {
      debugPrint('Error checking favorite: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (widget.car.id.isEmpty || widget.car.id == '0') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Hata: Geçersiz araç ID')));
      return;
    }

    // Optimistic update
    final previousState = isFavorite;
    setState(() => isFavorite = !isFavorite);

    // Notify parent immediately if needed (e.g. to remove from list)
    widget.onFavoriteChanged?.call();

    try {
      final userId = _userService.getCurrentUserId();
      if (userId == null) return;

      if (isFavorite) {
        await _userService.addToFavorites(userId, widget.car.id);
      } else {
        await _userService.removeFromFavorites(userId, widget.car.id);
      }
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() => isFavorite = previousState);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('İşlem başarısız: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = '${widget.car.brand} ${widget.car.model}';
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarDetailsPage(car: widget.car),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      text,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: _toggleFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.car.year,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.car.dailyRate} ₺',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: widget.car.imageurl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.car.imageurl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.directions_car,
                                    size: 60,
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          )
                        : Icon(
                            Icons.directions_car,
                            size: 60,
                            color: AppColors.textSecondary,
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.iconLight,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          widget.car.locations != null
                              ? '${widget.car.locations?.address ?? 'No address'}, ${widget.car.locations?.country ?? 'No country'}'
                              : 'Location ID: ${widget.car.locationId}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
