# Dating App Frontend

## 기술 스택
- Flutter 3.x + Dart
- Riverpod (상태관리)
- Dio (HTTP)
- web_socket_channel + STOMP (실시간 채팅)
- 배포: Android/iOS/Web 동시 빌드

**참고**: Firebase Cloud Messaging (푸시 알림)은 향후 구현 예정입니다.

## 프로젝트 구조

```
lib/
├── core/
│   ├── constants/       # API URL, 키 상수
│   ├── theme/           # 색상, 폰트, 공통 스타일
│   ├── router/          # GoRouter 설정
│   └── utils/           # 헬퍼 함수
├── data/
│   ├── datasources/     # API 호출, WebSocket
│   ├── repositories/    # Repository 구현체
│   └── models/          # JSON 직렬화 모델
├── domain/
│   ├── entities/        # 순수 도메인 객체
│   └── repositories/    # Repository 인터페이스
├── presentation/
│   ├── providers/       # Riverpod Provider
│   ├── screens/         # 화면 위젯
│   └── widgets/         # 재사용 위젯
└── main.dart
```

## 핵심 규칙

### 계층 분리
- **presentation**: UI + Provider. 비즈니스 로직 금지
- **domain**: 순수 Dart. Flutter 의존성 금지
- **data**: 외부 통신. domain 인터페이스 구현

### 상태관리 (Riverpod)
- 서버 상태: `AsyncNotifierProvider` (API 호출)
- UI 상태: `StateNotifierProvider` (로컬 상태)
- 단순 값: `Provider` (계산된 값)

```dart
// 예시: 인증 상태
@riverpod
class Auth extends _$Auth {
  @override
  FutureOr<User?> build() => _loadUser();

  Future<void> login(String email, String password) async { ... }
  Future<void> logout() async { ... }
}
```

### Dio 설정
- BaseUrl: 환경별 분리
- 인터셉터: JWT 자동 첨부, 401 시 토큰 갱신, 에러 핸들링

```dart
// 인터셉터 핵심 로직
onRequest: (options, handler) {
  options.headers['Authorization'] = 'Bearer $accessToken';
  handler.next(options);
}

onError: (error, handler) {
  if (error.response?.statusCode == 401) {
    // refresh 시도 → 실패 시 로그인 화면
  }
}
```

### 모델
- 수동으로 작성된 모델 클래스 사용
- Request/Response 모델 분리
- fromJson/toJson 메서드 구현

```dart
class UserModel {
  final int id;
  final String email;
  final String nickname;

  const UserModel({
    required this.id,
    required this.email,
    required this.nickname,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
    };
  }
}
```

### WebSocket (채팅)
- STOMP 프로토콜
- 연결 끊김 시 Exponential Backoff 재연결
- 앱 포그라운드/백그라운드 상태 관리

```dart
// 구독
stompClient.subscribe('/topic/chat/$roomId', (frame) {
  final message = ChatMessage.fromJson(jsonDecode(frame.body!));
  // 상태 업데이트
});

// 발행
stompClient.send(
  destination: '/app/chat/$roomId/send',
  body: jsonEncode(message.toJson()),
);
```

### 이미지 업로드
1. `GET /uploads/presigned-url` → URL 받기
2. `PUT` 으로 R2 직접 업로드
3. 업로드된 URL을 프로필 저장 API에 전달

### 에러 처리
- API 응답: `{ success, data, error }` 구조
- 공통 에러 핸들링 → 스낵바 or 다이얼로그

```dart
// 공통 응답 모델
class ApiResponse<T> {
  final bool success;
  final T? data;
  final ApiError? error;
}
```

## 화면 흐름

```
Splash → Auth Check
         ├── 토큰 없음 → Login/Signup
         └── 토큰 있음 → Main
                        ├── Home (매칭 카드)
                        ├── Chat (채팅 목록)
                        └── Profile (내 프로필)
```

## Backend API

### API 문서
- **Swagger UI**: `http://localhost:8080/swagger-ui/index.html`
- **OpenAPI JSON**: `http://localhost:8080/v3/api-docs`
- **최신 스펙 확인**: `curl http://localhost:8080/v3/api-docs`

### Base
- URL: `http://localhost:8080/api/v1` (개발환경)
- 인증: `Authorization: Bearer {accessToken}`

