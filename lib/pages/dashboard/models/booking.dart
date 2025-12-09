class Booking {
  final String id;
  final String userId;
  final String carId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalPrice;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.userId,
    required this.carId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      carId: map['car_id']?.toString() ?? '',
      startDate: DateTime.parse(
        map['start_date']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        map['end_date']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      totalPrice: (num.tryParse(map['total_price']?.toString() ?? '') ?? 0)
          .toInt(),
      status: map['status']?.toString() ?? 'pending',
      createdAt: DateTime.parse(
        map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'car_id': carId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'total_price': totalPrice,
      'status': status,
    };
  }

  int get totalDays {
    return endDate.difference(startDate).inDays + 1;
  }
}
