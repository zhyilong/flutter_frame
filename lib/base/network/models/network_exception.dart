/*
 * Created by zhyilong on 2026/3/23
 * 网络异常处理
 */

import 'package:dio/dio.dart';

/// 网络异常类型
enum NetworkErrorType {
  /// 未知错误
  unknown,

  /// 网络连接错误
  networkError,

  /// 请求超时
  timeout,

  /// 服务器错误（4xx、5xx）
  serverError,

  /// 业务错误（code != 0）
  businessError,

  /// 数据为空
  emptyData,

  /// 取消请求
  cancel,
}

/// 网络异常类
class NetworkException implements Exception {
  /// 错误类型
  final NetworkErrorType type;

  /// 错误码
  final int? code;

  /// 错误消息
  final String? message;

  /// 原始错误
  final dynamic originalError;

  NetworkException({
    required this.type,
    this.code,
    this.message,
    this.originalError,
  });

  /// 从Dio异常创建
  factory NetworkException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          type: NetworkErrorType.timeout,
          message: '请求超时，请检查网络连接',
          originalError: error,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          type: NetworkErrorType.networkError,
          message: '网络连接失败，请检查网络设置',
          originalError: error,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return NetworkException(
          type: NetworkErrorType.serverError,
          code: statusCode,
          message: _getHttpErrorMessage(statusCode),
          originalError: error,
        );

      case DioExceptionType.cancel:
        return NetworkException(
          type: NetworkErrorType.cancel,
          message: '请求已取消',
          originalError: error,
        );

      case DioExceptionType.unknown:
      default:
        return NetworkException(
          type: NetworkErrorType.unknown,
          message: '未知错误：${error.message}',
          originalError: error,
        );
    }
  }

  /// 从通用错误创建
  factory NetworkException.fromError(dynamic error) {
    if (error is NetworkException) {
      return error;
    }
    if (error is DioException) {
      return NetworkException.fromDioError(error);
    }
    return NetworkException(
      type: NetworkErrorType.unknown,
      message: error.toString(),
      originalError: error,
    );
  }

  /// 创建业务异常
  factory NetworkException.businessError({
    required int code,
    required String message,
  }) {
    return NetworkException(
      type: NetworkErrorType.businessError,
      code: code,
      message: message,
    );
  }

  /// 创建数据为空异常
  factory NetworkException.emptyData({String message = '响应数据为空'}) {
    return NetworkException(
      type: NetworkErrorType.emptyData,
      message: message,
    );
  }

  /// 获取HTTP错误消息
  static String _getHttpErrorMessage(int? statusCode) {
    if (statusCode == null) {
      return '服务器响应异常';
    }
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请重新登录';
      case 403:
        return '拒绝访问';
      case 404:
        return '请求资源不存在';
      case 405:
        return '请求方法不允许';
      case 500:
        return '服务器内部错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务不可用';
      case 504:
        return '网关超时';
      default:
        return 'HTTP错误: $statusCode';
    }
  }

  /// 是否为网络错误
  bool get isNetworkError => type == NetworkErrorType.networkError;

  /// 是否为超时错误
  bool get isTimeout => type == NetworkErrorType.timeout;

  /// 是否为业务错误
  bool get isBusinessError => type == NetworkErrorType.businessError;

  /// 是否为服务器错误
  bool get isServerError => type == NetworkErrorType.serverError;

  @override
  String toString() {
    return 'NetworkException{type: $type, code: $code, message: $message}';
  }
}
