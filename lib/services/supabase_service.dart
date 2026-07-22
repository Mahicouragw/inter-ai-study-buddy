import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseStudyService {
  final _client = SupabaseConfig.client;

  // Check username duplicate - prevents duplicate
  Future<bool> isUsernameTaken(String username) async {
    final res = await _client
        .from('profiles')
        .select('username')
        .eq('username', username.trim().toLowerCase())
        .maybeSingle();
    return res != null;
  }

  Future<bool> isEmailTaken(String email) async {
    final res = await _client
        .from('profiles')
        .select('email')
        .eq('email', email.trim().toLowerCase())
        .maybeSingle();
    return res != null;
  }

  // Sign Up with email, password, username, confirm password (name optional)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
    String name = '',
  }) async {
    final cleanUsername = username.trim().toLowerCase();
    final cleanEmail = email.trim().toLowerCase();

    if (await isUsernameTaken(cleanUsername)) {
      throw Exception('Username already taken. Please choose another.');
    }
    if (await isEmailTaken(cleanEmail)) {
      throw Exception('Email already registered. Please login.');
    }

    final response = await _client.auth.signUp(
      email: cleanEmail,
      password: password,
      data: {
        'name': name.trim().isEmpty ? username.trim() : name.trim(),
        'username': cleanUsername,
        'email': cleanEmail,
      },
      emailRedirectTo: 'io.supabase.interstuddy://login-callback/',
    );

    // Profile auto-created via trigger handle_new_user, but ensure manually
    if (response.user != null) {
      try {
        await _client.from('profiles').upsert({
          'id': response.user!.id,
          'name': name.trim().isEmpty ? username.trim() : name.trim(),
          'username': cleanUsername,
          'email': cleanEmail,
        });
      } catch (e) {
        print('Profile upsert: $e');
      }
    }

    return response;
  }

  // Login: just email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resendVerification(String email) async {
    await _client.auth.resend(type: OtpType.signup, email: email);
  }

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
}
