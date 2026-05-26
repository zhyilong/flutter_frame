import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'multi_media_picker_controller.dart' show MediaItem, MultiMediaPickerController;
import 'multi_media_picker_controller.dart' as picker show MediaType;

/// 多媒体选择器组件
class MultiMediaPickerView extends StatelessWidget {
  /// 控制器
  final MultiMediaPickerController controller;

  /// 宫格列数（在 itemSize 为 null 时有效）
  final int crossAxisCount;

  /// 单个项目宽度（设置后优先使用此宽度）
  final double? itemWidth;

  /// 单个项目高度（设置后优先使用此高度）
  final double? itemHeight;

  /// 项目间距
  final double spacing;

  /// 行间距
  final double runSpacing;

  /// 添加按钮边框颜色
  final Color? addBorderColor;

  /// 添加按钮图标颜色
  final Color? addIconColor;

  /// 删除按钮背景颜色
  final Color? deleteBackgroundColor;

  /// 删除按钮图标颜色
  final Color? deleteIconColor;

  /// 是否显示视频标识
  final bool showVideoIndicator;

  /// 是否使用固定大小模式（优先使用 itemWidth 和 itemHeight）
  bool get useFixedSize => itemWidth != null || itemHeight != null;

  /// 上传状态回调函数（根据 mediaId 返回状态文本）
  final String? Function(String mediaId)? uploadStatusCallback;

  const MultiMediaPickerView({
    Key? key,
    required this.controller,
    this.crossAxisCount = 3,
    this.itemWidth,
    this.itemHeight,
    this.spacing = 10,
    this.runSpacing = 10,
    this.addBorderColor,
    this.addIconColor,
    this.deleteBackgroundColor,
    this.deleteIconColor,
    this.showVideoIndicator = true,
    this.uploadStatusCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      // 添加选择完成
      animation: controller,
      builder: (context, child) {
        final itemCount = controller.selectedCount + (controller.showAddButton ? 1 : 0);

        // 使用固定大小模式
        if (useFixedSize) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFixedSizeView(itemCount),
              //
              SizedBox(height: 10),
              // 左下角视图
              _buildBottomLeftView(),
            ],
          );
        }

