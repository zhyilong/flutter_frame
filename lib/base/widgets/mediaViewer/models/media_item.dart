/// 媒体类型枚举
enum MediaType {
  video,
  image,
  audio,
}

/// 媒体项基类（抽象类）
///
/// 定义所有媒体类型的通用属性和方法
abstract class MediaItem {
  /// 媒体类型
  final MediaType type;

  /// 唯一标识符（用于 Hero 动画等）
  final String uniqueId;

  /// 标题/描述
  final String? title;

  /// 封面图片 URL（视频/音频使用）
  final String? coverUrl;

  /// 资源 URL（网络资源）
  final String? url;

  /// 本地资源路径
  final String? assetPath;

  /// 是否自动播放（视频/音频）
  final bool autoPlay;

  MediaItem({
    required this.type,
    required this.uniqueId,
    this.title,
    this.coverUrl,
    this.url,
    this.assetPath,
    this.autoPlay = false,
  });
}

/// 图片媒体项
class ImageMediaItem extends MediaItem {
  /// 图片 URL
  final String imageUrl;

  /// 是否缓存图片
  final bool cacheImage;

  ImageMediaItem({
    required this.imageUrl,
    required super.uniqueId,
    super.title,
    this.cacheImage = true,
  }) : super(
          type: MediaType.image,
          url: imageUrl,
        );

  /// 从网络 URL 创建
  factory ImageMediaItem.network({
    required String url,
    String? uniqueId,
    String? title,
    bool cacheImage = true,
  }) {
    return ImageMediaItem(
      imageUrl: url,
      uniqueId: uniqueId ?? url,
      title: title,
      cacheImage: cacheImage,
    );
  }

  /// 从资源创建
  factory ImageMediaItem.asset({
    required String assetPath,
    required String uniqueId,
    String? title,
  }) {
    return ImageMediaItem(
      imageUrl: assetPath,
      uniqueId: uniqueId,
      title: title,
      cacheImage: false,
    );
  }
}

/// 视频媒体项
class VideoMediaItem extends MediaItem {
  /// 视频 URL
  final String videoUrl;

  /// 封面图片 URL
  final String? videoCoverUrl;

  /// 是否显示控制栏
  final bool showControls;

  /// 是否循环播放
  final bool looping;

  /// 初始音量 (0.0 - 1.0)
  final double initialVolume;

  VideoMediaItem({
    required this.videoUrl,
    required super.uniqueId,
    super.title,
    this.videoCoverUrl,
    this.showControls = true,
    this.looping = false,
    this.initialVolume = 1.0,
    super.autoPlay = false,
  }) : super(
          type: MediaType.video,
          url: videoUrl,
          coverUrl: videoCoverUrl,
        );

  /// 从网络 URL 创建
  factory VideoMediaItem.network({
    required String url,
    required String uniqueId,
    String? title,
    String? coverUrl,
    bool showControls = true,
    bool looping = false,
    bool autoPlay = false,
    double volume = 1.0,
  }) {
    return VideoMediaItem(
      videoUrl: url,
      uniqueId: uniqueId,
      title: title,
      videoCoverUrl: coverUrl,
      showControls: showControls,
      looping: looping,
      autoPlay: autoPlay,
      initialVolume: volume,
    );
  }

  /// 从资源创建
  factory VideoMediaItem.asset({
    required String assetPath,
    required String uniqueId,
    String? title,
    String? coverUrl,
    bool showControls = true,
    bool looping = false,
    bool autoPlay = false,
  }) {
    return VideoMediaItem(
      videoUrl: assetPath,
      uniqueId: uniqueId,
      title: title,
      videoCoverUrl: coverUrl,
      showControls: showControls,
      looping: looping,
      autoPlay: autoPlay,
    );
  }

  @override
  String? get coverUrl => videoCoverUrl;
}

/// 音频媒体项
class AudioMediaItem extends MediaItem {
  /// 音频 URL
  final String audioUrl;

  /// 封面图片 URL
  final String? audioCoverUrl;

  /// 艺术家
  final String? artist;

  /// 专辑名称
  final String? album;

  /// 是否显示控制栏
  final bool showControls;

  /// 是否循环播放
  final bool looping;

  /// 初始音量 (0.0 - 1.0)
  final double initialVolume;

  AudioMediaItem({
    required this.audioUrl,
    required super.uniqueId,
    super.title,
    this.audioCoverUrl,
    this.artist,
    this.album,
    this.showControls = true,
    this.looping = false,
    this.initialVolume = 1.0,
    super.autoPlay = false,
  }) : super(
          type: MediaType.audio,
          url: audioUrl,
          coverUrl: audioCoverUrl,
        );

  /// 从网络 URL 创建
  factory AudioMediaItem.network({
    required String url,
    required String uniqueId,
    String? title,
    String? coverUrl,
    String? artist,
    String? album,
    bool showControls = true,
    bool looping = false,
    bool autoPlay = false,
    double volume = 1.0,
  }) {
    return AudioMediaItem(
      audioUrl: url,
      uniqueId: uniqueId,
      title: title,
      audioCoverUrl: coverUrl,
      artist: artist,
      album: album,
      showControls: showControls,
      looping: looping,
      autoPlay: autoPlay,
      initialVolume: volume,
    );
  }

  /// 从资源创建
  factory AudioMediaItem.asset({
    required String assetPath,
    required String uniqueId,
    String? title,
    String? coverUrl,
    String? artist,
    String? album,
    bool showControls = true,
    bool looping = false,
  }) {
    return AudioMediaItem(
      audioUrl: assetPath,
      uniqueId: uniqueId,
      title: title,
      audioCoverUrl: coverUrl,
      artist: artist,
      album: album,
      showControls: showControls,
      looping: looping,
    );
  }

  @override
  String? get coverUrl => audioCoverUrl;
}
