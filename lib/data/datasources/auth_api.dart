import '../../core/constants/api_constants.dart';
import '../../core/utils/secure_storage.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import 'dio_client.dart';

class AuthApi {
  final DioClient _client;

  AuthApi(this._client);

  Future<void> signup({
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
    final response = await _client.post(
      ApiConstants.signup,
      data: SignupRequest(
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
      ).toJson(),
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Signup failed');
    }

    final tokenResponse = TokenResponse.fromJson(apiResponse.data!);
    await _saveTokens(tokenResponse);
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiConstants.login,
      data: LoginRequest(
        email: email,
        password: password,
      ).toJson(),
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Login failed');
    }

    final tokenResponse = TokenResponse.fromJson(apiResponse.data!);
    await _saveTokens(tokenResponse);

    // 로그인 후 프로필 조회
    final profileResponse = await _client.get(ApiConstants.profileMe);

    final profileApiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      profileResponse.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!profileApiResponse.success || profileApiResponse.data == null) {
      throw Exception(
          profileApiResponse.error?.message ?? 'Failed to get profile');
    }

    return UserModel.fromJson(profileApiResponse.data!);
  }

  Future<void> logout() async {
    try {
      await _client.post(ApiConstants.logout);
    } finally {
      await SecureStorage.deleteAll();
    }
  }

  Future<void> _saveTokens(TokenResponse tokenResponse) async {
    await SecureStorage.write(
      ApiConstants.accessTokenKey,
      tokenResponse.accessToken,
    );
    await SecureStorage.write(
      ApiConstants.refreshTokenKey,
      tokenResponse.refreshToken,
    );
  }
}
