import '../../core/constants/api_constants.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import 'dio_client.dart';

class ProfileApi {
  final DioClient _client;

  ProfileApi(this._client);

  Future<UserModel> getMyProfile() async {
    final response = await _client.get(ApiConstants.profileMe);

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Failed to get profile');
    }

    return UserModel.fromJson(apiResponse.data!);
  }

  Future<UserModel> updateProfile({
    String? nickname,
    String? profileImageUrl,
    int? age,
    String? gender,
    String? bio,
  }) async {
    final data = <String, dynamic>{};
    if (nickname != null) data['nickname'] = nickname;
    if (profileImageUrl != null) data['profileImageUrl'] = profileImageUrl;
    if (age != null) data['age'] = age;
    if (gender != null) data['gender'] = gender;
    if (bio != null) data['bio'] = bio;

    final response = await _client.patch(
      ApiConstants.profileMe,
      data: data,
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Failed to update profile');
    }

    return UserModel.fromJson(apiResponse.data!);
  }
}
