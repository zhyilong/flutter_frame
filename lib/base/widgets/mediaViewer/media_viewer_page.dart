import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'models/media_item.dart';
import 'widgets/video_player_widget.dart';
import 'widgets/audio_player_widget.dart';
import 'utils/player_lifecycle_manager.dart';

/// 显示模式枚举
enum MediaViewerShowMode {
  /// 对话框模式
  dialog,

  /// 路由模式
  route,
}

/// 混合媒体画廊页面
///
/// 核心功能：
/// - 支持图片、视频、音频混排
/// - 统一的翻页体验
/// - 视频全屏时禁用翻页
/// - 页面指示器
/// - 媒体信息显示
class MediaViewerPage extends StatefulWidget {
  /// 媒体项列表
  final List<MediaItem> mediaItems;

  /// 初始显示的索引
  final int initialIndex;

  /// 背景颜色
  final Color backgroundColor;

  /// 页面切换完成回调
  final void Function(int index, MediaItem item)? onPageChanged;

  const MediaViewerPage({
    super.key,
    required this.mediaItems,
    this.initialIndex = 0,
    this.backgroundColor = Colors.black,
    this.onPageChanged,
  });

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  late PageController _pageController;
  late int _currentIndex;

  /// 是否有视频处于全屏状态
  bool _hasFullscreenVideo = false;

  /// 播放器生命周期管理器
  final PlayerLifecycleManager _lifecycleManager = PlayerLifecycleManager();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    // 释放所有播放器资源
    _lifecycleManager.disposeAll();
    _pageController.dispose();
    super.dispose();
  }

  /// 处理页面切换
  void _onPageChanged(int index) {
    // ⭐ 页面切换时暂停所有播放器
    _lifecycleManager.pauseAll();

    setState(() {
      _currentIndex = index;
    });

    // 调用外部回调
    widget.onPageChanged?.call(index, widget.mediaItems[index]);
  }

  /// 处理视频全屏状态变化
  void _onVideoFullscreenChanged(bool isFullscreen) {
    setState(() {
      _hasFullscreenVideo = isFullscreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaItems.isEmpty) {
      return Scaffold(
        backgroundColor: widget.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library, color: Colors.white54, size: 64),
              SizedBox(height: 16),
              Text('暂无内容', style: TextStyle(color: Colors.white54, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: GestureDetector(
        // ⭐ 添加单击关闭功能
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            // 媒体画廊
            _buildMediaGallery(),

            // 页面指示器（移到下方）
            _buildPageIndicator(),
          ],
        ),
      ),
    );
  }

  /// 构建媒体画廊
  Widget _buildMediaGallery() {
    return PhotoViewGallery.builder(
      // ⭐ 关键：全屏时禁用页面滚动
      scrollPhysics: _hasFullscreenVideo ? NeverScrollableScrollPhysics() : null,
      pageController: _pageController,
      onPageChanged: _onPageChanged,
      itemCount: widget.mediaItems.length,
      builder: (context, index) {
        final mediaItem = widget.mediaItems[index];
        return _buildMediaPage(mediaItem, index);
      },
      backgroundDecoration: BoxDecoration(color: widget.backgroundColor),
    );
  }

  /// 构建单个媒体页面
  PhotoViewGalleryPageOptions _buildMediaPage(MediaItem mediaItem, int index) {
    switch (mediaItem.type) {
      case MediaType.image:
        return _buildImagePage(mediaItem as ImageMediaItem);

      case MediaType.video:
        return _buildVideoPage(mediaItem as VideoMediaItem);

      case MediaType.audio:
        return _buildAudioPage(mediaItem as AudioMediaItem);
    }
  }

  /// 构建图片页面
  PhotoViewGalleryPageOptions _buildImagePage(ImageMediaItem item) {
    // 构建 ImageProvider
    ImageProvider<Object> imageProvider;

    if (item.imageUrl.startsWith('http')) {
      if (item.cacheImage) {
        imageProvider = CachedNetworkImageProvider(item.imageUrl);
      } else {
        imageProvider = NetworkImage(item.imageUrl);
      }
    } else {
      imageProvider = AssetImage(item.imageUrl);
    }

    return PhotoViewGalleryPageOptions(
      imageProvider: imageProvider,
      // ⭐ 初始状态：完整显示图片（contained），不铺满屏幕
      // 放大后：填满屏幕（covered），无黑色区域
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * 0.8,
      maxScale: PhotoViewComputedScale.covered * 3.0,
      heroAttributes: PhotoViewHeroAttributes(tag: item.uniqueId),
    );
  }

  /// 构建视频页面
  PhotoViewGalleryPageOptions _buildVideoPage(VideoMediaItem item) {
    return PhotoViewGalleryPageOptions.customChild(
      child: VideoPlayerWrapper(
        mediaItem: item,
        lifecycleManager: _lifecycleManager,
        autoPlay: item.autoPlay,
        looping: item.looping,
        showControls: item.showControls,
        initialVolume: item.initialVolume,
        onFullscreenChanged: _onVideoFullscreenChanged,
      ),
      // ⭐ 完全禁用手势和缩放
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.contained,
      gestureDetectorBehavior: HitTestBehavior.deferToChild, // 只让子组件处理手势
    );
  }

  /// 构建音频页面
  PhotoViewGalleryPageOptions _buildAudioPage(AudioMediaItem item) {
    return PhotoViewGalleryPageOptions.customChild(
      child: AudioPlayerWrapper(
        mediaItem: item,
        lifecycleManager: _lifecycleManager,
        autoPlay: item.autoPlay,
        looping: item.looping,
        showControls: item.showControls,
        initialVolume: item.initialVolume,
      ),
      // ⭐ 完全禁用手势和缩放
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.contained,
      gestureDetectorBehavior: HitTestBehavior.deferToChild, // 只让子组件处理手势
    );
  }

  /// 构建页面指示器
  Widget _buildPageIndicator() {
    if (widget.mediaItems.length <= 1) {
      return SizedBox.shrink();
    }

    // ⭐ 全屏播放时不显示分页指示器
    if (_hasFullscreenVideo) {
      return SizedBox.shrink();
    }

    return Positioned(
      bottom: 100, // ⭐ 距离屏幕底部 100 像素
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.mediaItems.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 6,
            width: _currentIndex == index ? 20 : 6,
            decoration: BoxDecoration(
              color: _currentIndex == index ? Colors.white : Colors.white54,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}
