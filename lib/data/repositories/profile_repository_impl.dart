import '../../domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_api.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApi _profileApi;

  ProfileRepositoryImpl(this._profileApi);

  @override
  Future<User> getMyProfile() async {
    final userModel = await _profileApi.getMyProfile();
    return userModel.toEntity();
  }

  @override
  Future<User> updateProfile({
    String? nickname,
    String? profileImageUrl,
    int? age,
    String? gender,
    String? bio,
  }) async {
    final userModel = await _profileApi.updateProfile(
      nickname: nickname,
      profileImageUrl: profileImageUrl,
      age: age,
      gender: gender,
      bio: bio,
    );
    return userModel.toEntity();
  }
}
