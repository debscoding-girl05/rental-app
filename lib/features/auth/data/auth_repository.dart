import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/core/errors/app_exception.dart' as app;
import 'package:landlord_os/features/auth/domain/user_model.dart';

part 'auth_repository.g.dart';

/// Provides access to Supabase authentication.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  /// Returns the currently signed-in user, or `null`.
  UserModel? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String?,
      createdAt: DateTime.tryParse(user.createdAt),
    );
  }

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Signs in with email and password.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) throw const app.AuthException('Sign in failed.');
      return UserModel(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] as String?,
        createdAt: DateTime.tryParse(user.createdAt),
      );
    } on AuthApiException catch (e) {
      throw app.AuthException(e.message);
    }
  }

  /// Creates a new account with email, password, and optional name.
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
      final user = response.user;
      if (user == null) throw const app.AuthException('Sign up failed.');
      return UserModel(
        id: user.id,
        email: user.email ?? '',
        fullName: fullName,
        createdAt: DateTime.tryParse(user.createdAt),
      );
    } on AuthApiException catch (e) {
      throw app.AuthException(e.message);
    }
  }

  /// Sends a password reset email.
  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthApiException catch (e) {
      throw app.AuthException(e.message);
    }
  }

  /// Signs in with Google OAuth via Supabase.
  Future<bool> signInWithGoogle() async {
    try {
      final result = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.landlordos://login-callback/',
      );
      return result;
    } on AuthApiException catch (e) {
      throw app.AuthException(e.message);
    }
  }

  /// Signs the user out.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(Supabase.instance.client);
}
