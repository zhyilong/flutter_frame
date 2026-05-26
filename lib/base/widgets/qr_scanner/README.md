# Scanner

一个强大的 Flutter 扫码组件，支持二维码和条形码扫描，提供完整的页面和可嵌入的 Widget 两种使用方式。

## ✨ 功能特性

### ScannerView（全屏页面）
- 📷 **全屏扫码** - 独立的扫码页面，完整的用户体验
- 🔦 **闪光灯控制** - 支持开启/关闭闪光灯
- 🔄 **摄像头切换** - 支持前后摄像头切换
- 🎨 **自定义样式** - 可自定义扫描框颜色、提示文本等
- 📳 **震动反馈** - 扫码成功时提供震动反馈
- ⚡ **防重复扫描** - 扫码成功后自动暂停，避免重复触发

### ScannerWidget（可嵌入组件）
- 🧩 **灵活嵌入** - 可嵌入到现有页面中
- 🎯 **连续扫描** - 支持连续扫描模式
- 🖼️ **自定义覆盖层** - 支持自定义扫描框样式
- 🎛️ **控制器封装** - 提供简化的控制器接口

## 📦 依赖项

### 必需依赖

```yaml
dependencies:
  # 扫码核心库
  mobile_scanner: ^7.2.0
```

### 依赖说明

| 依赖包 | 版本 | 作用 |
|--------|------|------|
| **mobile_scanner** | ^7.2.0 | 核心功能，提供扫码能力 |
| | | `MobileScanner` - 扫码视图组件 |
| | | `MobileScannerController` - 控制器，管理扫码行为 |
| | | 支持二维码、条形码等多种格式 |

## 📥 安装

1. 确保在 `pubspec.yaml` 中添加了依赖：

```yaml
dependencies:
  mobile_scanner: ^7.2.0
```

2. 安装依赖：

```bash
flutter pub get
```

3. 将组件文件复制到项目中：

```
lib/base/widgets/qr_scanner/
├── scanner_view.dart
├── scanner_widget.dart
└── example_usage.dart
```

4. 配置权限（必需）

### Android 配置

在 `android/app/src/main/AndroidManifest.xml` 中添加：

```xml
<manifest>
    <!-- 相机权限 -->
    <uses-permission android:name="android.permission.CAMERA" />

    <application>
        ...
    </application>
</manifest>
```

Android 10+ 需要声明相机功能（在 `<application>` 标签内）：

```xml
<application>
    <meta-data
        android:name="com.google.mlkit.vision.DEPENDENCIES"
        android:value="barcode" />
</application>
```

### iOS 配置

在 `ios/Runner/Info.plist` 中添加：

```xml
<key>NSCameraUsageDescription</key>
<string>需要使用相机扫描二维码</string>
```

在 `ios/Podfile` 中取消注释相机权限（如果需要）：

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CAMERA=1',
      ]
    end
  end
end
```

## 🚀 使用方法

### 方式一：使用 ScannerView（全屏页面）

```dart
import 'package:flutter/material.dart';
import 'package:your_app/base/widgets/qr_scanner/scanner_view.dart';

// 跳转到扫码页面
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ScannerView(
      onScanned: (code) {
        // 处理扫描结果
        print('扫描结果: $code');
        // 可以在这里处理扫码结果，比如解析URL、验证码等
        Navigator.pop(context); // 扫码完成后返回
      },
      // 可选参数
      scanLineColor: Colors.cyan,        // 扫描框颜色
      showFlashlightButton: true,        // 显示闪光灯按钮
      showCameraSwitchButton: true,      // 显示摄像头切换按钮
      scanTipText: '将二维码/条形码放入框内，即可自动扫描',
      title: '扫一扫',
    ),
  ),
);
```

### 方式二：使用 ScannerWidget（嵌入页面）

```dart
import 'package:flutter/material.dart';
import 'package:your_app/base/widgets/scanner/scanner_widget.dart';

