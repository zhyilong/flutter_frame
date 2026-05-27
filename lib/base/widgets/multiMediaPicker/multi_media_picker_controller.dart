import 'dart:io';

import 'package:flutter/material.dart';
import '../hud/hud.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

/// 多媒体选择数据模型
///  - ✅ 拍照 (fromFile): path: file.path - 有值
//   - ✅ 录制视频 (fromVideoFile): path: file.path - 有值
//   - ❌ 从相册选择 (fromAssetEntity): path: '' - 空值
//   - ✅ 网络图片 (fromNetworkUrl): path: url - 有值
//   - ✅ 网络视频 (fromNetworkVideoUrl): path: srcUrl - 有值
class MediaItem {
  final String id;
  final String path; // 没有值，需要从assetEntity.file异步获取,因此自行处理
  final MediaType type;
  final File? file;
  final AssetEntity? assetEntity;
  final String? thumbnailPath;
  final String? networkUrl; // 网络图片URL
  final String? videoUrl; //

  MediaItem({required this.id, required this.path, required this.type, this.file, this.assetEntity, this.thumbnailPath, this.networkUrl, this.videoUrl});

  factory MediaItem.fromFile(File file) {
    return MediaItem(id: Uuid().v4(), path: file.path, type: MediaType.image, file: file);
  }

  /// 从文件创建视频媒体项
  factory MediaItem.fromVideoFile(File file) {
    return MediaItem(id: Uuid().v4(), path: file.path, type: MediaType.video, file: file);
  }

  factory MediaItem.fromAssetEntity(AssetEntity entity) {
    return MediaItem(id: entity.id, path: '', type: entity.type == AssetType.video ? MediaType.video : MediaType.image, assetEntity: entity);
  }

  /// 从网络URL创建媒体项（用于浏览模式）
  factory MediaItem.fromNetworkUrl(String url, {String? id}) {
    return MediaItem(id: id ?? Uuid().v4(), path: url, type: MediaType.image, networkUrl: url);
  }

  /// 从网络URL创建媒体项（用于浏览模式）
  factory MediaItem.fromNetworkVideoUrl(String thumbnailUrl, String srcUrl, {String? id}) {
    return MediaItem(id: id ?? Uuid().v4(), path: srcUrl, type: MediaType.video, networkUrl: thumbnailUrl, videoUrl: srcUrl);
  }

  /// 判断是否为网络图片
  bool get isNetworkImage => networkUrl != null && networkUrl!.isNotEmpty;
}

enum MediaType { image, video }

/// 多媒体选择器控制器（使用 ChangeNotifier，不依赖 GetX）
class MultiMediaPickerController extends ChangeNotifier {
  /// 选择的最大数量
  final int maxCount;

  /// 是否可以选择视频
  final bool enableVideo;

  /// 是否可以选择图片
  final bool enableImage;

  /// 是否显示拍照和录像选项
  final bool enableCamera;

  /// 是否只浏览（不可选择、不可删除）
  final bool viewOnly;

  /// 点击媒体项回调（浏览模式下有效）
  final void Function(List<MediaItem> allMedia, MediaItem clickedMedia)? onMediaTap;

  /// 删除回调
  final void Function(List<MediaItem> allMedia, MediaItem clickedMedia)? onMediaDeleted;

  /// 选择完成
  final void Function(List<MediaItem> allMedia)? onSelected;

  /// 录像最大时长（秒），为 null 时不限制
  final int? maxVideoSeconds;

  /// 已选择的媒体列表（内部状态）
  final List<MediaItem> _selectedMedia = [];

  /// 图片选择器
  final ImagePicker _picker = ImagePicker();

  MultiMediaPickerController({
    this.maxCount = 9,
    this.enableVideo = true,
    this.enableImage = true,
    this.enableCamera = false, // 默认不显示拍照和录像
    this.viewOnly = false, // 默认可以选择和删除
    this.onMediaTap, // 点击回调
    this.onMediaDeleted, // 删除回调
    this.onSelected, // 选择完成
    this.maxVideoSeconds, // 录像时长限制
  });

  /// 获取已选择的媒体列表
  List<MediaItem> get selectedMedia => List.unmodifiable(_selectedMedia);

  /// 获取已选择媒体的数量
  int get selectedCount => _selectedMedia.length;

  /// 是否显示添加按钮
  bool get showAddButton => !viewOnly && _selectedMedia.length < maxCount;

  /// 是否可以删除
  bool get canRemove => !viewOnly;

