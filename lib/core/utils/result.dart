/// Result 패턴 - 에러 핸들링을 위한 타입 안전한 방식
///
/// 사용법:
/// ```dart
/// final result = await repository.getData();
/// result.when(
///   success: (data) => print(data),
///   failure: (error) => print(error.message),
/// );
/// ```
sealed class Result<T> {
  const Result();

  /// 성공 결과 생성
  const factory Result.success(T data) = Success<T>;

  /// 실패 결과 생성
  const factory Result.failure(AppException exception) = Failure<T>;

  /// 패턴 매칭
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  });

  /// 성공 여부
  bool get isSuccess => this is Success<T>;

  /// 실패 여부
  bool get isFailure => this is Failure<T>;

  /// 성공 시 데이터 반환 (실패 시 null)
  T? get dataOrNull {
    return switch (this) {
      Success(data: final data) => data,
      Failure() => null,
    };
  }

  /// 성공 시 데이터 반환 (실패 시 예외 throw)
  T get dataOrThrow {
    return switch (this) {
      Success(data: final data) => data,
      Failure(exception: final e) => throw e,
    };
  }

  /// 실패 시 예외 반환 (성공 시 null)
  AppException? get exceptionOrNull {
    return switch (this) {
      Success() => null,
      Failure(exception: final e) => e,
    };
  }

  /// 데이터 변환
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success(data: final data) => Result.success(transform(data)),
      Failure(exception: final e) => Result.failure(e),
    };
  }

  /// 비동기 데이터 변환
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) transform) async {
    return switch (this) {
      Success(data: final data) => Result.success(await transform(data)),
      Failure(exception: final e) => Result.failure(e),
    };
  }
}

/// 성공 결과
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  }) {
    return success(data);
  }

  @override
  bool operator ==(Object other) {
    return other is Success<T> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success($data)';
}

/// 실패 결과
final class Failure<T> extends Result<T> {
  final AppException exception;

  const Failure(this.exception);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  }) {
    return failure(exception);
  }

  @override
  bool operator ==(Object other) {
    return other is Failure<T> && other.exception == exception;
  }

  @override
  int get hashCode => exception.hashCode;

  @override
  String toString() => 'Failure($exception)';
}

/// 앱 예외 클래스
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';

  /// 네트워크 에러
  factory AppException.network([String? message]) {
    return AppException(
      message: message ?? '네트워크 연결을 확인해주세요',
      code: 'NETWORK_ERROR',
    );
  }

  /// 서버 에러
  factory AppException.server([String? message]) {
    return AppException(
      message: message ?? '서버 오류가 발생했습니다',
      code: 'SERVER_ERROR',
    );
  }

  /// 인증 에러
  factory AppException.unauthorized([String? message]) {
    return AppException(
      message: message ?? '로그인이 필요합니다',
      code: 'UNAUTHORIZED',
    );
  }

  /// 유효성 검사 에러
  factory AppException.validation(String message) {
    return AppException(
      message: message,
      code: 'VALIDATION_ERROR',
    );
  }

  /// 알 수 없는 에러
  factory AppException.unknown([dynamic error, StackTrace? stackTrace]) {
    return AppException(
      message: '알 수 없는 오류가 발생했습니다',
      code: 'UNKNOWN_ERROR',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}

/// Result를 쉽게 생성하기 위한 확장 함수
extension ResultExtensions<T> on T {
  Result<T> toSuccess() => Result.success(this);
}

/// 비동기 작업을 Result로 감싸기
Future<Result<T>> runCatching<T>(Future<T> Function() action) async {
  try {
    final result = await action();
    return Result.success(result);
  } on AppException catch (e) {
    return Result.failure(e);
  } catch (e, st) {
    return Result.failure(AppException.unknown(e, st));
  }
}
