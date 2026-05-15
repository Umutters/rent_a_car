import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_a_cart/core/theme/app_colors.dart';

class DashboardHeader extends StatelessWidget {
  final String location;
  final VoidCallback? onFilterTap;
  final VoidCallback? onProfileTap;

  const DashboardHeader({
    super.key,
    required this.location,
    this.onFilterTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Konumunuz:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
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
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.tune, color: AppColors.iconLight),
              onPressed: onFilterTap,
            ),
            GestureDetector(
              onTap: onProfileTap,
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color.fromRGBO(255, 255, 255, 0.2),
                        width: 1,
                      ),
                    ),
                    child: const Icon(Icons.person, color: AppColors.iconLight),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
