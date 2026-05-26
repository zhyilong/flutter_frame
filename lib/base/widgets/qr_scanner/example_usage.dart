import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'qr_scanner_view.dart';
import 'qr_scanner_widget.dart';
import 'qr_generator.dart';
import 'qr_image_parser.dart';

/// 扫码组件使用示例
///
/// 演示如何使用扫码功能，包括全屏页面和嵌入式组件两种方式
class ScannerExample extends StatelessWidget {
  const ScannerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('扫码组件示例'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 功能说明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✨ 功能特性', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  FeatureItem('📷 支持二维码和条形码扫描'),
                  FeatureItem('🔦 闪光灯控制开关'),
                  FeatureItem('🔄 前后摄像头切换'),
                  FeatureItem('📳 扫码成功震动反馈'),
                  FeatureItem('⚡ 防重复扫描机制'),
                  FeatureItem('🎨 自定义扫描框样式'),
                  FeatureItem('🧩 可嵌入现有页面'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 方式1：全屏扫码页面
            const Text('方式1：全屏扫码页面', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('完整的扫码页面体验，包含闪光灯、摄像头切换等功能', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRScannerView(
                      onScanned: (code) {
                        Navigator.of(context).pop();
                        _handleScannedResult(context, code);
                      },
                      scanLineColor: Colors.cyan,
                      showFlashlightButton: true,
                      showCameraSwitchButton: true,
                      scanTipText: '将二维码/条形码放入框内，即可自动扫描',
                      title: '扫一扫',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('打开全屏扫码页面'),
            ),
            const SizedBox(height: 32),

            // 方式2：嵌入式扫码组件
            const Text('方式2：嵌入式扫码组件', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('将扫码功能嵌入到现有页面中', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EmbeddedScannerExample()));
              },
              icon: const Icon(Icons.widgets_outlined),
              label: const Text('查看嵌入式扫码示例'),
            ),
            const SizedBox(height: 32),

            // 方式3：自定义扫描框样式
            const Text('方式3：自定义扫描框样式', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('自定义扫描框的颜色和样式', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRScannerView(
                            onScanned: (code) {
                              _handleScannedResult(context, code);
                            },
                            scanLineColor: Colors.red,
                            title: '红色扫描框',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: const Text('红色'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRScannerView(
                            onScanned: (code) {
                              _handleScannedResult(context, code);
                            },
                            scanLineColor: Colors.blue,
                            title: '蓝色扫描框',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    child: const Text('蓝色'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRScannerView(
                            onScanned: (code) {
                              _handleScannedResult(context, code);
                            },
                            scanLineColor: Colors.orange,
                            title: '橙色扫描框',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                    child: const Text('橙色'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 方式4：连续扫描模式
            const Text('方式4：连续扫描模式', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('扫码后自动继续扫描，适合批量处理场景', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ContinuousScanExample()));
              },
              icon: const Icon(Icons.repeat),
              label: const Text('查看连续扫描示例'),
            ),
            const SizedBox(height: 32),

            // 方式5：隐藏扫描框
            const Text('方式5：隐藏扫描框', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('不显示扫描框覆盖层，只显示相机画面', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoOverlayExample(
                      onScanned: (code) {
                        _handleScannedResult(context, code);
                      },
                    ),
                  ),
                );
              },
              child: const Text('查看无扫描框示例'),
            ),
            const SizedBox(height: 32),

            // 二维码生成示例
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.qr_code, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('二维码生成工具', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('使用 QRGenerator 工具类快速生成各种样式的二维码', style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const QRGeneratorExample()));
              },
              icon: const Icon(Icons.qr_code_2),
              label: const Text('查看二维码生成示例'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const QRImageParserExample()));
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('从相册图片识别二维码'),
            ),
          ],
        ),
      ),
    );
  }

  /// 处理扫描结果
  void _handleScannedResult(BuildContext context, String code) {
    // 震动反馈
    HapticFeedback.mediumImpact();

    // 判断扫描结果类型
    if (code.startsWith('http')) {
      // URL 类型
      _showResultDialog(context, title: '扫描结果（URL）', content: code, isUrl: true);
    } else if (code.startsWith('PRODUCT:')) {
      // 商品码类型（示例）
      final productId = code.substring(8);
      _showResultDialog(context, title: '商品码', content: '商品ID: $productId');
    } else {
      // 普通文本
      _showResultDialog(context, title: '扫描结果', content: code);
    }
  }

  /// 显示结果对话框
  void _showResultDialog(BuildContext context, {required String title, required String content, bool isUrl = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SelectableText(content),
        actions: [
          // 复制按钮
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: content));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
            },
            icon: const Icon(Icons.copy),
            label: const Text('复制'),
          ),
          // 打开URL按钮
          if (isUrl)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // TODO: 使用 url_launcher 打开URL
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('打开URL: $content')));
              },
              icon: const Icon(Icons.open_in_browser),
              label: const Text('打开'),
            ),
          // 关闭按钮
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭')),
        ],
      ),
    );
  }
}

