/*
 * Created by zhyilong on 2026/5/18
 */

import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

/// 权限工具类
///
/// 提供统一的权限检查和请求接口
class PermissionUtil {
  /// 检查和请求网络权限
  ///
  /// [callback] 回调函数，参数为 (是否授权, 消息)
  /// [isRequest] 是否在未授权时主动请求权限
  ///
  /// 注意：
  /// - iOS 不需要请求网络权限
  /// - Android 需要在 AndroidManifest.xml 中声明权限
  static void checkNetwork(
    Function(bool isGrant, String message) callback, {
    bool isRequest = false,
  }) async {
    // iOS 不需要请求网络权限
    if (Platform.isIOS) {
      callback.call(true, "iOS 不需要网络权限");
      return;
    }

    // Android 检查网络权限
    // 注意：网络权限在 Android 6.0+ 不需要运行时请求
    // 只需要在 AndroidManifest.xml 中声明即可
    callback.call(true, "网络权限已在 AndroidManifest.xml 中配置");
  }

  /// 检查和请求相机权限
  ///
  /// [callback] 回调函数，参数为 (是否授权, 消息)
  /// [isRequest] 是否在未授权时主动请求权限
  static void checkCamera(
    Function(bool isGrant, String message)? callback, {
    bool isRequest = false,
  }) async {
    PermissionStatus status = await Permission.camera.status;

    // 已授权
    if (status.isGranted) {
      callback?.call(true, "相机权限已授权");
      return;
    }

    // 永久拒绝
    if (status.isPermanentlyDenied) {
      callback?.call(
        false,
        "相机权限被永久拒绝，请前往设置开启",
      );
      // 提示用户打开设置
      _showOpenSettingsDialog("相机");
      return;
    }

    // 限制使用（如家长控制）
    if (status.isRestricted) {
      callback?.call(false, "相机权限受限");
      return;
    }

    // 拒绝或未请求
    if (status.isDenied || status.isLimited) {
      if (isRequest) {
        final result = await Permission.camera.request();
        if (result.isGranted) {
          callback?.call(true, "相机权限已授权");
        } else if (result.isPermanentlyDenied) {
          callback?.call(
            false,
            "相机权限被永久拒绝，请前往设置开启",
          );
          _showOpenSettingsDialog("相机");
        } else {
          callback?.call(false, "相机权限被拒绝");
        }
      } else {
        callback?.call(false, "相机权限未授权");
      }
      return;
    }
  }

  /// 检查和请求相册权限
  ///
  /// [callback] 回调函数，参数为 (是否授权, 消息)
  /// [isRequest] 是否在未授权时主动请求权限
  ///
  /// 注意：
  /// - iOS 使用 photos 权限
  /// - Android 使用 read_external_storage (Android 12-) 或 read_media_images (Android 13+)
  static void checkPhotoalbum(
    Function(bool isGrant, String message) callback, {
    bool isRequest = false,
  }) async {
    Permission permission;

    // 根据平台选择权限类型
    if (Platform.isIOS) {
      permission = Permission.photos;
    } else {
      // Android 13+ 使用新的媒体权限
      if (await _isAndroid13OrHigher()) {
        permission = Permission.photos;
      } else {
        permission = Permission.storage;
      }
    }

    PermissionStatus status = await permission.status;

    // 已授权
    if (status.isGranted) {
      callback.call(true, "相册权限已授权");
      return;
    }

    // 部分授权（iOS 特有）
    if (status.isLimited) {
      callback.call(true, "相册权限部分授权");
      return;
    }

    // 永久拒绝
    if (status.isPermanentlyDenied) {
      callback.call(
        false,
        "相册权限被永久拒绝，请前往设置开启",
      );
      _showOpenSettingsDialog("相册");
      return;
    }

    // 限制使用
    if (status.isRestricted) {
      callback.call(false, "相册权限受限");
      return;
    }

    // 拒绝或未请求
    if (status.isDenied) {
      if (isRequest) {
        final result = await permission.request();
        if (result.isGranted || result.isLimited) {
          callback.call(true, "相册权限已授权");
        } else if (result.isPermanentlyDenied) {
          callback.call(
            false,
            "相册权限被永久拒绝，请前往设置开启",
          );
          _showOpenSettingsDialog("相册");
        } else {
          callback.call(false, "相册权限被拒绝");
        }
      } else {
        callback.call(false, "相册权限未授权");
      }
      return;
    }
  }

