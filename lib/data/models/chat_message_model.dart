import '../../domain/entities/chat_message.dart';

class ChatMessageModel {
  final int id;
  final int roomId;
  final int senderId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  const ChatMessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as int,
      roomId: json['roomId'] as int,
      senderId: json['senderId'] as int,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'senderId': senderId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  ChatMessage toEntity() {
    return ChatMessage(
      id: id,
      roomId: roomId,
      senderId: senderId,
      content: content,
      createdAt: createdAt,
      isRead: isRead,
    );
  }
}

class SendMessageRequest {
  final String content;

  const SendMessageRequest({
    required this.content,
  });

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) {
    return SendMessageRequest(
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }
}
