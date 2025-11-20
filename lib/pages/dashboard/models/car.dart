import 'package:flutter/material.dart';

class Car {
  final String speed;// e.g. '120 km/h'
  final String brand;//e.g. 'Ford'
  final String model; // e.g. 'Focus'
  final String year; // e.g. '2020'
  final String licensePlate;
  final double dailyRate;// e.g. 1280
  final String status; // e.g. 'Available'
  final String fuel; // e.g. '8.9 L'
  final String location;
  final Color imageColor; // placeholder color or could be image path later

  const Car({
    required this.speed,
    required this.brand,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.dailyRate,
    required this.status,
    required this.fuel,
    required this.location,
    required this.imageColor,
  });
}
