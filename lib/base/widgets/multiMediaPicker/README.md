# MultiMediaPicker

一个强大的 Flutter 多媒体选择器组件，支持图片和视频的选择、拍照、录制，以及只浏览模式展示网络图片/视频。

## ✨ 功能特性

### 核心功能
- 🖼️ **图片选择** - 从相册选择图片或拍照
- 🎥 **视频选择** - 从相册选择视频或录制
- 📷 **拍照录制** - 支持直接拍照和录制视频（可选）
- 🌐 **网络资源** - 支持显示和浏览网络图片/视频
- 👁️ **只浏览模式** - 禁用选择和删除，仅用于展示
- 📱 **宫格布局** - 支持自适应和固定大小两种宫格模式
- 🗑️ **删除功能** - 每个媒体项右上角有删除按钮
- 🎬 **视频缩略图** - 自动生成视频缩略图并保存到临时目录

### 高级特性
- 🎨 **自定义样式** - 可自定义添加按钮、删除按钮颜色
- 📊 **数量限制** - 支持设置最大选择数量
- 🔒 **类型控制** - 可单独启用/禁用图片或视频选择
- ⏱️ **时长限制** - 支持设置录制视频的最大时长
- 📤 **文件获取** - 提供统一的文件获取接口用于上传
- 🎯 **点击回调** - 浏览模式下支持点击事件处理
- 📝 **上传状态** - 支持显示每个媒体项的上传状态
- 🔄 **状态监听** - 使用 ChangeNotifier 实现响应式更新

## 📦 依赖项

### 必需依赖

```yaml
dependencies:
  # 多媒体选择核心库
  wechat_assets_picker: ^9.0.0
  # 拍照和录制
  image_picker: ^1.0.0
  # 视频缩略图
  video_thumbnail: ^0.5.0
  # 网络图片缓存
  cached_network_image: ^3.4.0
  # 虚线边框
  dotted_border: ^2.0.0
  # Toast提示
  fluttertoast: ^9.0.0
  # UUID生成
  uuid: ^4.0.0
  # 日志
  logger: ^2.7.0
```

### 依赖说明

| 依赖包 | 版本 | 作用 |
|--------|------|------|
| **wechat_assets_picker** | ^9.0.0 | 核心功能，提供相册选择能力 |
| | | `AssetPicker.pickAssets()` - 打开相册选择器 |
| | | `AssetEntity` - 媒体资源实体 |
| | | 支持图片、视频等多种格式 |
| **image_picker** | ^1.0.0 | 拍照和录制视频 |
| | | `ImagePicker().pickImage()` - 拍照 |
| | | `ImagePicker().pickVideo()` - 录制视频 |
| **video_thumbnail** | ^0.5.0 | 生成视频缩略图 |
| | | `VideoThumbnail.thumbnailData()` - 生成缩略图数据 |
| **cached_network_image** | ^3.4.0 | 网络图片缓存和显示 |
| **dotted_border** | ^2.0.0 | 添加按钮的虚线边框 |
| **fluttertoast** | ^9.0.0 | Toast 消息提示 |
| **uuid** | ^4.0.0 | 生成唯一ID |
| **logger** | ^2.7.0 | 日志输出 |

## 📥 安装

1. 确保在 `pubspec.yaml` 中添加了依赖：

```yaml
dependencies:
  wechat_assets_picker: ^9.0.0
  image_picker: ^1.0.0
  video_thumbnail: ^0.5.0
  cached_network_image: ^3.4.0
  dotted_border: ^2.0.0
  fluttertoast: ^9.0.0
  uuid: ^4.0.0
  logger: ^2.7.0
```

2. 安装依赖：

```bash
flutter pub get
```

3. 将组件文件复制到项目中：

```
lib/base/widgets/multiMediaPicker/
├── multi_media_picker.dart
├── multi_media_picker_controller.dart
├── multi_media_picker_view.dart
└── example_usage.dart
```

