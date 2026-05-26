# MediaViewer

一个强大的 Flutter 混合媒体查看器组件，支持图片、视频、音频混排浏览，提供统一的翻页体验和流畅的交互。

## ✨ 功能特性

### 📸 图片功能
- 🔍 **双指缩放** - 支持 0.8x 到 3x 的缩放范围
- 👆 **拖动查看** - 图片放大后可自由拖动查看细节
- 💾 **智能缓存** - 集成 CachedNetworkImage，自动缓存已加载的图片

### 🎬 视频功能
- ▶️ **全屏播放** - 支持横屏全屏，播放完成自动退出
- 🎥 **视频缓存** - 自动缓存视频文件，提升播放速度
- 🎛️ **播放控制** - 进度条、音量、播放/暂停、循环播放
- 🚫 **智能翻页** - 全屏播放时自动禁用翻页，避免误操作
- ⏳ **加载提示** - 显示视频加载进度和状态

### 🎵 音频功能
- 🎶 **音频播放** - 支持网络音频播放
- 📊 **进度控制** - 进度条拖动跳转
- 🎨 **封面显示** - 显示专辑封面和音频信息
- 💿 **音频缓存** - 自动缓存音频文件

### 🎯 通用功能
- ⬅️➡️ **滑动翻页** - 左右滑动切换媒体
- 🔀 **混排支持** - 图片、视频、音频可随意混排
- 📍 **页面指示器** - 底部显示当前页面位置，带有流畅动画
- 🖱️ **点击关闭** - 点击背景任意位置即可关闭查看器
- 🌐 **两种模式** - 支持对话框和路由两种显示方式
- 🎬 **优雅过渡** - 路由模式使用 fade 过渡动画

## 📦 依赖项

### 必需依赖

```yaml
dependencies:
  # 图片查看器核心库
  photo_view: ^0.15.0

  # 网络图片缓存
  cached_network_image: ^3.4.1

  # 视频播放
  video_player: ^2.9.0

  # 音频播放
  flutter_sound: ^9.0.0

  # 网络请求（用于媒体缓存）
  dio: ^5.0.0

  # 获取临时目录（用于缓存）
  path_provider: ^2.0.0
```

### 依赖说明

| 依赖包 | 版本 | 作用 |
|--------|------|------|
| **photo_view** | ^0.15.0 | 图片缩放、拖动、手势处理 |
| **cached_network_image** | ^3.4.1 | 网络图片加载和缓存 |
| **video_player** | ^2.9.0 | 视频播放和控制 |
| **flutter_sound** | ^9.0.0 | 音频播放和控制 |
| **dio** | ^5.0.0 | 下载视频/音频文件到本地 |
| **path_provider** | ^2.0.0 | 获取临时目录用于缓存 |

## 📥 安装

1. 确保在 `pubspec.yaml` 中添加了依赖：

```yaml
dependencies:
  photo_view: ^0.15.0
  cached_network_image: ^3.4.1
  video_player: ^2.9.0
  flutter_sound: ^9.0.0
  dio: ^5.0.0
  path_provider: ^2.0.0
```

2. 安装依赖：

```bash
flutter pub get
```

3. 将组件文件复制到项目中：

```
lib/common/widgets/mediaViewer/
├── media_viewer.dart              # 入口类，提供便捷方法
├── media_viewer_page.dart         # 核心页面组件
├── media_viewer_example.dart      # 完整使用示例
├── models/
│   └── media_item.dart            # 媒体项数据模型
├── widgets/
│   ├── image_viewer_widget.dart   # 图片查看器
│   ├── video_player_widget.dart   # 视频播放器
│   └── audio_player_widget.dart   # 音频播放器
└── utils/
    ├── media_cache_manager.dart   # 媒体缓存管理
    └── player_lifecycle_manager.dart  # 播放器生命周期管理
```

## 🚀 使用方法

### 快速开始

