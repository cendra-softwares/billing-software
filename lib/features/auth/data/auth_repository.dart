import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> signInWithPassword(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw e.message;
    }
  }

  Future<void> signUp(String email, String password, String fullName,
      String phone, String role) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        await _client.from('profiles').insert({
          'user_id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'phone_number': phone,
          'role': role,
        });
      }
    } on AuthException catch (e) {
      throw e.message;
    }
  }

  Future<void> signUpWithPassword(String email, String password) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw e.message;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw e.message;
    }
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return null;
      }
      final response = await _client
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }
}