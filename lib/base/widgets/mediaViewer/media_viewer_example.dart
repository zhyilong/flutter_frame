import 'package:flutter/material.dart';
import 'media_viewer.dart';
import 'media_viewer_page.dart';
import 'models/media_item.dart';

/// 混合媒体画廊示例页面
///
/// 提供 3 个完整示例展示如何使用 MixedMediaGalleryPage
class MediaViewerExamplePage extends StatelessWidget {
  const MediaViewerExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('混合媒体画廊示例'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildExampleCard(
            context,
            title: '示例 1：图片画廊',
            subtitle: '纯图片浏览',
            icon: Icons.image,
            color: Colors.blue,
            onTap: () => _openImageGalleryExample(context),
          ),
          SizedBox(height: 12),
          _buildExampleCard(
            context,
            title: '示例 2：视频专辑',
            subtitle: '多个视频播放，支持全屏',
            icon: Icons.videocam,
            color: Colors.red,
            onTap: () => _openVideoGalleryExample(context),
          ),
          SizedBox(height: 12),
          _buildExampleCard(
            context,
            title: '示例 3：音乐播放器',
            subtitle: '音频播放，带封面',
            icon: Icons.audiotrack,
            color: Colors.green,
            onTap: () => _openAudioGalleryExample(context),
          ),
          SizedBox(height: 12),
          _buildExampleCard(
            context,
            title: '示例 4：混合内容',
            subtitle: '图片 + 视频 + 音频混排',
            icon: Icons.collections,
            color: Colors.purple,
            onTap: () => _openMixedGalleryExample(context),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  /// 示例 1：图片画廊
  void _openImageGalleryExample(BuildContext context) {
    final mediaItems = [
      ImageMediaItem.network(
        url: 'https://picsum.photos/800/600?random=1',
        uniqueId: 'image_1',
        title: '风景图片 1',
      ),
      ImageMediaItem.network(
        url: 'https://picsum.photos/800/600?random=2',
        uniqueId: 'image_2',
        title: '风景图片 2',
      ),
      ImageMediaItem.network(
        url: 'https://picsum.photos/800/600?random=3',
        uniqueId: 'image_3',
        title: '风景图片 3',
      ),
      ImageMediaItem.network(
        url: 'https://picsum.photos/800/600?random=4',
        uniqueId: 'image_4',
        title: '风景图片 4',
      ),
    ];

    // 使用静态方法打开（路由模式，默认 fade 过渡）
    MediaViewer.show(
      context: context,
      mediaItems: mediaItems,
      initialIndex: 0,
    );
  }

  /// 示例 2：视频专辑
  void _openVideoGalleryExample(BuildContext context) {
    final mediaItems = [
      VideoMediaItem.network(
        url: 'https://media.w3.org/2010/05/sintel/trailer.mp4',
        uniqueId: 'video_1',
        title: 'Sintel 预告片',
        coverUrl: 'https://picsum.photos/800/600?random=11',
      ),
      VideoMediaItem.network(
        url: 'https://media.w3.org/2010/05/sintel/trailer.mp4',
        uniqueId: 'video_2',
        title: '大雄兔预告片',
        coverUrl: 'https://picsum.photos/800/600?random=12',
      ),
      VideoMediaItem.network(
        url: 'https://media.w3.org/2010/05/sintel/trailer.mp4',
        uniqueId: 'video_3',
        title: '大雄兔短片',
        coverUrl: 'https://picsum.photos/800/600?random=13',
      ),
    ];

    // 使用静态方法打开（对话框模式示例）
    MediaViewer.show(
      context: context,
      mediaItems: mediaItems,
      initialIndex: 0,
      mode: MediaViewerShowMode.dialog,
    );
  }

  /// 示例 3：音乐播放器
  void _openAudioGalleryExample(BuildContext context) {
    final mediaItems = [
      AudioMediaItem.network(
        url: 'https://media.w3.org/2010/05/sintel/trailer.mp4',
        uniqueId: 'audio_1',
        title: 'Baby Elephant Walk',
        artist: 'Henry Mancini',
        album: '示例专辑',
        coverUrl: 'https://picsum.photos/400/400?random=21',
      ),
      AudioMediaItem.network(
        url: 'https://media.w3.org/2010/05/sintel/trailer.mp4',
        uniqueId: 'audio_2',
        title: 'Star Wars Theme',
        artist: 'John Williams',
        album: '示例专辑',
        coverUrl: 'https://picsum.photos/400/400?random=22',
      ),
      AudioMediaItem.network(
        url: 'https://media.w3.org/2010/05/sintel/trailer.mp4',
        uniqueId: 'audio_3',
        title: 'Immigrant Song',
        artist: 'Led Zeppelin',
        album: '示例专辑',
        coverUrl: 'https://picsum.photos/400/400?random=23',
      ),
    ];

    // 使用静态方法打开（带页面切换回调）
    MediaViewer.show(
      context: context,
      mediaItems: mediaItems,
      initialIndex: 0,
      onPageChanged: (index, item) {
        debugPrint('切换到音频: ${index + 1}/${mediaItems.length}');
      },
    );
  }

  /// 示例 4：混合内容
  void _openMixedGalleryExample(BuildContext context) {
    final mediaItems = [
      // 图片
      ImageMediaItem.network(
        url: 'https://picsum.photos/800/600?random=31',
        uniqueId: 'mixed_1',
        title: '产品展示图',
      ),

      // 视频
      VideoMediaItem.network(
        url: 'https://media.w3.org/2010/05/sintel/trailer.mp4',
        uniqueId: 'mixed_2',
        title: '产品介绍视频',
        coverUrl: 'https://picsum.photos/800/600?random=32',
      ),

      // 图片
      ImageMediaItem.network(
        url: 'https://picsum.photos/800/600?random=33',
        uniqueId: 'mixed_3',
        title: '产品细节图',
      ),

      // 音频
      AudioMediaItem.network(
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        uniqueId: 'mixed_4',
        title: '产品解说音频',
        artist: '产品团队',
        coverUrl: 'https://picsum.photos/400/400?random=34',
      ),

      // 图片
      ImageMediaItem.network(
        url: 'https://picsum.photos/800/600?random=35',
        uniqueId: 'mixed_5',
        title: '使用场景图',
      ),
    ];

    // 使用静态方法打开（完整参数示例）
    MediaViewer.show(
      context: context,
      mediaItems: mediaItems,
      initialIndex: 0,
      mode: MediaViewerShowMode.route,
      backgroundColor: Colors.black,
      onPageChanged: (index, item) {
        debugPrint('当前媒体: ${item.type} - ${item.title}');
      },
    );
  }
}

/// ==================== 快速开始指南 ====================
///
/// ## 1. 导入必要的包
/// ```dart
/// import 'package:riverpod_base/common/widgets/mediaViewer/media_viewer.dart';
/// import 'package:riverpod_base/common/widgets/mediaViewer/models/media_item.dart';
/// ```
///
/// ## 2. 创建媒体项列表
/// ```dart
/// final mediaItems = [
///   // 图片
///   ImageMediaItem.network(
///     url: 'https://example.com/image.jpg',
///     uniqueId: 'image_1',
///     title: '图片标题',
///   ),
///
///   // 视频
///   VideoMediaItem.network(
///     url: 'https://example.com/video.mp4',
///     uniqueId: 'video_1',
///     title: '视频标题',
///     coverUrl: 'https://example.com/cover.jpg',
///   ),
///
///   // 音频
///   AudioMediaItem.network(
///     url: 'https://example.com/audio.mp3',
///     uniqueId: 'audio_1',
///     title: '音频标题',
///     artist: '艺术家',
///     coverUrl: 'https://example.com/cover.jpg',
///   ),
/// ];
/// ```
///
/// ## 3. 打开画廊（推荐使用静态方法）
/// ```dart
/// // 方式 1：路由模式（默认，fade 过渡动画）
/// MediaViewer.show(
///   context: context,
///   mediaItems: mediaItems,
///   initialIndex: 0,
/// );
///
/// // 方式 2：对话框模式
/// MediaViewer.show(
///   context: context,
///   mediaItems: mediaItems,
///   mode: MediaViewerShowMode.dialog,
/// );
///
/// // 方式 3：带页面切换回调
/// MediaViewer.show(
///   context: context,
///   mediaItems: mediaItems,
///   onPageChanged: (index, item) {
///     print('当前页面: ${index + 1}, 类型: ${item.type}');
///   },
/// );
/// ```
///
/// ## 特性说明
/// ✅ 支持图片、视频、音频混排
/// ✅ 图片可捏合缩放、拖动查看
/// ✅ 视频支持全屏播放，全屏时禁用翻页
/// ✅ 音频显示封面、进度条、控制按钮
/// ✅ 统一的翻页体验
/// ✅ 页面指示器
/// ✅ 媒体信息显示
/// ✅ 支持路由和对话框两种显示模式
/// ✅ 路由模式使用优雅的 fade 过渡动画
