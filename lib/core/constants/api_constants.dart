class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com/api/v1',
  );

  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'wss://api.example.com/ws/chat',
  );

  // Auth endpoints
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Profile endpoints
  static const String profileMe = '/profiles/me';

  // Match endpoints
  static const String matchCandidates = '/matches/candidates';
  static String matchLike(int id) => '/matches/$id/like';
  static String matchPass(int id) => '/matches/$id/pass';

  // Chat endpoints
  static const String chatRooms = '/chat/rooms';
  static String chatRoomMessages(int roomId) => '/chat/rooms/$roomId/messages';

  // Upload endpoints
  static const String presignedUrl = '/uploads/presigned-url';

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
}
