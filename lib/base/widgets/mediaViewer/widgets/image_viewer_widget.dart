import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 图片查看器包装器
///
/// 核心功能：
/// - 支持网络和本地图片
/// - 捏合缩放
/// - 拖动查看
/// - 使用 PhotoView 实现流畅的手势交互
class ImageViewerWrapper extends StatelessWidget {
  /// 图片 URL
  final String imageUrl;

  /// 是否缓存图片
  final bool cacheImage;

  /// 图片标题
  final String? title;

  /// 初始缩放比例
  final PhotoViewComputedScale initialScale;

  /// 最小缩放比例
  final PhotoViewComputedScale minScale;

  /// 最大缩放比例
  final PhotoViewComputedScale maxScale;

  /// Hero 标签
  final String? heroTag;

  const ImageViewerWrapper({
    super.key,
    required this.imageUrl,
    this.cacheImage = true,
    this.title,
    this.initialScale = PhotoViewComputedScale.contained,
    PhotoViewComputedScale? minScale,
    PhotoViewComputedScale? maxScale,
    this.heroTag,
  })  : minScale = minScale ?? PhotoViewComputedScale.contained * 0.8,
        maxScale = maxScale ?? PhotoViewComputedScale.covered * 2.5;

  @override
  Widget build(BuildContext context) {
    return PhotoView.customChild(
      initialScale: initialScale,
      minScale: minScale,
      maxScale: maxScale,
      heroAttributes: heroTag != null
          ? PhotoViewHeroAttributes(tag: heroTag!)
          : null,
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      child: _buildImage(),
    );
  }

  /// 构建图片
  Widget _buildImage() {
    if (cacheImage && imageUrl.startsWith('http')) {
      // 网络图片（缓存）
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(color: Colors.white54),
        ),
        errorWidget: (context, url, error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.white54, size: 48),
              SizedBox(height: 16),
              Text(
                '图片加载失败',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    } else if (imageUrl.startsWith('http')) {
      // 网络图片（不缓存）
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.white54, size: 48),
                SizedBox(height: 16),
                Text(
                  '图片加载失败',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: Colors.white54,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    } else {
      // 本地图片
      return Image.asset(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.white54, size: 48),
                SizedBox(height: 16),
                Text(
                  '图片加载失败',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        },
      );
    }
  }
}
