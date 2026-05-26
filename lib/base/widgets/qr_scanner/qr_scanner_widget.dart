/*
 * Created by zhyilong on 2026/5/18
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// 扫码 Widget（可嵌入使用）
/// 适合嵌入到现有页面中，而非全屏页面
class QRScannerWidget extends StatefulWidget {
  /// 扫码成功回调
  final Function(String code) onScanned;

  /// 扫描框颜色
  final Color scanLineColor;

  /// 是否显示扫描框覆盖层
  final bool showOverlay;

  /// 扫描成功后是否自动继续扫描
  final bool continuousScan;

  /// 自定义覆盖层 Widget
  final Widget? overlayBuilder;

  /// 扫描框大小占比
  final double scanAreaFator;

  const QRScannerWidget({
    super.key,
    required this.onScanned,
    this.scanLineColor = Colors.cyan,
    this.showOverlay = true,
    this.continuousScan = false,
    this.overlayBuilder,
    this.scanAreaFator = 0.65,
  });

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  /// 扫描控制器
  late final MobileScannerController _controller;

  /// 是否正在扫描
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 处理扫描结果
  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    // 检查是否有扫描到条码
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    if (barcode.rawValue != null) {
      final code = barcode.rawValue!;
      HapticFeedback.mediumImpact();

      widget.onScanned(code);

      if (!widget.continuousScan) {
        setState(() {
          _isScanning = false;
        });
        // 延迟后恢复扫描
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isScanning = true;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          // 扫码视图
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // 覆盖层
          if (widget.showOverlay) (widget.overlayBuilder ?? _DefaultOverlay(scanLineColor: widget.scanLineColor, scanAreaFator: widget.scanAreaFator)),
        ],
      ),
    );
  }
}

/// 默认扫描框覆盖层
class _DefaultOverlay extends StatelessWidget {
  final Color scanLineColor;

  /// 扫描框大小占比
  final double scanAreaFator;

  const _DefaultOverlay({required this.scanLineColor, required this.scanAreaFator});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.4)),
      child: CustomPaint(
        size: Size.infinite,
        painter: _DefaultOverlayPainter(scanLineColor: scanLineColor, scanAreaFator: scanAreaFator),
      ),
    );
  }
}

/// 默认扫描框绘制器
class _DefaultOverlayPainter extends CustomPainter {
  final Color scanLineColor;

  /// 扫描框大小占比
  final double scanAreaFator;

  _DefaultOverlayPainter({required this.scanLineColor, required this.scanAreaFator});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = scanLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();

    // 扫描框尺寸
    final scanSize = size.width * scanAreaFator;
    final left = (size.width - scanSize) / 2;
    final top = (size.height - scanSize) / 2;
    final right = left + scanSize;
    final bottom = top + scanSize;

    // 绘制四个角落的边框
    final cornerLength = scanSize * 0.2;

    // 左上角
    path.moveTo(left, top + cornerLength);
    path.lineTo(left, top);
    path.lineTo(left + cornerLength, top);

    // 右上角
    path.moveTo(right - cornerLength, top);
    path.lineTo(right, top);
    path.lineTo(right, top + cornerLength);

    // 右下角
    path.moveTo(right, bottom - cornerLength);
    path.lineTo(right, bottom);
    path.lineTo(right - cornerLength, bottom);

    // 左下角
    path.moveTo(left + cornerLength, bottom);
    path.lineTo(left, bottom);
    path.lineTo(left, bottom - cornerLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 简化的扫码控制器封装
/// 用于外部控制扫码行为
class ScannerControllerWrapper {
  final MobileScannerController _controller;

  ScannerControllerWrapper(this._controller);

  /// 切换闪光灯
  void toggleTorch() => _controller.toggleTorch();

  /// 切换摄像头
  void switchCamera() => _controller.switchCamera();

  /// 分析图片
  void analyzeImage(String path) => _controller.analyzeImage(path);
}
