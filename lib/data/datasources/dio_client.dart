import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../../core/utils/secure_storage.dart';

/// HTTP 클라이언트
///
/// Dio를 래핑하여 인증, 토큰 갱신, 로깅 등을 처리합니다.
class DioClient {
  late final Dio _dio;
  static const _tag = 'DioClient';

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _authInterceptor(),
      _loggingInterceptor(),
    ]);
  }

  /// 인증 인터셉터 - 토큰 추가 및 갱신
  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage.read(ApiConstants.accessTokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final retried = await _tryRefreshToken(error);
          if (retried != null) {
            return handler.resolve(retried);
          }
        }
        return handler.next(error);
      },
    );
  }

  /// 토큰 갱신 시도
  Future<Response?> _tryRefreshToken(DioException error) async {
    try {
      final refreshToken = await SecureStorage.read(ApiConstants.refreshTokenKey);
      if (refreshToken == null) return null;

      AppLogger.d('Attempting token refresh', tag: _tag);

      final response = await _dio.post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.data['success'] == true) {
        final newAccessToken = response.data['data']['accessToken'];
        await SecureStorage.write(ApiConstants.accessTokenKey, newAccessToken);

        AppLogger.i('Token refreshed successfully', tag: _tag);

        error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        return await _dio.fetch(error.requestOptions);
      }
    } catch (e) {
      AppLogger.e('Token refresh failed', tag: _tag, error: e);
      await SecureStorage.deleteAll();
    }
    return null;
  }

  /// 로깅 인터셉터
  InterceptorsWrapper _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        AppLogger.network(
          options.method,
          '${options.baseUrl}${options.path}',
          tag: _tag,
        );
        return handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.network(
          response.requestOptions.method,
          response.requestOptions.path,
          statusCode: response.statusCode,
          tag: _tag,
        );
        return handler.next(response);
      },
      onError: (error, handler) {
        AppLogger.e(
          '${error.requestOptions.method} ${error.requestOptions.path}',
          tag: _tag,
          error: error.message,
        );
        return handler.next(error);
      },
    );
  }

  Dio get dio => _dio;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response> patch(
    String path, {
    dynamic data,
  }) async {
    return await _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }

  Future<Response> put(
    String url, {
    dynamic data,
    Options? options,
  }) async {
    return await _dio.put(url, data: data, options: options);
  }
}

/// DioException을 AppException으로 변환
AppException dioExceptionToAppException(DioException e) {
  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout =>
      AppException.network('연결 시간이 초과되었습니다'),
    DioExceptionType.connectionError => AppException.network(),
    DioExceptionType.badResponse => _handleBadResponse(e),
    DioExceptionType.cancel => AppException(message: '요청이 취소되었습니다', code: 'CANCELLED'),
    _ => AppException.unknown(e),
  };
}

AppException _handleBadResponse(DioException e) {
  final statusCode = e.response?.statusCode;
  final data = e.response?.data;

  // API 에러 메시지 추출
  String? message;
  if (data is Map<String, dynamic>) {
    message = data['error']?['message'] as String? ??
        data['message'] as String?;
  }

  return switch (statusCode) {
    400 => AppException.validation(message ?? '잘못된 요청입니다'),
    401 => AppException.unauthorized(message),
    403 => AppException(message: message ?? '접근 권한이 없습니다', code: 'FORBIDDEN'),
    404 => AppException(message: message ?? '요청한 리소스를 찾을 수 없습니다', code: 'NOT_FOUND'),
    500 || 502 || 503 => AppException.server(message),
    _ => AppException(
        message: message ?? '서버 오류가 발생했습니다',
        code: 'HTTP_$statusCode',
      ),
  };
}
