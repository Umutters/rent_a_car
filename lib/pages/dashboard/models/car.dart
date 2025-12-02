import 'package:flutter/material.dart';

class Car {
  final String createdat;
  final String brand; //e.g. 'Ford'
  final String model; // e.g. 'Focus'
  final String year; // e.g. '2020'
  final String licensePlate;
  final int dailyRate; // e.g. 1280
  final String status; // e.g. 'Available'
  final String imageurl; // e.g. '8.9 L'
  final String location;

  const Car({
    required this.createdat,
    required this.brand,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.dailyRate,
    required this.status,
    required this.imageurl,
    required this.location,
  });

  // Supabase'den gelen Map'ten Car oluşturmak için factory constructor
  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      createdat: map['created_at'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      year: map['year']?.toString() ?? '',
      licensePlate: map['license_plate'] ?? '',
      dailyRate: map['daily_rate'] ?? 0,
      status: map['status'] ?? '',
      imageurl: map['image_url'] ?? '',
      location: map['location'] ?? '',
    );
  }
}
