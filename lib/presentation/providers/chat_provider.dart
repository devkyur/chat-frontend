import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/chat_message.dart';
import 'providers.dart';

class ChatRoomsNotifier extends AsyncNotifier<List<ChatRoom>> {
  @override
  Future<List<ChatRoom>> build() async {
    return await ref.watch(chatRepositoryProvider).getChatRooms();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(chatRepositoryProvider).getChatRooms();
    });
  }
}

final chatRoomsProvider =
    AsyncNotifierProvider<ChatRoomsNotifier, List<ChatRoom>>(() {
  return ChatRoomsNotifier();
});

class ChatMessagesNotifier extends FamilyAsyncNotifier<List<ChatMessage>, int> {
  @override
  Future<List<ChatMessage>> build(int arg) async {
    return await ref.watch(chatRepositoryProvider).getMessages(arg);
  }

  Future<void> loadMore() async {
    final currentMessages = state.value ?? [];
    if (currentMessages.isEmpty) return;

    final oldestMessageId = currentMessages.last.id;

    final newMessages = await ref.read(chatRepositoryProvider).getMessages(
          arg,
          before: oldestMessageId,
        );

    state = AsyncValue.data([...currentMessages, ...newMessages]);
  }

  Future<void> sendMessage(String content) async {
    await ref.read(chatRepositoryProvider).sendMessage(arg, content);
  }

  void addMessage(ChatMessage message) {
    final currentMessages = state.value ?? [];
    state = AsyncValue.data([message, ...currentMessages]);
  }
}

final chatMessagesProvider = AsyncNotifierProvider.family<ChatMessagesNotifier,
    List<ChatMessage>, int>(() {
  return ChatMessagesNotifier();
});

final chatMessageStreamProvider =
    StreamProvider.family<ChatMessage, int>((ref, roomId) {
  return ref.watch(chatRepositoryProvider).subscribeToRoom(roomId);
});
