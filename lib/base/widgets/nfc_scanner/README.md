# NFC Scanner Widget

一个功能完善、易于使用的Flutter NFC扫描组件，支持NFC标签的读取和写入操作。

## 功能特性

- ✅ **NFC标签读取**：支持文本、URL、JSON格式的NDEF记录
- ✅ **NFC标签写入**：支持写入文本、URL、JSON数据到NFC标签
- ✅ **优雅的UI**：底部弹出式面板，流畅的动画效果
- ✅ **脉冲波纹动画**：直观的感应动画效果
- ✅ **自动重试机制**：读取失败自动重试3次
- ✅ **完善的错误处理**：明确的错误类型和友好的错误提示
- ✅ **数据验证**：写入前自动验证数据大小
- ✅ **易于集成**：简单的API，快速集成到现有项目

## 快速开始

### 1. 依赖配置

确保在 `pubspec.yaml` 中已添加以下依赖：

```yaml
dependencies:
  flutter_nfc_kit: ^3.6.2
  permission_handler: ^12.0.1
  logger: ^2.7.0
  fluttertoast: ^9.0.0
```

### 2. 权限配置

#### Android
在 `android/app/src/main/AndroidManifest.xml` 中添加：

```xml
<uses-permission android:name="android.permission.NFC" />
<uses-feature android:name="android.hardware.nfc" android:required="false" />
```

**注意**：Android NFC权限是普通权限，不需要动态请求。但建议在使用前检查NFC是否开启。

#### iOS
在 `ios/Runner/Info.plist` 中添加：

```xml
<key>NFCReaderUsageDescription</key>
<string>需要使用NFC功能读取标签</string>
<key>com.apple.developer.nfc.readersession.formats</key>
<array>
  <string>NDEF</string>
</array>
```

在 `ios/Runner.entitlements` 中添加（如果没有该文件请创建）：

```xml
<key>com.apple.developer.nfc.readersession.formats</key>
<array>
  <string>NDEF</string>
</array>
```

**重要**：
- iOS需要iPhone 7及以上机型支持
- 需要在Xcode中添加"NFC Tag Reading"能力
- 需要在`Signing & Capabilities`中启用Near Field Communication Tag Reading

### 3. 权限检测（可选）

虽然组件内部会自动检测NFC可用性，但你也可以在使用前手动检测：

```dart
import 'package:mvvm_demo/base/widgets/nfc_scanner/nfc_helper.dart';

// 检查NFC是否可用
final isAvailable = await NfcHelper.isNfcAvailable();
if (!isAvailable) {
  // 显示提示：设备不支持NFC或NFC未开启
  return;
}

// 继续使用NFC功能
NfcScannerWidget.show(...);
```

### 4. 导入组件

```dart
import 'package:mvvm_demo/base/widgets/nfc_scanner/nfc_scanner_widget.dart';
import 'package:mvvm_demo/base/widgets/nfc_scanner/nfc_helper.dart';
```

## 使用示例

### 读取NFC标签

```dart
// 简单读取
NfcScannerWidget.show(
  context: context,
  onReadComplete: (result) {
    if (result.success) {
      switch (result.type) {
        case NfcDataType.text:
          print('文本内容: ${result.content}');
          break;
        case NfcDataType.url:
          print('URL: ${result.content}');
          break;
        case NfcDataType.json:
          print('JSON数据: ${result.jsonData}');
          break;
      }
    } else {
      print('读取失败: ${result.error?.message}');
    }
  },
);
```

### 写入文本到NFC标签

```dart
NfcScannerWidget.show(
  context: context,
  title: '写入文本',
  isWriteMode: true,
  writeTextData: 'Hello, NFC!',
  onWriteComplete: (success, error) {
    if (success) {
      print('写入成功');
    } else {
      print('写入失败: ${error?.message}');
    }
  },
);
```

### 写入URL到NFC标签

```dart
NfcScannerWidget.show(
  context: context,
  title: '写入URL',
  isWriteMode: true,
  writeTextData: 'https://github.com',
  onWriteComplete: (success, error) {
    // 处理结果
  },
);
```

### 写入JSON到NFC标签

```dart
final jsonData = {
  'id': '12345',
  'name': '张三',
  'age': 25,
};

// 验证数据大小
if (!NfcHelper.validateJsonSize(jsonData)) {
  print('数据太大，超出NFC标签容量');
  return;
}

NfcScannerWidget.show(
  context: context,
  title: '写入JSON',
  isWriteMode: true,
  writeJsonData: jsonData,
  onWriteComplete: (success, error) {
    // 处理结果
  },
);
```

## API参考

### NfcScannerWidget

#### 参数说明

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `title` | String | 'NFC感应' | 面板标题 |
| `scanningHint` | String | '请将手机靠近NFC标签' | 扫描提示文字 |
| `readingHint` | String | '正在读取...' | 读取提示文字 |
| `writeHint` | String | '正在写入...' | 写入提示文字 |
| `primaryColor` | Color | Colors.cyan | 主题颜色 |
| `height` | double | 340 | 面板高度 |
| `isWriteMode` | bool | false | 是否为写入模式 |
| `writeTextData` | String? | null | 要写入的文本数据 |
| `writeJsonData` | Map<String, dynamic>? | null | 要写入的JSON数据 |
| `showCloseButton` | bool | true | 是否显示关闭按钮 |
| `animationDuration` | Duration | 300ms | 动画时长 |

#### 回调函数

| 回调 | 类型 | 说明 |
|------|------|------|
| `onReadComplete` | Function(NfcReadResult)? | 读取完成回调 |
| `onWriteComplete` | Function(bool success, NfcError? error)? | 写入完成回调 |
| `onClosed` | VoidCallback? | 面板关闭回调 |

