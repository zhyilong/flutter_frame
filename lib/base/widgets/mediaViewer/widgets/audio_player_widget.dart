import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/media_cache_manager.dart';
import '../utils/player_lifecycle_manager.dart';
import '../models/media_item.dart';

/// 音频播放器状态
enum AudioPlayerStatus {
  loading, // 加载中
  ready, // 准备就绪
  playing, // 播放中
  paused, // 已暂停
  stopped, // 已停止
  completed, // 播放完成
  error, // 错误
}

/// 音频播放器包装器
///
/// 核心功能：
/// - 支持封面显示
/// - 播放控制（播放/暂停、进度条）
/// - 显示音频信息（标题、艺术家、专辑）
/// - 支持网络和本地音频
/// - 音频缓存支持
class AudioPlayerWrapper extends StatefulWidget {
  /// 媒体项（包含音频URL和封面URL）
  final AudioMediaItem mediaItem;

  /// 生命周期管理器（用于翻页暂停）
  final PlayerLifecycleManager? lifecycleManager;

  /// 是否自动播放
  final bool autoPlay;

  /// 是否循环播放
  final bool looping;

  /// 是否显示控制栏
  final bool showControls;

  /// 初始音量 (0.0 - 1.0)
  final double initialVolume;

  const AudioPlayerWrapper({
    super.key,
    required this.mediaItem,
    this.lifecycleManager,
    this.autoPlay = false,
    this.looping = false,
    this.showControls = true,
    this.initialVolume = 1.0,
  });

  @override
  State<AudioPlayerWrapper> createState() => _AudioPlayerWrapperState();
}

class _AudioPlayerWrapperState extends State<AudioPlayerWrapper> {
  late FlutterSoundPlayer _player;
  AudioPlayerStatus _status = AudioPlayerStatus.loading;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // 缓存管理器
  final MediaCacheManager _cacheManager = MediaCacheManager();

  // 本地音频路径（缓存或下载后的路径）
  String? _localAudioPath;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _player = FlutterSoundPlayer();
      await _player.openPlayer();

      // 注册到生命周期管理器
      widget.lifecycleManager?.registerAudioPlayer(_player);

      // 设置监听器
      _player.setSubscriptionDuration(const Duration(milliseconds: 100)); // ⭐ 设置更新频率为100ms
      _player.onProgress!.listen((event) {
        if (mounted) {
          setState(() {
            _position = event.position;
            _duration = event.duration;
          });
        }
      });

      // 获取音频文件（优先使用缓存）
      String audioPath = widget.mediaItem.audioUrl;
      final cachedFile = await _cacheManager.getCachedFile(widget.mediaItem.audioUrl, MediaType.audio);
      if (cachedFile != null && await cachedFile.exists()) {
        audioPath = cachedFile.path;
        debugPrint('使用缓存音频: $audioPath');
      } else {
        // 缓存不存在，先下载
        final downloadedFile = await _cacheManager.getOrDownloadMedia(widget.mediaItem.audioUrl, MediaType.audio);
        if (downloadedFile != null) {
          audioPath = downloadedFile.path;
          debugPrint('使用下载的音频: $audioPath');
        } else {
          debugPrint('使用网络URL直接播放');
        }
      }

      // 保存本地路径用于播放
      _localAudioPath = audioPath;

      if (mounted) {
        setState(() {
          _status = AudioPlayerStatus.ready;
        });
      }

      if (widget.autoPlay) {
        _play();
      }
    } catch (e) {
      debugPrint('音频初始化失败: $e');
      if (mounted) {
        setState(() {
          _status = AudioPlayerStatus.error;
        });
      }
    }
  }

  @override
  void dispose() {
    // 注销生命周期管理器
    widget.lifecycleManager?.unregisterAudioPlayer();
    // 安全停止并关闭播放器
    try {
      if (_player.isPlaying) {
        _player.stopPlayer();
      }
    } catch (e) {
      // 忽略停止失败
    }
    _player.closePlayer();
    // 取消下载任务
    _cacheManager.cancelAllDownloads();
    super.dispose();
  }

  /// 播放
  Future<void> _play() async {
    try {
      await _player.startPlayer(
        fromURI: _localAudioPath ?? widget.mediaItem.audioUrl,
        whenFinished: () {
          if (mounted) {
            setState(() {
              _status = AudioPlayerStatus.completed;
            });
          }
        },
      );
      if (mounted) {
        setState(() {
          _status = AudioPlayerStatus.playing;
        });
      }
    } catch (e) {
      debugPrint('播放失败: $e');
    }
  }

  /// 暂停
  Future<void> _pause() async {
    try {
      await _player.pausePlayer();
      if (mounted) {
        setState(() {
          _status = AudioPlayerStatus.paused;
        });
      }
    } catch (e) {
      debugPrint('暂停失败: $e');
    }
  }

  /// 从暂停恢复播放
  Future<void> _resume() async {
    try {
      await _player.resumePlayer();
      if (mounted) {
        setState(() {
          _status = AudioPlayerStatus.playing;
        });
      }
    } catch (e) {
      debugPrint('恢复播放失败: $e');
    }
  }

  /// 播放/暂停切换
  void _togglePlayPause() {
    if (_status == AudioPlayerStatus.playing) {
      _pause();
    } else if (_status == AudioPlayerStatus.paused) {
      // 如果是暂停状态，使用 resumePlayer 恢复播放
      _resume();
    } else {
      // 其他状态（ready、stopped、completed），使用 startPlayer 开始播放
      _play();
    }
  }

  /// 跳转到指定位置
  Future<void> _seek(Duration position) async {
    try {
      await _player.seekToPlayer(position);
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    } catch (e) {
      debugPrint('跳转失败: $e');
    }
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
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ⭐ 封面/图标容器
            _buildCoverContainer(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 构建封面容器（正方形圆角）
  Widget _buildCoverContainer() {
    return Container(
        width: 220,
        height: 220,
        clipBehavior: Clip.hardEdge,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.white, blurRadius: 2, blurStyle: BlurStyle.outer)]),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 封面图片或背景
            widget.mediaItem.audioCoverUrl != null && widget.mediaItem.audioCoverUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: widget.mediaItem.audioCoverUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white54),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.music_note,
                        color: Colors.white54,
                        size: 80,
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.music_note,
                      color: Colors.white54,
                      size: 80,
                    ),
                  ),

            // 中间的播放/暂停按钮
            Center(
              child: _buildPlayPauseButton(),
            ),

            //
            Positioned(left: 0, right: 0, bottom: 10, child: _buildProgressBar()),
          ],
        ));
  }

  /// 构建播放/暂停按钮
  Widget _buildPlayPauseButton() {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1)),
        child: Icon(
          _status == AudioPlayerStatus.playing ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }

  /// 构建进度条
  Widget _buildProgressBar() {
    return Container(
      height: 26,
      color: Colors.black26,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Text(
            _formatDuration(_position),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: SliderTheme(
              data: const SliderThemeData(
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
                trackHeight: 3,
              ),
              child: Slider(
                key: ValueKey(_position.inMilliseconds), // ⭐ 添加key强制重建
                value: _duration.inMilliseconds > 0 ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0) : 0.0,
                onChanged: (value) {
                  final newPosition = Duration(
                    milliseconds: (value * _duration.inMilliseconds).toInt(),
                  );
                  _seek(newPosition);
                },
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            _formatDuration(_duration),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
