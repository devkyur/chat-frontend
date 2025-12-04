import 'user.dart';

class ChatRoom {
  final int id;
  final User otherUser;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  const ChatRoom({
    required this.id,
    required this.otherUser,
    this.lastMessage,
    this.lastMessageTime,
    required this.unreadCount,
  });
}
