import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/chat_message.dart';

part 'chat_message_model.freezed.dart';
part 'chat_message_model.g.dart';

@freezed
class ChatMessageModel with _$ChatMessageModel {
  const ChatMessageModel._();

  const factory ChatMessageModel({
    required int id,
    required int roomId,
    required int senderId,
    required String content,
    required DateTime createdAt,
    @Default(false) bool isRead,
  }) = _ChatMessageModel;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);

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

@freezed
class SendMessageRequest with _$SendMessageRequest {
  const factory SendMessageRequest({
    required String content,
  }) = _SendMessageRequest;

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendMessageRequestFromJson(json);
}
