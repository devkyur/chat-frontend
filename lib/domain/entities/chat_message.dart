class ChatMessage {
  final int id;
  final int roomId;
  final int senderId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    required this.isRead,
  });
}
