import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_a_cart/core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardHeader extends StatelessWidget {
  final String location;
  final VoidCallback? onFilterTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLocationTap;

  const DashboardHeader({
    super.key,
    required this.location,
    this.onFilterTap,
    this.onProfileTap,
    this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    // Kullanıcı bilgilerini al
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata;
    final avatarUrl = metadata?['avatar_url'] ?? '';
    final fullName = metadata?['full_name'] ?? metadata?['name'] ?? '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Lokasyon - Tıklanabilir
        GestureDetector(
          onTap: onLocationTap ?? onFilterTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 18,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Konum',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      location,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        // Sağ taraf - Bildirim ve Profil
        Row(
          children: [
            // Bildirim butonu
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.2)),
              ),
              child: IconButton(
                icon: Stack(
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.iconLight,
                      size: 22,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bildirimler yakında eklenecek'),
                    ),
                  );
                },
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(width: 12),
            // Profil butonu - Avatar ile
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color.fromRGBO(AppColors.accent.red, AppColors.accent.green, AppColors.accent.blue, 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(AppColors.accent.red, AppColors.accent.green, AppColors.accent.blue, 0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: avatarUrl.isNotEmpty
                      ? Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultAvatar(fullName),
                        )
                      : _buildDefaultAvatar(fullName),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}
