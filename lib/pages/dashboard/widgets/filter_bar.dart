import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: filters.map((f) => _chip(context, f)).toList(),
      ),
    );
  }

  Widget _chip(BuildContext context, String label) {
    final isSelected = label == selected;
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != 'All')
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.directions_car,
                  size: 16,
                  color: isSelected ? Colors.black : Colors.white70,
                ),
              ),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onSelected(label),
        backgroundColor: Colors.white.withOpacity(0.85),
        selectedColor: const Color(0xFFFFC107),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.black : Colors.white70,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFFFFC107) : Colors.white24,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
