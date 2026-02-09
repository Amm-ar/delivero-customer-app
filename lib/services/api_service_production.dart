import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../config/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  late Dio _dio;
  String? _token;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Delivero-Flutter/1.0.0',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          
          // Log requests in debug mode
          if (!const bool.fromEnvironment('dart.vm.product')) {
            print('API Request: ${options.method} ${options.path}');
            if (options.data != null) {
              print('Request Data: ${options.data}');
            }
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log responses in debug mode
          if (!const bool.fromEnvironment('dart.vm.product')) {
            print('API Response: ${response.statusCode} ${response.requestOptions.path}');
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          // Handle errors globally
          if (!const bool.fromEnvironment('dart.vm.product')) {
            print('API Error: ${error.message}');
            if (error.response?.data != null) {
              print('Error Response: ${error.response?.data}');
            }
          }
          
          // Handle network errors
          if (error.type == DioExceptionType.connectionTimeout) {
            return handler.next(DioException(
              'Connection timeout. Please check your internet connection.',
              error.requestOptions,
              error.type,
            ));
          }
          
          if (error.type == DioExceptionType.receiveTimeout) {
            return handler.next(DioException(
              'Server response timeout. Please try again.',
              error.requestOptions,
              error.type,
            ));
          }
          
          if (error.type == DioExceptionType.connectionError) {
            return handler.next(DioException(
              'No internet connection. Please check your network.',
              error.requestOptions,
              error.type,
            ));
          }
          
          return handler.next(error);
        },
      ),
    );
  }

  // Set auth token
  void setToken(String token) {
    _token = token;
  }

  // Clear auth token
  void clearToken() {
    _token = null;
  }

  // GET request
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      return await _dio.post(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      return await _dio.put(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  // PATCH request
  Future<Response> patch(String endpoint, {dynamic data}) async {
    try {
      return await _dio.patch(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  // Upload file
  Future<Response> uploadFile(
    String endpoint,
    String filePath,
    String fileName,
    Map<String, dynamic>? data,
  ) async {
    try {
      String uploadFileName = fileName.isNotEmpty ? fileName : filePath.split('/').last;
      FormData formData = FormData.fromMap({
        ...?data,
        'image': await MultipartFile.fromFile(filePath, filename: uploadFileName),
      });

      return await _dio.post(endpoint, data: formData);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Exception _handleError(DioException error) {
    // Handle different HTTP status codes
    if (error.response?.statusCode != null) {
      switch (error.response!.statusCode) {
        case 401:
          return Exception('Unauthorized. Please login again.');
        case 403:
          return Exception('Access forbidden. You don\'t have permission to perform this action.');
        case 404:
          return Exception('Resource not found.');
        case 429:
          return Exception('Too many requests. Please try again later.');
        case 500:
          return Exception('Server error. Please try again later.');
        case 503:
          return Exception('Service unavailable. Please try again later.');
      }
    }

    if (error.response?.data != null && error.response!.data is Map) {
      final message = error.response!.data['message'];
      if (message != null) {
        return Exception(message);
      }
    }
    
    return Exception(error.message ?? 'Unknown API error');
  }
}
