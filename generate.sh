#!/bin/bash

# Flutter 코드 생성 스크립트
echo "Flutter 의존성을 가져오는 중..."
flutter pub get

echo ""
echo "Freezed 및 JSON 직렬화 코드를 생성하는 중..."
flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo "완료! 이제 앱을 실행할 수 있습니다:"
echo "flutter run -d chrome"
