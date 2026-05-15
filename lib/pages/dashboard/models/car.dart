import 'package:flutter/foundation.dart';

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
  final String locationId;
  final String transmission;
  final String fuelType;
  final int seats;
  final String description;
  final String engineCapacity;
  final String maxSpeed;
  final String acceleration;
  final Locations? locations;
  Car({
    required this.id,
    required this.createdat,
    required this.brand,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.dailyRate,
    required this.status,
    required this.imageurl,
    required this.locationId,
    this.transmission = 'Automatic',
    this.fuelType = 'Petrol',
    this.seats = 5,
    this.description = '',
    this.engineCapacity = '1.6L',
    this.maxSpeed = '200 km/h',
    this.acceleration = '8.5s',
    this.locations,
  });

  // Supabase'den gelen Map'ten Car oluşturmak için factory constructor
  factory Car.fromMap(Map<String, dynamic> map) {
    // Debug: Map'i yazdır
    debugPrint('Car.fromMap - locations data: ${map['locations']}');

    return Car(
      locations: map['locations'] != null
          ? Locations(
              id: map['locations']['id']?.toString() ?? '',
              city: map['locations']['city']?.toString() ?? '',
              country: map['locations']['country']?.toString() ?? '',
              address: map['locations']['address']?.toString() ?? '',
            )
          : null,
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
      locationId: map['location_id']?.toString() ?? 'Miami, FL',
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

  // Location bilgisini çekmek için getter (locationId string olduğu için)
  String get location {
    // locations varsa ve city doluysa city'yi döndür
    if (locations?.city != null && locations!.city.isNotEmpty) {
      return locations!.city;
    }
    return locationId;
  }
}

class Locations {
  final String id;
  final String city;
  final String country;
  final String? address;
  Locations({
    required this.id,
    required this.city,
    required this.country,
    required this.address,
  });
}
