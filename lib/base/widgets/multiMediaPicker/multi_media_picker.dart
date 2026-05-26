/// 多媒体选择器组件
///
/// 功能特性：
/// - 支持从相册选择图片或视频
/// - 支持拍照和录制视频（可选）
/// - 支持只浏览模式（不可选择、不可删除）
/// - 支持显示网络图片（浏览模式）
/// - 支持点击回调（浏览模式下可查看大图）
/// - 宫格布局显示
/// - 初始状态显示"+"按钮
/// - 选择后插入到"+"前面
/// - 达到最大数量后隐藏"+"按钮
/// - 每个媒体右上角有删除按钮（浏览模式下隐藏）
/// - 支持设置最大选择数量
/// - 支持启用/禁用图片和视频选择
/// - 支持固定大小和自适应两种宫格模式
/// - 视频自动生成缩略图并保存到临时目录
///
/// ## 基础使用示例
///
/// ```dart
/// // 1. 创建控制器（默认可编辑模式）
/// final controller = MultiMediaPickerController(
///   maxCount: 9,           // 最多选择9个
///   enableImage: true,     // 支持图片
///   enableVideo: true,     // 支持视频
///   enableCamera: false,   // 不显示拍照和录像（默认）
///   viewOnly: false,       // 可编辑模式（默认）
/// );
///
/// // 2. 只浏览模式（显示网络图片）
/// final controller = MultiMediaPickerController(
///   maxCount: 9,
///   enableImage: true,
///   enableVideo: true,
///   viewOnly: true,        // 只浏览模式
///   onMediaTap: (allMedia, clickedMedia) {
///     // 处理点击事件
///     final index = allMedia.indexOf(clickedMedia);
///     print('点击了第 ${index + 1} 张图片');
///     // 可以在这里打开大图预览、跳转详情页等
///   },
/// );
///
/// // 添加网络图片
/// controller.addNetworkImages([
///   'https://example.com/image1.jpg',
///   'https://example.com/image2.jpg',
/// ]);
///
/// // 3. 显示拍照和录像选项
/// final controller = MultiMediaPickerController(
///   maxCount: 9,
///   enableImage: true,
///   enableVideo: true,
///   enableCamera: true,    // 显示拍照和录像
/// );
///
/// // 4. 使用组件（自适应宫格模式）
/// MultiMediaPickerView(
///   controller: controller,
///   crossAxisCount: 3,    // 3列，宽度自动计算
///   spacing: 10,
///   runSpacing: 10,
/// )
///
/// // 5. 使用组件（固定大小模式）
/// MultiMediaPickerView(
///   controller: controller,
///   itemWidth: 100,     // 固定宽度
///   itemHeight: 100,    // 固定高度
///   spacing: 10,
/// )
///
/// // 6. 获取选择的文件（用于上传）
/// final files = await controller.getAllFiles();
///
/// // 7. 获取视频缩略图路径（用于上传封面）
/// final thumbnailPaths = controller.getAllVideoThumbnails();
///
/// // 8. 获取指定项的缩略图路径
/// final thumbnailPath = controller.getThumbnailPath(0);
/// if (thumbnailPath != null) {
///   await uploadThumbnail(File(thumbnailPath));
/// }
///
/// // 9. 监听选择数量变化
/// AnimatedBuilder(
///   animation: controller,
///   builder: (context, child) {
///     return Text('已选: ${controller.selectedCount}');
///   },
/// )
///
/// // 10. 清空选择
/// controller.clearAll();
///
/// // 11. 删除指定项
/// controller.removeMedia(index);
/// ```
///
/// ## 完整示例
///
/// 查看 `example_usage.dart` 文件获取更多使用示例，包括：
/// - 基础使用（自适应宫格）
/// - 固定大小宫格
/// - 仅支持图片
/// - 自定义样式
/// - 带操作按钮
/// - 支持拍照和录像
/// - 只浏览模式（显示网络图片 + 点击回调）
/// - 网络视频（显示缩略图 + 点击播放）
library;

export 'multi_media_picker_controller.dart';
export 'multi_media_picker_view.dart';