/// 功能特性展示项
class FeatureItem extends StatelessWidget {
  final String text;

  const FeatureItem(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}

/// 嵌入式扫码组件示例
class EmbeddedScannerExample extends StatefulWidget {
  const EmbeddedScannerExample({super.key});

  @override
  State<EmbeddedScannerExample> createState() => _EmbeddedScannerExampleState();
}

class _EmbeddedScannerExampleState extends State<EmbeddedScannerExample> {
  String _lastScannedCode = '';
  int _scanCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('嵌入式扫码组件')),
      body: Column(
        children: [
          // 顶部信息区域
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey.withValues(alpha: 0.1),
            child: Column(
              children: [
                Text('扫描次数: $_scanCount', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_lastScannedCode.isNotEmpty) Text('最近扫描: $_lastScannedCode', style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),

          // 扫码组件
          Container(
            width: 200,
            height: 200,
            child: QRScannerWidget(
              onScanned: (code) {
                setState(() {
                  _scanCount++;
                  _lastScannedCode = code;
                });
                HapticFeedback.lightImpact();
              },
              scanLineColor: Colors.green,
              showOverlay: true,
              continuousScan: true, // 开启连续扫描
            ),
          ),

          Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}

/// 连续扫描模式示例
class ContinuousScanExample extends StatefulWidget {
  const ContinuousScanExample({super.key});

  @override
  State<ContinuousScanExample> createState() => _ContinuousScanExampleState();
}

class _ContinuousScanExampleState extends State<ContinuousScanExample> {
  final List<String> _scannedCodes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('连续扫描模式'),
        actions: [
          // 清空按钮
          IconButton(
            onPressed: () {
              setState(() {
                _scannedCodes.clear();
              });
            },
            icon: const Icon(Icons.clear_all),
            tooltip: '清空记录',
          ),
        ],
      ),
      body: Column(
        children: [
          // 扫码记录区域
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            color: Colors.grey.withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('扫描记录 (${_scannedCodes.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: _scannedCodes.isEmpty
                      ? const Center(
                          child: Text('暂无扫描记录', style: TextStyle(color: Colors.grey)),
                        )
                      : ListView.builder(
                          itemCount: _scannedCodes.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 4),
                              child: ListTile(
                                leading: Text('#${index + 1}'),
                                title: Text(_scannedCodes[index]),
                                trailing: IconButton(
                                  icon: const Icon(Icons.copy, size: 18),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: _scannedCodes[index]));
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制')));
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // 扫码组件
          Expanded(
            child: QRScannerWidget(
              onScanned: (code) {
                if (!_scannedCodes.contains(code)) {
                  setState(() {
                    _scannedCodes.insert(0, code); // 添加到开头
                  });
                }
              },
              continuousScan: true, // 开启连续扫描
            ),
          ),
        ],
      ),
    );
  }
}

/// 无扫描框示例
class NoOverlayExample extends StatelessWidget {
  final Function(String) onScanned;

  const NoOverlayExample({super.key, required this.onScanned});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('无扫描框模式')),
      body: Stack(
        children: [
          // 扫码组件（隐藏覆盖层）
          QRScannerWidget(
            onScanned: onScanned,
            showOverlay: false, // 隐藏扫描框
          ),

          // 顶部提示
          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 20,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                '对准二维码即可扫描',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 二维码生成示例
///
/// 演示如何使用 QRGenerator 工具类生成各种样式的二维码
class QRGeneratorExample extends StatelessWidget {
  const QRGeneratorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('二维码生成示例'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 示例1：基础二维码
            _ExampleSection(
              title: '示例1：基础二维码',
              description: '生成最简单的黑白二维码',
              child: Center(child: QRGenerator.generate('https://example.com', size: 200)),
            ),
            const SizedBox(height: 24),

            // 示例2：自定义颜色
            _ExampleSection(
              title: '示例2：自定义颜色',
              description: '使用自定义颜色生成二维码',
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _ColorQRDemo('蓝色', Colors.blue),
                  _ColorQRDemo('红色', Colors.red),
                  _ColorQRDemo('绿色', Colors.green),
                  _ColorQRDemo('紫色', Colors.purple),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 示例3：圆角二维码
            _ExampleSection(
              title: '示例3：圆角二维码',
              description: '为二维码添加圆角效果',
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [_RoundedQRDemo('小圆角', 8), _RoundedQRDemo('中圆角', 16), _RoundedQRDemo('大圆角', 32), _RoundedQRDemo('圆形', 100)],
              ),
            ),
            const SizedBox(height: 24),

            // 示例4：带边框二维码
            _ExampleSection(
              title: '示例4：带边框二维码',
              description: '为二维码添加边框装饰',
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [_BorderedQRDemo('灰色边框', Colors.grey), _BorderedQRDemo('蓝色边框', Colors.blue), _BorderedQRDemo('红色边框', Colors.red)],
              ),
            ),
            const SizedBox(height: 24),

            // 示例5：样式变化
            _ExampleSection(
              title: '示例5：样式变化',
              description: '圆形和方形样式对比',
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _StyleQRDemo('方形样式', QrEyeShape.square, QrDataModuleShape.square),
                  _StyleQRDemo('圆形样式', QrEyeShape.circle, QrDataModuleShape.circle),
                  _StyleQRDemo('混合样式', QrEyeShape.square, QrDataModuleShape.circle),
                  _StyleQRDemo('反向混合', QrEyeShape.circle, QrDataModuleShape.square),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 示例6：带Logo二维码
            _ExampleSection(
              title: '示例6：带Logo二维码',
              description: '在二维码中心添加Logo',
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [_LogoQRDemo('文字Logo', 'A'), _LogoQRDemo('图标Logo', Icons.favorite), _LogoQRDemo('自定义', Icons.star)],
              ),
            ),
            const SizedBox(height: 24),

            // 示例7：可交互二维码
            _ExampleSection(
              title: '示例7：可交互二维码',
              description: '点击二维码复制内容',
              child: Center(
                child: QRGenerator.generateInteractive(
                  'https://github.com',
                  size: 200,
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: 'https://github.com'));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
                  },
                  tooltip: '点击复制链接',
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 示例8：错误纠正级别
            _ExampleSection(
              title: '示例8：错误纠正级别',
              description: '不同错误纠正级别对比（数据量相同时）',
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _ErrorLevelQRDemo('L级 (7%)', QrErrorCorrectLevel.L),
                  _ErrorLevelQRDemo('M级 (15%)', QrErrorCorrectLevel.M),
                  _ErrorLevelQRDemo('Q级 (25%)', QrErrorCorrectLevel.Q),
                  _ErrorLevelQRDemo('H级 (30%)', QrErrorCorrectLevel.H),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 示例9：使用配置类
            _ExampleSection(
              title: '示例9：使用配置类',
              description: '使用 QRGeneratorConfig 创建复杂配置',
              child: Column(
                children: [
                  // 品牌色配置
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('品牌色配置', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          QRGeneratorConfig.brandTheme(Colors.blue).generate('Brand Theme'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 深色主题配置
                  Card(
                    color: Colors.black87,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            '深色主题配置',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          QRGeneratorConfig.darkTheme.generate('Dark Theme'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 圆形样式配置
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('圆形样式配置', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          QRGeneratorConfig.circularStyle(color: Colors.purple).generate('Circular Style'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 代码示例
            _CodeExampleSection(),
          ],
        ),
      ),
    );
  }
}

/// 示例区块组件
class _ExampleSection extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const _ExampleSection({required this.title, required this.description, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(description, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ],
    );
  }
}

/// 颜色二维码演示组件
class _ColorQRDemo extends StatelessWidget {
  final String label;
  final Color color;

  const _ColorQRDemo(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QRGenerator.generateWithColor('https://example.com', size: 120, color: color, backgroundColor: Colors.white),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// 圆角二维码演示组件
class _RoundedQRDemo extends StatelessWidget {
  final String label;
  final double radius;

  const _RoundedQRDemo(this.label, this.radius);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QRGenerator.generateWithRadius('https://example.com', size: 120, radius: radius),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// 边框二维码演示组件
class _BorderedQRDemo extends StatelessWidget {
  final String label;
  final Color color;

  const _BorderedQRDemo(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QRGenerator.generateWithBorder('https://example.com', size: 120, borderColor: color),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// 样式二维码演示组件
class _StyleQRDemo extends StatelessWidget {
  final String label;
  final QrEyeShape eyeShape;
  final QrDataModuleShape dataModuleShape;

  const _StyleQRDemo(this.label, this.eyeShape, this.dataModuleShape);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QRGenerator.generateCustom('https://example.com', size: 120, color: Colors.blue, eyeShape: eyeShape, dataModuleShape: dataModuleShape),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// Logo二维码演示组件
class _LogoQRDemo extends StatelessWidget {
  final String label;
  final dynamic logo;

  const _LogoQRDemo(this.label, this.logo);

  @override
  Widget build(BuildContext context) {
    Widget logoWidget;

    if (logo is String) {
      logoWidget = Text(
        logo,
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
      );
    } else if (logo is IconData) {
      logoWidget = Icon(logo, size: 32, color: Colors.blue);
    } else {
      logoWidget = const SizedBox.shrink();
    }

    return Column(
      children: [
        QRGenerator.generateWithLogo('https://example.com', size: 120, logo: logoWidget),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// 错误纠正级别演示组件
class _ErrorLevelQRDemo extends StatelessWidget {
  final String label;
  final int errorLevel;

  const _ErrorLevelQRDemo(this.label, this.errorLevel);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QRGenerator.generateWithErrorLevel('Error Correction Level', size: 120, errorCorrectionLevel: errorLevel),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// 代码示例区块
class _CodeExampleSection extends StatelessWidget {
  const _CodeExampleSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(8)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '代码示例',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 16),
          SelectableText('''
// 1. 基础用法
QRGenerator.generate('https://example.com')

// 2. 自定义颜色
QRGenerator.generateWithColor(
  'https://example.com',
  color: Colors.blue,
  backgroundColor: Colors.white,
)

// 3. 带圆角
QRGenerator.generateWithRadius(
  'https://example.com',
  radius: 16,
)

// 4. 带边框
QRGenerator.generateWithBorder(
  'https://example.com',
  borderColor: Colors.blue,
)

// 5. 圆形样式
QRGenerator.generateCircularStyle(
  'https://example.com',
  color: Colors.blue,
)

// 6. 带Logo
QRGenerator.generateWithLogo(
  'https://example.com',
  logo: Icon(Icons.star),
)

// 7. 使用配置类
final config = QRGeneratorConfig(
  size: 250,
  color: Colors.blue,
  eyeShape: QrEyeShape.circle,
  showBorder: true,
);
config.generate('https://example.com')
''', style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: Color(0xFFD4D4D4))),
        ],
      ),
    );
  }
}

/// 从相册图片识别二维码示例
class QRImageParserExample extends StatefulWidget {
  const QRImageParserExample({super.key});

  @override
  State<QRImageParserExample> createState() => _QRImageParserExampleState();
}

class _QRImageParserExampleState extends State<QRImageParserExample> {
  final ImagePicker _picker = ImagePicker();
  bool _isParsing = false;
  List<String> _parsedCodes = [];
  String? _selectedImagePath;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('从图片识别二维码'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 功能说明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('功能说明', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('从相册选择包含二维码的图片，自动识别其中的二维码内容', style: TextStyle(fontSize: 14)),
                  SizedBox(height: 4),
                  Text('支持识别多个二维码', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 选择图片按钮
            ElevatedButton.icon(
              onPressed: _isParsing ? null : _pickImage,
              icon: _isParsing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.photo_library),
              label: Text(_isParsing ? '正在识别...' : '从相册选择图片'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            const SizedBox(height: 16),

            // 显示选中的图片
            if (_selectedImagePath != null) ...[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(_selectedImagePath!), width: 200, height: 200, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 显示解析结果
            if (_parsedCodes.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Text('识别成功 (${_parsedCodes.length}个)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_parsedCodes.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ParseResultItem(label: '二维码 ${index + 1}', code: _parsedCodes[index], onTap: () => _handleCodeTap(_parsedCodes[index])),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 显示错误信息
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 使用说明
            const Divider(height: 32),
            const Text('使用说明', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildInstructionItem('1', '点击上方按钮从相册选择图片'),
            _buildInstructionItem('2', '选择包含二维码的图片'),
            _buildInstructionItem('3', '系统自动识别图片中的所有二维码'),
            _buildInstructionItem('4', '点击识别结果可复制或打开链接'),
            const SizedBox(height: 24),

            // 代码示例
            _buildCodeExample(),
          ],
        ),
      ),
    );
  }

  /// 从相册选择图片
  Future<void> _pickImage() async {
    try {
      setState(() {
        _isParsing = true;
        _errorMessage = null;
        _parsedCodes = [];
      });

      // 选择图片
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 100);

      if (image == null) {
        setState(() {
          _isParsing = false;
        });
        return;
      }

      setState(() {
        _selectedImagePath = image.path;
      });

      // 解析二维码
      final codes = await QRImageParser.fromPath(image.path);

      if (codes.isEmpty) {
        setState(() {
          _errorMessage = '未能识别到二维码，请选择包含二维码的图片';
          _isParsing = false;
        });
        HapticFeedback.lightImpact();
      } else {
        setState(() {
          _parsedCodes = codes;
          _isParsing = false;
        });
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      setState(() {
        _errorMessage = '识别失败: $e';
        _isParsing = false;
      });
      HapticFeedback.heavyImpact();
    }
  }

  /// 处理识别结果点击
  void _handleCodeTap(String code) {
    if (code.startsWith('http')) {
      _showResultDialog(context, title: '识别结果（URL）', content: code, isUrl: true);
    } else {
      _showResultDialog(context, title: '识别结果', content: code);
    }
  }

  /// 显示结果对话框
  void _showResultDialog(BuildContext context, {required String title, required String content, bool isUrl = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SelectableText(content),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: content));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
            },
            icon: const Icon(Icons.copy),
            label: const Text('复制'),
          ),
          if (isUrl)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('打开URL: $content')));
              },
              icon: const Icon(Icons.open_in_browser),
              label: const Text('打开'),
            ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭')),
        ],
      ),
    );
  }

  /// 构建说明项
  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  /// 构建代码示例
  Widget _buildCodeExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(8)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '代码示例',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 12),
          SelectableText('''
// 基础用法
final codes = await QRImageParser.fromPath('/path/to/image.png');
if (codes.isNotEmpty) {
  print('识别到: \${codes.first}');
}

// 只获取第一个
final code = await QRImageParser.parseOne('/path/to/image.png');

// 获取详细信息
final results = await QRImageParserAdvanced.parse('/path/to/image.png');
for (final result in results) {
  print('内容: \${result.content}, 类型: \${result.type}');
}
''', style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFFD4D4D4))),
        ],
      ),
    );
  }
}

/// 解析结果项
class _ParseResultItem extends StatelessWidget {
  final String label;
  final String code;
  final VoidCallback onTap;

  const _ParseResultItem({required this.label, required this.code, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              code,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              maxLines: 20,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
