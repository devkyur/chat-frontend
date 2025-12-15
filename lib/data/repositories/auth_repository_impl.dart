import '../../core/constants/api_constants.dart';
import '../../core/utils/secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api.dart';
import '../datasources/profile_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _authApi;
  final ProfileApi _profileApi;

  AuthRepositoryImpl(this._authApi, this._profileApi);

  @override
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
  }) async {
    await _authApi.signup(
      email: email,
      password: password,
      name: name,
      nickname: nickname,
      birthDate: birthDate,
      gender: gender,
      phoneNumber: phoneNumber,
      bio: bio,
      location: location,
      minAgePreference: minAgePreference,
      maxAgePreference: maxAgePreference,
      maxDistance: maxDistance,
    );
    // 회원가입 후 프로필이 없으므로 null 반환
    return null;
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final userModel = await _authApi.login(
      email: email,
      password: password,
    );
    return userModel.toEntity();
  }

  @override
  Future<void> logout() async {
    await _authApi.logout();
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final token = await SecureStorage.read(ApiConstants.accessTokenKey);
      if (token == null) return null;

      final userModel = await _profileApi.getMyProfile();
      return userModel.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> refreshToken() async {
    throw UnimplementedError('Token refresh is handled by DioClient');
  }
}
