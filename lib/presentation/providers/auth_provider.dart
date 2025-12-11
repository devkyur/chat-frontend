import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import 'providers.dart';

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    return await ref.watch(authRepositoryProvider).getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authRepositoryProvider).login(
            email: email,
            password: password,
          );
      return user;
    });
  }

  Future<void> signup(String email, String password, String nickname) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authRepositoryProvider).signup(
            email: email,
            password: password,
            nickname: nickname,
          );
      return user;
    });
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncValue.data(null);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(authRepositoryProvider).getCurrentUser();
    });
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(() {
  return AuthNotifier();
});
