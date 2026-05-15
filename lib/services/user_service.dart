import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Kullanıcı bilgilerini getir
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  // Kullanıcı bilgilerini güncelle
  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
    String? phone,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updateData['full_name'] = fullName;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (phone != null) updateData['phone'] = phone;

      await _supabase.from('users').update(updateData).eq('id', userId);
    } catch (e) {
      throw Exception('Profil güncellenemedi: $e');
    }
  }

  // Kullanıcıyı public tabloya senkronize et
  Future<void> syncUserToPublicTable({
    required String userId,
    required String email,
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      await _supabase.from('users').upsert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Kullanıcı senkronizasyonu başarısız: $e');
    }
  }

  // Mevcut kullanıcı ID'sini al
  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  // Mevcut kullanıcı bilgilerini al
  Map<String, dynamic>? getCurrentUserMetadata() {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    return {
      'id': user.id,
      'email': user.email,
      'full_name':
          user.userMetadata?['full_name'] ?? user.userMetadata?['name'],
      'avatar_url': user.userMetadata?['avatar_url'],
    };
  }

  // Kullanıcının favorilerini getir
  Future<List<String>> getUserFavorites(String userId) async {
    try {
      final response = await _supabase
          .from('favorites')
          .select('car_id')
          .eq('user_id', userId);

      return (response as List).map((f) => f['car_id'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  // Favorilere ekle
  Future<void> addToFavorites(String userId, String carId) async {
    try {
      await _supabase.from('favorites').insert({
        'user_id': userId,
        'car_id': carId,
      });
    } catch (e) {
      throw Exception('Favorilere eklenemedi: $e');
    }
  }

  // Favorilerden çıkar
  Future<void> removeFromFavorites(String userId, String carId) async {
    try {
      await _supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('car_id', carId);
    } catch (e) {
      throw Exception('Favorilerden çıkarılamadı: $e');
    }
  }
}
