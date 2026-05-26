import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/media_cache_manager.dart';
import '../utils/player_lifecycle_manager.dart';
import '../models/media_item.dart';

/// 视频播放器状态
enum VideoPlayerStatus {
  loading, // 加载中
  ready, // 准备就绪
  playing, // 播放中
  paused, // 已暂停
  completed, // 播放完成
  error, // 错误
}

/// 视频播放器包装器
///
/// 核心功能：
/// - 支持全屏播放
/// - 全屏时禁用左右滑动翻页
/// - 支持封面显示
/// - 播放控制栏
/// - 视频缓存支持
class VideoPlayerWrapper extends StatefulWidget {
  /// 媒体项（包含视频URL和封面URL）
  final VideoMediaItem mediaItem;

  /// 生命周期管理器（用于翻页暂停）
  final PlayerLifecycleManager? lifecycleManager;

  /// 是否自动播放
  final bool autoPlay;

  /// 是否循环播放
  final bool looping;

  /// 是否显示控制栏
  final bool showControls;

  /// 初始音量
  final double initialVolume;

  /// 全屏状态变化回调
  final ValueChanged<bool>? onFullscreenChanged;

  const VideoPlayerWrapper({
    super.key,
    required this.mediaItem,
    this.lifecycleManager,
    this.autoPlay = false,
    this.looping = false,
    this.showControls = true,
    this.initialVolume = 1.0,
    this.onFullscreenChanged,
  });

  @override
  State<VideoPlayerWrapper> createState() => _VideoPlayerWrapperState();
}

class _VideoPlayerWrapperState extends State<VideoPlayerWrapper> {
  late VideoPlayerController _controller;
  VideoPlayerStatus _status = VideoPlayerStatus.loading;
  bool _isFullscreen = false;
  bool _showControlsOverlay = true;
  double _volume = 1.0;

  // 控制栏自动隐藏定时器
  DateTime? _lastInteractionTime;

  // 缓存管理器
  final MediaCacheManager _cacheManager = MediaCacheManager();

  @override
  void initState() {
    super.initState();
    _volume = widget.initialVolume;
    _initializeVideo();
  }

  void _initializeVideo() async {
    try {
      // 获取缓存文件路径
      final File? cachedFile = await _getCachedVideoFile();

      if (cachedFile != null && await cachedFile.exists()) {
        // 使用缓存文件
        _controller = VideoPlayerController.file(cachedFile);
        debugPrint('使用缓存视频: ${cachedFile.path}');
      } else {
        // 缓存不存在，先下载再播放
        final File? downloadedFile = await _cacheVideo();
        if (downloadedFile != null) {
          _controller = VideoPlayerController.file(downloadedFile);
          debugPrint('使用下载的视频: ${downloadedFile.path}');
        } else {
          // 下载失败，回退到直接播放
          _controller = VideoPlayerController.networkUrl(
            Uri.parse(widget.mediaItem.videoUrl),
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          );
          debugPrint('使用网络URL直接播放');
        }
      }

      await _controller.initialize();
      _controller.setLooping(widget.looping);
      _controller.setVolume(_volume);

      // 注册到生命周期管理器
      widget.lifecycleManager?.registerVideoPlayer(_controller);

      if (widget.autoPlay) {
        await _controller.play();
      }

      if (mounted) {
        setState(() {
          _status = VideoPlayerStatus.ready;
        });
      }

      // 监听播放状态
      _controller.addListener(_onVideoStateChanged);
    } catch (e) {
      debugPrint('视频初始化失败: $e');
      if (mounted) {
        setState(() {
          _status = VideoPlayerStatus.error;
        });
      }
    }
  }

  /// 获取缓存视频文件
  Future<File?> _getCachedVideoFile() async {
    return await _cacheManager.getCachedFile(widget.mediaItem.videoUrl, MediaType.video);
  }

  /// 缓存视频到临时目录
  Future<File?> _cacheVideo() async {
    return await _cacheManager.getOrDownloadMedia(widget.mediaItem.videoUrl, MediaType.video);
  }

