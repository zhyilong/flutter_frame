import 'package:flutter/material.dart';
import 'image_viewer_page.dart';
import 'image_viewer.dart';

/// 图片查看器使用示例
///
/// 演示如何使用图片查看器功能（支持图片缩放、翻页）
class ImageViewerExample extends StatelessWidget {
  /// 示例图片URL列表
  static const List<String> sampleImages = [
    'https://picsum.photos/800/1200?random=1',
    'https://picsum.photos/800/1200?random=2',
    'https://picsum.photos/800/1200?random=3',
    'https://picsum.photos/800/1200?random=4',
    'https://picsum.photos/800/1200?random=5',
  ];

  const ImageViewerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图片查看器示例'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 功能说明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✨ 功能特性',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureItem('🔍 双指捏合缩放（0.5x - 3x）'),
                  _buildFeatureItem('👆 放大后拖动查看图片细节'),
                  _buildFeatureItem('⬅️➡️ 左右滑动翻页查看图片'),
                  _buildFeatureItem('🎯 无手势冲突，操作流畅'),
                  _buildFeatureItem('💾 自动缓存，加载快速'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 方式1：直接跳转
            const Text(
              '方式1：直接跳转到查看器页面',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ImageViewerPage(
                      imageUrls: sampleImages,
                      initialIndex: 0,
                    ),
                  ),
                );
              },
              child: const Text('打开图片查看器'),
            ),
            const SizedBox(height: 32),

            // 方式2：对话框方式
            const Text(
              '方式2：使用对话框打开（默认）',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ImageViewer.show(
                  context,
                  imageUrls: sampleImages,
                  initialIndex: 0,
                );
              },
              child: const Text('对话框方式打开'),
            ),
            const SizedBox(height: 32),

            // 方式3：路由方式
            const Text(
              '方式3：使用路由打开',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ImageViewer.show(
                  context,
                  imageUrls: sampleImages,
                  mode: ImageViewerMode.route,
                );
              },
              child: const Text('路由方式打开'),
            ),
            const SizedBox(height: 32),

            // 方式4：从指定图片开始
            const Text(
              '方式4：从指定图片开始',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ImageViewer.showFromUrl(
                  context,
                  imageUrls: sampleImages,
                  imageUrl: sampleImages[2], // 从第三张图片开始
                );
              },
              child: const Text('从第三张图片开始查看'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
