import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'multi_media_picker.dart';
import 'multi_media_picker_controller.dart' as picker;

/// 多媒体选择器使用示例
class MultiMediaPickerExample extends StatelessWidget {
  const MultiMediaPickerExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('多媒体选择器示例')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 示例1: 基础使用 - 自适应宫格
            _buildSectionTitle('示例1: 基础使用（自适应宫格）'),
            SizedBox(height: 10),
            _BasicExample(),
            SizedBox(height: 30),

            // 示例2: 固定大小宫格
            _buildSectionTitle('示例2: 固定大小宫格'),
            SizedBox(height: 10),
            _FixedSizeExample(),
            SizedBox(height: 30),

            // 示例3: 仅支持图片
            _buildSectionTitle('示例3: 仅支持图片'),
            SizedBox(height: 10),
            _ImageOnlyExample(),
            SizedBox(height: 30),

            // 示例4: 自定义样式
            _buildSectionTitle('示例4: 自定义样式'),
            SizedBox(height: 10),
            _CustomStyleExample(),
            SizedBox(height: 30),

            // 示例5: 带操作按钮
            _buildSectionTitle('示例5: 带操作按钮'),
            SizedBox(height: 10),
            _WithActionButtonsExample(),
            SizedBox(height: 30),

            // 示例6: 支持拍照和录像
            _buildSectionTitle('示例6: 支持拍照和录像'),
            SizedBox(height: 10),
            _WithCameraExample(),
            SizedBox(height: 30),

            // 示例7: 只浏览模式
            _buildSectionTitle('示例7: 只浏览模式（不可选择、不可删除）'),
            SizedBox(height: 10),
            _ViewOnlyExample(),
            SizedBox(height: 30),

            // 示例8: 网络视频（浏览模式）
            _buildSectionTitle('示例8: 网络视频（浏览模式 + 点击播放）'),
            SizedBox(height: 10),
            _NetworkVideoExample(),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1C5A4F)),
    );
  }
}

/// 示例1: 基础使用 - 自适应宫格
class _BasicExample extends StatefulWidget {
  @override
  State<_BasicExample> createState() => _BasicExampleState();
}

class _BasicExampleState extends State<_BasicExample> {
  late final MultiMediaPickerController controller;

  @override
  void initState() {
    super.initState();
    controller = MultiMediaPickerController(maxCount: 9, enableImage: true, enableVideo: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiMediaPickerView(
      controller: controller,
      crossAxisCount: 3, // 3列宫格，宽度自动计算
      spacing: 10,
      runSpacing: 10,
    );
  }
}

/// 示例2: 固定大小宫格
class _FixedSizeExample extends StatefulWidget {
  @override
  State<_FixedSizeExample> createState() => _FixedSizeExampleState();
}

class _FixedSizeExampleState extends State<_FixedSizeExample> {
  late final MultiMediaPickerController controller;

  @override
  void initState() {
    super.initState();
    controller = MultiMediaPickerController(maxCount: 6);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiMediaPickerView(
      controller: controller,
      itemWidth: 80, // 固定宽度
      itemHeight: 80, // 固定高度
      spacing: 10,
      runSpacing: 10,
    );
  }
}

/// 示例3: 仅支持图片
class _ImageOnlyExample extends StatefulWidget {
  @override
  State<_ImageOnlyExample> createState() => _ImageOnlyExampleState();
}

class _ImageOnlyExampleState extends State<_ImageOnlyExample> {
  late final MultiMediaPickerController controller;

