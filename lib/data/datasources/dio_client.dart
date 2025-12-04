import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/secure_storage.dart';

class DioClient {
  late final Dio _dio;

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

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.read(ApiConstants.accessTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            try {
              final refreshToken = await SecureStorage.read(
                ApiConstants.refreshTokenKey,
              );
              if (refreshToken != null) {
                final response = await _dio.post(
                  ApiConstants.refresh,
                  data: {'refreshToken': refreshToken},
                );

                if (response.data['success'] == true) {
                  final newAccessToken = response.data['data']['accessToken'];
                  await SecureStorage.write(
                    ApiConstants.accessTokenKey,
                    newAccessToken,
                  );

                  error.requestOptions.headers['Authorization'] =
                      'Bearer $newAccessToken';
                  return handler.resolve(await _dio.fetch(error.requestOptions));
                }
              }
            } catch (e) {
              await SecureStorage.deleteAll();
            }
          }
          return handler.next(error);
        },
      ),
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