4. 配置权限（必需）

### Android 配置

在 `android/app/src/main/AndroidManifest.xml` 中添加：

```xml
<manifest>
    <!-- 相机权限 -->
    <uses-permission android:name="android.permission.CAMERA" />
    <!-- 读取相册权限 -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
    <!-- Android 12及以下版本 -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

    <application>
        ...
    </application>
</manifest>
```

在 `android/app/build.gradle` 中设置版本：

```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.example.your_app"
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### iOS 配置

在 `ios/Runner/Info.plist` 中添加：

```xml
<!-- 相机权限 -->
<key>NSCameraUsageDescription</key>
<string>需要使用相机拍照和录制视频</string>

<!-- 相册权限 -->
<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册选择图片和视频</string>

<!-- 相册写入权限（保存照片） -->
<key>NSPhotoLibraryAddUsageDescription</key>
<string>需要保存照片到相册</string>

<!-- 麦克风权限（录制视频时需要） -->
<key>NSMicrophoneUsageDescription</key>
<string>录制视频时需要使用麦克风</string>
```

在 `ios/Podfile` 中配置平台版本：

```ruby
platform :ios, '12.0'

# 取消注释并修改权限配置
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CAMERA=1',
        'PERMISSION_PHOTOS=1',
        'PERMISSION_MICROPHONE=1',
      ]
    end
  end
end
```

## 🚀 使用方法

### 方式一：基础使用（自适应宫格）

```dart
import 'package:flutter/material.dart';
import 'package:your_app/base/widgets/multiMediaPicker/multi_media_picker.dart';

class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late final MultiMediaPickerController controller;

  @override
  void initState() {
    super.initState();
    // 1. 创建控制器
    controller = MultiMediaPickerController(
      maxCount: 9,           // 最多选择9个
      enableImage: true,     // 支持图片
      enableVideo: true,     // 支持视频
      enableCamera: false,   // 不显示拍照和录像
    );
  }

  @override
  void dispose() {
    controller.dispose();  // 2. 记得释放控制器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('多媒体选择器')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // 3. 使用组件
          MultiMediaPickerView(
            controller: controller,
            crossAxisCount: 3,    // 3列，宽度自动计算
            spacing: 10,
            runSpacing: 10,
          ),
        ],
      ),
    );
  }
}
```

### 方式二：固定大小宫格

```dart
MultiMediaPickerView(
  controller: controller,
  itemWidth: 100,     // 固定宽度
  itemHeight: 100,    // 固定高度
  spacing: 10,
  runSpacing: 10,
)
```

### 方式三：仅支持图片

```dart
controller = MultiMediaPickerController(
  maxCount: 9,
  enableImage: true,
  enableVideo: false,  // 禁用视频
);
```

### 方式四：支持拍照和录像

```dart
controller = MultiMediaPickerController(
  maxCount: 9,
  enableImage: true,
  enableVideo: true,
  enableCamera: true,    // 显示拍照和录像选项
  maxVideoSeconds: 60,   // 录像最大时长60秒
);
```

### 方式五：只浏览模式（显示网络图片）

```dart
controller = MultiMediaPickerController(
  maxCount: 9,
  enableImage: true,
  enableVideo: true,
  viewOnly: true,  // 只浏览模式
  onMediaTap: (allMedia, clickedMedia) {
    // 处理点击事件
    final index = allMedia.indexOf(clickedMedia);
    print('点击了第 ${index + 1} 张图片');
    // 可以在这里打开大图预览、跳转详情页等
  },
);

// 添加网络图片
controller.addNetworkImages([
  'https://example.com/image1.jpg',
  'https://example.com/image2.jpg',
]);
```

### 方式六：网络视频（浏览模式）

```dart
controller = MultiMediaPickerController(
  viewOnly: true,
  onMediaTap: (allMedia, clickedMedia) {
    if (clickedMedia.type == MediaType.video) {
      // 点击了视频，可以播放
      final videoUrl = clickedMedia.videoUrl;
      // 使用 video_player 播放视频
    }
  },
);

