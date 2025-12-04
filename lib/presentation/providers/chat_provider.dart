import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/chat_message.dart';
import 'providers.dart';

part 'chat_provider.g.dart';

@riverpod
class ChatRooms extends _$ChatRooms {
  @override
  FutureOr<List<ChatRoom>> build() async {
    return await ref.watch(chatRepositoryProvider).getChatRooms();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(chatRepositoryProvider).getChatRooms();
    });
  }
}

@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  FutureOr<List<ChatMessage>> build(int roomId) async {
    return await ref.watch(chatRepositoryProvider).getMessages(roomId);
  }

  Future<void> loadMore() async {
    final currentMessages = state.value ?? [];
    if (currentMessages.isEmpty) return;

    final oldestMessageId = currentMessages.last.id;

    final newMessages = await ref.read(chatRepositoryProvider).getMessages(
          roomId,
          before: oldestMessageId,
        );

    state = AsyncValue.data([...currentMessages, ...newMessages]);
  }

  Future<void> sendMessage(String content) async {
    await ref.read(chatRepositoryProvider).sendMessage(roomId, content);
  }

  void addMessage(ChatMessage message) {
    final currentMessages = state.value ?? [];
    state = AsyncValue.data([message, ...currentMessages]);
  }
}

@riverpod
Stream<ChatMessage> chatMessageStream(ChatMessageStreamRef ref, int roomId) {
  return ref.watch(chatRepositoryProvider).subscribeToRoom(roomId);
}
