/*
 * Created by zhyilong on 2026/3/23
 * API请求拦截器
 */

import 'package:dio/dio.dart';

/// API拦截器
class ApiInterceptor extends Interceptor {
  /// 基础URL
  final String baseUrl;

  /// 是否开启日志（调试模式）
  final bool enableLog;

  /// 自定义请求头
  final Map<String, String>? headers;

  /// Token获取回调
  final String Function()? tokenProvider;

  ApiInterceptor({
    required this.baseUrl,
    this.enableLog = true,
    this.headers,
    this.tokenProvider,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 设置基础URL
    options.baseUrl = baseUrl;

    // 添加通用请求头
    options.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    });

    // 添加Token
    final token = tokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // 打印请求信息
    if (enableLog) {
      _printRequestLog(options);
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 打印响应信息
    if (enableLog) {
      _printResponseLog(response);
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 打印错误信息
    if (enableLog) {
      _printErrorLog(err);
    }

    super.onError(err, handler);
  }

  /// 打印请求日志
  void _printRequestLog(RequestOptions options) {
    print('════════════════════════════════════════════════════════════');
    print('🚀 请求URL: ${options.uri}');
    print('📝 请求方法: ${options.method}');
    print('📋 请求头: ${options.headers}');
    if (options.data != null) {
      print('📦 请求数据: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      print('🔍 查询参数: ${options.queryParameters}');
    }
    print('════════════════════════════════════════════════════════════');
  }

  /// 打印响应日志
  void _printResponseLog(Response response) {
    print('════════════════════════════════════════════════════════════');
    print('✅ 响应URL: ${response.requestOptions.uri}');
    print('📊 响应状态码: ${response.statusCode}');
    print('📋 响应数据: ${response.data}');
    print('⏱️ 响应耗时: ${response.requestOptions.extra['startTime'] != null ? DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(response.requestOptions.extra['startTime'])).inMilliseconds : 0}ms');
    print('════════════════════════════════════════════════════════════');
  }

  /// 打印错误日志
  void _printErrorLog(DioException err) {
    print('════════════════════════════════════════════════════════════');
    print('❌ 请求错误');
    print('🔗 错误URL: ${err.requestOptions.uri}');
    print('📝 错误类型: ${err.type}');
    print('💬 错误消息: ${err.message}');
    if (err.response != null) {
      print('📊 响应状态码: ${err.response?.statusCode}');
      print('📋 响应数据: ${err.response?.data}');
    }
    print('════════════════════════════════════════════════════════════');
  }
}
