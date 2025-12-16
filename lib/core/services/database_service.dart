import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rent_a_cart/pages/dashboard/models/car.dart';

/// Veritabanı işlemleri için servis sınıfı
/// View, Trigger ve Stored Procedure'ları kullanır
class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // VIEWS KULLANIMI
  // ============================================

  /// v_available_cars_with_stats view'ından müsait araçları istatistiklerle getirir
  Future<List<Map<String, dynamic>>> getAvailableCarsWithStats() async {
    try {
      final response = await _supabase
          .from('v_available_cars_with_stats')
          .select()
          .order('total_bookings', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Hata - getAvailableCarsWithStats: $e');
      rethrow;
    }
  }

  /// v_user_booking_history view'ından kullanıcının rezervasyon geçmişini getirir
  Future<List<Map<String, dynamic>>> getUserBookingHistory(
    String userId,
  ) async {
    try {
      final response = await _supabase
          .from('v_user_booking_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Hata - getUserBookingHistory: $e');
      rethrow;
    }
  }

  /// v_car_availability_calendar view'ından araç müsaitlik takvimini getirir
  Future<List<Map<String, dynamic>>> getCarAvailabilityCalendar(
    String? carId,
  ) async {
    try {
      var query = _supabase.from('v_car_availability_calendar').select();

      if (carId != null) {
        query = query.eq('car_id', carId);
      }

      final response = await query.order('start_date', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Hata - getCarAvailabilityCalendar: $e');
      rethrow;
    }
  }

  /// v_revenue_summary view'ından gelir özetini getirir
  Future<List<Map<String, dynamic>>> getRevenueSummary() async {
    try {
      final response = await _supabase
          .from('v_revenue_summary')
          .select()
          .order('month', ascending: false)
          .limit(12);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Hata - getRevenueSummary: $e');
      rethrow;
    }
  }

  // ============================================
  // STORED PROCEDURES (RPC) KULLANIMI
  // ============================================

  /// get_available_cars procedure'ü ile müsait araçları filtreli getirir
  Future<List<Car>> getAvailableCars({
    required DateTime startDate,
    required DateTime endDate,
    String? location,
    String? brand,
    int? minPrice,
    int? maxPrice,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_available_cars',
        params: {
          'p_start_date': startDate.toIso8601String().split('T')[0],
          'p_end_date': endDate.toIso8601String().split('T')[0],
          'p_location': location,
          'p_brand': brand,
          'p_min_price': minPrice,
          'p_max_price': maxPrice,
        },
      );

      return (response as List).map((carMap) => Car.fromMap(carMap)).toList();
    } catch (e) {
      print('Hata - getAvailableCars RPC: $e');
      rethrow;
    }
  }

  /// create_booking_with_validation procedure'ü ile doğrulamalı rezervasyon oluşturur
  Future<Map<String, dynamic>> createBookingWithValidation({
    required String userId,
    required String carId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabase.rpc(
        'create_booking_with_validation',
        params: {
          'p_user_id': userId,
          'p_car_id': carId,
          'p_start_date': startDate.toIso8601String().split('T')[0],
          'p_end_date': endDate.toIso8601String().split('T')[0],
        },
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      print('Hata - createBookingWithValidation: $e');
      rethrow;
    }
  }

  /// get_user_statistics procedure'ü ile kullanıcı istatistiklerini getirir
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      final response = await _supabase.rpc(
        'get_user_statistics',
        params: {'p_user_id': userId},
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      print('Hata - getUserStatistics: $e');
      rethrow;
    }
  }

  /// cancel_booking procedure'ü ile rezervasyon iptal eder
  Future<Map<String, dynamic>> cancelBooking({
    required String bookingId,
    required String userId,
  }) async {
    try {
      final response = await _supabase.rpc(
        'cancel_booking',
        params: {'p_booking_id': bookingId, 'p_user_id': userId},
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      print('Hata - cancelBooking: $e');
      rethrow;
    }
  }

  /// search_cars procedure'ü ile gelişmiş araç arama yapar
  Future<List<Car>> searchCars({
    required String searchText,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await _supabase.rpc(
        'search_cars',
        params: {'p_search_text': searchText, 'p_filters': filters},
      );

      return (response as List).map((carMap) => Car.fromMap(carMap)).toList();
    } catch (e) {
      print('Hata - searchCars: $e');
      rethrow;
    }
  }

  /// get_top_brands (mevcut RPC'niz)
  Future<List<Map<String, dynamic>>> getTopBrands() async {
    try {
      final response = await _supabase.rpc('get_top_brands');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Hata - getTopBrands: $e');
      rethrow;
    }
  }

  // ============================================
  // TRIGGER'LAR OTOMATIK ÇALIŞIR
  // ============================================

  // Not: Trigger'lar otomatik çalışır, manuel çağırmanıza gerek yok:
  // - update_car_status_on_booking: Rezervasyon eklenince/güncellenince araç durumunu günceller
  // - calculate_booking_price: Rezervasyon eklenince toplam fiyatı otomatik hesaplar
  // - prevent_double_booking: Çift rezervasyonu otomatik engeller
  // - update_updated_at_column: Güncelleme zamanını otomatik ayarlar

  // ============================================
  // LOCATIONS - LOKASYONLAR
  // ============================================

  /// Aktif lokasyonları getirir
  Future<List<Map<String, dynamic>>> getActiveLocations() async {
    try {
      final response = await _supabase.rpc('get_active_locations');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // RPC yoksa direkt tablodan çek
      try {
        final response = await _supabase
            .from('locations')
            .select()
            .eq('is_active', true)
            .order('city');
        return List<Map<String, dynamic>>.from(response);
      } catch (e2) {
        print('Hata - getActiveLocations: $e2');
        rethrow;
      }
    }
  }

  // ============================================
  // RENTAL EXTRAS - KİRALANABİLİR EKSTRALAR
  // ============================================

  /// Tüm kiralanabilir ekstraları getirir
  Future<List<Map<String, dynamic>>> getRentalExtras() async {
    try {
      final response = await _supabase
          .from('rental_extras')
          .select()
          .eq('is_available', true)
          .order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Hata - getRentalExtras: $e');
      rethrow;
    }
  }

  /// Rezervasyona ekstra ekler
  Future<Map<String, dynamic>> addExtraToBooking({
    required String bookingId,
    required String extraId,
    int quantity = 1,
  }) async {
    try {
      final response = await _supabase.rpc(
        'add_extra_to_booking',
        params: {
          'p_booking_id': bookingId,
          'p_extra_id': extraId,
          'p_quantity': quantity,
        },
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      print('Hata - addExtraToBooking: $e');
      rethrow;
    }
  }

  /// Rezervasyonun ekstralarını getirir
  Future<List<Map<String, dynamic>>> getBookingExtras(String bookingId) async {
    try {
      final response = await _supabase
          .from('booking_rental_extras')
          .select('*, rental_extras(*)')
          .eq('booking_id', bookingId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Hata - getBookingExtras: $e');
      rethrow;
    }
  }

  // ============================================
  // CAR EXTRAS - ARAÇ TEKNİK ÖZELLİKLERİ
  // ============================================

  /// Aracın teknik özelliklerini getirir
  Future<Map<String, dynamic>?> getCarExtras(String carId) async {
    try {
      final response = await _supabase
          .from('car_extras')
          .select()
          .eq('car_id', carId)
          .maybeSingle();
      return response;
    } catch (e) {
      print('Hata - getCarExtras: $e');
      return null;
    }
  }

  /// Araçla birlikte teknik özelliklerini getirir
  Future<Map<String, dynamic>> getCarWithExtras(String carId) async {
    try {
      final carResponse = await _supabase
          .from('cars')
          .select()
          .eq('id', carId)
          .single();

      final extrasResponse = await getCarExtras(carId);

      return {...carResponse, 'extras': extrasResponse};
    } catch (e) {
      print('Hata - getCarWithExtras: $e');
      rethrow;
    }
  }

  /// Tüm araçları teknik özellikleriyle getirir
  Future<List<Map<String, dynamic>>> getCarsWithExtras() async {
    try {
      final response = await _supabase.from('cars').select('*, car_extras(*)');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Hata - getCarsWithExtras: $e');
      rethrow;
    }
  }

  // ============================================
  // FAVORİLER
  // ============================================

  /// Kullanıcının favori araçlarını getirir
  Future<List<Car>> getUserFavorites(String userId) async {
    try {
      final response = await _supabase
          .from('favorites')
          .select('car_id, cars(*, car_extras(*))')
          .eq('user_id', userId);

      final List<Car> cars = [];
      for (var item in response) {
        if (item['cars'] != null) {
          cars.add(Car.fromMap(item['cars']));
        }
      }
      return cars;
    } catch (e) {
      print('Hata - getUserFavorites: $e');
      rethrow;
    }
  }

  /// Aracın favorilerde olup olmadığını kontrol eder
  Future<bool> isFavorite(String userId, String carId) async {
    try {
      final response = await _supabase
          .from('favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('car_id', carId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      print('Hata - isFavorite: $e');
      return false;
    }
  }

  /// Favorilere araç ekler
  Future<void> addToFavorites(String userId, String carId) async {
    try {
      await _supabase.from('favorites').insert({
        'user_id': userId,
        'car_id': carId,
      });
    } catch (e) {
      print('Hata - addToFavorites: $e');
      rethrow;
    }
  }

  /// Favorilerden araç kaldırır
  Future<void> removeFromFavorites(String userId, String carId) async {
    try {
      await _supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('car_id', carId);
    } catch (e) {
      print('Hata - removeFromFavorites: $e');
      rethrow;
    }
  }

  /// Favori durumunu değiştirir (toggle)
  Future<bool> toggleFavorite(String userId, String carId) async {
    try {
      final isFav = await isFavorite(userId, carId);
      if (isFav) {
        await removeFromFavorites(userId, carId);
        return false;
      } else {
        await addToFavorites(userId, carId);
        return true;
      }
    } catch (e) {
      print('Hata - toggleFavorite: $e');
      rethrow;
    }
  }

  /// Realtime favoriler kanalı oluşturur
  RealtimeChannel subscribeFavorites({
    required String userId,
    required Function(PostgresChangePayload) onChanged,
  }) {
    return _supabase
        .channel('favorites:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'favorites',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: onChanged,
        )
        .subscribe();
  }
}
