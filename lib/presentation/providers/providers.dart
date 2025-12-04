import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_api.dart';
import '../../data/datasources/chat_api.dart';
import '../../data/datasources/chat_websocket.dart';
import '../../data/datasources/dio_client.dart';
import '../../data/datasources/profile_api.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/profile_repository.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(dioClientProvider)),
);

final profileApiProvider = Provider<ProfileApi>(
  (ref) => ProfileApi(ref.watch(dioClientProvider)),
);

final chatApiProvider = Provider<ChatApi>(
  (ref) => ChatApi(ref.watch(dioClientProvider)),
);

final chatWebSocketProvider = Provider<ChatWebSocket>(
  (ref) => ChatWebSocket(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.watch(authApiProvider),
    ref.watch(profileApiProvider),
  ),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.watch(profileApiProvider)),
);

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepositoryImpl(
    ref.watch(chatApiProvider),
    ref.watch(chatWebSocketProvider),
  ),
);
