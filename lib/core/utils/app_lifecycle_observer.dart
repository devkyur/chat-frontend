import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'logger.dart';

/// 앱 생명주기 상태
enum AppLifecycleStatus {
  resumed,
  paused,
  inactive,
  detached,
  hidden,
}

/// 앱 생명주기 상태 Provider
final appLifecycleProvider = StateProvider<AppLifecycleStatus>((ref) {
  return AppLifecycleStatus.resumed;
});

/// 앱 생명주기 감지기
///
/// 앱이 백그라운드로 가거나 포어그라운드로 돌아올 때를 감지합니다.
/// main.dart에서 사용합니다:
///
/// ```dart
/// class MyApp extends ConsumerStatefulWidget {
///   @override
///   ConsumerState<MyApp> createState() => _MyAppState();
/// }
///
/// class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
///   late final AppLifecycleObserver _lifecycleObserver;
///
///   @override
///   void initState() {
///     super.initState();
///     _lifecycleObserver = AppLifecycleObserver(ref);
///     WidgetsBinding.instance.addObserver(_lifecycleObserver);
///   }
///
///   @override
///   void dispose() {
///     WidgetsBinding.instance.removeObserver(_lifecycleObserver);
///     super.dispose();
///   }
/// }
/// ```
class AppLifecycleObserver with WidgetsBindingObserver {
  static const _tag = 'AppLifecycle';

  final WidgetRef ref;

  AppLifecycleObserver(this.ref);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final status = _mapToStatus(state);
    AppLogger.i('App lifecycle changed: $status', tag: _tag);
    ref.read(appLifecycleProvider.notifier).state = status;
  }

  AppLifecycleStatus _mapToStatus(AppLifecycleState state) {
    return switch (state) {
      AppLifecycleState.resumed => AppLifecycleStatus.resumed,
      AppLifecycleState.paused => AppLifecycleStatus.paused,
      AppLifecycleState.inactive => AppLifecycleStatus.inactive,
      AppLifecycleState.detached => AppLifecycleStatus.detached,
      AppLifecycleState.hidden => AppLifecycleStatus.hidden,
    };
  }
}
