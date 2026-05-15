import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_a_cart/core/theme/app_colors.dart';
import 'package:rent_a_cart/core/widgets/animations/scale_button.dart';

class FilterBar extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  const FilterBar({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        itemBuilder: (context, index) => _chip(context, filters[index]),
      ),
    );
  }

  IconData _getIconForFilter(String label) {
    switch (label.toLowerCase()) {
      case 'all':
      case 'tümü':
        return Icons.grid_view_rounded;
      case 'sedan':
        return Icons.directions_car_rounded;
      case 'suv':
        return Icons.airport_shuttle_rounded;
      case 'sport':
      case 'sports':
        return Icons.sports_score_rounded;
      case 'electric':
      case 'elektrik':
        return Icons.electric_car_rounded;
      case 'luxury':
      case 'lüks':
        return Icons.star_rounded;
      default:
        return Icons.directions_car_rounded;
    }
  }

  Widget _chip(BuildContext context, String label) {
    final isSelected = label == selected;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ScaleButton(
        onPressed: () => onSelected(label),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          AppColors.accent.withOpacity(0.25),
                          AppColors.accent.withOpacity(0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected
                    ? null
                    : const Color.fromRGBO(255, 255, 255, 0.08),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? AppColors.accent
                      : const Color.fromRGBO(255, 255, 255, 0.15),
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIconForFilter(label),
                      size: 18,
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