  @override
  void initState() {
    super.initState();
    controller = MultiMediaPickerController(
      maxCount: 9,
      enableImage: true,
      enableVideo: false, // 禁用视频
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MultiMediaPickerView(controller: controller, itemWidth: 80, itemHeight: 80, spacing: 8),
        SizedBox(height: 10),
        Text('提示：此示例仅支持选择图片', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

/// 示例4: 自定义样式
class _CustomStyleExample extends StatefulWidget {
  @override
  State<_CustomStyleExample> createState() => _CustomStyleExampleState();
}

class _CustomStyleExampleState extends State<_CustomStyleExample> {
  late final MultiMediaPickerController controller;

  @override
  void initState() {
    super.initState();
    controller = MultiMediaPickerController(maxCount: 4);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiMediaPickerView(
      controller: controller,
      itemWidth: 90,
      itemHeight: 90,
      spacing: 12,
      // 自定义添加按钮颜色
      addBorderColor: Color(0xFF1C5A4F),
      addIconColor: Color(0xFF1C5A4F),
      // 自定义删除按钮颜色
      deleteBackgroundColor: Color(0xFF1C5A4F),
      deleteIconColor: Colors.white,
      // 不显示视频标识
      showVideoIndicator: true,
    );
  }
}

/// 示例5: 带操作按钮
class _WithActionButtonsExample extends StatefulWidget {
  @override
  State<_WithActionButtonsExample> createState() => _WithActionButtonsExampleState();
}

class _WithActionButtonsExampleState extends State<_WithActionButtonsExample> {
  late final MultiMediaPickerController controller;

  @override
  void initState() {
    super.initState();
    controller = MultiMediaPickerController(maxCount: 6);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 多媒体选择器
        MultiMediaPickerView(controller: controller, itemWidth: 90, itemHeight: 90, spacing: 10, runSpacing: 10),
        SizedBox(height: 20),

        // 操作按钮行
        Row(
          children: [
            // 预览按钮
            Expanded(
              child: ElevatedButton(
                onPressed: controller.selectedCount == 0 ? null : () => _handlePreview(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1C5A4F),
                  disabledBackgroundColor: Colors.grey,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('预览已选', style: TextStyle(fontSize: 14, color: Colors.white)),
              ),
            ),
            SizedBox(width: 10),

            // 清空按钮
            Expanded(
              child: OutlinedButton(
                onPressed: controller.selectedCount == 0 ? null : () => _handleClear(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(0xFF1C5A4F),
                  disabledForegroundColor: Colors.grey,
                  side: BorderSide(color: Color(0xFF1C5A4F)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('清空', style: TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),

        // 提交按钮
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.selectedCount == 0 ? null : () => _handleSubmit(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1C5A4F),
              disabledBackgroundColor: Colors.grey,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              '提交上传',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),

        // 统计信息
        SizedBox(height: 10),
        _buildStats(),
      ],
    );
  }

  /// 构建统计信息
  Widget _buildStats() {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Text('已选择: ${controller.selectedCount}/${controller.maxCount}', style: TextStyle(fontSize: 12, color: Colors.grey));
      },
    );
  }

  /// 预览已选择的媒体
  void _handlePreview() {
    final media = controller.selectedMedia;
    final imageCount = media.where((m) => m.type == picker.MediaType.image).length;
    final videoCount = media.where((m) => m.type == picker.MediaType.video).length;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('图片: $imageCount\n视频: $videoCount'), behavior: SnackBarBehavior.floating));
  }

  /// 清空选择
  void _handleClear() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认清空'),
        content: Text('确定要清空所有已选择的媒体吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('取消')),
          TextButton(
            onPressed: () {
              controller.clearAll();
              Navigator.pop(context);
            },
            child: Text('确定', style: TextStyle(color: Color(0xFF1C5A4F))),
          ),
        ],
      ),
    );
  }

  /// 提交处理
  void _handleSubmit() async {
    // 显示加载
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      // 获取所有文件
      final files = await controller.getAllFiles();

      // 获取所有视频的缩略图路径（用于上传封面）
      final thumbnailPaths = controller.getAllVideoThumbnails();

      // 模拟上传
      await Future.delayed(Duration(seconds: 2));

      // 关闭加载
      Navigator.pop(context);

      // 显示成功提示
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已选择 ${files.length} 个文件，其中 ${thumbnailPaths.length} 个视频包含缩略图'), behavior: SnackBarBehavior.floating));

      print('准备上传的文件：');
      for (var i = 0; i < files.length; i++) {
        print('${i + 1}. ${files[i].path}');

        // 如果是视频且有缩略图
        final thumbnailPath = controller.getThumbnailPath(i);
        if (thumbnailPath != null) {
          print('   └─ 缩略图路径: $thumbnailPath');
          // 在这里可以上传缩略图作为视频封面
          // await uploadVideo(files[i]);
          // await uploadThumbnail(File(thumbnailPath));
        }
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('获取文件失败: $e'), behavior: SnackBarBehavior.floating));
    }
  }
}

/// 示例6: 支持拍照和录像
class _WithCameraExample extends StatefulWidget {
  @override
  State<_WithCameraExample> createState() => _WithCameraExampleState();
}

class _WithCameraExampleState extends State<_WithCameraExample> {
  late final MultiMediaPickerController controller;