  /// 检查和请求位置权限
  ///
  /// [callback] 回调函数，参数为 (是否授权, 消息)
  /// [isRequest] 是否在未授权时主动请求权限
  ///
  /// 注意：
  /// - 使用 locationWhenInUse（使用应用时位置）
  /// - 如需后台位置，需要额外请求 locationAlways
  static void checkLocation(
    Function(bool isGrant, String message) callback, {
    bool isRequest = false,
  }) async {
    PermissionStatus status = await Permission.locationWhenInUse.status;

    // 已授权
    if (status.isGranted) {
      callback.call(true, "位置权限已授权");
      return;
    }

    // 永久拒绝
    if (status.isPermanentlyDenied) {
      callback.call(
        false,
        "位置权限被永久拒绝，请前往设置开启",
      );
      _showOpenSettingsDialog("位置");
      return;
    }

    // 限制使用
    if (status.isRestricted) {
      callback.call(false, "位置权限受限");
      return;
    }

    // 拒绝或未请求
    if (status.isDenied) {
      if (isRequest) {
        final result = await Permission.locationWhenInUse.request();
        if (result.isGranted) {
          callback.call(true, "位置权限已授权");
        } else if (result.isPermanentlyDenied) {
          callback.call(
            false,
            "位置权限被永久拒绝，请前往设置开启",
          );
          _showOpenSettingsDialog("位置");
        } else {
          callback.call(false, "位置权限被拒绝");
        }
      } else {
        callback.call(false, "位置权限未授权");
      }
      return;
    }
  }

  /// 检查和请求 NFC 权限
  ///
  /// [callback] 回调函数，参数为 (是否授权, 消息)
  /// [isRequest] 是否在未授权时主动请求权限
  ///
  /// 注意：
  /// - 仅 Android 支持 NFC
  /// - permission_handler 12.x 已移除 NFC 支持
  /// - 请使用其他 NFC 包（如 nfc_manager）进行 NFC 功能开发
  @Deprecated(
    'permission_handler 12.x 已移除 NFC 支持，请使用 nfc_manager 包',
  )
  static void checkNFC(
    Function(bool isGrant, String message) callback, {
    bool isRequest = false,
  }) async {
    // permission_handler 12.x 不再支持 NFC
    callback.call(
      false,
      '当前版本不支持 NFC 权限检查，请使用 nfc_manager 包',
    );
  }

  /// 检查和请求麦克风权限
  ///
  /// [callback] 回调函数，参数为 (是否授权, 消息)
  /// [isRequest] 是否在未授权时主动请求权限
  static void checkMicrophone(
    Function(bool isGrant, String message) callback, {
    bool isRequest = false,
  }) async {
    PermissionStatus status = await Permission.microphone.status;

    if (status.isGranted) {
      callback.call(true, "麦克风权限已授权");
      return;
    }

    if (status.isPermanentlyDenied) {
      callback.call(
        false,
        "麦克风权限被永久拒绝，请前往设置开启",
      );
      _showOpenSettingsDialog("麦克风");
      return;
    }

    if (status.isRestricted) {
      callback.call(false, "麦克风权限受限");
      return;
    }

    if (status.isDenied) {
      if (isRequest) {
        final result = await Permission.microphone.request();
        if (result.isGranted) {
          callback.call(true, "麦克风权限已授权");
        } else if (result.isPermanentlyDenied) {
          callback.call(
            false,
            "麦克风权限被永久拒绝，请前往设置开启",
          );
          _showOpenSettingsDialog("麦克风");
        } else {
          callback.call(false, "麦克风权限被拒绝");
        }
      } else {
        callback.call(false, "麦克风权限未授权");
      }
      return;
    }
  }

