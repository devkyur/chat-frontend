import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/chat_room.dart';
import 'user_model.dart';

part 'chat_room_model.freezed.dart';
part 'chat_room_model.g.dart';

@freezed
class ChatRoomModel with _$ChatRoomModel {
  const ChatRoomModel._();

  const factory ChatRoomModel({
    required int id,
    required UserModel otherUser,
    String? lastMessage,
    DateTime? lastMessageTime,
    @Default(0) int unreadCount,
  }) = _ChatRoomModel;

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomModelFromJson(json);

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