  /// 选择媒体
  Future<void> pickMedia(BuildContext context) async {
    // 如果不支持选择任何类型，直接返回
    if (!enableImage && !enableVideo) {
      return;
    }

    // 检查是否还有剩余选择数量
    final remainingCount = maxCount - _selectedMedia.length;
    if (remainingCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('最多只能选择$maxCount个文件'), behavior: SnackBarBehavior.floating));
      return;
    }

    // 只有一种类型时，直接打开相册
    if (enableImage != enableVideo) {
      await _openAssetPicker(context, remainingCount);
      return;
    }

    // 两种类型都支持，但不显示相机选项时，直接打开相册
    if (!enableCamera) {
      await _openAssetPicker(context, remainingCount);
      return;
    }

    // 两种类型都支持且显示相机选项时，显示选择方式弹窗
    await showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (context) => _buildPickerSheet(context, remainingCount));
  }

  /// 构建选择器底部弹窗
  Widget _buildPickerSheet(BuildContext context, int remainingCount) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 相机拍照
            if (enableCamera && enableImage)
              ListTile(
                leading: Icon(Icons.camera_alt, color: Color(0xFF1C5A4F)),
                title: Text('拍照', style: TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  _openCamera();
                },
              ),
            // 录制视频
            if (enableCamera && enableVideo)
              ListTile(
                leading: Icon(Icons.videocam, color: Color(0xFF1C5A4F)),
                title: Text('录制视频', style: TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  _openVideoCamera();
                },
              ),
            // 从相册选择
            ListTile(
              leading: Icon(Icons.photo_library, color: Color(0xFF1C5A4F)),
              title: Text('从相册选择', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                _openAssetPicker(context, remainingCount);
              },
            ),
            // 取消按钮
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(16),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFF5F5F5),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('取消', style: TextStyle(fontSize: 16, color: Color(0xFF1C5A4F))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 打开相机拍照
  Future<void> _openCamera() async {
    if (_selectedMedia.length >= maxCount) return;

    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        final file = File(photo.path);

        // 读取文件字节数据
        final imageData = await file.readAsBytes();

        // 生成文件名（使用时间戳）
        final filename = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';

        // 保存到相册并获取 AssetEntity
        final AssetEntity? assetEntity = await PhotoManager.editor.saveImage(imageData, filename: filename);

        if (assetEntity != null) {
          // 使用 AssetEntity 创建媒体项
          final mediaItem = MediaItem.fromAssetEntity(assetEntity);
          _addMedia(mediaItem);

          // 选择完成回调
          onSelected?.call(_selectedMedia);
        } else {
          // 保存失败，提示用户
          HUDToast.show( '保存图片失败，请检查相册权限或存储空间');
          debugPrint('❌ 保存图片到相册失败：assetEntity 为 null');
        }
      }
    } catch (e) {
      debugPrint('拍照失败: $e');
      // 根据错误类型给出具体提示
      if (e.toString().contains('Permission')) {
        HUDToast.show( '请允许访问相册权限');
      } else {
        HUDToast.show( '保存图片失败: ${e.toString()}');
      }
    }
  }

  /// 打开相机录制视频
  Future<void> _openVideoCamera() async {
    if (_selectedMedia.length >= maxCount) return;

    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: maxVideoSeconds != null ? Duration(seconds: maxVideoSeconds!) : null,
      );
      if (video != null) {
        final file = File(video.path);

        // 保存到相册并获取 AssetEntity（视频保存直接使用 File 对象）
        final AssetEntity? assetEntity = await PhotoManager.editor.saveVideo(file);

        if (assetEntity != null) {
          // 使用 AssetEntity 创建媒体项
          final mediaItem = MediaItem.fromAssetEntity(assetEntity);
          _addMedia(mediaItem);

          // 选择完成回调
          onSelected?.call(_selectedMedia);
        } else {
          // 保存失败，提示用户
          HUDToast.show( '保存视频失败，请检查相册权限或存储空间');
          debugPrint('❌ 保存视频到相册失败：assetEntity 为 null');
        }
      }
    } catch (e) {
      debugPrint('录制视频失败: $e');
      // 根据错误类型给出具体提示
      if (e.toString().contains('Permission')) {
        HUDToast.show( '请允许访问相册权限');
      } else {
        HUDToast.show( '保存视频失败: ${e.toString()}');
      }
    }
  }

  /// 打开资源选择器（相册）
  Future<void> _openAssetPicker(BuildContext context, int remainingCount) async {
    try {
      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: remainingCount,
          requestType: _getRequestType(),
          specialPickerType: SpecialPickerType.noPreview,
          textDelegate: AssetPickerTextDelegate(),
        ),
      );

      if (result != null && result.isNotEmpty) {
        for (var entity in result) {
          final mediaItem = MediaItem.fromAssetEntity(entity);
          _addMedia(mediaItem);
        }

        // 选择完成回调
        onSelected?.call(_selectedMedia);
      }
    } catch (e) {
      debugPrint('选择资源失败: $e');
    }
  }

  /// 获取请求类型
  RequestType _getRequestType() {
    if (enableImage && enableVideo) {
      return RequestType.common;
    } else if (enableImage) {
      return RequestType.image;
    } else {
      return RequestType.video;
    }
  }

  /// 添加媒体项
  Future<void> _addMedia(MediaItem item) async {
    Logger().d("已经选择的文件路径: ${item.path}");
    // 如果是视频且没有缩略图，生成缩略图
    if (item.type == MediaType.video && item.thumbnailPath == null) {
      final thumbnailPath = await _generateVideoThumbnail(item);
      if (thumbnailPath != null) {
        item = MediaItem(id: item.id, path: item.path, type: item.type, file: item.file, assetEntity: item.assetEntity, thumbnailPath: thumbnailPath);
      }
    }
    _selectedMedia.add(item);
    notifyListeners();
  }

  /// 批量添加网络图片（用于浏览模式）
  void addNetworkImages(List<String> urls) {
    for (var url in urls) {
      final item = MediaItem.fromNetworkUrl(url);
      _selectedMedia.add(item);
    }
    notifyListeners();
  }

  /// 添加单个网络图片
  void addNetworkImage(String url) {
    final item = MediaItem.fromNetworkUrl(url);
    _selectedMedia.add(item);
    notifyListeners();
  }

  /// 添加视频
  void addNetworkVideo(String thumbnailUrl, String srcUrl) {
    final item = MediaItem.fromNetworkVideoUrl(thumbnailUrl, srcUrl);
    _selectedMedia.add(item);
    notifyListeners();
  }

  /// 生成视频缩略图并保存到临时目录
  Future<String?> _generateVideoThumbnail(MediaItem item) async {
    try {
      String? videoPath;
      if (item.file != null) {
        videoPath = item.file!.path;
      } else if (item.assetEntity != null) {
        // 从 assetEntity 获取视频路径
        final file = await item.assetEntity!.file;
        videoPath = file?.path;
      }

      if (videoPath == null) return null;

      // 生成缩略图数据
      final uint8list = await VideoThumbnail.thumbnailData(video: videoPath, imageFormat: ImageFormat.JPEG, maxWidth: 400, quality: 75);

      if (uint8list == null) return null;

      // 保存到临时目录
      final tempDir = Directory.systemTemp;
      final fileName = 'video_thumb_${item.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempFile = File('${tempDir.path}${Platform.pathSeparator}$fileName');
      await tempFile.writeAsBytes(uint8list);

      return tempFile.path;
    } catch (e) {
      debugPrint('生成视频缩略图失败: $e');
      return null;
    }
  }

  /// 删除指定索引的媒体
  void removeMedia(int index) {
    if (index >= 0 && index < _selectedMedia.length) {
      MediaItem mediaItem = _selectedMedia[index];
      _selectedMedia.removeAt(index);
      notifyListeners();

      onMediaDeleted?.call(_selectedMedia, mediaItem);
    }
  }

  /// 删除指定ID的媒体
  void removeMediaById(String id) {
    _selectedMedia.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  /// 清空所有选择
  void clearAll() {
    _selectedMedia.clear();
    notifyListeners();
  }

  /// 获取所有已选择的文件（仅 File 类型的）
  List<File> getFiles() {
    return _selectedMedia.where((item) => item.file != null).map((item) => item.file!).toList();
  }

  /// 获取所有资源实体（用于上传）
  Future<List<File>> getAllFiles() async {
    List<File> files = [];

    for (var item in _selectedMedia) {
      if (item.file != null) {
        files.add(item.file!);
      } else if (item.assetEntity != null) {
        // 从资源实体获取文件
        final file = await item.assetEntity!.file;
        if (file != null) {
          files.add(file);
        }
      }
    }

    return files;
  }

  /// 获取所有视频的缩略图路径（用于上传封面）
  /// 返回 Map，key 为媒体项的索引，value 为缩略图文件路径
  Map<int, String> getAllVideoThumbnails() {
    Map<int, String> thumbnails = {};
    for (int i = 0; i < _selectedMedia.length; i++) {
      final item = _selectedMedia[i];
      if (item.type == MediaType.video && item.thumbnailPath != null) {
        thumbnails[i] = item.thumbnailPath!;
      }
    }
    return thumbnails;
  }

  /// 获取指定媒体项的缩略图路径
  String? getThumbnailPath(int index) {
    if (index >= 0 && index < _selectedMedia.length) {
      return _selectedMedia[index].thumbnailPath;
    }
    return null;
  }

  @override
  void dispose() {
    // 清理临时缩略图文件
    for (var item in _selectedMedia) {
      if (item.thumbnailPath != null) {
        try {
          final file = File(item.thumbnailPath!);
          if (file.existsSync()) {
            file.deleteSync();
          }
        } catch (e) {
          debugPrint('删除缩略图文件失败: $e');
        }
      }
    }
    _selectedMedia.clear();
    super.dispose();
  }
}
