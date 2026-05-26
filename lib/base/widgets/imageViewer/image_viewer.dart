import 'package:flutter/material.dart';
import 'image_viewer_page.dart';

/// 图片查看器显示模式
enum ImageViewerMode {
  /// 对话框模式
  dialog,
  /// 路由模式
  route,
}

/// 图片查看器工具类
///
/// 提供便捷的方法来显示全屏图片查看器
/// 支持对话框和路由两种显示模式
class ImageViewer {
  /// 显示图片查看器
  ///
  /// [context] 上下文
  /// [imageUrls] 图片URL列表
  /// [initialIndex] 初始显示的图片索引，默认为0
  /// [backgroundColor] 背景颜色，默认为黑色
  /// [indicatorColor] 指示器颜色，默认为白色
  /// [mode] 显示模式，默认为对话框模式
  /// [onPageChanged] 页面切换完成回调，返回当前索引和图片URL
  static void show(
    BuildContext context, {
    required List<String> imageUrls,
    int initialIndex = 0,
    Color backgroundColor = Colors.black,
    Color indicatorColor = Colors.white,
    ImageViewerMode mode = ImageViewerMode.dialog,
    void Function(int index, String imageUrl)? onPageChanged,
  }) {
    // 参数验证：空列表检查
    if (imageUrls.isEmpty) {
      debugPrint('ImageViewer: 警告 - 图片列表为空，无法显示查看器');
      return;
    }

    // 参数验证：索引边界检查
    if (initialIndex < 0 || initialIndex >= imageUrls.length) {
      debugPrint('ImageViewer: 警告 - 索引 $initialIndex 超出范围 [0, ${imageUrls.length - 1}]，已重置为 0');
      initialIndex = 0;
    }

    final viewer = ImageViewerPage(
      imageUrls: imageUrls,
      initialIndex: initialIndex,
      backgroundColor: backgroundColor,
      indicatorColor: indicatorColor,
      onPageChanged: onPageChanged,
    );

    switch (mode) {
      case ImageViewerMode.dialog:
        showDialog(
          context: context,
          builder: (context) => viewer,
          barrierColor: backgroundColor,
        );
        break;
      case ImageViewerMode.route:
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return FadeTransition(
                opacity: animation,
                child: viewer,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            opaque: false,
            barrierColor: Colors.black,
          ),
        );
        break;
    }
  }

  /// 从指定图片URL开始显示图片查看器
  ///
  /// [context] 上下文
  /// [imageUrls] 图片URL列表
  /// [imageUrl] 要显示的图片URL
  /// [backgroundColor] 背景颜色，默认为黑色
  /// [indicatorColor] 指示器颜色，默认为白色
  /// [mode] 显示模式，默认为对话框模式
  /// [onPageChanged] 页面切换完成回调，返回当前索引和图片URL
  static void showFromUrl(
    BuildContext context, {
    required List<String> imageUrls,
    required String imageUrl,
    Color backgroundColor = Colors.black,
    Color indicatorColor = Colors.white,
    ImageViewerMode mode = ImageViewerMode.dialog,
    void Function(int index, String imageUrl)? onPageChanged,
  }) {
    final index = imageUrls.indexOf(imageUrl);

    // 如果URL不在列表中，给出警告
    if (index == -1) {
      debugPrint('ImageViewer: 警告 - 指定的图片URL不在列表中: $imageUrl');
      debugPrint('ImageViewer: 将显示第一张图片');
    }

    show(
      context,
      imageUrls: imageUrls,
      initialIndex: index >= 0 ? index : 0,
      backgroundColor: backgroundColor,
      indicatorColor: indicatorColor,
      mode: mode,
      onPageChanged: onPageChanged,
    );
  }
}