        // 使用自适应宫格模式
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFlexibleView(itemCount),
            //
            SizedBox(height: 10),
            // 左下角视图
            _buildBottomLeftView(),
          ],
        );
      },
    );
  }

  /// 构建固定大小视图
  Widget _buildFixedSizeView(int itemCount) {
    // 使用 LayoutBuilder 获取可用宽度
    return LayoutBuilder(
      builder: (context, constraints) {
        final actualWidth = itemWidth ?? 100;
        final actualHeight = itemHeight ?? actualWidth;

        // 计算每行可以放几个项目
        final availableWidth = constraints.maxWidth;
        final itemsPerRow = ((availableWidth + spacing) / (actualWidth + spacing)).floor();

        return Container(
          child: GridView.builder(
            padding: EdgeInsets.all(0),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: itemsPerRow > 0 ? itemsPerRow : 1,
              crossAxisSpacing: spacing,
              mainAxisSpacing: runSpacing,
              childAspectRatio: actualWidth / actualHeight,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              // 添加按钮
              if (index == controller.selectedCount) {
                return _buildAddButton();
              }

              // 媒体项
              return _buildMediaItem(index);
            },
          ),
        );
      },
    );
  }

  /// 构建自适应宫格视图
  Widget _buildFlexibleView(int itemCount) {
    return GridView.builder(
      padding: EdgeInsets.all(0),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: 1,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // 添加按钮
        if (index == controller.selectedCount) {
          return _buildAddButton();
        }

        // 媒体项
        return _buildMediaItem(index);
      },
    );
  }

  /// 构建添加按钮（无参数，用于固定大小模式）
  Widget _buildAddButton() {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => controller.pickMedia(context),
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            radius: Radius.circular(8),
            color: addBorderColor ?? Color(0xFFEBEAEF),
            strokeWidth: 1.5,
            dashPattern: [4, 4],
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.add, size: 40, color: addIconColor ?? Color(0xFFC0C0C0)),
          ),
        ),
      ),
    );
  }

  /// 构建媒体项
  Widget _buildMediaItem(int index) {
    final mediaItem = controller.selectedMedia[index];

    final child = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand, // 让 Stack 填满父容器
        children: [
          // 媒体内容 - 使用 Positioned.fill 填满整个 Stack
          Positioned.fill(child: mediaItem.type == picker.MediaType.image ? _buildImage(mediaItem) : _buildVideo(mediaItem)),

          // 删除按钮 - 在最上层（只在可删除时显示）
          if (controller.canRemove) Positioned(top: 0, right: 0, child: _buildDeleteButton(index)),

          // 视频标识 - 在最上层
          if (showVideoIndicator && mediaItem.type == picker.MediaType.video) Positioned(top: 0, left: 0, child: _buildVideoIndicator(mediaItem)),

          // 底部描述
          Positioned(left: 0, right: 0, bottom: 0, child: _buildDescription(mediaItem)),
        ],
      ),
    );

    // 如果有点击回调，添加点击事件
    if (controller.onMediaTap != null) {
      return GestureDetector(
        onTap: () {
          final allMedia = controller.selectedMedia;
          controller.onMediaTap!(allMedia, mediaItem);
        },
        child: child,
      );
    }

    return child;
  }

  /// 构建图片
  Widget _buildImage(MediaItem mediaItem) {
    // 优先显示网络图片
    if (mediaItem.isNetworkImage) {
      return CachedNetworkImage(
        imageUrl: mediaItem.networkUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Container(
          color: Color(0xFFF5F5F5),
          width: double.infinity,
          height: double.infinity,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) =>
            Container(color: Color(0xFFF5F5F5), width: double.infinity, height: double.infinity, child: Icon(Icons.broken_image, size: 40)),
      );
    }

    // 本地文件
    if (mediaItem.file != null) {
      return Image.file(mediaItem.file!, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    }

    // 相册资源
    if (mediaItem.assetEntity != null) {
      return FutureBuilder<Uint8List?>(
        future: mediaItem.assetEntity!.thumbnailData,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return Image.memory(snapshot.data!, fit: BoxFit.cover, width: double.infinity, height: double.infinity, gaplessPlayback: true);
          }
          return Container(
            color: Color(0xFFF5F5F5),
            width: double.infinity,
            height: double.infinity,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
      );
    }

    // 默认占位图
    return Container(color: Color(0xFFF5F5F5), width: double.infinity, height: double.infinity, child: Icon(Icons.broken_image, size: 40));
  }

  /// 构建视频
  Widget _buildVideo(MediaItem mediaItem) {
    Widget videoContent;

    // 优先使用网络缩略图
    if (mediaItem.networkUrl != null && mediaItem.networkUrl!.isNotEmpty) {
      videoContent = CachedNetworkImage(
        imageUrl: mediaItem.networkUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Container(
          color: Color(0xFFF5F5F5),
          width: double.infinity,
          height: double.infinity,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) =>
            Container(color: Color(0xFFF5F5F5), width: double.infinity, height: double.infinity, child: Icon(Icons.broken_image, size: 40)),
      );
    }
    // 使用已生成的缩略图路径
    else if (mediaItem.thumbnailPath != null) {
      videoContent = Image.file(File(mediaItem.thumbnailPath!), fit: BoxFit.cover, width: double.infinity, height: double.infinity, gaplessPlayback: true);
    }
    // 如果没有缩略图，使用原来的逻辑
    else if (mediaItem.file != null) {
      videoContent = VideoThumbnailWidget(file: mediaItem.file!);
    } else if (mediaItem.assetEntity != null) {
      videoContent = FutureBuilder<Uint8List?>(
        future: mediaItem.assetEntity!.thumbnailData,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return Image.memory(snapshot.data!, fit: BoxFit.cover, width: double.infinity, height: double.infinity, gaplessPlayback: true);
          }
          return Container(
            color: Color(0xFFF5F5F5),
            width: double.infinity,
            height: double.infinity,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
      );
    } else {
      videoContent = Container(color: Color(0xFFF5F5F5), width: double.infinity, height: double.infinity, child: Icon(Icons.videocam, size: 40));
    }

    // 在视频上叠加播放图标
    return Stack(
      fit: StackFit.expand,
      children: [
        videoContent,
        // 中心播放图标
        Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
            child: Icon(Icons.play_arrow, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }

  /// 构建删除按钮
  Widget _buildDeleteButton(int index) {
    return GestureDetector(
      onTap: () => controller.removeMedia(index),
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center, // 明确设置居中对齐
        decoration: BoxDecoration(
          color: deleteBackgroundColor ?? Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5)),
        ),
        child: Icon(Icons.close, color: deleteIconColor ?? Colors.white, size: 16),
      ),
    );
  }

  /// 额外信息
  Widget _buildDescription(MediaItem mediaItem) {
    // 获取上传状态文本（如果有回调）
    String statusText = "";
    if (uploadStatusCallback != null) {
      final callbackText = uploadStatusCallback!(mediaItem.id);
      if (callbackText != null && callbackText.isNotEmpty) {
        statusText = callbackText;
      }
    }

    return (statusText != null && statusText.length > 0)
        ? Container(
            height: 24,
            decoration: BoxDecoration(color: Colors.black54),
            padding: EdgeInsets.symmetric(horizontal: 5),
            alignment: Alignment.centerLeft,
            child: Text(
              statusText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          )
        : SizedBox.shrink();
  }

  /// 构建视频标识
  Widget _buildVideoIndicator(MediaItem mediaItem) {
    // 兼容 assetEntity 为 null 的情况
    if (mediaItem.assetEntity == null) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      height: 24,
      constraints: BoxConstraints(minWidth: 40),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon(Icons.play_arrow, color: Colors.white, size: 12),
          // SizedBox(width: 2),
          Text(_formatDuration(mediaItem.assetEntity!.duration), style: TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }

  /// 将秒转换为时分秒格式
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  /// 构建左下角视图
  Widget _buildBottomLeftView() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: _buildHintLabel(),
    );
  }

  /// 构建提示标签
  Widget _buildHintLabel() {
    final maxCount = controller.maxCount;
    final enableImage = controller.enableImage;
    final enableVideo = controller.enableVideo;
    final viewOnly = controller.viewOnly;

    // 根据支持的类型和模式生成提示文本
    String hintText;
    if (viewOnly) {
      // 浏览模式
      if (enableImage && enableVideo) {
        hintText = "共${controller.selectedCount}个文件（图片或视频）";
      } else if (enableImage) {
        hintText = "共${controller.selectedCount}个文件（图片）";
      } else if (enableVideo) {
        hintText = "共${controller.selectedCount}个文件（视频）";
      } else {
        hintText = "共${controller.selectedCount}个文件";
      }
    } else {
      // 选择模式
      if (enableImage && enableVideo) {
        hintText = "最多上传$maxCount个文件（图片或视频）";
      } else if (enableImage) {
        hintText = "最多上传$maxCount个文件（图片）";
      } else if (enableVideo) {
        hintText = "最多上传$maxCount个文件（视频）";
      } else {
        hintText = "最多上传$maxCount个文件";
      }
    }

    return RichText(
      text: TextSpan(
        text: hintText,
        style: TextStyle(fontSize: 12, color: Color(0xFF9498B3)),
      ),
    );
  }
}

/// 视频缩略图组件
class VideoThumbnailWidget extends StatefulWidget {
  final File file;

  const VideoThumbnailWidget({Key? key, required this.file}) : super(key: key);

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  Uint8List? _thumbnailData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    try {
      final uint8list = await VideoThumbnail.thumbnailData(video: widget.file.path, imageFormat: ImageFormat.JPEG, maxWidth: 400, quality: 75);

      if (uint8list != null) {
        setState(() {
          _thumbnailData = uint8list;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('生成视频缩略图失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Color(0xFFF5F5F5),
        width: double.infinity,
        height: double.infinity,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_thumbnailData != null) {
      return Image.memory(_thumbnailData!, fit: BoxFit.cover, width: double.infinity, height: double.infinity, gaplessPlayback: true);
    }

    // 加载失败或出错时显示占位符
    return Container(
      color: Color(0xFFF5F5F5),
      width: double.infinity,
      height: double.infinity,
      child: Center(child: Icon(Icons.videocam, size: 40)),
    );
  }
}
