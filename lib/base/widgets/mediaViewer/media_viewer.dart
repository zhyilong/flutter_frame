import 'package:flutter/material.dart';

import 'models/media_item.dart';
import 'media_viewer_page.dart';

/// 混合媒体画廊库
///
/// 提供图片、视频、音频混排的画廊功能

class MediaViewer {
  /// 显示混合媒体画廊
  ///
  /// - [context]: 上下文
  /// - [mediaItems]: 媒体项列表
  /// - [initialIndex]: 初始显示的索引，默认为 0
  /// - [mode]: 显示模式，默认为路由模式（fade 过渡）
  /// - [backgroundColor]: 背景颜色，默认为黑色
  /// - [onPageChanged]: 页面切换完成回调
  ///
  /// 返回值：对话框模式返回 `Future<void>`，路由模式返回 `Future<T?>`
  static Future<T?> show<T>({
    required BuildContext context,
    required List<MediaItem> mediaItems,
    int initialIndex = 0,
    MediaViewerShowMode mode = MediaViewerShowMode.route,
    Color backgroundColor = Colors.black,
    void Function(int index, MediaItem item)? onPageChanged,
  }) {
    final page = MediaViewerPage(
      mediaItems: mediaItems,
      initialIndex: initialIndex,
      backgroundColor: backgroundColor,
      onPageChanged: onPageChanged,
    );

    switch (mode) {
      case MediaViewerShowMode.dialog:
        return showDialog<T>(
          context: context,
          builder: (context) => page,
          barrierColor: Colors.black,
        );

      case MediaViewerShowMode.route:
        return Navigator.of(context).push<T>(
          PageRouteBuilder<T>(
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Fade 过渡动画
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
    }
  }
}