  void _onVideoStateChanged() {
    if (!mounted) return;

    VideoPlayerStatus newStatus;
    if (_controller.value.isPlaying) {
      newStatus = VideoPlayerStatus.playing;
    } else if (_controller.value.isInitialized) {
      if (_controller.value.position >= _controller.value.duration) {
        newStatus = VideoPlayerStatus.completed;
      } else {
        newStatus = VideoPlayerStatus.paused;
      }
    } else {
      newStatus = _status;
    }

    if (newStatus != _status) {
      setState(() {
        _status = newStatus;
      });

      // ⭐ 视频播放完成时，如果是全屏状态，自动退出全屏
      if (newStatus == VideoPlayerStatus.completed && _isFullscreen) {
        _exitFullscreen();
        setState(() {
          _isFullscreen = false;
        });
        widget.onFullscreenChanged?.call(false);
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoStateChanged);
    // 注销生命周期管理器
    widget.lifecycleManager?.unregisterVideoPlayer();
    // 安全释放视频控制器
    if (_controller.value.isInitialized) {
      _controller.dispose();
    }
    // 取消下载任务
    _cacheManager.cancelAllDownloads();
    // 退出全屏时恢复系统UI
    if (_isFullscreen) {
      _exitFullscreen();
    }
    super.dispose();
  }

  /// 播放/暂停
  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _resetControlsHideTimer();
    });
  }

  /// 切换全屏
  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      _resetControlsHideTimer();

      if (_isFullscreen) {
        _enterFullscreen();
      } else {
        _exitFullscreen();
      }

      widget.onFullscreenChanged?.call(_isFullscreen);
    });
  }

  /// 进入全屏
  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// 退出全屏
  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// 重置控制栏隐藏定时器
  void _resetControlsHideTimer() {
    setState(() {
      _lastInteractionTime = DateTime.now();
      _showControlsOverlay = true;
    });
  }

  /// 格式化时长
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // 检查控制栏是否应该隐藏
    _checkControlsVisibility();

    return Container(
      color: Colors.black,
      child: _buildContent(),
    );
  }

  /// 检查控制栏可见性（延迟执行，避免在 build 中调用 setState）
  void _checkControlsVisibility() {
    if (_lastInteractionTime != null &&
        _showControlsOverlay &&
        DateTime.now().difference(_lastInteractionTime!) > const Duration(seconds: 3) &&
        _status == VideoPlayerStatus.playing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _showControlsOverlay = false;
          });
        }
      });
    }
  }

  /// 构建内容
  Widget _buildContent() {
    if (_status == VideoPlayerStatus.loading) {
      return _buildCoverOrLoading();
    }

    if (_status == VideoPlayerStatus.error) {
      return _buildErrorWidget();
    }

    if (!_controller.value.isInitialized) {
      return _buildCoverWithPlayButton();
    }

    return Stack(
      fit: _isFullscreen ? StackFit.expand : StackFit.loose,
      children: [
        // 视频播放器
        Center(
          child: _isFullscreen
              // ⭐ 全屏时：填满屏幕，裁剪多余部分（无黑边，不变形）
              ? ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.center,
                    maxWidth: double.infinity,
                    maxHeight: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),
                )
              // 非全屏时：保持视频比例，完整显示视频
              : AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    children: [
                      // 视频播放器
                      VideoPlayer(_controller),

                      // ⭐ 点击整个视频区域切换播放/暂停
                      GestureDetector(
                        onTap: _togglePlayPause,
                        behavior: HitTestBehavior.opaque,
                      ),

                      // 中间的播放按钮（只在暂停时显示）
                      if (!_controller.value.isPlaying && _controller.value.isInitialized)
                        Center(
                          child: GestureDetector(
                            onTap: _togglePlayPause,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1)),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ),

                      // ⭐ 底部进度条（浮在视频之上）
                      if (widget.showControls && _showControlsOverlay)
                        Positioned(
                          bottom: 20, // ⭐ 距离底部20像素
                          left: 0,
                          right: 0,
                          child: _buildBottomBar(),
                        ),
                    ],
                  ),
                ),
        ),

        // ⭐ 全屏时的控制层（进度条和点击区域）
        if (_isFullscreen)
          Positioned.fill(
            child: Stack(
              children: [
                // 点击整个视频区域切换播放/暂停
                GestureDetector(
                  onTap: _togglePlayPause,
                  behavior: HitTestBehavior.opaque,
                ),

                // 中间的播放按钮（只在暂停时显示）
                if (!_controller.value.isPlaying && _controller.value.isInitialized)
                  Center(
                    child: GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1)),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),

                // ⭐ 底部进度条（浮在视频之上）
                if (widget.showControls && _showControlsOverlay)
                  Positioned(
                    bottom: 20, // ⭐ 距离底部20像素
                    left: 0,
                    right: 0,
                    child: _buildBottomBar(),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  /// 构建封面图或视频图标（加载时）
  Widget _buildCoverOrLoading() {
    final hasCover = widget.mediaItem.videoCoverUrl != null && widget.mediaItem.videoCoverUrl!.isNotEmpty;

    if (hasCover) {
      // 有封面图，显示封面 + 加载指示器
      return Center(
        child: AspectRatio(
          aspectRatio: 16 / 9, // 默认视频比例
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 封面图
              CachedNetworkImage(
                imageUrl: widget.mediaItem.videoCoverUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.black,
                  child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.black87,
                  child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
              ),

              // 视频加载指示器（浮在封面图之上）
              Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black54,
                    ],
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      SizedBox(height: 16),
                      Text(
                        '视频加载中...',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // 没有封面图，显示视频图标
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library,
                color: Colors.white54,
                size: 64,
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(color: Colors.white54),
              SizedBox(height: 8),
              Text(
                '视频加载中...',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }
  }

  /// 构建错误提示
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.white54, size: 48),
          SizedBox(height: 16),
          Text(
            '视频加载失败',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  /// 构建封面+播放按钮（未播放时）
  Widget _buildCoverWithPlayButton() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 封面图
        if (widget.mediaItem.videoCoverUrl != null && widget.mediaItem.videoCoverUrl!.isNotEmpty)
          CachedNetworkImage(
            imageUrl: widget.mediaItem.videoCoverUrl!,
            fit: BoxFit.contain,
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(color: Colors.white54),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.black26,
            ),
          ),

        // 播放按钮
        Center(
          child: GestureDetector(
            onTap: () {
              _controller.play();
              _resetControlsHideTimer();
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1)),
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建底部栏（进度条）
  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black54,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // 进度条
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30), // ⭐ 增加左右边距为30
              child: Row(
                children: [
                  // 当前时间
                  Text(
                    _formatDuration(_controller.value.position),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(width: 8),

                  // 进度条
                  Expanded(
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: Colors.white,
                        bufferedColor: Colors.white24,
                        backgroundColor: Colors.white12,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),
                  // 总时长
                  Text(
                    _formatDuration(_controller.value.duration),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),

                  const SizedBox(width: 8),

                  // ⭐ 全屏按钮
                  GestureDetector(
                    onTap: _toggleFullscreen,
                    child: Icon(
                      _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
