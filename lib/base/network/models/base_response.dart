/*
 * Created by zhyilong on 2026/3/23
 * 统一响应模型
 */

import 'package:json_annotation/json_annotation.dart';

part 'base_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class BaseResponse<T> {
  /// 业务状态码，0表示成功
  final int code;

  /// 响应消息
  final String message;

  /// 响应数据
  final T? data;

  BaseResponse({
    required this.code,
    required this.message,
    this.data,
  });

  /// 从JSON创建实例
  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$BaseResponseFromJson(json, fromJsonT);

  /// 转换为JSON
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$BaseResponseToJson(this, toJsonT);

  /// 判断请求是否成功
  bool get isSuccess => code == 0;

  /// 判断请求是否失败
  bool get isFailure => code != 0;

  @override
  String toString() {
    return 'BaseResponse{code: $code, message: $message, data: $data}';
  }
}
