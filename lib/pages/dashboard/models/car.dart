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

  // Ekstra teknik özellikler (car_extras tablosundan)
  final int? doors;
  final bool hasAc;
  final bool hasBluetooth;
  final bool hasGps;
  final bool hasSunroof;
  final bool hasParkingSensors;
  final bool hasCruiseControl;

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
    this.doors,
    this.hasAc = true,
    this.hasBluetooth = true,
    this.hasGps = false,
    this.hasSunroof = false,
    this.hasParkingSensors = false,
    this.hasCruiseControl = false,
  });

  // Supabase'den gelen Map'ten Car oluşturmak için factory constructor
  factory Car.fromMap(Map<String, dynamic> map) {
    // car_extras nested object olarak gelebilir (JOIN ile)
    final extras = map['car_extras'];
    Map<String, dynamic>? extrasMap;

    if (extras is List && extras.isNotEmpty) {
      extrasMap = extras[0] as Map<String, dynamic>;
    } else if (extras is Map<String, dynamic>) {
      extrasMap = extras;
    }

    return Car(
      id: map['id']?.toString() ?? '',
      createdat: map['created_at']?.toString() ?? '',
      brand: map['brand']?.toString() ?? '',
      model: map['model']?.toString() ?? '',
      year: map['year']?.toString() ?? '',
      licensePlate: map['license_plate']?.toString() ?? '',
      dailyRate: (num.tryParse(map['daily_rate']?.toString() ?? '') ?? 0)
          .toInt(),
      status: map['status']?.toString() ?? 'Available',
      imageurl: map['image_url']?.toString() ?? '',
      location: map['location']?.toString() ?? 'İstanbul',
      // car_extras'tan veya doğrudan map'ten al
      transmission:
          extrasMap?['transmission']?.toString() ??
          map['transmission']?.toString() ??
          'Automatic',
      fuelType:
          extrasMap?['fuel_type']?.toString() ??
          map['fuel_type']?.toString() ??
          'Petrol',
      seats:
          (num.tryParse(
                    extrasMap?['seats']?.toString() ??
                        map['seats']?.toString() ??
                        '',
                  ) ??
                  5)
              .toInt(),
      description:
          map['description']?.toString() ?? 'A great car for your daily needs.',
      engineCapacity: map['engine_capacity']?.toString() ?? '2.0L',
      maxSpeed: map['max_speed']?.toString() ?? '220 km/h',
      acceleration: map['acceleration']?.toString() ?? '7.5s',
      // Ekstra özellikler
      doors: int.tryParse(extrasMap?['doors']?.toString() ?? ''),
      hasAc: extrasMap?['has_ac'] == true,
      hasBluetooth: extrasMap?['has_bluetooth'] == true,
      hasGps: extrasMap?['has_gps'] == true,
      hasSunroof: extrasMap?['has_sunroof'] == true,
      hasParkingSensors: extrasMap?['has_parking_sensors'] == true,
      hasCruiseControl: extrasMap?['has_cruise_control'] == true,
    );
  }

  /// Özellik listesini döndürür (UI'da göstermek için)
  List<String> get featuresList {
    List<String> features = [];
    if (hasAc) features.add('Klima');
    if (hasBluetooth) features.add('Bluetooth');
    if (hasGps) features.add('GPS');
    if (hasSunroof) features.add('Sunroof');
    if (hasParkingSensors) features.add('Park Sensörü');
    if (hasCruiseControl) features.add('Cruise Control');
    return features;
  }

  /// Kısa özellik özeti
  String get featuresSummary {
    final features = featuresList;
    if (features.isEmpty) return 'Standart özellikler';
    if (features.length <= 3) return features.join(' • ');
    return '${features.take(3).join(' • ')} +${features.length - 3}';
  }
}
