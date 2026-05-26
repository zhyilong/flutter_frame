/*
 * Created by zhyilong on 2026/3/23
 * BaseResponse 扩展方法
 */

import 'base_response.dart';

/// BaseResponse 扩展方法
extension BaseResponseExtension<T> on BaseResponse<T> {
  /// 成功时回调
  BaseResponse<T> onSuccess(void Function(T data) callback) {
    if (isSuccess && data != null) {
      callback(data!);
    }
    return this;
  }

  /// 失败时回调
  BaseResponse<T> onFailure(void Function(int code, String message) callback) {
    if (isFailure) {
      callback(code, message);
    }
    return this;
  }

  /// 获取数据或默认值
  T getDataOrElse(T defaultValue) {
    return isSuccess ? data! : defaultValue;
  }

  /// 获取数据，如果失败或数据为空则返回 null
  T? get dataOrNull {
    return (isSuccess && data != null) ? data : null;
  }

  /// 判断是否为特定的错误码
  bool hasCode(int errorCode) {
    return code == errorCode;
  }

  /// 判断是否为网络错误（错误码 <= -1000）
  bool get isNetworkError => code <= -1000;

  /// 判断是否为业务错误（错误码 > 0）
  bool get isBusinessError => code > 0;

  /// 判断是否为超时错误
  bool get isTimeout => code == -1001;

  /// 判断是否为连接错误
  bool get isConnectionError => code == -1002;

  /// 判断是否为取消请求
  bool get isCancelled => code == -1004;

  /// 判断是否为 HTTP 错误
  bool get isHttpError => code >= 400 && code < 600;
}
