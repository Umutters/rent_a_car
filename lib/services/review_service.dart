import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rent_a_cart/pages/dashboard/models/review.dart';

class ReviewService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Araç için yorumları getir
  Future<List<Review>> getCarReviews(String carId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('*, users(full_name, email)')
          .eq('car_id', carId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Review.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      return [];
    }
  }

  // Araç için ortalama rating getir
  Future<Map<String, dynamic>> getCarRating(String carId) async {
    try {
      final reviews = await getCarReviews(carId);

      if (reviews.isEmpty) {
        return {'average': 0.0, 'count': 0};
      }

      final totalRating = reviews.fold<int>(
        0,
        (sum, review) => sum + review.rating,
      );
      final average = totalRating / reviews.length;

      return {'average': average, 'count': reviews.length};
    } catch (e) {
      debugPrint('Error calculating car rating: $e');
      return {'average': 0.0, 'count': 0};
    }
  }

  // Yorum ekle
  Future<void> addReview({
    required String carId,
    required String userId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _supabase.from('reviews').insert({
        'car_id': carId,
        'user_id': userId,
        'rating': rating,
        'comment': comment,
      });
    } catch (e) {
      debugPrint('Error adding review: $e');
      rethrow;
    }
  }

  // Yorum güncelle
  Future<void> updateReview({
    required String reviewId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _supabase
          .from('reviews')
          .update({'rating': rating, 'comment': comment})
          .eq('id', reviewId);
    } catch (e) {
      debugPrint('Error updating review: $e');
      rethrow;
    }
  }

  // Yorum sil
  Future<void> deleteReview(String reviewId) async {
    try {
      await _supabase.from('reviews').delete().eq('id', reviewId);
    } catch (e) {
      debugPrint('Error deleting review: $e');
      rethrow;
    }
  }

  // Kullanıcının bu araç için yorumu var mı kontrol et
  Future<Review?> getUserReviewForCar(String userId, String carId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('*, users(full_name, email)')
          .eq('user_id', userId)
          .eq('car_id', carId)
          .maybeSingle();

      if (response == null) return null;
      return Review.fromMap(response);
    } catch (e) {
      debugPrint('Error checking user review: $e');
      return null;
    }
  }
}
