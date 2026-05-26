# NFC扫描组件 - GIF动画使用指南

## 功能说明

NFC扫描组件现在支持自定义GIF动画。如果没有提供GIF，则使用默认的脉冲动画。

## 使用方式

### 1. 使用默认脉冲动画（无需任何参数）

```dart
NfcScannerWidget.show(
  context: context,
  title: '扫描NFC标签',
  onReadComplete: (result) {
    // 处理读取结果
  },
);
```

### 2. 使用自定义GIF动画

```dart
NfcScannerWidget.show(
  context: context,
  title: '扫描NFC标签',
  gifAnimationAsset: 'assets/animations/nfc_scanning.gif', // GIF资源路径
  gifWidth: 150,  // 可选：GIF宽度（默认120）
  gifHeight: 150, // 可选：GIF高度（默认120）
  onReadComplete: (result) {
    // 处理读取结果
  },
);
```

### 3. 完整示例

```dart
// 读取示例
NfcScannerWidget.show(
  context: context,
  title: '扫描员工卡',
  scanningHint: '请将员工卡靠近手机',
  readingHint: '正在读取员工信息...',
  gifAnimationAsset: 'assets/animations/nfc_scan.gif',
  gifWidth: 180,
  gifHeight: 180,
  primaryColor: Colors.blue,
  onReadComplete: (result) {
    if (result.success) {
      print('读取成功: ${result.content}');
    } else {
      print('读取失败: ${result.error?.message}');
    }
  },
);

// 写入示例
NfcScannerWidget.show(
  context: context,
  title: '写入数据',
  isWriteMode: true,
  writeTextData: 'Hello NFC!',
  gifAnimationAsset: 'assets/animations/nfc_writing.gif',
  gifWidth: 150,
  onWriteComplete: (success, error) {
    if (success) {
      print('写入成功');
    } else {
      print('写入失败: ${error?.message}');
    }
  },
);
```

## GIF资源准备

### 1. 创建assets目录

在项目根目录创建以下结构：
```
assets/
  └── animations/
      ├── nfc_scanning.gif   // 扫描动画
      ├── nfc_writing.gif    // 写入动画
      └── nfc_success.gif    // 成功动画（可选）
```

### 2. 配置pubspec.yaml

```yaml
flutter:
  assets:
    - assets/animations/
```

### 3. 重新运行项目

配置后需要重新运行项目（热重载可能不生效）：
```bash
flutter clean
flutter pub get
flutter run
```

## GIF动画建议

### 尺寸建议
- **推荐尺寸**: 150x150 到 200x200 像素
- **最小尺寸**: 100x100 像素
- **最大尺寸**: 300x300 像素

### 动画时长
- **推荐时长**: 1.5 - 3 秒循环
- **帧率**: 15-30 FPS

### 文件大小
- **推荐大小**: < 500KB
- **最大大小**: < 2MB

### 设计建议
1. 使用简洁的动画效果
2. 避免过多复杂元素
3. 确保循环播放流畅
4. 背景透明或与应用主题色匹配

## 错误处理

组件已内置错误处理：

1. **GIF加载失败**: 自动回退到默认脉冲动画
2. **GIF路径错误**: 显示默认动画并记录错误日志
3. **GIF尺寸过大**: 仍会显示，但可能影响性能

## 优势

### 使用GIF动画的优势
- ✅ 更生动的视觉效果
- ✅ 可以自定义品牌风格
- ✅ 支持复杂的动画效果
- ✅ 无需编写动画代码

### 使用默认动画的优势
- ✅ 无需额外资源
- ✅ 自动适配主题色
- ✅ 性能更好
- ✅ 加载速度更快

## 性能对比

| 特性 | 默认动画 | GIF动画 |
|------|---------|---------|
| 资源占用 | 低 | 中 |
| 加载速度 | 快 | 中 |
| 动画流畅度 | 高 | 取决于GIF质量 |
| 自定义程度 | 低（仅颜色） | 高（完全自定义） |
| 兼容性 | 100% | 100% |

## 完整示例代码

```dart
import 'package:flutter/material.dart';
import 'package:mvvm_demo/base/widgets/nfc_scanner/nfc_scanner_widget.dart';
import 'package:mvvm_demo/base/widgets/nfc_scanner/nfc_helper.dart';

class NfcScanExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('NFC扫描示例')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 使用默认动画
            ElevatedButton(
              onPressed: () => scanWithDefaultAnimation(context),
              child: Text('使用默认动画扫描'),
            ),
            SizedBox(height: 20),

            // 使用GIF动画
            ElevatedButton(
              onPressed: () => scanWithGifAnimation(context),
              child: Text('使用GIF动画扫描'),
            ),
          ],
        ),
      ),
    );
  }

  // 使用默认动画
  void scanWithDefaultAnimation(BuildContext context) {
    NfcScannerWidget.show(
      context: context,
      title: '扫描NFC标签',
      primaryColor: Colors.cyan,
      onReadComplete: (result) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('读取成功: ${result.content}')),
          );
        }
      },
    );
  }

  // 使用GIF动画
  void scanWithGifAnimation(BuildContext context) {
    NfcScannerWidget.show(
      context: context,
      title: '扫描NFC标签',
      gifAnimationAsset: 'assets/animations/nfc_scanning.gif',
      gifWidth: 180,
      gifHeight: 180,
      primaryColor: Colors.blue,
      onReadComplete: (result) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('读取成功: ${result.content}')),
          );
        }
      },
    );
  }
}
```

## 常见问题

### Q: GIF不显示怎么办？
**A**:
1. 确认GIF路径正确
2. 检查pubspec.yaml中是否配置了assets
3. 运行 `flutter clean` 和 `flutter pub get`
4. 重新运行项目（不要用热重载）

### Q: GIF播放卡顿怎么办？
**A**:
1. 优化GIF文件大小
2. 减少GIF帧数
3. 降低GIF分辨率

### Q: 能否使用网络GIF？
**A**: 当前版本只支持本地assets。如需网络GIF，可以修改代码使用`Image.network`代替`Image.asset`。

### Q: GIF循环时有闪烁？
**A**: 已使用`gaplessPlayback: true`参数解决。如果仍有问题，检查GIF本身是否循环流畅。

## 更新日志

### v1.1.0 (2024-05-19)
- ✨ 新增GIF动画支持
- ✨ 新增`gifAnimationAsset`参数
- ✨ 新增`gifWidth`和`gifHeight`参数
- 🐛 修复GIF加载失败时的回退机制
- 📝 完善文档和示例

## 技术支持

如有问题或建议，请提交Issue或Pull Request。
