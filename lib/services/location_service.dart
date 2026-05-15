import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Tüm aktif lokasyonları getir
  Future<List<Map<String, dynamic>>> getActiveLocations() async {
    try {
      final response = await _supabase
          .from('locations')
          .select()
          .eq('is_active', true)
          .order('city');

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Lokasyonlar yüklenirken hata: $e');
    }
  }

  // Seçili lokasyonu kaydet
  Future<void> saveSelectedLocation(String locationId, String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_location_id', locationId);
    await prefs.setString('selected_location_city', cityName);
  }

  // Seçili lokasyonu getir
  Future<Map<String, String?>> getSelectedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString('selected_location_id'),
      'city': prefs.getString('selected_location_city'),
    };
  }

  // Seçili lokasyonu temizle
  Future<void> clearSelectedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_location_id');
    await prefs.remove('selected_location_city');
  }

  // Lokasyon şehir listesini getir
  Future<List<String>> getLocationCities() async {
    try {
      final response = await _supabase
          .from('locations')
          .select('city')
          .eq('is_active', true)
          .order('city');

      return (response as List).map((loc) => loc['city'] as String).toList();
    } catch (e) {
      throw Exception('Şehirler yüklenirken hata: $e');
    }
  }

  // ID'ye göre lokasyon detayı getir
  Future<Map<String, dynamic>?> getLocationById(String locationId) async {
    try {
      final response = await _supabase
          .from('locations')
          .select()
          .eq('id', locationId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }
}
