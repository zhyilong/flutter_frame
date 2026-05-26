# ImageViewer

一个强大的 Flutter 图片查看器组件，支持多张网络图片浏览、双指缩放、手势拖动和页面切换。

## ✨ 功能特性

- 🔍 **双指缩放** - 支持 0.5x 到 3x 的缩放范围
- 👆 **拖动查看** - 图片放大后可自由拖动查看细节
- ⬅️➡️ **滑动翻页** - 左右滑动切换图片
- 🎯 **无手势冲突** - 使用 PhotoViewGallery 智能处理手势，缩放和翻页完美配合
- 💾 **自动缓存** - 集成 CachedNetworkImage，自动缓存已加载的图片
- 🎨 **多点指示器** - 底部显示当前页面位置，带有流畅动画
- 🖱️ **点击关闭** - 点击背景任意位置即可关闭查看器
- 🌐 **网络图片** - 支持加载网络图片，带加载状态和错误处理

## 📦 依赖项

### 必需依赖

```yaml
dependencies:
  # 图片查看器核心库
  photo_view: ^0.15.0

  # 网络图片缓存
  cached_network_image: ^3.4.1
```

### 依赖说明

| 依赖包 | 版本 | 作用 |
|--------|------|------|
| **photo_view** | ^0.15.0 | 核心功能，提供图片缩放、拖动、手势处理等能力 |
| | | `PhotoViewGallery` - 解决手势冲突，智能分发缩放和翻页手势 |
| | | `PhotoViewComputedScale` - 提供预定义的缩放比例 |
| **cached_network_image** | ^3.4.1 | 网络图片加载和缓存 |
| | | `CachedNetworkImageProvider` - 作为 ImageProvider 提供给 PhotoView |
| | | 自动缓存已加载的图片，提升性能和用户体验 |

## 📥 安装

1. 确保在 `pubspec.yaml` 中添加了依赖：

```yaml
dependencies:
  photo_view: ^0.15.0
  cached_network_image: ^3.4.1
```

2. 安装依赖：

```bash
flutter pub get
```

3. 将组件文件复制到项目中：

```
lib/common/widgets/imageViewer/
├── image_viewer_page.dart
├── image_viewer.dart
└── example_usage.dart
```

## 🚀 使用方法

### 方式一：直接跳转到查看器页面

```dart
import 'package:your_app/common/widgets/imageViewer/image_viewer_page.dart';

// 准备图片列表
final List<String> imageUrls = [
  'https://example.com/image1.jpg',
  'https://example.com/image2.jpg',
  'https://example.com/image3.jpg',
];

// 跳转到查看器
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ImageViewerPage(
      imageUrls: imageUrls,
      initialIndex: 0,  // 可选：从第几张开始，默认为 0
      backgroundColor: Colors.black,  // 可选：背景色，默认为黑色
      indicatorColor: Colors.white,  // 可选：指示器颜色，默认为白色
    ),
  ),
);
```

### 方式二：使用 ImageViewer 工具类（推荐）

```dart
import 'package:your_app/common/widgets/imageViewer/image_viewer.dart';

// 基础用法（对话框模式，默认）
ImageViewer.show(
  context,
  imageUrls: imageUrls,
  initialIndex: 0,
);

// 路由模式
ImageViewer.show(
  context,
  imageUrls: imageUrls,
  mode: ImageViewerMode.route,
);

// 从指定图片开始查看
ImageViewer.showFromUrl(
  context,
  imageUrls: imageUrls,
  imageUrl: imageUrls[2],  // 从第三张图片开始
  backgroundColor: Colors.black,
  indicatorColor: Colors.white,
);
```

## 📖 API 文档

### ImageViewerPage

全屏图片查看器页面组件。

#### 参数

| 参数 | 类型 | 必需 | 默认值 | 说明 |
|------|------|------|--------|------|
| `imageUrls` | `List<String>` | ✅ | - | 图片 URL 列表 |
| `initialIndex` | `int` | ❌ | `0` | 初始显示的图片索引 |
| `backgroundColor` | `Color` | ❌ | `Colors.black` | 背景颜色 |
| `indicatorColor` | `Color` | ❌ | `Colors.white` | 页面指示器颜色 |

### ImageViewer

图片查看器工具类，提供便捷的方法来显示全屏图片查看器。

支持对话框和路由两种显示模式。

#### 静态方法

##### show()

显示图片查看器。

```dart
static void show(
  BuildContext context, {
  required List<String> imageUrls,
  int initialIndex = 0,
  Color backgroundColor = Colors.black,
  Color indicatorColor = Colors.white,
  ImageViewerMode mode = ImageViewerMode.dialog,
})
```

**参数：**

| 参数 | 类型 | 必需 | 默认值 | 说明 |
|------|------|------|--------|------|
| `context` | `BuildContext` | ✅ | - | 上下文 |
| `imageUrls` | `List<String>` | ✅ | - | 图片 URL 列表 |
| `initialIndex` | `int` | ❌ | `0` | 初始显示的图片索引 |
| `backgroundColor` | `Color` | ❌ | `Colors.black` | 背景颜色 |
| `indicatorColor` | `Color` | ❌ | `Colors.white` | 指示器颜色 |
| `mode` | `ImageViewerMode` | ❌ | `ImageViewerMode.dialog` | 显示模式 |

##### showFromUrl()

从指定图片 URL 开始显示查看器。

