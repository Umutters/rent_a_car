import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rent_a_cart/services/user_service.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final UserService _userService = UserService();
  final GoogleSignIn googleSignIn = GoogleSignIn(
    serverClientId:
        '743286900860-ss48fqp9cl44479s7cp7b9iekvritcro.apps.googleusercontent.com',
  );
  // Email ile giriş
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        await _syncCurrentUser();
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Email ile kayıt
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.session != null) {
        await _userService.syncUserToPublicTable(
          userId: response.user!.id,
          email: email,
          fullName: fullName,
        );
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Google ile giriş
  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;

      final idToken = googleAuth?.idToken;

      if (idToken == null) {
        throw 'Google ID token not found';
      }

      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: null,
      );

      await _syncCurrentUser();
    } catch (e) {
      rethrow;
    }
  }

  // Şifre sıfırlama emaili gönder
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Mevcut kullanıcıyı senkronize et
  Future<void> _syncCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _userService.syncUserToPublicTable(
      userId: user.id,
      email: user.email!,
      fullName: user.userMetadata?['full_name'] ?? user.userMetadata?['name'],
      avatarUrl: user.userMetadata?['avatar_url'],
    );
  }

  // Mevcut oturumu kontrol et
  Session? getCurrentSession() {
    return _supabase.auth.currentSession;
  }

  // Mevcut kullanıcıyı al
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // Auth state değişikliklerini dinle
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