```dart
import 'package:your_app/common/widgets/mediaViewer/media_viewer.dart';
import 'package:your_app/common/widgets/mediaViewer/models/media_item.dart';

// 创建媒体列表
final mediaItems = [
  // 图片
  ImageMediaItem.network(
    url: 'https://example.com/image.jpg',
    uniqueId: 'image_1',
    title: '产品展示图',
  ),

  // 视频
  VideoMediaItem.network(
    url: 'https://example.com/video.mp4',
    uniqueId: 'video_1',
    title: '产品介绍视频',
    coverUrl: 'https://example.com/cover.jpg',
    autoPlay: false,
    showControls: true,
  ),

  // 音频
  AudioMediaItem.network(
    url: 'https://example.com/audio.mp3',
    uniqueId: 'audio_1',
    title: '产品解说音频',
    artist: '产品团队',
    coverUrl: 'https://example.com/cover.jpg',
  ),
];

// 打开查看器（路由模式，默认）
MediaViewer.show(
  context: context,
  mediaItems: mediaItems,
  initialIndex: 0,
);

// 对话框模式
MediaViewer.show(
  context: context,
  mediaItems: mediaItems,
  mode: MediaViewerShowMode.dialog,
);

// 带页面切换回调
MediaViewer.show(
  context: context,
  mediaItems: mediaItems,
  onPageChanged: (index, item) {
    print('当前媒体: ${item.type} - ${item.title}');
  },
);
```

### 创建媒体项

#### 图片媒体项

```dart
// 网络图片（自动缓存）
ImageMediaItem.network(
  url: 'https://example.com/image.jpg',
  uniqueId: 'image_1',
  title: '图片标题',
  cacheImage: true,  // 是否缓存，默认 true
);

// 本地资源图片
ImageMediaItem.asset(
  assetPath: 'assets/images/product.jpg',
  uniqueId: 'image_2',
  title: '本地图片',
);
```

#### 视频媒体项

```dart
// 网络视频
VideoMediaItem.network(
  url: 'https://example.com/video.mp4',
  uniqueId: 'video_1',
  title: '视频标题',
  coverUrl: 'https://example.com/cover.jpg',  // 封面图
  autoPlay: false,        // 是否自动播放，默认 false
  showControls: true,     // 是否显示控制栏，默认 true
  looping: false,         // 是否循环播放，默认 false
  volume: 1.0,           // 初始音量 0.0-1.0，默认 1.0
);

// 本地资源视频
VideoMediaItem.asset(
  assetPath: 'assets/videos/product.mp4',
  uniqueId: 'video_2',
  title: '本地视频',
  coverUrl: 'assets/images/cover.jpg',
);
```

#### 音频媒体项

```dart
// 网络音频
AudioMediaItem.network(
  url: 'https://example.com/audio.mp3',
  uniqueId: 'audio_1',
  title: '音频标题',
  artist: '艺术家',
  album: '专辑名称',
  coverUrl: 'https://example.com/cover.jpg',  // 封面图
  autoPlay: false,        // 是否自动播放，默认 false
  showControls: true,     // 是否显示控制栏，默认 true
  looping: false,         // 是否循环播放，默认 false
  volume: 1.0,           // 初始音量 0.0-1.0，默认 1.0
);

// 本地资源音频
AudioMediaItem.asset(
  assetPath: 'assets/audios/bgm.mp3',
  uniqueId: 'audio_2',
  title: '本地音频',
  artist: '艺术家',
  coverUrl: 'assets/images/cover.jpg',
);
```

## 📖 API 文档

### MediaViewer

媒体查看器工具类，提供便捷的方法来显示全屏媒体查看器。

#### 静态方法

##### show()

显示混合媒体查看器。

```dart
static Future<T?> show<T>({
  required BuildContext context,
  required List<MediaItem> mediaItems,
  int initialIndex = 0,
  MediaViewerShowMode mode = MediaViewerShowMode.route,
  Color backgroundColor = Colors.black,
  void Function(int index, MediaItem item)? onPageChanged,
})
```

**参数：**

| 参数 | 类型 | 必需 | 默认值 | 说明 |
|------|------|------|--------|------|
| `context` | `BuildContext` | ✅ | - | 上下文 |
| `mediaItems` | `List<MediaItem>` | ✅ | - | 媒体项列表（支持图片、视频、音频混排） |
| `initialIndex` | `int` | ❌ | `0` | 初始显示的媒体索引 |
| `mode` | `MediaViewerShowMode` | ❌ | `MediaViewerShowMode.route` | 显示模式（route/dialog） |
| `backgroundColor` | `Color` | ❌ | `Colors.black` | 背景颜色 |
| `onPageChanged` | `void Function(int, MediaItem)?` | ❌ | `null` | 页面切换完成回调 |

### MediaViewerShowMode

显示模式枚举。

| 值 | 说明 |
|----|------|
| `MediaViewerShowMode.route` | 路由模式，使用 fade 过渡动画 |
| `MediaViewerShowMode.dialog` | 对话框模式 |

