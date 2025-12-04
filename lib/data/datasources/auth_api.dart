import '../../core/constants/api_constants.dart';
import '../../core/utils/secure_storage.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import 'dio_client.dart';

class AuthApi {
  final DioClient _client;

  AuthApi(this._client);

  Future<UserModel> signup({
    required String email,
    required String password,
    required String nickname,
  }) async {
    final response = await _client.post(
      ApiConstants.signup,
      data: SignupRequest(
        email: email,
        password: password,
        nickname: nickname,
      ).toJson(),
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Signup failed');
    }

    final authResponse = AuthResponse.fromJson(apiResponse.data!);
    await _saveTokens(authResponse);

    return authResponse.user;
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

    final authResponse = AuthResponse.fromJson(apiResponse.data!);
    await _saveTokens(authResponse);

    return authResponse.user;
  }

  Future<void> logout() async {
    try {
      await _client.post(ApiConstants.logout);
    } finally {
      await SecureStorage.deleteAll();
    }
  }

  Future<void> _saveTokens(AuthResponse authResponse) async {
    await SecureStorage.write(
      ApiConstants.accessTokenKey,
      authResponse.accessToken,
    );
    await SecureStorage.write(
      ApiConstants.refreshTokenKey,
      authResponse.refreshToken,
    );
  }
}
