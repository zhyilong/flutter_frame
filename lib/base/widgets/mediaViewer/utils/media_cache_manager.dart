import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../models/media_item.dart';

/// 多媒体缓存管理器
///
/// 管理视频和音频缓存，避免重复下载
class MediaCacheManager {
  /// 缓存的文件路径集合
  final Set<String> _cachedFiles = {};

  /// Dio实例
  late final Dio _dio;

  /// 取消令牌（用于取消下载任务）
  final CancelToken _cancelToken = CancelToken();

  /// 创建缓存管理器
  MediaCacheManager() {
    _dio = Dio();
    // 配置超时时间
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 15);
  }

  /// 取消所有正在进行的下载任务
  void cancelAllDownloads() {
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel('取消下载');
    }
  }

  /// 生成缓存文件名（使用URL的hash作为文件名）
  String _getCacheFileName(String url, MediaType type) {
    final uri = Uri.parse(url);
    final hash = uri.toString().hashCode;
    final extension = _getExtension(uri.path, type);
    return 'media_cache_$hash.$extension';
  }

  /// 根据路径或类型获取扩展名
  String _getExtension(String path, MediaType type) {
    final pathSegments = path.split('.');
    if (pathSegments.length > 1) {
      return pathSegments.last.toLowerCase();
    }
    // 根据类型返回默认扩展名
    switch (type) {
      case MediaType.video:
        return 'mp4';
      case MediaType.audio:
        return 'mp3';
      case MediaType.image:
        return 'jpg';
    }
  }

  /// 获取缓存文件
  Future<File?> getCachedFile(String url, MediaType type) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = _getCacheFileName(url, type);
      final file = File('${tempDir.path}/$fileName');
      return file;
    } catch (e) {
      return null;
    }
  }

  /// 获取或下载媒体文件
  /// 返回本地文件路径
  Future<File?> getOrDownloadMedia(String url, MediaType type) async {
    // 先检查缓存
    final cachedFile = await getCachedFile(url, type);
    if (cachedFile != null && await cachedFile.exists()) {
      _cachedFiles.add(cachedFile.path);
      return cachedFile;
    }

    // 下载文件
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = _getCacheFileName(url, type);
      final file = File('${tempDir.path}/$fileName');

      await _dio.download(
        url,
        file.path,
        cancelToken: _cancelToken,
      );

      _cachedFiles.add(file.path);
      return file;
    } catch (e) {
      return null;
    }
  }

  /// 清理所有缓存（仅在页面销毁时调用）
  Future<void> clearAllCache() async {
    for (final path in _cachedFiles.toList()) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // 忽略删除失败
      }
    }
    _cachedFiles.clear();
  }

  /// 获取当前缓存数量
  int get cachedCount => _cachedFiles.length;
}