  @override
  void initState() {
    super.initState();
    controller = MultiMediaPickerController(
      maxCount: 6,
      enableCamera: true, // 显示拍照和录像选项
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MultiMediaPickerView(controller: controller, itemWidth: 90, itemHeight: 90, spacing: 10, runSpacing: 10),
        SizedBox(height: 10),
        Text('提示：此示例支持拍照、录制视频和从相册选择', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

/// 示例7: 只浏览模式
class _ViewOnlyExample extends StatefulWidget {
  @override
  State<_ViewOnlyExample> createState() => _ViewOnlyExampleState();
}

class _ViewOnlyExampleState extends State<_ViewOnlyExample> {
  late final MultiMediaPickerController controller;

  @override
  void initState() {
    super.initState();
    // 模拟一些已选择的数据
    controller = MultiMediaPickerController(
      maxCount: 9,
      enableImage: true,
      enableVideo: true,
      viewOnly: true, // 只浏览模式
      onMediaTap: _handleMediaTap, // 点击回调
    );

    // 模拟添加一些网络图片
    _loadSampleData();
  }

  /// 加载示例数据
  Future<void> _loadSampleData() async {
    // 模拟从服务器获取的图片URL列表
    final List<String> imageUrls = [
      'https://picsum.photos/200/200?random=1',
      'https://picsum.photos/200/200?random=2',
      'https://picsum.photos/200/200?random=3',
      'https://picsum.photos/200/200?random=4',
    ];

    // 添加网络图片到控制器
    controller.addNetworkImages(imageUrls);
  }

  /// 处理媒体项点击
  void _handleMediaTap(List<MediaItem> allMedia, MediaItem clickedMedia) {
    final index = allMedia.indexOf(clickedMedia);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('点击了第 ${index + 1} 张图片\n共 ${allMedia.length} 张'), behavior: SnackBarBehavior.floating, duration: Duration(seconds: 2)),
    );

    // 在这里可以实现：
    // 1. 打开大图预览
    // 2. 跳转到详情页
    // 3. 显示操作菜单等
    Logger().d('点击了图片: ${clickedMedia.path} ${clickedMedia.type}');
    Logger().d('所有图片数量: ${allMedia.length}');
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MultiMediaPickerView(controller: controller, itemWidth: 90, itemHeight: 90, spacing: 10, runSpacing: 10),
        SizedBox(height: 10),
        Text('提示：只浏览模式，显示网络图片，点击可查看', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

/// 示例8: 网络视频（浏览模式 + 点击播放）
class _NetworkVideoExample extends StatefulWidget {
  @override
  State<_NetworkVideoExample> createState() => _NetworkVideoExampleState();
}

class _NetworkVideoExampleState extends State<_NetworkVideoExample> {
  late final MultiMediaPickerController controller;

  @override
  void initState() {
    super.initState();
    controller = MultiMediaPickerController(
      maxCount: 9,
      enableImage: true,
      enableVideo: true,
      viewOnly: true, // 只浏览模式
      onMediaTap: _handleMediaTap, // 点击回调
    );

    // 模拟添加网络视频
    _loadSampleData();
  }

  /// 加载示例数据
  Future<void> _loadSampleData() async {
    // 添加网络图片
    controller.addNetworkImages(['https://picsum.photos/200/200?random=10', 'https://picsum.photos/200/200?random=11']);

    // 添加网络视频（缩略图 + 视频URL）
    // 使用公共测试视频URL
    controller.addNetworkVideo(
      'https://picsum.photos/200/200?random=20', // 缩略图URL
      'https://media.w3.org/2010/05/sintel/trailer.mp4', // 视频播放URL（公共测试视频）
    );
  }

  /// 处理媒体项点击
  void _handleMediaTap(List<MediaItem> allMedia, MediaItem clickedMedia) {
    final index = allMedia.indexOf(clickedMedia);

    // 判断点击的是图片还是视频
    if (clickedMedia.type == picker.MediaType.image) {
      // 点击了图片
    } else {
      // 点击了视频
    }

    Logger().d('点击了媒体: ${clickedMedia.type}');
    Logger().d('路径: ${clickedMedia.path}');
    Logger().d('视频URL: ${clickedMedia.videoUrl}');
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MultiMediaPickerView(controller: controller, itemWidth: 90, itemHeight: 90, spacing: 10, runSpacing: 10),
        SizedBox(height: 10),
        Text('提示：混合显示网络图片和视频，点击视频可播放', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