```dart
static void showFromUrl(
  BuildContext context, {
  required List<String> imageUrls,
  required String imageUrl,
  Color backgroundColor = Colors.black,
  Color indicatorColor = Colors.white,
  ImageViewerMode mode = ImageViewerMode.dialog,
})
```

**参数：**

| 参数 | 类型 | 必需 | 默认值 | 说明 |
|------|------|------|--------|------|
| `context` | `BuildContext` | ✅ | - | 上下文 |
| `imageUrls` | `List<String>` | ✅ | - | 图片 URL 列表 |
| `imageUrl` | `String` | ✅ | - | 要显示的图片 URL（会自动查找索引） |
| `backgroundColor` | `Color` | ❌ | `Colors.black` | 背景颜色 |
| `indicatorColor` | `Color` | ❌ | `Colors.white` | 指示器颜色 |
| `mode` | `ImageViewerMode` | ❌ | `ImageViewerMode.dialog` | 显示模式 |

## 💡 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:your_app/common/widgets/imageViewer/image_viewer_page.dart';
import 'package:your_app/common/widgets/imageViewer/image_viewer.dart';

class ImageExamplePage extends StatelessWidget {
  // 示例图片列表
  final List<String> images = [
    'https://picsum.photos/800/1200?random=1',
    'https://picsum.photos/800/1200?random=2',
    'https://picsum.photos/800/1200?random=3',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('图片查看器示例')),
      body: Column(
        children: [
          // 方式1：直接跳转
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageViewerPage(
                    imageUrls: images,
                    initialIndex: 0,
                  ),
                ),
              );
            },
            child: const Text('打开查看器'),
          ),

          // 方式2：对话框方式
          ElevatedButton(
            onPressed: () {
              ImageViewer.show(
                context,
                imageUrls: images,
                initialIndex: 0,
              );
            },
            child: const Text('对话框打开'),
          ),

          // 方式3：路由方式
          ElevatedButton(
            onPressed: () {
              ImageViewer.show(
                context,
                imageUrls: images,
                mode: ImageViewerMode.route,
              );
            },
            child: const Text('路由打开'),
          ),

          // 方式4：从指定图片开始
          ElevatedButton(
            onPressed: () {
              ImageViewer.showFromUrl(
                context,
                imageUrls: images,
                imageUrl: images[1],  // 从第二张开始
              );
            },
            child: const Text('从第二张图片开始'),
          ),
        ],
      ),
    );
  }
}
```

## 🎯 核心实现原理

### 手势冲突解决方案

使用 `PhotoViewGallery.builder` 而不是 `PageView + PhotoView` 组合：

```
❌ PageView + PhotoView
├── PageView 监听：水平拖动 → 翻页
└── PhotoView 监听：水平拖动 → 查看图片
→ 冲突！放大后拖动会翻页

✅ PhotoViewGallery.builder
└── 统一手势处理：
    - 图片未放大 → 水平拖动 → 翻页
    - 图片放大后 → 水平拖动 → 查看图片
    - 拖到边缘 → 继续拖动 → 翻页
→ 无冲突！智能分发手势
```

### 关键代码

```dart
PhotoViewGallery.builder(
  pageController: _pageController,
  onPageChanged: _onPageChanged,
  itemCount: widget.imageUrls.length,
  builder: (context, index) {
    return PhotoViewGalleryPageOptions(
      imageProvider: CachedNetworkImageProvider(widget.imageUrls[index]),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * 0.5,
      maxScale: PhotoViewComputedScale.covered * 3.0,
      heroAttributes: PhotoViewHeroAttributes(tag: widget.imageUrls[index]),
    );
  },
  backgroundDecoration: BoxDecoration(color: widget.backgroundColor),
)
```

## 📌 注意事项

1. **网络权限**：确保在 `android/app/src/main/AndroidManifest.xml` 中添加了网络权限：

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

2. **图片 URL**：确保图片 URL 可访问，建议使用 HTTPS

3. **内存管理**：组件会自动缓存图片，大量图片时注意内存使用

4. **Hero 动画**：组件支持 Hero 动画，可以通过 `heroAttributes` 参数自定义

5. **手势优先级**：
   - 图片未放大时：水平滑动优先翻页
   - 图片放大后：拖动优先查看图片，拖到边缘才翻页

## 🐛 常见问题

### Q: 图片加载失败怎么办？
A: 组件会自动显示占位符， CachedNetworkImage 内置了错误处理。

### Q: 如何自定义缩放范围？
A: 修改 `image_viewer_page.dart` 中的 `minScale` 和 `maxScale` 参数：
```dart
minScale: PhotoViewComputedScale.contained * 0.3,  // 最小 0.3x
maxScale: PhotoViewComputedScale.covered * 5.0,   // 最大 5x
```

### Q: 如何禁用多点指示器？
A: 注释掉 `_buildDotIndicator()` 方法的调用即可。

### Q: 支持本地图片吗？
A: 当前版本只支持网络图片。如需支持本地图片，可以修改 `ImageProvider` 为 `AssetImage` 或 `FileImage`。

## 📝 更新日志

### v1.0.0 (2024-05-09)
- ✨ 初始版本发布
- 🎯 基于 PhotoViewGallery 实现无手势冲突的图片浏览
- 💾 集成 CachedNetworkImage 自动缓存
- 🎨 多点页面指示器
- 🖱️ 点击背景关闭功能

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

**开发者提示**：查看 `example_usage.dart` 获取更多使用示例。
