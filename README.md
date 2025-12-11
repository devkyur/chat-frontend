# Dating App Frontend

Flutter 기반의 실시간 채팅 데이팅 앱 프론트엔드

## 기술 스택

- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Riverpod
- **HTTP Client**: Dio
- **WebSocket**: STOMP + web_socket_channel
- **Navigation**: GoRouter
- **Code Generation**: Freezed, json_serializable

## 프로젝트 구조

```
lib/
├── core/               # 핵심 설정 및 유틸리티
│   ├── constants/     # API URL, 상수
│   ├── theme/         # 앱 테마
│   ├── router/        # 라우팅 설정
│   └── utils/         # 헬퍼 함수
├── domain/            # 비즈니스 로직
│   ├── entities/      # 도메인 엔티티
│   └── repositories/  # 리포지토리 인터페이스
├── data/              # 데이터 계층
│   ├── models/        # API 모델 (Freezed)
│   ├── datasources/   # API 및 WebSocket
│   └── repositories/  # 리포지토리 구현
└── presentation/      # UI 계층
    ├── providers/     # Riverpod Provider
    ├── screens/       # 화면
    └── widgets/       # 재사용 위젯
```

## 시작하기

### 1. 의존성 설치

```bash
flutter pub get
```

### 2. 앱 실행

```bash
# Chrome에서 실행
flutter run -d chrome

# 또는 모바일 디바이스에서 실행
flutter run
```

### 3. 환경 변수 설정 (선택사항)

```bash
flutter run -d chrome \
  --dart-define=API_BASE_URL=https://your-api.com/api/v1 \
  --dart-define=WS_URL=wss://your-api.com/ws/chat
```

## 트러블슈팅

### 패키지 의존성 문제

최신 의존성을 받으려면:
```bash
flutter clean
flutter pub get
```

### 분석 에러 확인

```bash
flutter analyze
```

## 주요 기능

- ✅ 회원가입 / 로그인
- ✅ JWT 토큰 기반 인증
- ✅ 자동 토큰 갱신
- ✅ 실시간 채팅 (WebSocket/STOMP)
- ✅ 채팅방 목록
- ✅ 프로필 관리
- ✅ 웹 플랫폼 지원
- 🔜 매칭 시스템
- 🔜 이미지 업로드
- 🔜 푸시 알림 (Firebase Cloud Messaging)

## 아키텍처

이 프로젝트는 Clean Architecture 원칙을 따릅니다:

- **Domain Layer**: 순수 Dart 코드, Flutter 의존성 없음
- **Data Layer**: API 통신, 데이터 변환
- **Presentation Layer**: UI 및 상태 관리

## 개발 가이드

상세한 개발 가이드는 [claude.md](./claude.md)를 참조하세요.
