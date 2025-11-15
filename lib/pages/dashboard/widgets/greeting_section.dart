import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GreetingSection extends StatelessWidget {
  final String username;
  const GreetingSection({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Morning, $username!',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Time to hit the road! Select a car that matches your style.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
