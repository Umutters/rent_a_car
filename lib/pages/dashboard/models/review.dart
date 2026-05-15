class Review {
  final String id;
  final String carId;
  final String userId;
  final int rating;
  final String? comment;
  final String createdAt;
  final String? userName; // Join ile gelecek

  Review({
    required this.id,
    required this.carId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.userName,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id']?.toString() ?? '',
      carId: map['car_id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      rating: (num.tryParse(map['rating']?.toString() ?? '') ?? 0).toInt(),
      comment: map['comment']?.toString(),
      createdAt: map['created_at']?.toString() ?? '',
      userName:
          map['users']?['full_name']?.toString() ??
          map['users']?['email']?.toString() ??
          'Anonymous',
    );
  }
}
