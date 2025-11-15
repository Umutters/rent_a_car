import 'package:flutter/material.dart';

class Car {
  final String name;
  final String speed; // e.g. '250 km/h'
  final String fuel; // e.g. '8.9 L'
  final String location;
  final Color imageColor; // placeholder color or could be image path later

  const Car({
    required this.name,
    required this.speed,
    required this.fuel,
    required this.location,
    required this.imageColor,
  });
}
