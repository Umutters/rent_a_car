import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_a_cart/core/theme/app_colors.dart';
import 'package:rent_a_cart/core/widgets/common_cards.dart';

/// Kullanıcı istatistikleri widget'ı
class UserStatsCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const UserStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.2),
            AppColors.accent.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'İstatistiklerim',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatCard(
                icon: Icons.directions_car,
                value: '${stats['total_bookings'] ?? 0}',
                label: 'Toplam\nRezervasyonlar',
              ),
              StatCard(
                icon: Icons.check_circle,
                value: '${stats['completed_bookings'] ?? 0}',
                label: 'Tamamlanan\nKiralamalar',
              ),
              StatCard(
                icon: Icons.attach_money,
                value: '₺${_formatNumber(stats['total_spent'])}',
                label: 'Toplam\nHarcama',
              ),
            ],
          ),
          if (stats['favorite_brand'] != null) ...[
            const SizedBox(height: 16),
            _FavoriteBrandCard(brand: stats['favorite_brand']),
          ],
        ],
      ),
    );
  }

  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    if (value is num) return value.toStringAsFixed(0);
    final parsed = num.tryParse(value.toString());
    return parsed?.toStringAsFixed(0) ?? '0';
  }
}

class _FavoriteBrandCard extends StatelessWidget {
  final String brand;

  const _FavoriteBrandCard({required this.brand});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Favori Markanız',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                brand,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Profil menü item widget'ı
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.accent, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Profil avatar widget'ı
class ProfileAvatar extends StatelessWidget {
  final String fullName;
  final String avatarUrl;
  final double size;

  const ProfileAvatar({
    super.key,
    required this.fullName,
    required this.avatarUrl,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipOval(
        child: avatarUrl.isNotEmpty
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultAvatar(),
              )
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: Text(
          fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
          style: GoogleFonts.plusJakartaSans(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}