class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('扫码示例')),
      body: Column(
        children: [
          // 其他内容
          const Text('上方是其他内容'),

          // 嵌入扫码组件
          Expanded(
            child: ScannerWidget(
              onScanned: (code) {
                print('扫描结果: $code');
                // 处理扫描结果
              },
              // 可选参数
              scanLineColor: Colors.cyan,
              showOverlay: true,               // 显示扫描框
              continuousScan: false,           // 非连续扫描
              overlayBuilder: null,            // 使用默认覆盖层
            ),
          ),
        ],
      ),
    );
  }
}
```

### 方式三：连续扫描模式

```dart
ScannerWidget(
  onScanned: (code) {
    print('连续扫描: $code');
    // 扫码后会自动继续扫描，无需等待
  },
  continuousScan: true,  // 开启连续扫描
)
```

### 方式四：自定义覆盖层

```dart
ScannerWidget(
  onScanned: (code) {
    print('扫描结果: $code');
  },
  overlayBuilder: CustomOverlay(),  // 自定义覆盖层
)

// 自定义覆盖层示例
class CustomOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: const Center(
        child: Text(
          '自定义扫描框',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
```

## 📖 API 文档

### ScannerView

全屏扫码页面组件。

#### 参数

| 参数 | 类型 | 必需 | 默认值 | 说明 |
|------|------|------|--------|------|
| `onScanned` | `Function(String code)` | ✅ | - | 扫码成功回调，返回扫描到的字符串 |
| `scanLineColor` | `Color` | ❌ | `Colors.cyan` | 扫描框颜色 |
| `showFlashlightButton` | `bool` | ❌ | `true` | 是否显示闪光灯按钮 |
| `showCameraSwitchButton` | `bool` | ❌ | `true` | 是否显示摄像头切换按钮 |
| `scanTipText` | `String` | ❌ | `'将二维码/条形码放入框内，即可自动扫描'` | 扫描提示文本 |
| `title` | `String` | ❌ | `'扫一扫'` | 页面标题 |

### ScannerWidget

可嵌入的扫码 Widget 组件。

#### 参数

| 参数 | 类型 | 必需 | 默认值 | 说明 |
|------|------|------|--------|------|
| `onScanned` | `Function(String code)` | ✅ | - | 扫码成功回调 |
| `scanLineColor` | `Color` | ❌ | `Colors.cyan` | 扫描框颜色 |
| `showOverlay` | `bool` | ❌ | `true` | 是否显示扫描框覆盖层 |
| `continuousScan` | `bool` | ❌ | `false` | 扫描成功后是否自动继续扫描 |
| `overlayBuilder` | `Widget?` | ❌ | `null` | 自定义覆盖层 Widget |

### ScannerControllerWrapper

扫码控制器封装（预留接口，当前版本暂未在 ScannerWidget 中暴露）。

#### 方法

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `toggleTorch()` | - | `void` | 切换闪光灯 |
| `switchCamera()` | - | `void` | 切换摄像头 |
| `analyzeImage()` | `String path` | `void` | 分析图片中的二维码 |

## 💡 完整示例

查看 `example_usage.dart` 文件获取完整的使用示例，包括：

1. 全屏扫码页面示例
2. 嵌入式扫码组件示例
3. 连续扫描模式示例
4. 自定义覆盖层示例
5. 处理扫描结果的完整流程

## 🎯 核心实现原理

### ScannerView 实现原理

```
ScannerView (StatefulWidget)
├── MobileScannerController - 控制器
│   ├── toggleTorch() - 切换闪光灯
│   └── switchCamera() - 切换摄像头
├── MobileScanner - 扫码视图
│   ├── onDetect - 扫码回调
│   └── overlay - 扫描框覆盖层
└── Stack - 界面布局
    ├── MobileScanner - 扫码视图（底层）
    ├── 提示文本（顶层）
    └── 控制按钮（底部）
```

### 防重复扫描机制

```dart
// 使用状态标记防止重复扫描
bool _isScanning = true;

void _onDetect(BarcodeCapture capture) {
  if (!_isScanning) return;  // 如果正在扫描中，直接返回

  final code = barcode.rawValue!;
  _isScanning = false;  // 暂停扫描
  widget.onScanned(code);  // 回调结果

  // 2秒后恢复扫描
  Future.delayed(const Duration(seconds: 2), () {
    if (mounted) {
      setState(() {
        _isScanning = true;
      });
    }
  });
}
```

### 扫描框绘制

使用 `CustomPainter` 绘制四个角落的边框：

```dart
class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 绘制四个角落的L形边框
    // 每个角落由两条线段组成
    // cornerLength 控制边框长度
  }
}
```

## 📌 注意事项

1. **权限申请**：
   - Android: 需要在 `AndroidManifest.xml` 中声明相机权限
   - iOS: 需要在 `Info.plist` 中添加相机使用说明
   - 建议使用 `permission_handler` 包在运行时动态申请权限

2. **支持的码制**：
   - QR Code（二维码）
   - BarCode（条形码）
   - Code 128、Code 39、EAN-13、UPC-A 等多种格式

3. **性能优化**：
   - 扫码成功后建议暂停扫描或返回页面
   - 避免长时间占用摄像头资源
   - 使用 `continuousScan: false` 可自动暂停扫描

4. **错误处理**：
   - 设备不支持相机时会报错，建议添加 try-catch
   - 用户拒绝权限时需要提示并引导开启权限

5. **扫码结果处理**：
   - 建议验证扫码结果的有效性
   - 对于 URL，可以使用 `url_launcher` 打开
   - 对于文本，可以复制到剪贴板或进行业务处理

## 🐛 常见问题

### Q: 如何申请相机权限？

A: 建议使用 `permission_handler` 包：

```yaml
dependencies:
  permission_handler: ^11.0.0
