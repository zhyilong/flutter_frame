# PermissionUtil - 权限工具类

一个简单易用的 Flutter 权限管理工具类，基于 `permission_handler` 包封装。

## ✨ 功能特性

- 🎯 **统一接口** - 提供一致的权限检查和请求 API
- 🔒 **多权限支持** - 相机、相册、位置、麦克风、存储等
- 📱 **平台适配** - 自动处理 Android/iOS 差异
- ⚠️ **状态处理** - 完整处理授权、拒绝、永久拒绝等状态
- 🛠️ **批量检查** - 支持一次性检查多个权限
- 📝 **详细回调** - 提供清晰的权限状态和提示信息

## 📦 依赖项

```yaml
dependencies:
  permission_handler: ^12.0.1
```

## 🚀 快速开始

### 1. 基本用法

#### 检查权限（不主动请求）

```dart
import 'package:mvvm_demo/base/utils/permissionUtil.dart';

// 检查相机权限
PermissionUtil.checkCamera(
  (isGrant, message) {
    if (isGrant) {
      print('相机权限已授权');
    } else {
      print('相机权限未授权: $message');
    }
  },
  isRequest: false, // 仅检查，不请求
);
```

#### 检查并请求权限

```dart
// 检查并请求相机权限
PermissionUtil.checkCamera(
  (isGrant, message) {
    if (isGrant) {
      // 权限已授权，执行相关操作
      openScanner();
    } else {
      // 权限未授权
      if (message.contains('永久拒绝')) {
        // 引导用户打开设置
        _showSettingsDialog();
      } else {
        // 显示普通提示
        _showToast(message);
      }
    }
  },
  isRequest: true, // 如果未授权，主动请求
);
```

### 2. 支持的权限类型

| 方法 | 权限类型 | 说明 |
|------|---------|------|
| `checkNetwork()` | 网络权限 | iOS 不需要，Android 需在 AndroidManifest.xml 配置 |
| `checkCamera()` | 相机权限 | 扫码、拍照等功能需要 |
| `checkPhotoalbum()` | 相册权限 | Android 13+ 使用细粒度权限 |
| `checkLocation()` | 位置权限 | 使用 locationWhenInUse（应用使用时） |
| ~~`checkNFC()`~~ | ~~NFC 权限~~ | **已弃用** - permission_handler 12.x 不再支持，请使用 `nfc_manager` 包 |
| `checkMicrophone()` | 麦克风权限 | 录音功能需要 |
| `checkStorage()` | 存储权限 | iOS 不需要（应用沙盒） |

### 3. 批量权限检查

```dart
import 'package:permission_handler/permission_handler.dart';

// 一次性检查多个权限
PermissionUtil.checkMultiple(
  [
    Permission.camera,
    Permission.microphone,
  ],
  (statuses, message) {
    final cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
    final micGranted = statuses[Permission.microphone]?.isGranted ?? false;

    print('相机: $cameraGranted, 麦克风: $micGranted');
  },
  isRequest: true,
);
```

### 4. 打开系统设置

```dart
// 引导用户手动开启权限
final success = await PermissionUtil.openSystemSettings();
if (success) {
  print('已打开系统设置');
}
```

### 5. 工具方法

```dart
// 检查单个权限状态
final status = await PermissionUtil.checkPermissionStatus(Permission.camera);

// 判断权限是否已授权
final granted = await PermissionUtil.isGranted(Permission.camera);

// 判断权限是否被永久拒绝
final permanentlyDenied = await PermissionUtil.isPermanentlyDenied(Permission.camera);
```

## 📖 完整示例

### 示例1：扫码前检查相机权限

```dart
Future<void> openScanner(BuildContext context) async {
  PermissionUtil.checkCamera(
    (isGrant, message) async {
      if (isGrant) {
        // 权限已授权，打开扫码页面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScannerView(
              onScanned: (code) => print('扫描结果: $code'),
            ),
          ),
        );
      } else {
        // 权限未授权
        if (message.contains('永久拒绝')) {
          // 显示对话框，引导用户打开设置
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('权限受限'),
              content: const Text('相机权限被永久拒绝，请前往设置开启'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    PermissionUtil.openSystemSettings();
                  },
                  child: const Text('去设置'),
                ),
              ],
            ),
          );
        } else {
          // 显示普通提示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      }
    },
    isRequest: true,
  );
}
```

