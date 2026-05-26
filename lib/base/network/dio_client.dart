/*
 * Created by zhyilong on 2026/3/23
 * Dio网络客户端
 */

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'models/base_response.dart';
import 'models/network_exception.dart';
import 'api_interceptor.dart';

/// 服务配置
class ServiceConfig {
  /// 基础URL
  final String baseUrl;

  /// 连接超时
  final Duration connectTimeout;

  /// 接收超时
  final Duration receiveTimeout;

  /// 发送超时
  final Duration sendTimeout;

  /// 是否启用日志
  final bool enableLog;

  /// 默认请求头
  final Map<String, String>? headers;

  /// Token提供器
  final String Function()? tokenProvider;

  /// 自定义拦截器
  final List<Interceptor>? interceptors;

  const ServiceConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.enableLog = true,
    this.headers,
    this.tokenProvider,
    this.interceptors,
  });

  /// 复制并修改部分配置
  ServiceConfig copyWith({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    bool? enableLog,
    Map<String, String>? headers,
    String Function()? tokenProvider,
    List<Interceptor>? interceptors,
  }) {
    return ServiceConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      enableLog: enableLog ?? this.enableLog,
      headers: headers ?? this.headers,
      tokenProvider: tokenProvider ?? this.tokenProvider,
      interceptors: interceptors ?? this.interceptors,
    );
  }
}

/// 预定义的服务配置
class ServiceConfigs {
  /// 默认配置
  static const defaultConfig = ServiceConfig(baseUrl: 'https://pub.dev');
}

/// Dio网络客户端
class DioClient {
  /// Dio实例
  late final Dio _dio;

  /// 服务配置
  final ServiceConfig config;

  /// 构造函数
  DioClient({required this.config}) {
    _dio = Dio(
      BaseOptions(connectTimeout: config.connectTimeout, receiveTimeout: config.receiveTimeout, sendTimeout: config.sendTimeout, headers: config.headers),
    );

    // 添加API拦截器
    _dio.interceptors.add(ApiInterceptor(baseUrl: config.baseUrl, enableLog: config.enableLog, headers: config.headers, tokenProvider: config.tokenProvider));

    // 添加日志拦截器（可选）
    if (config.enableLog) {
      _dio.interceptors.add(
        PrettyDioLogger(requestHeader: true, requestBody: true, responseBody: true, responseHeader: false, error: true, compact: true, maxWidth: 90),
      );
    }

    // 添加自定义拦截器
    if (config.interceptors != null) {
      _dio.interceptors.addAll(config.interceptors!);
    }
  }

  /// GET请求
  Future<BaseResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    required T Function(dynamic) fromJson,
    int successCode = 0,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

      return _parseResponse<T>(response.data, fromJson, successCode);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// GET请求-返回原始数据
  Future<dynamic> getRaw(String path, {Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters, options: options, cancelToken: cancelToken);
      return response.data;
    } catch (e) {
      if (e is DioException) {
        return {
          'error': true,
          'message': e.message ?? '网络请求失败',
          'type': e.type.toString(),
          'statusCode': e.response?.statusCode,
        };
      }
      return {
        'error': true,
        'message': e.toString(),
      };
    }
  }

  /// POST请求
  Future<BaseResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    required T Function(dynamic) fromJson,
    int successCode = 0,
  }) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

      return _parseResponse<T>(response.data, fromJson, successCode);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// PUT请求
  Future<BaseResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    required T Function(dynamic) fromJson,
    int successCode = 0,
  }) async {
    try {
      final response = await _dio.put(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

      return _parseResponse<T>(response.data, fromJson, successCode);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// DELETE请求
  Future<BaseResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    required T Function(dynamic) fromJson,
    int successCode = 0,
  }) async {
    try {
      final response = await _dio.delete(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

      return _parseResponse<T>(response.data, fromJson, successCode);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// 文件上传
  Future<BaseResponse<T>> upload<T>(
    String path, {
    required File file,
    String? fileName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    required T Function(dynamic) fromJson,
    int successCode = 0,
  }) async {
    try {
      final formData = FormData.fromMap({'file': await MultipartFile.fromFile(file.path, filename: fileName ?? file.path.split('/').last), ...?data});

      final response = await _dio.post(path, data: formData, onSendProgress: onSendProgress);

      return _parseResponse<T>(response.data, fromJson, successCode);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// 文件下载
  Future<BaseResponse<String>> download(String url, String savePath, {ProgressCallback? onReceiveProgress, CancelToken? cancelToken}) async {
    try {
      await _dio.download(url, savePath, onReceiveProgress: onReceiveProgress, cancelToken: cancelToken);

      return BaseResponse<String>(code: 0, message: '下载成功', data: savePath);
    } catch (e) {
      return _handleError<String>(e);
    }
  }

  /// 解析响应数据
  BaseResponse<T> _parseResponse<T>(dynamic responseData, T Function(dynamic) fromJson, int successCode) {
    try {
      // 解析BaseResponse
      final baseResponse = BaseResponse<dynamic>.fromJson(responseData as Map<String, dynamic>, (json) => json);

      // 检查业务状态码
      if (baseResponse.code != successCode) {
        // 业务失败，返回错误响应
        return BaseResponse<T>(code: baseResponse.code, message: baseResponse.message, data: null);
      }

      // 检查数据是否为空
      if (baseResponse.data == null) {
        return BaseResponse<T>(code: baseResponse.code, message: baseResponse.message, data: null);
      }

      // 使用fromJson解析数据
      final parsedData = fromJson(baseResponse.data);

      // 返回成功响应
      return BaseResponse<T>(code: baseResponse.code, message: baseResponse.message, data: parsedData);
    } catch (e) {
      // 解析异常
      return BaseResponse<T>(code: -1, message: '数据解析失败: $e', data: null);
    }
  }

  /// 处理错误
  BaseResponse<T> _handleError<T>(dynamic error) {
    if (error is NetworkException) {
      return BaseResponse<T>(code: error.code ?? -1, message: error.message ?? '未知错误', data: null);
    }

    if (error is DioException) {
      final exception = NetworkException.fromDioError(error);
      return BaseResponse<T>(code: _getErrorCodeFromDioException(error), message: exception.message ?? '网络请求失败', data: null);
    }

    return BaseResponse<T>(code: -1, message: error.toString(), data: null);
  }

  /// 从Dio异常获取错误码
  int _getErrorCodeFromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return -1001; // 超时
      case DioExceptionType.connectionError:
        return -1002; // 网络错误
      case DioExceptionType.badResponse:
        return error.response?.statusCode ?? -1003; // HTTP错误
      case DioExceptionType.cancel:
        return -1004; // 取消
      default:
        return -1; // 未知错误
    }
  }

  /// 获取Dio实例（用于高级用法）
  Dio get dio => _dio;
}