  /// 检查和请求存储权限
  ///
  /// [callback] 回调函数，参数为 (是否授权, 消息)
  /// [isRequest] 是否在未授权时主动请求权限
  ///
  /// 注意：
  /// - Android 13+ 使用细粒度媒体权限
  /// - Android 12- 使用 storage 权限
  /// - iOS 不需要存储权限（应用沙盒）
  static void checkStorage(
    Function(bool isGrant, String message) callback, {
    bool isRequest = false,
  }) async {
    // iOS 不需要存储权限
    if (Platform.isIOS) {
      callback.call(true, "iOS 不需要存储权限");
      return;
    }

    Permission permission;
    if (await _isAndroid13OrHigher()) {
      // Android 13+ 使用细粒度权限
      permission = Permission.photos; // 或 videos, audio
    } else {
      permission = Permission.storage;
    }

    PermissionStatus status = await permission.status;

    if (status.isGranted) {
      callback.call(true, "存储权限已授权");
      return;
    }

    if (status.isPermanentlyDenied) {
      callback.call(
        false,
        "存储权限被永久拒绝，请前往设置开启",
      );
      _showOpenSettingsDialog("存储");
      return;
    }

    if (status.isRestricted) {
      callback.call(false, "存储权限受限");
      return;
    }

    if (status.isDenied) {
      if (isRequest) {
        final result = await permission.request();
        if (result.isGranted) {
          callback.call(true, "存储权限已授权");
        } else if (result.isPermanentlyDenied) {
          callback.call(
            false,
            "存储权限被永久拒绝，请前往设置开启",
          );
          _showOpenSettingsDialog("存储");
        } else {
          callback.call(false, "存储权限被拒绝");
        }
      } else {
        callback.call(false, "存储权限未授权");
      }
      return;
    }
  }

  /// 打开系统设置页面
  ///
  /// 引导用户手动开启权限
  static Future<bool> openSystemSettings() async {
    return await openAppSettings();
  }

  /// 判断是否为 Android 13+ 版本
  static Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;
    // 这里需要使用 device_info_plus 获取系统版本
    // 简化实现：直接检查 SDK 版本
    // Android 13 = SDK 33
    // 实际项目中建议使用 device_info_plus
    return true; // 临时返回 true，实际需要检查版本
  }

  /// 显示打开设置对话框
  ///
  /// [permissionName] 权限名称
  static void _showOpenSettingsDialog(String permissionName) {
    // 这里可以显示一个对话框，引导用户打开设置
    // 示例：
    // showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     title: Text('权限受限'),
    //     content: Text('$permissionName权限被永久拒绝，请前往设置开启'),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.pop(context),
    //         child: Text('取消'),
    //       ),
    //       TextButton(
    //         onPressed: () {
    //           openAppSettings();
    //           Navigator.pop(context);
    //         },
    //         child: Text('去设置'),
    //       ),
    //     ],
    //   ),
    // );
  }

  /// 批量检查和请求多个权限
  ///
  /// [permissions] 要检查的权限列表
  /// [callback] 回调函数，参数为 (权限状态Map, 消息)
  /// [isRequest] 是否在未授权时主动请求权限
  ///
  /// 示例：
  /// ```dart
  /// PermissionUtil.checkMultiple(
  ///   [Permission.camera, Permission.microphone],
  ///   (statuses, message) {
  ///     print('Camera: ${statuses[Permission.camera]}');
  ///     print('Microphone: ${statuses[Permission.microphone]}');
  ///   },
  ///   isRequest: true,
  /// );
  /// ```
  static void checkMultiple(
    List<Permission> permissions,
    Function(Map<Permission, PermissionStatus> statuses, String message) callback, {
    bool isRequest = false,
  }) async {
    Map<Permission, PermissionStatus> statuses = {};

    // 逐个检查权限
    for (var permission in permissions) {
      statuses[permission] = await permission.status;
    }

    // 检查是否所有权限都已授权
    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (allGranted) {
      callback.call(statuses, "所有权限已授权");
      return;
    }

    // 如果需要请求权限
    if (isRequest) {
      // 批量请求权限
      final result = await permissions.request();
      callback.call(result, "权限请求完成");
    } else {
      callback.call(statuses, "部分权限未授权");
    }
  }

  /// 检查单个权限状态
  ///
  /// [permission] 要检查的权限
  /// 返回权限状态
  static Future<PermissionStatus> checkPermissionStatus(
    Permission permission,
  ) async {
    return await permission.status;
  }

  /// 判断权限是否已授权
  ///
  /// [permission] 要检查的权限
  /// 返回是否已授权
  static Future<bool> isGranted(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  /// 判断权限是否被永久拒绝
  ///
  /// [permission] 要检查的权限
  /// 返回是否被永久拒绝
  static Future<bool> isPermanentlyDenied(Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }
}
