import '../entities/chat_message.dart';
import '../entities/chat_room.dart';

abstract class ChatRepository {
  Future<List<ChatRoom>> getChatRooms();

  Future<List<ChatMessage>> getMessages(int roomId, {int? before});

  Stream<ChatMessage> subscribeToRoom(int roomId);

  Future<void> sendMessage(int roomId, String content);

  Future<void> connectWebSocket();

  Future<void> disconnectWebSocket();
}
