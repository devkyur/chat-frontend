import '../../domain/entities/chat_room.dart';
import 'user_model.dart';

class ChatRoomModel {
  final int id;
  final UserModel otherUser;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  const ChatRoomModel({
    required this.id,
    required this.otherUser,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] as int,
      otherUser: UserModel.fromJson(json['otherUser'] as Map<String, dynamic>),
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'] as String)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'otherUser': otherUser.toJson(),
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }

  ChatRoom toEntity() {
    return ChatRoom(
      id: id,
      otherUser: otherUser.toEntity(),
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      unreadCount: unreadCount,
    );
  }
}