// 添加网络视频（缩略图 + 播放URL）
controller.addNetworkVideo(
  'https://example.com/thumbnail.jpg',  // 缩略图URL
  'https://example.com/video.mp4',      // 视频播放URL
);
```

### 方式七：获取文件用于上传

```dart
// 获取所有文件
final files = await controller.getAllFiles();

// 遍历上传
for (var file in files) {
  await uploadFile(file);
}

// 获取视频缩略图（用于上传封面）
final thumbnailPaths = controller.getAllVideoThumbnails();
thumbnailPaths.forEach((index, thumbnailPath) {
  print('视频 $index 的缩略图: $thumbnailPath');
  uploadThumbnail(File(thumbnailPath));
});
```

### 方式八：自定义样式

```dart
MultiMediaPickerView(
  controller: controller,
  crossAxisCount: 3,
  spacing: 10,
  // 自定义添加按钮颜色
  addBorderColor: Color(0xFF1C5A4F),
  addIconColor: Color(0xFF1C5A4F),
  // 自定义删除按钮颜色
  deleteBackgroundColor: Color(0xFF1C5A4F),
  deleteIconColor: Colors.white,
  // 不显示视频时长标识
  showVideoIndicator: false,
)
```

## 📖 API 文档

### MultiMediaPickerController

多媒体选择器控制器。

#### 构造参数

| 参数 | 类型 | 必需 | 默认值 | 说明 |
|------|------|------|--------|------|
| `maxCount` | `int` | ❌ | `9` | 最大选择数量 |
| `enableImage` | `bool` | ❌ | `true` | 是否支持图片选择 |
| `enableVideo` | `bool` | ❌ | `true` | 是否支持视频选择 |
| `enableCamera` | `bool` | ❌ | `false` | 是否显示拍照和录像选项 |
| `viewOnly` | `bool` | ❌ | `false` | 是否只浏览（不可选择、不可删除） |
| `onMediaTap` | `Function(List<MediaItem>, MediaItem)` | ❌ | `null` | 点击媒体项回调（浏览模式下有效） |
| `onMediaDeleted` | `Function(List<MediaItem>, MediaItem)` | ❌ | `null` | 删除媒体项回调 |
| `onSelected` | `Function(List<MediaItem>)` | ❌ | `null` | 选择完成回调 |
| `maxVideoSeconds` | `int?` | ❌ | `null` | 录像最大时长（秒），为 null 时不限制 |

#### 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `selectedMedia` | `List<MediaItem>` | 已选择的媒体列表（只读） |
| `selectedCount` | `int` | 已选择媒体的数量（只读） |
| `showAddButton` | `bool` | 是否显示添加按钮（只读） |
| `canRemove` | `bool` | 是否可以删除（只读） |
| `maxCount` | `int` | 最大选择数量 |
| `enableImage` | `bool` | 是否支持图片 |
| `enableVideo` | `bool` | 是否支持视频 |
| `viewOnly` | `bool` | 是否只浏览模式 |

#### 方法

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `pickMedia()` | `BuildContext context` | `Future<void>` | 打开媒体选择器 |
| `removeMedia()` | `int index` | `void` | 删除指定索引的媒体 |
| `removeMediaById()` | `String id` | `void` | 删除指定ID的媒体 |
| `clearAll()` | - | `void` | 清空所有选择 |
| `getAllFiles()` | - | `Future<List<File>>` | 获取所有文件（用于上传） |
| `getThumbnailPath()` | `int index` | `String?` | 获取指定媒体项的缩略图路径 |
| `getAllVideoThumbnails()` | - | `Map<int, String>` | 获取所有视频的缩略图路径 |
| `addNetworkImage()` | `String url` | `void` | 添加单个网络图片 |
| `addNetworkImages()` | `List<String> urls` | `void` | 批量添加网络图片 |
| `addNetworkVideo()` | `String thumbnailUrl, String srcUrl` | `void` | 添加网络视频 |
| `dispose()` | - | `void` | 释放资源 |

### MultiMediaPickerView

多媒体选择器视图组件。

#### 参数

| 参数 | 类型 | 必需 | 默认值 | 说明 |
|------|------|------|--------|------|
| `controller` | `MultiMediaPickerController` | ✅ | - | 控制器 |
| `crossAxisCount` | `int` | ❌ | `3` | 宫格列数（自适应模式） |
| `itemWidth` | `double?` | ❌ | `null` | 单个项目宽度（固定大小模式） |
| `itemHeight` | `double?` | ❌ | `null` | 单个项目高度（固定大小模式） |
| `spacing` | `double` | ❌ | `10` | 项目间距 |
| `runSpacing` | `double` | ❌ | `10` | 行间距 |
| `addBorderColor` | `Color?` | ❌ | `Color(0xFFEBEAEF)` | 添加按钮边框颜色 |
| `addIconColor` | `Color?` | ❌ | `Color(0xFFC0C0C0)` | 添加按钮图标颜色 |
| `deleteBackgroundColor` | `Color?` | ❌ | `Colors.black54` | 删除按钮背景颜色 |
| `deleteIconColor` | `Color?` | ❌ | `Colors.white` | 删除按钮图标颜色 |
| `showVideoIndicator` | `bool` | ❌ | `true` | 是否显示视频标识 |
| `uploadStatusCallback` | `String? Function(String mediaId)?` | ❌ | `null` | 上传状态回调 |

### MediaItem

媒体项数据模型。

#### 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `id` | `String` | 唯一标识 |
| `path` | `String` | 文件路径或网络URL |
| `type` | `MediaType` | 媒体类型（image/video） |
| `file` | `File?` | 本地文件对象 |
| `assetEntity` | `AssetEntity?` | 相册资源实体 |
| `thumbnailPath` | `String?` | 视频缩略图路径 |
| `networkUrl` | `String?` | 网络图片URL |
| `videoUrl` | `String?` | 网络视频播放URL |
| `isNetworkImage` | `bool` | 是否为网络图片 |

#### 构造方法

| 方法 | 说明 |
|------|------|
| `MediaItem.fromFile(File file)` | 从本地文件创建 |
| `MediaItem.fromVideoFile(File file)` | 从视频文件创建 |
| `MediaItem.fromAssetEntity(AssetEntity entity)` | 从相册资源创建 |
| `MediaItem.fromNetworkUrl(String url)` | 从网络图片URL创建 |
| `MediaItem.fromNetworkVideoUrl(String thumbnailUrl, String srcUrl)` | 从网络视频URL创建 |

### MediaType

媒体类型枚举。

```dart
enum MediaType {
  image,  // 图片
  video,  // 视频
}
```

## 💡 完整示例

查看 `example_usage.dart` 文件获取完整的使用示例，包括：

1. **基础使用** - 自适应宫格布局
2. **固定大小宫格** - 指定宽高
3. **仅支持图片** - 禁用视频选择
4. **自定义样式** - 自定义颜色
5. **带操作按钮** - 预览、清空、提交
6. **支持拍照和录像** - 显示相机选项
7. **只浏览模式** - 显示网络图片，支持点击
8. **网络视频** - 显示缩略图，支持播放

## 🎯 核心实现原理

### 控制器实现

```
MultiMediaPickerController (ChangeNotifier)
├── List<MediaItem> _selectedMedia - 已选择的媒体列表
├── ImagePicker _picker - 图片选择器
├── pickMedia() - 打开选择器
│   ├── _openAssetPicker() - 从相册选择
│   ├── _openCamera() - 拍照
│   └── _openVideoCamera() - 录制视频
├── _addMedia() - 添加媒体项
│   └── _generateVideoThumbnail() - 生成视频缩略图
├── removeMedia() - 删除媒体项
├── getAllFiles() - 获取所有文件
└── notifyListeners() - 通知更新
```

### 视图实现

```
MultiMediaPickerView (StatelessWidget)
├── AnimatedBuilder - 监听控制器变化
│   ├── GridView.builder - 宫格布局
│   │   ├── _buildAddButton() - 添加按钮
│   │   └── _buildMediaItem() - 媒体项
│   │       ├── _buildImage() - 图片
│   │       ├── _buildVideo() - 视频
│   │       ├── _buildDeleteButton() - 删除按钮
│   │       ├── _buildVideoIndicator() - 视频标识
│   │       └── _buildDescription() - 底部描述
│   └── _buildBottomLeftView() - 提示文本
```

### 视频缩略图生成

```dart
// 1. 生成缩略图数据
final uint8list = await VideoThumbnail.thumbnailData(
  video: videoPath,
  imageFormat: ImageFormat.JPEG,
  maxWidth: 400,
  quality: 75,
);