### 示例2：选择图片前检查相册权限

```dart
Future<void> pickImage(BuildContext context) async {
  PermissionUtil.checkPhotoalbum(
    (isGrant, message) async {
      if (isGrant) {
        // 权限已授权，打开图片选择器
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        // 处理选中的图片...
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    },
    isRequest: true,
  );
}
```

### 示例3：获取位置前检查权限

```dart
Future<void> getCurrentLocation(BuildContext context) async {
  PermissionUtil.checkLocation(
    (isGrant, message) async {
      if (isGrant) {
        // 权限已授权，获取位置
        // Position position = await Geolocator.getCurrentPosition();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    },
    isRequest: true,
  );
}
```

## 🔧 平台配置

### Android 配置

在 `android/app/src/main/AndroidManifest.xml` 中添加权限：

```xml
<manifest>
    <!-- 相机权限 -->
    <uses-permission android:name="android.permission.CAMERA" />

    <!-- 相册权限 -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />

    <!-- 位置权限 -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

    <!-- 麦克风权限 -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />

    <!-- NFC 权限（已弃用，请使用 nfc_manager 包） -->
    <!-- <uses-permission android:name="android.permission.NFC" /> -->

    <!-- 存储权限（Android 12 及以下） -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

    <application ...>
        ...
    </application>
</manifest>
```

### iOS 配置

在 `ios/Runner/Info.plist` 中添加权限说明：

```xml
<key>NSCameraUsageDescription</key>
<string>需要使用相机扫描二维码</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册选择图片</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>需要保存图片到相册</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>需要获取您的位置信息</string>

<key>NSMicrophoneUsageDescription</key>
<string>需要使用麦克风录音</string>

<!-- NFC 权限（已弃用，请使用 nfc_manager 包） -->
<!-- <key>NFCReaderUsageDescription</key> -->
<!-- <string>需要使用NFC功能</string> -->
```

在 `ios/Podfile` 中配置权限（可选）：

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CAMERA=1',
        'PERMISSION_PHOTOS=1',
        'PERMISSION_LOCATION=1',
        'PERMISSION_MICROPHONE=1',
      ]
    end
  end
end
```

## 📋 权限状态说明

| 状态 | 说明 | 建议处理 |
|------|------|---------|
| `isGranted` | 已授权 | 继续执行功能 |
| `isDenied` | 拒绝 | 显示权限请求对话框 |
| `isPermanentlyDenied` | 永久拒绝 | 引导用户打开设置 |
| `isLimited` | 部分授权（iOS） | 可以继续使用 |
| `isRestricted` | 受限（家长控制） | 提示无法使用 |

## 🎯 最佳实践

1. **提前检查权限** - 在需要使用权限的功能前先检查
2. **友好提示** - 向用户解释为什么需要该权限
3. **处理拒绝** - 区分"拒绝"和"永久拒绝"
4. **引导设置** - 永久拒绝时引导用户打开设置
5. **批量请求** - 多个权限可以一次性请求

## ⚠️ 注意事项

1. **Android 13+ 变化**：
   - 相册权限细分为：`READ_MEDIA_IMAGES`、`READ_MEDIA_VIDEO`、`READ_MEDIA_AUDIO`
   - 工具类已自动适配

2. **iOS 特殊处理**：
   - 相册权限支持"部分授权"（选择部分照片）
   - 不需要网络权限和存储权限

3. **永久拒绝**：
   - 用户勾选"不再询问"后，无法再弹出权限请求
   - 必须引导用户到系统设置中手动开启

4. **测试建议**：
   - 在真机上测试权限流程
   - 模拟器可能无法完整测试权限功能

## 📝 更新日志

### v1.0.0 (2026-05-18)
- ✨ 初始版本发布
- 🎯 支持相机、相册、位置、麦克风、存储权限
- 📱 自动适配 Android/iOS 平台差异
- 🔧 批量权限检查功能
- 🛠️ 工具方法：isGranted、isPermanentlyDenied
- 📖 完整的使用示例和文档
- ⚠️ NFC 权限已弃用（permission_handler 12.x 不再支持）

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License