### NfcHelper

底层NFC操作类，可以直接调用进行NFC操作。

#### 静态方法

##### `isNfcAvailable()`
检查设备NFC功能是否可用。

```dart
static Future<bool> isNfcAvailable()
```

**返回**：`Future<bool>` - NFC是否可用

##### `read()`
读取NFC标签。

```dart
static Future<NfcReadResult> read({
  Duration timeout = const Duration(seconds: 15),
  int maxRetries = 3,
})
```

**参数**：
- `timeout` - 超时时间，默认15秒
- `maxRetries` - 最大重试次数，默认3次

**返回**：`Future<NfcReadResult>` - 读取结果

##### `writeText()`
写入文本到NFC标签。

```dart
static Future<NfcResult> writeText(
  String text, {
  Duration timeout = const Duration(seconds: 15),
})
```

##### `writeUrl()`
写入URL到NFC标签。

```dart
static Future<NfcResult> writeUrl(
  String url, {
  Duration timeout = const Duration(seconds: 15),
})
```

##### `writeJson()`
写入JSON到NFC标签。

```dart
static Future<NfcResult> writeJson(
  Map<String, dynamic> json, {
  Duration timeout = const Duration(seconds: 15),
})
```

##### `validateJsonSize()`
验证JSON数据大小。

```dart
static bool validateJsonSize(
  Map<String, dynamic> json, {
  int maxSize = 137,
})
```

**参数**：
- `json` - JSON数据
- `maxSize` - 最大字节数，默认137（标准NFC标签容量）

**返回**：`bool` - 是否在容量限制内

##### `getJsonSize()`
获取JSON数据的字节大小。

```dart
static int getJsonSize(Map<String, dynamic> json)
```

**返回**：`int` - 字节大小

## 数据类型

### NfcDataType
NFC数据类型枚举。

```dart
enum NfcDataType {
  text,    // 文本
  url,     // URL
  json,    // JSON
  unknown, // 未知
}
```

### NfcErrorType
NFC错误类型枚举。

```dart
enum NfcErrorType {
  // 权限相关
  nfcNotAvailable,   // 设备不支持NFC
  nfcDisabled,       // NFC未开启
  permissionDenied,  // 权限未授予

  // 操作相关
  readFailed,        // 读取失败
  writeFailed,       // 写入失败
  tagLost,           // 标签丢失
  operationTimeout,  // 操作超时
  maxRetriesExceeded, // 超过最大重试次数

  // 数据相关
  invalidDataFormat, // 数据格式无效
  dataTooLarge,      // 数据太大
  tagTooSmall,       // 标签容量不足

  // 其他
  unknownError,      // 未知错误
}
```

### NfcReadResult
读取结果类。

```dart
class NfcReadResult {
  final NfcDataType type;              // 数据类型
  final String? content;               // 文本/URL内容
  final Map<String, dynamic>? jsonData; // JSON数据
  final NfcError? error;               // 错误信息

  bool get success => error == null;    // 是否成功
  bool get hasError => error != null;  // 是否有错误
}
```

### NfcResult
操作结果类。

```dart
class NfcResult {
  final bool success;      // 是否成功
  final NfcError? error;   // 错误信息
}
```

### NfcError
错误信息类。

```dart
class NfcError {
  final NfcErrorType type;          // 错误类型
  final String message;             // 用户友好的提示信息
  final String? technicalDetails;   // 技术详细信息
  final dynamic originalException;  // 原始异常
}
```

## 错误处理

组件提供了完善的错误处理机制，所有错误都会通过回调返回给调用者。

### 常见错误处理示例

```dart
NfcScannerWidget.show(
  context: context,
  onReadComplete: (result) {
    if (result.hasError) {
      final error = result.error!;
      switch (error.type) {
        case NfcErrorType.nfcDisabled:
          // NFC未开启，引导用户开启
          _showNfcDisabledDialog();
          break;
        case NfcErrorType.nfcNotAvailable:
          // 设备不支持NFC
          _showNfcNotAvailableDialog();
          break;
        case NfcErrorType.operationTimeout:
          // 操作超时
          _showTimeoutDialog();
          break;
        default:
          // 其他错误
          _showErrorDialog(error.message);
      }
    } else {
      // 处理读取成功的数据
    }
  },
);
```

## 注意事项

1. **权限**：确保应用已获得NFC权限，否则无法使用
2. **设备支持**：部分设备可能不支持NFC功能，使用前建议先检查
3. **数据大小**：标准NFC标签容量有限（约137字节），大数据建议使用大容量标签
4. **写入前验证**：建议在写入前使用 `validateJsonSize()` 验证数据大小
5. **超时设置**：根据实际需求调整超时时间，默认15秒
6. **测试**：建议在真机上测试，模拟器不支持NFC功能

## 完整示例

查看 `nfc_scanner_example.dart` 文件获取更多使用示例，包括：
- 基础读取示例
- 文本写入示例
- URL写入示例
- JSON写入示例
- 实际业务场景示例

## 常见问题

### Q: 为什么读取一直失败？
A: 请检查：
1. 设备是否支持NFC
2. NFC功能是否在系统设置中开启
3. 应用是否获得了NFC权限
4. NFC标签是否正常工作

### Q: 可以写入多大的数据？
A: 标准NFC标签容量约137字节，大容量标签可达2KB。建议在写入前验证数据大小。

### Q: 支持哪些NFC标签类型？
A: 支持所有NDEF格式的NFC标签，包括NTAG、MIFARE等常见类型。

### Q: 可以在iOS上使用吗？
A: 可以，但需要iPhone 7及以上机型，且需要在Xcode中配置NFC权限。

## 许可证

MIT License
