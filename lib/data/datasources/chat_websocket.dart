import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../../core/utils/secure_storage.dart';
import '../models/chat_message_model.dart';

/// WebSocket 연결 상태
enum WebSocketState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

/// Chat WebSocket 클라이언트
///
/// STOMP 프로토콜을 사용하여 실시간 메시지를 주고받습니다.
class ChatWebSocket {
  static const _tag = 'ChatWebSocket';
  static const int _maxReconnectAttempts = 5;

  StompClient? _stompClient;
  final _messageController = StreamController<ChatMessageModel>.broadcast();
  final _stateController = StreamController<WebSocketState>.broadcast();
  final Map<int, dynamic> _subscriptions = {};

  int _reconnectAttempts = 0;
  WebSocketState _state = WebSocketState.disconnected;

  /// 메시지 스트림
  Stream<ChatMessageModel> get messageStream => _messageController.stream;

  /// 연결 상태 스트림
  Stream<WebSocketState> get stateStream => _stateController.stream;

  /// 현재 연결 상태
  WebSocketState get state => _state;

  /// 연결 여부
  bool get isConnected => _state == WebSocketState.connected;

  /// WebSocket 연결
  Future<void> connect() async {
    if (_stompClient?.connected ?? false) {
      AppLogger.d('Already connected', tag: _tag);
      return;
    }

    _updateState(WebSocketState.connecting);

    final token = await SecureStorage.read(ApiConstants.accessTokenKey);
    if (token == null) {
      AppLogger.e('No access token found', tag: _tag);
      _updateState(WebSocketState.disconnected);
      throw AppException.unauthorized('인증 토큰이 없습니다');
    }

    AppLogger.i('Connecting to WebSocket...', tag: _tag);

    _stompClient = StompClient(
      config: StompConfig(
        url: ApiConstants.wsUrl,
        onConnect: _onConnect,
        onWebSocketError: (dynamic error) => _onError(error),
        onStompError: _onStompError,
        onDisconnect: _onDisconnect,
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    _stompClient!.activate();
  }

  void _onConnect(StompFrame frame) {
    _reconnectAttempts = 0;
    _updateState(WebSocketState.connected);
    AppLogger.i('WebSocket connected', tag: _tag);
  }

  void _onError(dynamic error) {
    AppLogger.e('WebSocket error', tag: _tag, error: error);

    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      _updateState(WebSocketState.reconnecting);

      final delay = Duration(seconds: 2 * _reconnectAttempts);
      AppLogger.i(
        'Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts/$_maxReconnectAttempts)',
        tag: _tag,
      );

      Future.delayed(delay, connect);
    } else {
      AppLogger.e('Max reconnection attempts reached', tag: _tag);
      _updateState(WebSocketState.disconnected);
    }
  }

  void _onStompError(StompFrame frame) {
    AppLogger.e('STOMP error: ${frame.body}', tag: _tag);
  }

  void _onDisconnect(StompFrame frame) {
    AppLogger.i('WebSocket disconnected', tag: _tag);
    _subscriptions.clear();
    _updateState(WebSocketState.disconnected);
  }

  void _updateState(WebSocketState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(newState);
    }
  }

  /// 채팅방 구독
  void subscribeToRoom(int roomId) {
    if (_subscriptions.containsKey(roomId)) {
      AppLogger.d('Already subscribed to room $roomId', tag: _tag);
      return;
    }

    if (!(_stompClient?.connected ?? false)) {
      AppLogger.w('Cannot subscribe: WebSocket not connected', tag: _tag);
      return;
    }

    AppLogger.i('Subscribing to room $roomId', tag: _tag);

    final subscription = _stompClient?.subscribe(
      destination: '/topic/chat/$roomId',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final json = jsonDecode(frame.body!);
            final message = ChatMessageModel.fromJson(json);
            _messageController.add(message);
            AppLogger.d('Received message in room $roomId', tag: _tag);
          } catch (e, st) {
            AppLogger.e('Error parsing message', tag: _tag, error: e, stackTrace: st);
          }
        }
      },
    );

    if (subscription != null) {
      _subscriptions[roomId] = subscription;
    }
  }

  /// 채팅방 구독 해제
  void unsubscribeFromRoom(int roomId) {
    final subscription = _subscriptions[roomId];
    if (subscription != null) {
      AppLogger.i('Unsubscribing from room $roomId', tag: _tag);
      subscription.unsubscribe();
      _subscriptions.remove(roomId);
    }
  }

  /// 메시지 전송
  void sendMessage(int roomId, String content) {
    if (!(_stompClient?.connected ?? false)) {
      throw AppException.network('WebSocket이 연결되어 있지 않습니다');
    }

    AppLogger.d('Sending message to room $roomId', tag: _tag);

    _stompClient!.send(
      destination: '/app/chat/$roomId/send',
      body: jsonEncode(
        SendMessageRequest(content: content).toJson(),
      ),
    );
  }

  /// 연결 해제
  Future<void> disconnect() async {
    AppLogger.i('Disconnecting WebSocket...', tag: _tag);

    for (var subscription in _subscriptions.values) {
      subscription.unsubscribe();
    }
    _subscriptions.clear();
    _stompClient?.deactivate();
    _updateState(WebSocketState.disconnected);
  }

  /// 리소스 정리
  void dispose() {
    disconnect();
    _messageController.close();
    _stateController.close();
    AppLogger.d('WebSocket disposed', tag: _tag);
  }
}
