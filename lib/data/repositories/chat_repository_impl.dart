import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_api.dart';
import '../datasources/chat_websocket.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatApi _chatApi;
  final ChatWebSocket _chatWebSocket;

  ChatRepositoryImpl(this._chatApi, this._chatWebSocket);

  @override
  Future<List<ChatRoom>> getChatRooms() async {
    final roomModels = await _chatApi.getChatRooms();
    return roomModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ChatMessage>> getMessages(int roomId, {int? before}) async {
    final messageModels = await _chatApi.getMessages(roomId, before: before);
    return messageModels.map((model) => model.toEntity()).toList();
  }

  @override
  Stream<ChatMessage> subscribeToRoom(int roomId) {
    _chatWebSocket.subscribeToRoom(roomId);
    return _chatWebSocket.messageStream
        .where((message) => message.roomId == roomId)
        .map((model) => model.toEntity());
  }

  @override
  Future<void> sendMessage(int roomId, String content) async {
    _chatWebSocket.sendMessage(roomId, content);
  }

  @override
  Future<void> connectWebSocket() async {
    await _chatWebSocket.connect();
  }

  @override
  Future<void> disconnectWebSocket() async {
    await _chatWebSocket.disconnect();
  }
}
