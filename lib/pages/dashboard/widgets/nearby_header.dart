import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NearbyHeader extends StatelessWidget {
  final VoidCallback? onSeeAll;
  const NearbyHeader({super.key, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Nearby You',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            'See All',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFC107),
            ),
          ),
        ),
      ],
    );
  }
}
