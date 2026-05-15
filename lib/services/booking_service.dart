import 'package:supabase_flutter/supabase_flutter.dart';

class BookingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Kullanıcının tüm rezervasyonlarını getir
  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('*, cars(*)')
          .eq('user_id', userId)
          .order('start_date', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Rezervasyonlar yüklenirken hata: $e');
    }
  }

  // Aktif rezervasyonları getir
  Future<List<Map<String, dynamic>>> getActiveBookings(String userId) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from('bookings')
          .select('*, cars(*)')
          .eq('user_id', userId)
          .gte('end_date', now)
          .neq('status', 'cancelled')
          .order('start_date', ascending: true);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Aktif rezervasyonlar yüklenirken hata: $e');
    }
  }

  // Geçmiş rezervasyonları getir
  Future<List<Map<String, dynamic>>> getPastBookings(String userId) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from('bookings')
          .select('*, cars(*)')
          .eq('user_id', userId)
          .lt('end_date', now)
          .order('start_date', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Geçmiş rezervasyonlar yüklenirken hata: $e');
    }
  }

  // Yeni rezervasyon oluştur
  Future<Map<String, dynamic>> createBooking({
    required String userId,
    required String carId,
    required DateTime startDate,
    required DateTime endDate,
    required double totalPrice,
  }) async {
    try {
      final response = await _supabase
          .from('bookings')
          .insert({
            'user_id': userId,
            'car_id': carId,
            'start_date': startDate.toIso8601String(),
            'end_date': endDate.toIso8601String(),
            'total_price': totalPrice,
            'status': 'confirmed',
          })
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Rezervasyon oluşturulamadı: $e');
    }
  }

  // Rezervasyonu iptal et
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _supabase
          .from('bookings')
          .update({'status': 'cancelled'})
          .eq('id', bookingId);
    } catch (e) {
      throw Exception('Rezervasyon iptal edilemedi: $e');
    }
  }

  // Rezervasyon detayını getir
  Future<Map<String, dynamic>?> getBookingById(String bookingId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('*, cars(*)')
          .eq('id', bookingId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  // Rezervasyon durumunu güncelle
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _supabase
          .from('bookings')
          .update({'status': status})
          .eq('id', bookingId);
    } catch (e) {
      throw Exception('Rezervasyon durumu güncellenemedi: $e');
    }
  }
}
