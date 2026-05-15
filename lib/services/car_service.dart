import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rent_a_cart/pages/dashboard/models/car.dart';
import 'package:rent_a_cart/pages/dashboard/models/car_extras.dart';

class CarService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Tarih aralığına göre müsait araçları getir
  Future<List<Car>> getAvailableCars({
    required DateTime startDate,
    required DateTime endDate,
    String? locationId,
    String? brand,
  }) async {
    try {
      // RPC yerine direkt sorgu kullanarak locations'ı da çekiyoruz
      var query = _supabase
          .from('cars')
          .select('*, locations(*)')
          .eq('status', 'available');

      if (brand != null) {
        query = query.eq('brand', brand);
      }

      if (locationId != null) {
        query = query.eq('location_id', locationId);
      }

      final response = await query;

      List<Car> allCars = (response as List)
          .map((json) => Car.fromMap(json as Map<String, dynamic>))
          .toList();

      // Manuel olarak müsaitlik kontrolü yap
      List<Car> availableCars = [];
      for (var car in allCars) {
        bool isAvailable = await isCarAvailable(car.id, startDate, endDate);
        if (isAvailable) {
          availableCars.add(car);
        }
      }

      return availableCars;
    } catch (e) {
      debugPrint('Error fetching available cars: $e');
      rethrow;
    }
  }

  // Tüm araçları getir
  Future<List<Car>> getAllCars({String? locationId}) async {
    try {
      var query = _supabase.from('cars').select('*, locations(*)');

      if (locationId != null) {
        query = query.eq('location_id', locationId);
      }

      final response = await query;
      return (response as List).map((c) => Car.fromMap(c)).toList();
    } catch (e) {
      throw Exception('Araçlar yüklenirken hata: $e');
    }
  }

  // Brand'a göre araçları getir
  Future<List<Car>> getCarsByBrand(String brand, {String? locationId}) async {
    try {
      var query = _supabase
          .from('cars')
          .select('*, locations(*)')
          .eq('brand', brand);

      if (locationId != null) {
        query = query.eq('location_id', locationId);
      }

      final response = await query;
      return (response as List).map((c) => Car.fromMap(c)).toList();
    } catch (e) {
      throw Exception('Araçlar yüklenirken hata: $e');
    }
  }

  // En popüler brand'ları getir
  Future<List<String>> getTopBrands() async {
    try {
      final topBrandsData = await _supabase.rpc('get_top_brands');

      List<String> brandNames = ['All'];
      for (var item in topBrandsData) {
        brandNames.add(item['brand']);
      }
      return brandNames;
    } catch (e) {
      // Hata olursa varsayılan değerler
      return ['All', 'Tesla', 'Mercedes', 'BMW'];
    }
  }

  // ID'ye göre araç getir
  Future<Car?> getCarById(String carId) async {
    try {
      final response = await _supabase
          .from('cars')
          .select('*, locations(*)')
          .eq('id', carId)
          .single();

      return Car.fromMap(response);
    } catch (e) {
      throw Exception('Araç bulunamadı: $e');
    }
  }

  // Araç müsaitlik kontrolü
  Future<bool> isCarAvailable(
    String carId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('car_id', carId)
          .or(
            'start_date.lte.${endDate.toIso8601String()},end_date.gte.${startDate.toIso8601String()}',
          )
          .neq('status', 'cancelled');

      return (response as List).isEmpty;
    } catch (e) {
      throw Exception('Müsaitlik kontrolü başarısız: $e');
    }
  }

  // Araç ekstralarını getir
  Future<CarExtras?> getCarExtras(String carId) async {
    try {
      final response = await _supabase
          .from('car_extras')
          .select()
          .eq('car_id', carId)
          .single();

      return CarExtras.fromMap(response);
    } catch (e) {
      debugPrint('Error fetching car extras: $e');
      return null;
    }
  }
}
