import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/secure_storage.dart';
import '../models/chat_message_model.dart';

class ChatWebSocket {
  StompClient? _stompClient;
  final _messageController = StreamController<ChatMessageModel>.broadcast();
  final Map<int, StreamSubscription> _subscriptions = {};
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  Stream<ChatMessageModel> get messageStream => _messageController.stream;

  Future<void> connect() async {
    if (_stompClient?.connected ?? false) return;

    final token = await SecureStorage.read(ApiConstants.accessTokenKey);
    if (token == null) {
      throw Exception('No access token found');
    }

    _stompClient = StompClient(
      config: StompConfig(
        url: ApiConstants.wsUrl,
        onConnect: _onConnect,
        onWebSocketError: (dynamic error) => _onError(error),
        onStompError: (StompFrame frame) => _onStompError(frame),
        onDisconnect: (StompFrame frame) => _onDisconnect(frame),
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    _stompClient!.activate();
  }

  void _onConnect(StompFrame frame) {
    _reconnectAttempts = 0;
  }

  void _onError(dynamic error) {
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      final delay = Duration(seconds: 2 * _reconnectAttempts);
      Future.delayed(delay, () => connect());
    }
  }

  void _onStompError(StompFrame frame) {
    print('STOMP Error: ${frame.body}');
  }

  void _onDisconnect(StompFrame frame) {
    _subscriptions.clear();
  }

  void subscribeToRoom(int roomId) {
    if (_subscriptions.containsKey(roomId)) return;

    final subscription = _stompClient?.subscribe(
      destination: '/topic/chat/$roomId',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final json = jsonDecode(frame.body!);
            final message = ChatMessageModel.fromJson(json);
            _messageController.add(message);
          } catch (e) {
            print('Error parsing message: $e');
          }
        }
      },
    );

    if (subscription != null) {
      _subscriptions[roomId] = subscription as StreamSubscription;
    }
  }

  void unsubscribeFromRoom(int roomId) {
    _subscriptions[roomId]?.cancel();
    _subscriptions.remove(roomId);
  }

  void sendMessage(int roomId, String content) {
    if (!(_stompClient?.connected ?? false)) {
      throw Exception('WebSocket not connected');
    }

    _stompClient!.send(
      destination: '/app/chat/$roomId/send',
      body: jsonEncode(
        SendMessageRequest(content: content).toJson(),
      ),
    );
  }

  Future<void> disconnect() async {
    for (var subscription in _subscriptions.values) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    _stompClient?.deactivate();
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
