/*
 * Created by zhyilong on 2026/5/18
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// 扫码页面组件
/// 支持二维码和条形码扫描，提供闪光灯、摄像头切换等功能
class QRScannerView extends StatefulWidget {
  /// 扫码成功回调
  final Function(String code) onScanned;

  /// 扫描框颜色
  final Color scanLineColor;

  /// 是否显示闪光灯按钮
  final bool showFlashlightButton;

  /// 是否显示摄像头切换按钮
  final bool showCameraSwitchButton;

  /// 扫描提示文本
  final String scanTipText;

  /// 页面标题
  final String title;

  /// 是否全屏（appbar是否显示）
  final bool isFullScreen;

  /// 扫描框大小占比
  final double scanAreaFator;

  const QRScannerView({
    super.key,
    required this.onScanned,
    this.scanLineColor = Colors.cyan,
    this.showFlashlightButton = true,
    this.showCameraSwitchButton = true,
    this.scanTipText = '将二维码/条形码放入框内，即可自动扫描',
    this.title = '扫一扫',
    this.isFullScreen = true,
    this.scanAreaFator = 0.65,
  });

  @override
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  /// 扫描控制器
  final MobileScannerController _controller = MobileScannerController();

  /// 是否正在扫描（防止重复扫描）
  bool _isScanning = true;

  /// 闪光灯状态
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    // 配置扫描器，监听手电筒状态变化
    _controller.addListener(() {
      if (_controller.value.torchState == TorchState.on && !_isFlashOn) {
        setState(() {
          _isFlashOn = true;
        });
      } else if (_controller.value.torchState == TorchState.off && _isFlashOn) {
        setState(() {
          _isFlashOn = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 切换闪光灯
  void _toggleFlash() {
    HapticFeedback.lightImpact();
    _controller.toggleTorch();
  }

  /// 切换摄像头
  void _switchCamera() {
    HapticFeedback.lightImpact();
    _controller.switchCamera();
  }

  /// 处理扫描结果
  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    // 检查是否有扫描到条码
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    if (barcode.rawValue != null) {
      final code = barcode.rawValue!;
      // 停止扫描
      _isScanning = false;
      // 震动反馈
      HapticFeedback.mediumImpact();
      // 回调结果
      widget.onScanned(code);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: widget.isFullScreen
          ? null
          : AppBar(
              title: Text(widget.title),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
      body: Stack(
        children: [
          // 扫码视图
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // 扫描框覆盖层
          _ScanOverlay(scanLineColor: widget.scanLineColor, factor: widget.scanAreaFator),

          // 顶部提示文字
          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                child: Text(widget.scanTipText, style: const TextStyle(color: Colors.white, fontSize: 14)),
              ),
            ),
          ),

          // 底部控制按钮
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 闪光灯按钮
                if (widget.showFlashlightButton)
                  _ControlButton(
                    icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off, color: Colors.white),
                    label: '闪光灯',
                    onPressed: _toggleFlash,
                  ),

                // 摄像头切换按钮
                if (widget.showCameraSwitchButton)
                  _ControlButton(
                    icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                    label: '切换',
                    onPressed: _switchCamera,
                  ),
              ],
            ),
          ),

          // 关闭按钮
          if (widget.isFullScreen)
            Positioned(
              top: 60,
              left: 15,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: Container(
                      height: 26,
                      width: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
                      child: Icon(Icons.close),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 扫描框覆盖层
class _ScanOverlay extends StatelessWidget {
  final Color scanLineColor;
  final double factor;

  const _ScanOverlay({required this.scanLineColor, required this.factor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.black45),
      child: CustomPaint(
        size: Size.infinite,
        painter: _ScanOverlayPainter(scanLineColor: scanLineColor, factor: factor),
      ),
    );
  }
}

/// 扫描框绘制器
class _ScanOverlayPainter extends CustomPainter {
  final Color scanLineColor;
  final double factor;

  _ScanOverlayPainter({required this.scanLineColor, required this.factor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = scanLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();

    // 扫描框尺寸
    final scanSize = size.width * factor;
    final left = (size.width - scanSize) / 2;
    final top = (size.height - 40 - scanSize) / 2;
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

/// 控制按钮
class _ControlButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onPressed;

  const _ControlButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        // decoration: BoxDecoration(
        //   color: Colors.white.withOpacity(0.2),
        //   borderRadius: BorderRadius.circular(25),
        //   border: Border.all(color: Colors.white.withOpacity(0.3)),
        // ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