### MediaItem（基类）

媒体项基类，定义了所有媒体类型的通用属性。

| 参数 | 类型 | 说明 |
|------|------|------|
| `type` | `MediaType` | 媒体类型（image/video/audio） |
| `uniqueId` | `String` | 唯一标识符（用于 Hero 动画） |
| `title` | `String?` | 标题/描述 |
| `coverUrl` | `String?` | 封面图片 URL（视频/音频使用） |
| `url` | `String?` | 资源 URL（网络资源） |
| `assetPath` | `String?` | 本地资源路径 |
| `autoPlay` | `bool` | 是否自动播放，默认 false |

### ImageMediaItem

图片媒体项，继承自 MediaItem。

| 参数 | 类型 | 必需 | 默认值 | 说明 |
|------|------|------|--------|------|
| `imageUrl` | `String` | ✅ | - | 图片 URL |
| `uniqueId` | `String` | ✅ | - | 唯一标识符 |
| `title` | `String?` | ❌ | - | 图片标题 |
| `cacheImage` | `bool` | ❌ | `true` | 是否缓存图片 |

### VideoMediaItem

视频媒体项，继承自 MediaItem。

| 参数 | 类型 | 必需 | 默认值 | 说明 |
|------|------|------|--------|------|
| `videoUrl` | `String` | ✅ | - | 视频 URL |
| `uniqueId` | `String` | ✅ | - | 唯一标识符 |
| `title` | `String?` | ❌ | - | 视频标题 |
| `videoCoverUrl` | `String?` | ❌ | - | 封面图片 URL |
| `showControls` | `bool` | ❌ | `true` | 是否显示控制栏 |
| `looping` | `bool` | ❌ | `false` | 是否循环播放 |
| `initialVolume` | `double` | ❌ | `1.0` | 初始音量 (0.0-1.0) |
| `autoPlay` | `bool` | ❌ | `false` | 是否自动播放 |

### AudioMediaItem

音频媒体项，继承自 MediaItem。

| 参数 | 类型 | 必需 | 默认值 | 说明 |
|------|------|------|--------|------|
| `audioUrl` | `String` | ✅ | - | 音频 URL |
| `uniqueId` | `String` | ✅ | - | 唯一标识符 |
| `title` | `String?` | ❌ | - | 音频标题 |
| `audioCoverUrl` | `String?` | ❌ | - | 封面图片 URL |
| `artist` | `String?` | ❌ | - | 艺术家 |
| `album` | `String?` | ❌ | - | 专辑名称 |
| `showControls` | `bool` | ❌ | `true` | 是否显示控制栏 |
| `looping` | `bool` | ❌ | `false` | 是否循环播放 |
| `initialVolume` | `double` | ❌ | `1.0` | 初始音量 (0.0-1.0) |
| `autoPlay` | `bool` | ❌ | `false` | 是否自动播放 |

## 💡 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:your_app/common/widgets/mediaViewer/media_viewer.dart';
import 'package:your_app/common/widgets/mediaViewer/models/media_item.dart';