```

```dart
import 'package:permission_handler/permission_handler.dart';

// 请求权限
Future<void> requestCameraPermission() async {
  final status = await Permission.camera.request();
  if (status.isGranted) {
    // 权限已授予，可以打开扫码页面
  } else {
    // 权限被拒绝，提示用户
  }
}
```

### Q: 扫码成功后如何关闭页面？

A: 在 `onScanned` 回调中调用 `Navigator.pop()`：

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ScannerView(
      onScanned: (code) {
        // 处理扫描结果
        print('扫描结果: $code');
        // 返回上一页
        Navigator.pop(context, code);
      },
    ),
  ),
);
```

### Q: 如何处理扫码结果？

A: 根据业务需求处理：

```dart
onScanned: (code) {
  // 1. 判断是否为URL
  if (code.startsWith('http')) {
    // 打开URL
    launchUrl(Uri.parse(code));
  }
  // 2. 判断是否为特定格式
  else if (code.startsWith('PRODUCT:')) {
    // 解析商品码
    final productId = code.substring(8);
    // 跳转到商品详情页
  }
  // 3. 其他情况
  else {
    // 显示结果或复制到剪贴板
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板')),
    );
  }
}
```

### Q: 如何自定义扫描框样式？

A: 修改 `scanner_view.dart` 中的 `_ScanOverlayPainter`：

```dart
@override
void paint(Canvas canvas, Size size) {
  final paint = Paint()
    ..color = scanLineColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;  // 修改线条宽度

  // 修改扫描框大小
  final scanSize = size.width * 0.8;  // 改为 80%

  // 修改边框长度
  final cornerLength = scanSize * 0.3;  // 改为 30%
}
```

### Q: 支持从相册选择图片识别吗？

A: `mobile_scanner` 支持从图片中识别二维码，可以使用 `image_picker` 选择图片后调用 `analyzeImage()` 方法。

## 📝 更新日志

### v1.0.0 (2026-05-18)
- ✨ 初始版本发布
- 📷 全屏扫码页面 `ScannerView`
- 🧩 可嵌入的扫码组件 `ScannerWidget`
- 🔦 闪光灯控制
- 🔄 摄像头切换
- 📳 震动反馈
- ⚡ 防重复扫描机制
- 🎨 自定义扫描框样式

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

**开发者提示**：查看 `example_usage.dart` 获取更多使用示例。
