import '../entities/user.dart';

abstract class AuthRepository {
  Future<User?> signup({
    required String email,
    required String password,
    required String name,
    required String nickname,
    required String birthDate,
    required String gender,
    String? phoneNumber,
    String? bio,
    String? location,
    int? minAgePreference,
    int? maxAgePreference,
    int? maxDistance,
  });

  Future<User> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<User?> getCurrentUser();

  Future<String> refreshToken();
}