// 2. 保存到临时目录
final tempFile = File('${tempDir.path}/video_thumb_$id.jpg');
await tempFile.writeAsBytes(uint8list);

// 3. 保存路径到 MediaItem
MediaItem(thumbnailPath: tempFile.path);
```

### 只浏览模式

```dart
// viewOnly = true 时：
// 1. 不显示添加按钮
// 2. 不显示删除按钮
// 3. 支持显示网络图片/视频
// 4. 支持点击回调（用于查看大图、播放视频等）

controller = MultiMediaPickerController(
  viewOnly: true,
  onMediaTap: (allMedia, clickedMedia) {
    // 处理点击事件
  },
);
```

## 📌 注意事项

1. **权限申请**：
   - Android: 需要在 `AndroidManifest.xml` 中声明相机、相册权限
   - iOS: 需要在 `Info.plist` 中添加权限使用说明
   - Android 13+ 需要新的权限模型：`READ_MEDIA_IMAGES`、`READ_MEDIA_VIDEO`
   - 建议使用 `permission_handler` 包在运行时动态申请权限

2. **平台差异**：
   - iOS 保存照片/视频到相册会自动创建 `AssetEntity`
   - Android 需要手动处理权限和文件存储
   - 不同平台的相册选择器UI可能不同

3. **内存管理**：
   - 控制器使用完毕后必须调用 `dispose()` 释放资源
   - 视频缩略图保存在临时目录，dispose 时会自动清理
   - 大量图片时注意内存占用，建议压缩后再上传

4. **性能优化**：
   - 使用 `cached_network_image` 缓存网络图片
   - 视频缩略图已生成并缓存，避免重复生成
   - 使用 `FutureBuilder` 异步加载缩略图

5. **错误处理**：
   - 拍照/录制失败时会有 Toast 提示
   - 权限被拒绝时需要引导用户开启权限
   - 网络图片加载失败会显示占位图

6. **上传建议**：
   - 使用 `getAllFiles()` 获取所有文件
   - 视频文件较大，建议压缩后再上传
   - 视频缩略图可作为封面图单独上传
   - 建议显示上传进度（使用 `uploadStatusCallback`）

## 🐛 常见问题

### Q: 如何申请相机和相册权限？

A: 建议使用 `permission_handler` 包：

```yaml
dependencies:
  permission_handler: ^11.0.0
