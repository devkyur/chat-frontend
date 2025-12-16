import 'package:flutter/foundation.dart';

/// 로그 레벨
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// 앱 로거
///
/// 사용법:
/// ```dart
/// AppLogger.d('Debug message');
/// AppLogger.i('Info message');
/// AppLogger.w('Warning message');
/// AppLogger.e('Error message', error, stackTrace);
/// ```
class AppLogger {
  AppLogger._();

  /// 현재 로그 레벨 (release 빌드에서는 warning 이상만 출력)
  static LogLevel minLevel = kReleaseMode ? LogLevel.warning : LogLevel.debug;

  /// 로그 출력 활성화 여부
  static bool enabled = true;

  /// Debug 로그
  static void d(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  /// Info 로그
  static void i(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  /// Warning 로그
  static void w(String message, {String? tag, Object? error}) {
    _log(LogLevel.warning, message, tag: tag, error: error);
  }

  /// Error 로그
  static void e(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// 네트워크 요청 로그
  static void network(String method, String url, {int? statusCode, String? tag}) {
    final status = statusCode != null ? '[$statusCode]' : '';
    _log(LogLevel.debug, '$method $url $status', tag: tag ?? 'Network');
  }

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!enabled) return;
    if (level.index < minLevel.index) return;

    final emoji = _getEmoji(level);
    final tagStr = tag != null ? '[$tag] ' : '';
    final timestamp = _formatTimestamp(DateTime.now());
    final levelStr = level.name.toUpperCase().padRight(7);

    final logMessage = '$emoji $timestamp $levelStr $tagStr$message';

    // 콘솔 출력
    debugPrint(logMessage);

    // 에러인 경우 상세 정보 출력
    if (error != null) {
      debugPrint('   Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('   StackTrace:\n${_formatStackTrace(stackTrace)}');
    }
  }

  static String _getEmoji(LogLevel level) {
    return switch (level) {
      LogLevel.debug => '🐛',
      LogLevel.info => 'ℹ️',
      LogLevel.warning => '⚠️',
      LogLevel.error => '❌',
    };
  }

  static String _formatTimestamp(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}.'
        '${time.millisecond.toString().padLeft(3, '0')}';
  }

  static String _formatStackTrace(StackTrace stackTrace) {
    final lines = stackTrace.toString().split('\n');
    final limitedLines = lines.take(5).map((line) => '      $line').toList();
    if (lines.length > 5) {
      limitedLines.add('      ... ${lines.length - 5} more lines');
    }
    return limitedLines.join('\n');
  }
}

/// Extension for convenient logging
extension LoggerExtension on Object {
  void logDebug({String? tag}) => AppLogger.d(toString(), tag: tag);
  void logInfo({String? tag}) => AppLogger.i(toString(), tag: tag);
  void logWarning({String? tag}) => AppLogger.w(toString(), tag: tag);
  void logError({String? tag, StackTrace? stackTrace}) =>
      AppLogger.e(toString(), tag: tag, stackTrace: stackTrace);
}
