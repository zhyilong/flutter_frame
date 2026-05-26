import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 图片查看器页面
///
/// 支持多张网络图片浏览，可捏合缩放和左右滑动翻页
/// ⭐ 使用 PhotoViewGallery.builder，完美解决手势冲突问题
class ImageViewerPage extends StatefulWidget {
  /// 图片URL列表
  final List<String> imageUrls;

  /// 初始显示的图片索引
  final int initialIndex;

  /// 背景颜色
  final Color backgroundColor;

  /// 页面指示器颜色
  final Color indicatorColor;

  /// 页面切换完成回调
  ///
  /// [index] 当前页面索引
  /// [imageUrl] 当前页面图片URL
  final void Function(int index, String imageUrl)? onPageChanged;

  const ImageViewerPage({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.backgroundColor = Colors.black,
    this.indicatorColor = Colors.white,
    this.onPageChanged,
  });

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    // 调用外部回调，传递当前索引和图片URL
    widget.onPageChanged?.call(index, widget.imageUrls[index]);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Scaffold(
        backgroundColor: widget.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.photo_library_outlined, color: Colors.white54, size: 64),
              const SizedBox(height: 16),
              const Text('暂无图片', style: TextStyle(color: Colors.white54, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: GestureDetector(
        // 点击背景关闭
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            // 图片画廊
            _buildPhotoViewGallery(),

            // 多点页面指示器
            if (widget.imageUrls.length > 1) _buildDotIndicator(),
          ],
        ),
      ),
    );
  }

  /// 构建 PhotoView 画廊
  /// ⭐ PhotoViewGallery 内部智能处理手势冲突：
  /// - 图片未放大时：水平滑动翻页
  /// - 图片放大后：水平拖动查看图片内容，边缘拖动才翻页
  Widget _buildPhotoViewGallery() {
    return PhotoViewGallery.builder(
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
      enableRotation: false,
      gaplessPlayback: true,
    );
  }

  /// 构建多点页面指示器
  Widget _buildDotIndicator() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 32,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.imageUrls.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 6,
            width: _currentIndex == index ? 16 : 6,
            decoration: BoxDecoration(
              color: _currentIndex == index ? widget.indicatorColor : widget.indicatorColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}
