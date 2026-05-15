class CarExtras {
  final String id;
  final String carId;
  final String transmission;
  final String fuelType;
  final int seats;
  final int doors;
  final int luggageCapacity;
  final bool hasAc;
  final bool hasBluetooth;
  final bool hasGps;
  final bool hasSunroof;
  final bool hasParkingSensors;
  final bool hasCruiseControl;
  final String createdAt;
  final String updatedAt;

  CarExtras({
    required this.id,
    required this.carId,
    required this.transmission,
    required this.fuelType,
    required this.seats,
    required this.doors,
    required this.luggageCapacity,
    required this.hasAc,
    required this.hasBluetooth,
    required this.hasGps,
    required this.hasSunroof,
    required this.hasParkingSensors,
    required this.hasCruiseControl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CarExtras.fromMap(Map<String, dynamic> map) {
    return CarExtras(
      id: map['id']?.toString() ?? '',
      carId: map['car_id']?.toString() ?? '',
      transmission: map['transmission']?.toString() ?? 'Automatic',
      fuelType: map['fuel_type']?.toString() ?? 'Petrol',
      seats: (num.tryParse(map['seats']?.toString() ?? '') ?? 5).toInt(),
      doors: (num.tryParse(map['doors']?.toString() ?? '') ?? 4).toInt(),
      luggageCapacity:
          (num.tryParse(map['luggage_capacity']?.toString() ?? '') ?? 2)
              .toInt(),
      hasAc: map['has_ac'] == true,
      hasBluetooth: map['has_bluetooth'] == true,
      hasGps: map['has_gps'] == true,
      hasSunroof: map['has_sunroof'] == true,
      hasParkingSensors: map['has_parking_sensors'] == true,
      hasCruiseControl: map['has_cruise_control'] == true,
      createdAt: map['created_at']?.toString() ?? '',
      updatedAt: map['updated_at']?.toString() ?? '',
    );
  }

  // Özellikler listesi (true olanlar)
  List<String> get features {
    List<String> list = [];
    if (hasAc) list.add('Air Conditioning');
    if (hasBluetooth) list.add('Bluetooth');
    if (hasGps) list.add('GPS Navigation');
    if (hasSunroof) list.add('Sunroof');
    if (hasParkingSensors) list.add('Parking Sensors');
    if (hasCruiseControl) list.add('Cruise Control');
    return list;
  }
}
