import 'package:dio/dio.dart';
import '../config/env.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class TimeoutException extends ApiException {
  TimeoutException(super.message);
}

class BadRequestException extends ApiException {
  BadRequestException(super.message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(super.message);
}

class NotFoundException extends ApiException {
  NotFoundException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message);
}

class RequestCancelledException extends ApiException {
  RequestCancelledException(super.message);
}

class ValidationException extends ApiException {
  ValidationException(super.message);
}

class DioService {
  late final Dio _dio;
  
  DioService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: apiTimeoutSeconds),
        receiveTimeout: const Duration(seconds: apiTimeoutSeconds),
        responseType: ResponseType.json,
        headers: apiDefaultHeaders,
      ),
    );
  }

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<T> get<T>({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<T>(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data!;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<T> post<T>({
    required String endpoint,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data!;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<T> put<T>({
    required String endpoint,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data!;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<T> patch<T>({
    required String endpoint,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<T> delete<T>({
    required String endpoint,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data!;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Connection timed out. Please check your internet connection.');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        
        String message = 'Unknown error occurred';
        if (responseData != null && responseData is Map<String, dynamic>) {
          // Check for validation errors structure
          if (responseData['errors'] != null) {
            final errors = responseData['errors'];
            if (errors is Map<String, dynamic>) {
              // Convert validation errors to readable format
              message = errors.entries
                  .map((e) => '${e.key}: ${(e.value as List).join(', ')}')
                  .join('\n');
            } else if (errors is List) {
              message = errors.join('\n');
            } else {
              message = errors.toString();
            }
            // print('DEBUG - Validation Errors: $errors'); // Debug log
          } else {
            message = responseData['message'] ?? message;
          }
        }
        
        switch (statusCode) {
          case 400:
            return BadRequestException(message);
          case 401:
            return UnauthorizedException(message);
          case 403:
            return ForbiddenException(message);
          case 404:
            return NotFoundException(message);
          case 422:
            return ValidationException(message);
          case 500:
          case 501:
          case 502:
          case 503:
            return ServerException(message);
          default:
            return ApiException(message);
        }
      
      case DioExceptionType.cancel:
        return ApiException('Request was cancelled');
      
      case DioExceptionType.unknown:
        if (error.message!.contains('SocketException')) {
          return ApiException('No internet connection');
        }
        return ApiException('Unexpected error occurred: ${error.message}');

      case DioExceptionType.badCertificate:
        return ApiException('Bad SSL certificate');

      case DioExceptionType.connectionError:
        return ApiException('Connection error');
    }
  }
} 
