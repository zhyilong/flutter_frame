import 'package:flutter_sound/flutter_sound.dart';
import 'package:video_player/video_player.dart';

/// 播放器生命周期管理器
///
/// 管理视频和音频播放器的生命周期
/// 确保在页面切换时正确暂停和释放播放器资源
class PlayerLifecycleManager {
  /// 当前注册的视频播放器
  VideoPlayerController? _videoController;

  /// 当前注册的音频播放器
  FlutterSoundPlayer? _audioPlayer;

  /// 创建播放器生命周期管理器
  PlayerLifecycleManager();

  /// 注册视频播放器
  void registerVideoPlayer(VideoPlayerController controller) {
    // 先暂停并释放之前的播放器
    pauseAndDisposeVideoPlayer();

    _videoController = controller;
  }

  /// 注册音频播放器
  void registerAudioPlayer(FlutterSoundPlayer player) {
    // 先暂停并释放之前的播放器
    pauseAndDisposeAudioPlayer();

    _audioPlayer = player;
  }

  /// 注销视频播放器
  void unregisterVideoPlayer() {
    _videoController = null;
  }

  /// 注销音频播放器
  void unregisterAudioPlayer() {
    _audioPlayer = null;
  }

  /// 暂停当前视频播放器
  Future<void> pauseVideoPlayer() async {
    if (_videoController != null && _videoController!.value.isPlaying) {
      await _videoController!.pause();
    }
  }

  /// 暂停当前音频播放器
  Future<void> pauseAudioPlayer() async {
    if (_audioPlayer != null && _audioPlayer!.isPlaying) {
      await _audioPlayer!.pausePlayer();
    }
  }

  /// 暂停并释放视频播放器
  Future<void> pauseAndDisposeVideoPlayer() async {
    if (_videoController != null) {
      try {
        if (_videoController!.value.isPlaying) {
          await _videoController!.pause();
        }
      } catch (e) {
        // 忽略暂停失败
      }
      try {
        await _videoController!.dispose();
      } catch (e) {
        // 忽略释放失败
      }
      _videoController = null;
    }
  }

  /// 暂停并释放音频播放器
  Future<void> pauseAndDisposeAudioPlayer() async {
    if (_audioPlayer != null) {
      try {
        if (_audioPlayer!.isPlaying) {
          await _audioPlayer!.stopPlayer();
        }
      } catch (e) {
        // 忽略停止失败
      }
      try {
        await _audioPlayer!.closePlayer();
      } catch (e) {
        // 忽略关闭失败
      }
      _audioPlayer = null;
    }
  }

  /// 暂停所有播放器
  Future<void> pauseAll() async {
    await pauseVideoPlayer();
    await pauseAudioPlayer();
  }

  /// 释放所有播放器资源
  Future<void> disposeAll() async {
    await pauseAndDisposeVideoPlayer();
    await pauseAndDisposeAudioPlayer();
  }

  /// 获取当前视频播放器
  VideoPlayerController? get currentVideoPlayer => _videoController;

  /// 获取当前音频播放器
  FlutterSoundPlayer? get currentAudioPlayer => _audioPlayer;
}