class MediaViewerExamplePage extends StatelessWidget {
  // 创建混合媒体列表
  final List<MediaItem> mediaItems = [
    // 图片
    ImageMediaItem.network(
      url: 'https://picsum.photos/800/600?random=1',
      uniqueId: 'image_1',
      title: '产品展示图',
    ),

    // 视频
    VideoMediaItem.network(
      url: 'https://media.w3.org/2010/05/sintel/trailer.mp4',
      uniqueId: 'video_1',
      title: '产品介绍视频',
      coverUrl: 'https://picsum.photos/800/600?random=11',
      autoPlay: false,
      showControls: true,
    ),

    // 图片
    ImageMediaItem.network(
      url: 'https://picsum.photos/800/600?random=2',
      uniqueId: 'image_2',
      title: '产品细节图',
    ),

    // 音频
    AudioMediaItem.network(
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      uniqueId: 'audio_1',
      title: '产品解说音频',
      artist: '产品团队',
      coverUrl: 'https://picsum.photos/400/400?random=21',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('混合媒体查看器示例')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 路由模式
          ElevatedButton(
            onPressed: () {
              MediaViewer.show(
                context: context,
                mediaItems: mediaItems,
                initialIndex: 0,
                mode: MediaViewerShowMode.route,
              );
            },
            child: const Text('路由模式打开'),
          ),

          // 对话框模式
          ElevatedButton(
            onPressed: () {
              MediaViewer.show(
                context: context,
                mediaItems: mediaItems,
                mode: MediaViewerShowMode.dialog,
              );
            },
            child: const Text('对话框模式打开'),
          ),

          // 带回调
          ElevatedButton(
            onPressed: () {
              MediaViewer.show(
                context: context,
                mediaItems: mediaItems,
                onPageChanged: (index, item) {
                  debugPrint('切换到: ${item.type} - ${item.title}');
                },
              );
            },
            child: const Text('带切换回调'),
          ),
        ],
      ),
    );
  }
}
```

## 🎯 核心实现原理

### 统一的手势处理

使用 `PhotoViewGallery.builder` 实现统一的翻页体验：

```
PhotoViewGallery
├── 图片：PhotoViewGalleryPageOptions（支持缩放、拖动）
├── 视频：PhotoViewGalleryPageOptions.customChild（禁用手势）
└── 音频：PhotoViewGalleryPageOptions.customChild（禁用手势）
```

### 智能翻页控制

```dart
// 视频全屏时禁用翻页
PhotoViewGallery.builder(
  scrollPhysics: _hasFullscreenVideo
      ? NeverScrollableScrollPhysics()  // 全屏时禁用
      : null,                            // 正常可滑动
  ...
)
```

### 播放器生命周期管理

```dart
// 页面切换时暂停所有播放器
void _onPageChanged(int index) {
  _lifecycleManager.pauseAll();  // 暂停视频和音频
  setState(() {
    _currentIndex = index;
  });
}

// 页面销毁时释放所有播放器
@override
void dispose() {
  _lifecycleManager.disposeAll();  // 释放所有资源
  super.dispose();
}
```

### 媒体缓存机制

```dart
// 视频/音频缓存流程
1. 检查本地缓存 → 存在则直接播放
2. 缓存不存在 → 下载到临时目录
3. 播放本地文件 → 提升加载速度
4. 页面销毁 → 取消下载任务
```

## 📌 注意事项

1. **网络权限**：确保在 `android/app/src/main/AndroidManifest.xml` 中添加了网络权限：

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

2. **媒体 URL**：确保媒体 URL 可访问，建议使用 HTTPS

3. **视频格式**：支持 MP4、WebM 等常见视频格式

4. **音频格式**：支持 MP3、AAC、WAV 等常见音频格式

5. **内存管理**：
   - 视频和音频会缓存到临时目录
   - 页面销毁时会自动清理缓存
   - 大量媒体时注意内存使用

6. **全屏播放**：
   - 视频全屏时自动禁用翻页
   - 播放完成后自动退出全屏
   - 支持横屏显示

7. **页面切换**：
   - 切换页面时自动暂停视频/音频
   - 图片保持当前缩放状态

## 🐛 常见问题

### Q: 视频加载慢怎么办？
A: 组件会自动缓存视频到本地，首次加载后下次播放会很快。

### Q: 如何自定义图片缩放范围？
A: 修改 `media_viewer_page.dart` 中的 `minScale` 和 `maxScale` 参数：
```dart
minScale: PhotoViewComputedScale.contained * 0.5,  // 最小 0.5x
maxScale: PhotoViewComputedScale.covered * 5.0,   // 最大 5x
```

### Q: 视频全屏时如何退出？
A: 点击全屏按钮或等待播放完成自动退出。

### Q: 支持本地文件吗？
A: 支持！使用 `ImageMediaItem.asset`、`VideoMediaItem.asset`、`AudioMediaItem.asset` 即可。

### Q: 如何禁用媒体缓存？
A: 图片设置 `cacheImage: false`；视频/音频目前不支持禁用缓存（用于提升播放速度）。

### Q: 音频播放失败怎么办？
A: 检查音频格式是否支持，确保 URL 可访问，查看控制台错误信息。

## 📝 更新日志

### v1.1.0 (2025-01-12)
- ✨ 添加视频加载指示器
- 🛠️ 优化资源释放和错误处理
- 🔧 修复 Flutter 版本兼容性问题
- ⚡ 性能优化和稳定性提升

### v1.0.0 (2024-XX-XX)
- ✨ 初始版本发布
- 🎯 支持图片、视频、音频混排
- 💾 自动缓存媒体文件
- 🎬 全屏播放和智能翻页
- 🎨 统一的翻页体验

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

**开发者提示**：查看 `media_viewer_example.dart` 获取完整使用示例。
