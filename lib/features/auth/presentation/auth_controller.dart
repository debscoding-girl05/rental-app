import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:landlord_os/features/auth/data/auth_repository.dart';
import 'package:landlord_os/features/auth/domain/user_model.dart';

part 'auth_controller.g.dart';

/// Manages authentication state for the entire app.
@riverpod
class AuthController extends _$AuthController {
  @override
  AsyncValue<UserModel?> build() {
    final repo = ref.watch(authRepositoryProvider);

    // Listen to auth state changes and update.
    repo.authStateChanges.listen((event) {
      if (event.event == AuthChangeEvent.signedIn ||
          event.event == AuthChangeEvent.tokenRefreshed) {
        state = AsyncData(repo.currentUser);
      } else if (event.event == AuthChangeEvent.signedOut) {
        state = const AsyncData(null);
      }
    });

    return AsyncData(repo.currentUser);
  }

  /// Signs in with email and password.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signIn(
            email: email,
            password: password,
          ),
    );
  }

  /// Creates a new account.
  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signUp(
            email: email,
            password: password,
            fullName: fullName,
          ),
    );
  }

  /// Signs in with Google OAuth.
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      final success =
          await ref.read(authRepositoryProvider).signInWithGoogle();
      // OAuth opens a browser — if it didn't launch or returns false,
      // reset to idle so buttons become tappable again.
      if (!success) {
        state = const AsyncData(null);
      }
      // On success the auth state listener handles the rest.
      // Reset to idle regardless so the UI isn't stuck loading
      // while waiting for the browser redirect.
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      // Immediately reset so buttons recover after the error snackbar fires.
      state = const AsyncData(null);
    }
  }

  /// Signs the user out.
  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }
}
