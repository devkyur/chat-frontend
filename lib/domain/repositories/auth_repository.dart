import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> signup({
    required String email,
    required String password,
    required String nickname,
  });

  Future<User> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<User?> getCurrentUser();

  Future<String> refreshToken();
}