```

```dart
import 'package:permission_handler/permission_handler.dart';

// 请求相机权限
Future<void> requestCameraPermission() async {
  final status = await Permission.camera.request();
  if (status.isGranted) {
    // 权限已授予
  } else {
    // 引导用户开启权限
    openAppSettings();
  }
}

// 请求相册权限
Future<void> requestPhotosPermission() async {
  final status = await Permission.photos.request();
  if (status.isGranted) {
    // 权限已授予
  }
}
```

### Q: 如何限制只选择图片或视频？

A: 在创建控制器时设置 `enableImage` 和 `enableVideo`：

```dart
// 只允许选择图片
controller = MultiMediaPickerController(
  enableImage: true,
  enableVideo: false,
);

// 只允许选择视频
controller = MultiMediaPickerController(
  enableImage: false,
  enableVideo: true,
);
```

### Q: 如何获取选择的文件并上传？

A: 使用 `getAllFiles()` 方法：

```dart
// 获取所有文件
final files = await controller.getAllFiles();

// 遍历上传
for (var i = 0; i < files.length; i++) {
  final file = files[i];

  // 上传文件
  final url = await uploadFile(file);

  // 如果是视频，获取缩略图
  final thumbnailPath = controller.getThumbnailPath(i);
  if (thumbnailPath != null) {
    await uploadThumbnail(File(thumbnailPath));
  }
}
```

### Q: 如何显示上传进度？

A: 使用 `uploadStatusCallback` 参数：

```dart
Map<String, String> uploadStatus = {};

