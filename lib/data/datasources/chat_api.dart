import '../../core/constants/api_constants.dart';
import '../models/api_response.dart';
import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';
import 'dio_client.dart';

class ChatApi {
  final DioClient _client;

  ChatApi(this._client);

  Future<List<ChatRoomModel>> getChatRooms() async {
    final response = await _client.get(ApiConstants.chatRooms);

    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data,
      (json) => json as List<dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Failed to get chat rooms');
    }

    return apiResponse.data!
        .map((json) => ChatRoomModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<ChatMessageModel>> getMessages(
    int roomId, {
    int? before,
  }) async {
    final queryParams = before != null ? {'before': before} : null;

    final response = await _client.get(
      ApiConstants.chatRoomMessages(roomId),
      queryParameters: queryParams,
    );

    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data,
      (json) => json as List<dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.error?.message ?? 'Failed to get messages');
    }

    return apiResponse.data!
        .map((json) => ChatMessageModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
