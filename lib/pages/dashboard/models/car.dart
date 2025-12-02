import 'package:flutter/material.dart';

class Car {
  final String id; // Changed from int to String to support UUIDs
  final String createdat;
  final String brand; //e.g. 'Ford'
  final String model; // e.g. 'Focus'
  final String year; // e.g. '2020'
  final String licensePlate;
  final int dailyRate; // e.g. 1280
  final String status; // e.g. 'Available'
  final String imageurl; // e.g. '8.9 L'
  final String location;
  final String transmission;
  final String fuelType;
  final int seats;
  final String description;
  final String engineCapacity;
  final String maxSpeed;
  final String acceleration;

  const Car({
    required this.id,
    required this.createdat,
    required this.brand,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.dailyRate,
    required this.status,
    required this.imageurl,
    required this.location,
    this.transmission = 'Automatic',
    this.fuelType = 'Petrol',
    this.seats = 5,
    this.description = '',
    this.engineCapacity = '1.6L',
    this.maxSpeed = '200 km/h',
    this.acceleration = '8.5s',
  });

  // Supabase'den gelen Map'ten Car oluşturmak için factory constructor
  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id']?.toString() ?? '',
      createdat: map['created_at']?.toString() ?? '',
      brand: map['brand']?.toString() ?? '',
      model: map['model']?.toString() ?? '',
      year: map['year']?.toString() ?? '',
      licensePlate: map['license_plate']?.toString() ?? '',
      dailyRate: (num.tryParse(map['daily_rate']?.toString() ?? '') ?? 0)
          .toInt(),
      status: map['status']?.toString() ?? '',
      imageurl: map['image_url']?.toString() ?? '',
      location: map['location']?.toString() ?? 'Miami, FL',
      transmission: map['transmission']?.toString() ?? 'Automatic',
      fuelType: map['fuel_type']?.toString() ?? 'Petrol',
      seats: (num.tryParse(map['seats']?.toString() ?? '') ?? 5).toInt(),
      description:
          map['description']?.toString() ?? 'A great car for your daily needs.',
      engineCapacity: map['engine_capacity']?.toString() ?? '2.0L',
      maxSpeed: map['max_speed']?.toString() ?? '220 km/h',
      acceleration: map['acceleration']?.toString() ?? '7.5s',
    );
  }
}