### Auth API
```
POST   /api/v1/auth/signup
  - Request: { email, password, name, phoneNumber? }
  - Validation: password(8-20자), name(2-50자)
  - Response: { success, data: { accessToken, refreshToken }, error }
  ⚠️ 주의: user 정보는 포함되지 않음. 로그인 후 GET /profiles/me로 조회 필요

POST   /api/v1/auth/login
  - Request: { email, password }
  - Response: { success, data: { accessToken, refreshToken }, error }
  ⚠️ 주의: user 정보는 포함되지 않음. 로그인 후 GET /profiles/me로 조회 필요

POST   /api/v1/auth/refresh
  - Request: { refreshToken }
  - Response: { success, data: { accessToken, refreshToken }, error }

POST   /api/v1/auth/logout
  - Headers: Authorization: Bearer {accessToken}
  - Response: { success, data: null, error }
```

### Profile API
```
POST   /api/v1/profiles
  - Request: { nickname, birthDate, gender(MALE|FEMALE|OTHER), bio?, location? }
  - Response: { success, data: ProfileResponse, error }

GET    /api/v1/profiles/me
  - Headers: Authorization: Bearer {accessToken}
  - Response: { success, data: ProfileResponse, error }

GET    /api/v1/profiles/{profileId}
  - Response: { success, data: ProfileResponse, error }

PATCH  /api/v1/profiles/me
  - Request: { nickname?, bio?, location?, imageUrls?, interests?,
              minAgePreference?, maxAgePreference?, maxDistance? }
  - Response: { success, data: ProfileResponse, error }

ProfileResponse 구조:
{
  id, userId, nickname, birthDate, gender, bio, location,
  imageUrls: string[], interests: string[],
  minAgePreference, maxAgePreference, maxDistance
}
```

### Match API
```
GET    /api/v1/matches
  - Response: { success, data: [MatchResponse], error }

GET    /api/v1/matches/candidates
  - Response: { success, data: [ProfileResponse], error }

POST   /api/v1/matches/{profileId}/like
  - Response: { success, data: MatchResponse, error }
  - MatchResponse.isMatched: true면 매칭 성사

POST   /api/v1/matches/{profileId}/pass
  - Response: { success, data: MatchResponse, error }

MatchResponse 구조:
{
  id, fromProfileId, toProfileId,
  action: "LIKE" | "PASS",
  isMatched: boolean,
  createdAt
}
```

### Chat API
```
GET    /api/v1/chat/rooms
  - Response: { success, data: [ChatRoomResponse], error }

POST   /api/v1/chat/rooms?matchId={matchId}
  - Response: { success, data: ChatRoomResponse, error }

GET    /api/v1/chat/rooms/{roomId}/messages?page=0&size=20
  - Response: { success, data: PageChatMessageResponse, error }

ChatRoomResponse: { id, matchId, createdAt }
ChatMessageResponse: { id, chatRoomId, senderProfileId, content, type, isRead, createdAt }
MessageType: TEXT | IMAGE | SYSTEM
```

### Notification API
```
POST   /api/v1/notifications/tokens
  - Request: { token }  # FCM token
  - Response: { success, data: null, error }

DELETE /api/v1/notifications/tokens
  - Request: { token }
  - Response: { success, data: null, error }
```

### 응답 형식
```json
{ "success": true, "data": { ... }, "error": null }
{ "success": false, "data": null, "error": { "code": "U001", "message": "..." } }
```

### WebSocket (STOMP)
```
연결: ws://localhost:8080/ws/chat
구독: /topic/chat/{roomId}
발행: /app/chat/{roomId}/send
```

## 네이밍 규칙

| 대상 | 규칙 | 예시 |
|------|------|------|
| 파일 | snake_case | `login_screen.dart` |
| 클래스 | PascalCase | `LoginScreen` |
| 변수/함수 | camelCase | `userProfile` |
| Provider | camelCase + Provider | `authProvider` |

## 의존성 (pubspec.yaml)

```yaml
dependencies:
  flutter_riverpod: ^2.6.0
  dio: ^5.4.0
  stomp_dart_client: ^1.0.0
  web_socket_channel: ^2.4.0
  go_router: ^13.0.0
  cached_network_image: ^3.3.0
  image_picker: ^1.0.0
  shared_preferences: ^2.2.0
  flutter_secure_storage: ^9.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

**참고**: 이 프로젝트는 Freezed나 Riverpod 코드 생성을 사용하지 않습니다. 모든 모델과 Provider는 수동으로 작성되어 더 나은 호환성과 안정성을 제공합니다.

## Git 커밋
```
feat: 기능 추가
fix: 버그 수정
refactor: 리팩토링
style: UI/스타일 변경
chore: 설정, 의존성
```
