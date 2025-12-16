import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_a_cart/core/theme/app_colors.dart';
import 'package:rent_a_cart/pages/dashboard/car_details_page.dart';
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
  bool isFavorite = false;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (widget.car.id.isEmpty || widget.car.id == '0') return;

    try {
      final response = await supabase
          .from('favorites')
          .select()
          .eq('user_id', user.id)
          .eq('car_id', widget.car.id);

      if (mounted) {
        setState(() {
          isFavorite = (response as List).isNotEmpty;
        });
      }
    } catch (e) {
      debugPrint('Error checking favorite: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (widget.car.id.isEmpty || widget.car.id == '0') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Hata: Geçersiz araç ID')));
      return;
    }

    setState(() {
      isFavorite = !isFavorite;
    });
    if (widget.onFavoriteChanged != null) {
      widget.onFavoriteChanged!();
    }

    try {
      if (isFavorite) {
        await supabase.from('favorites').insert({
          'user_id': user.id,
          'car_id': widget.car.id,
        });
      } else {
        await supabase
            .from('favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('car_id', widget.car.id);
      }
    } catch (e) {
      if (e is PostgrestException && e.code == '23503') {
        try {
          debugPrint(
            'Foreign Key Violation detected. Attempting to sync user...',
          );
          final metadata = user.userMetadata;
          await supabase.from('users').upsert({
            'id': user.id,
            'email': user.email,
            'full_name': metadata?['full_name'] ?? metadata?['name'] ?? '',
            'avatar_url': metadata?['avatar_url'] ?? '',
            'updated_at': DateTime.now().toIso8601String(),
          });

          if (isFavorite) {
            await supabase.from('favorites').insert({
              'user_id': user.id,
              'car_id': widget.car.id,
            });
          }
          return;
        } catch (syncError) {
          debugPrint('Sync failed: $syncError');
        }
      }

      if (mounted) {
        setState(() {
          isFavorite = !isFavorite;
        });
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
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.2),
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
                // Car Extras Info
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
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
                          Text(
                            widget.car.location,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Transmission
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 255, 255, 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.settings,
                            size: 14,
                            color: AppColors.iconLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.car.transmission,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Fuel Type
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 255, 255, 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_gas_station,
                            size: 14,
                            color: AppColors.iconLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.car.fuelType,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Seats
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 255, 255, 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.airline_seat_recline_normal,
                            size: 14,
                            color: AppColors.iconLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.car.seats} Kişi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