MultiMediaPickerView(
  controller: controller,
  uploadStatusCallback: (mediaId) {
    return uploadStatus[mediaId]; // 返回状态文本
  },
)

// 更新状态
void uploadMedia(MediaItem media) async {
  uploadStatus[media.id] = "上传中 50%";
  controller.notifyListeners();

  await uploadFile(media.file);

  uploadStatus[media.id] = "上传成功";
  controller.notifyListeners();
}
```

### Q: 如何实现大图预览？

A: 在浏览模式下的 `onMediaTap` 回调中实现：

```dart
controller = MultiMediaPickerController(
  viewOnly: true,
  onMediaTap: (allMedia, clickedMedia) async {
    final index = allMedia.indexOf(clickedMedia);

    // 使用 photo_view 或其他图片查看器
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewGalleryPage(
          images: allMedia,
          initialIndex: index,
        ),
      ),
    );
  },
);
```

### Q: 如何压缩图片后再上传？

A: 使用 `flutter_image_compress` 包：

```yaml
dependencies:
  flutter_image_compress: ^2.4.0
```

```dart
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<File> compressImage(File file) async {
  final compressed = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    quality: 70, // 压缩质量
    minWidth: 800,
    minHeight: 800,
  );
  return File(compressed!);
}
```

### Q: 视频缩略图保存在哪里？

A: 视频缩略图保存在系统临时目录：

```dart
// 路径示例（Android）
// /data/user/0/com.example.app/cache/video_thumb_xxx.jpg

// 路径示例（iOS）
// /var/mobile/.../tmp/video_thumb_xxx.jpg

// 控制器 dispose 时会自动清理
// 如果需要手动清理：
final thumbnailPath = controller.getThumbnailPath(0);
if (thumbnailPath != null) {
  File(thumbnailPath).deleteSync();
}
```

### Q: 如何自定义选择器的UI？

A: `wechat_assets_picker` 支持自定义主题：

```dart
// 在选择前设置主题
AssetPicker.themeData = ThemeData(
  primaryColor: Color(0xFF1C5A4F),
  // ... 其他主题配置
);

// 然后打开选择器
await AssetPicker.pickAssets(
  context,
  pickerConfig: AssetPickerConfig(
    // ... 配置
  ),
);
```

## 📝 更新日志

### v1.0.0 (2026-05-18)
- ✨ 初始版本发布
- 📷 支持图片和视频选择
- 🎥 支持拍照和录制视频
- 🌐 支持网络图片/视频显示
- 👁️ 支持只浏览模式
- 📱 支持自适应和固定大小宫格布局
- 🗑️ 支持删除功能
- 🎬 自动生成视频缩略图
- 🎨 支持自定义样式
- 📤 提供文件获取接口用于上传
- 🔄 使用 ChangeNotifier 实现响应式更新

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

**开发者提示**：查看 `example_usage.dart` 获取更多使用示例。
