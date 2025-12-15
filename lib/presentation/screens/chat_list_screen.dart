import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/chat_provider.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoomsAsync = ref.watch(chatRoomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
      ),
      body: chatRoomsAsync.when(
        data: (rooms) {
          if (rooms.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '채팅방이 없습니다',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(chatRoomsProvider.notifier).refresh();
            },
            child: ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: room.otherUser.imageUrls.isNotEmpty
                        ? NetworkImage(room.otherUser.imageUrls.first)
                        : null,
                    child: room.otherUser.imageUrls.isEmpty
                        ? Text(room.otherUser.nickname[0].toUpperCase())
                        : null,
                  ),
                  title: Text(room.otherUser.nickname),
                  subtitle: Text(
                    room.lastMessage ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: room.unreadCount > 0
                      ? CircleAvatar(
                          radius: 12,
                          backgroundColor: const Color(0xFFFF4458),
                          child: Text(
                            '${room.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : null,
                  onTap: () {
                    context.push('/chat/${room.id}');
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('에러: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(chatRoomsProvider);
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
