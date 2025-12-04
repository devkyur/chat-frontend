import '../entities/user.dart';

abstract class ProfileRepository {
  Future<User> getMyProfile();

  Future<User> updateProfile({
    String? nickname,
    String? profileImageUrl,
    int? age,
    String? gender,
    String? bio,
  });
}
