/*
 * Created by zhyilong on 2026/5/19
 * NFC扫描UI组件 - 底部弹出式面板
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:mvvm_demo/base/widgets/hud/hud.dart';
import 'nfc_helper.dart';

/// NFC扫描状态
enum _NfcScannerState {
  init, // 初始状态
  scanning, // 正在感应
  reading, // 正在读取
  writing, // 正在写入
  success, // 成功
  failed, // 失败
  emptyTag, // 标签为空
}

/// NFC扫描UI组件
class NfcScannerWidget extends StatefulWidget {
  // 回调函数
  final Function(NfcReadResult)? onReadComplete;
  final Function(bool success, NfcError? error)? onWriteComplete;
  final VoidCallback? onClosed;

  // UI配置
  final String title;
  final String scanningHint;
  final String readingHint;
  final String writeHint;
  final Color primaryColor;
  final double height;

  // 写入模式
  final bool isWriteMode;
  final String? writeTextData;
  final Map<String, dynamic>? writeJsonData;

  // 动画配置
  final String? gifAnimationAsset; // GIF动画资源路径
  final double? gifWidth; // GIF宽度
  final double? gifHeight; // GIF高度

  // 其他
  final bool showCloseButton;
  final Duration animationDuration;

  const NfcScannerWidget({
    super.key,
    this.onReadComplete,
    this.onWriteComplete,
    this.onClosed,
    this.title = 'NFC感应',
    this.scanningHint = '请将手机靠近NFC标签',
    this.readingHint = '正在读取...',
    this.writeHint = '正在写入...',
    this.primaryColor = Colors.cyan,
    this.height = 340,
    this.isWriteMode = false,
    this.writeTextData,
    this.writeJsonData,
    this.gifAnimationAsset,
    this.gifWidth,
    this.gifHeight,
    this.showCloseButton = true,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  /// 显示NFC扫描面板
  static Future<T?> show<T>({
    required BuildContext context,
    Function(NfcReadResult)? onReadComplete,
    Function(bool success, NfcError? error)? onWriteComplete,
    VoidCallback? onClosed,
    String title = 'NFC感应',
    String scanningHint = '请将手机靠近NFC标签',
    String readingHint = '正在读取...',
    String writeHint = '正在写入...',
    Color primaryColor = Colors.cyan,
    double height = 340,
    bool isWriteMode = false,
    String? writeTextData,
    Map<String, dynamic>? writeJsonData,
    String? gifAnimationAsset,
    double? gifWidth,
    double? gifHeight,
    bool showCloseButton = true,
    Duration animationDuration = const Duration(milliseconds: 300),
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => NfcScannerWidget(
        onReadComplete: onReadComplete,
        onWriteComplete: onWriteComplete,
        onClosed: onClosed,
        title: title,
        scanningHint: scanningHint,
        readingHint: readingHint,
        writeHint: writeHint,
        primaryColor: primaryColor,
        height: height,
        isWriteMode: isWriteMode,
        writeTextData: writeTextData,
        writeJsonData: writeJsonData,
        gifAnimationAsset: gifAnimationAsset,
        gifWidth: gifWidth,
        gifHeight: gifHeight,
        showCloseButton: showCloseButton,
        animationDuration: animationDuration,
      ),
    );
  }

  @override
  State<NfcScannerWidget> createState() => _NfcScannerWidgetState();
}

class _NfcScannerWidgetState extends State<NfcScannerWidget> with TickerProviderStateMixin {
  // 动画控制器
  late AnimationController _slideController;
  late CurvedAnimation _curvedAnimation;
  late Animation<Offset> _slideAnimation;

  // 脉冲动画控制器
  late AnimationController _pulseController;

  // NFC状态
  _NfcScannerState _currentState = _NfcScannerState.init;
  NfcError? _currentError;

  // 动画状态监听器函数
  late final AnimationStatusListener _animationStatusListener;

  // 标志：是否已被用户手动关闭
  bool _isUserClosed = false;

  // 标志：NFC操作是否正在进行
  bool _isNfcOperationInProgress = false;

  @override
  void initState() {
    super.initState();

    // 初始化滑动动画
    _slideController = AnimationController(duration: widget.animationDuration, vsync: this);

    // 创建独立的CurvedAnimation对象以便稍后释放
    _curvedAnimation = CurvedAnimation(parent: _slideController, curve: Curves.easeOut);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // 从底部开始
      end: Offset.zero,
    ).animate(_curvedAnimation);

    // 初始化脉冲动画
    _pulseController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)..repeat(); // 循环播放

    // 创建监听器函数引用，以便稍后移除
    _animationStatusListener = (AnimationStatus status) {
      if (_slideController.status == AnimationStatus.completed) {
        // 检查用户是否已关闭面板
        if (!_isUserClosed && mounted) {
          _startNfcOperation();
        }
      }
    };

    // 开始弹出动画
    _slideController.forward();

    // 动画完成后自动开始NFC操作
    _slideController.addStatusListener(_animationStatusListener);
  }

  @override
  void dispose() {
    // 标记为已关闭，防止NFC操作继续执行
    _isUserClosed = true;

    // 如果NFC操作正在进行，尝试终止会话
    if (_isNfcOperationInProgress) {
      FlutterNfcKit.finish().catchError((e) {
        // 忽略finish时的错误
      });
    }

    // 移除监听器防止内存泄漏
    _slideController.removeStatusListener(_animationStatusListener);
    _slideController.dispose();
    _curvedAnimation.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// 开始NFC操作
  Future<void> _startNfcOperation() async {
    // 检查是否已关闭或widget已销毁
    if (_isUserClosed || !mounted) {
      return;
    }

    if (widget.isWriteMode) {
      await _startWrite();
    } else {
      await _startRead();
    }
  }

  /// 开始读取
  Future<void> _startRead() async {
    // 检查是否已关闭
    if (_isUserClosed || !mounted) {
      return;
    }

    setState(() {
      _currentState = _NfcScannerState.scanning;
    });

    // 检查NFC可用性
    final available = await NfcHelper.isNfcAvailable();

    // 再次检查是否已关闭
    if (_isUserClosed || !mounted) {
      return;
    }

    if (!available) {
      _handleNfcError(NfcError.nfcDisabled());
      return;
    }

    setState(() {
      _currentState = _NfcScannerState.reading;
    });

    // 标记NFC操作开始
    _isNfcOperationInProgress = true;

    try {
      // 执行读取（自动重试3次）
      final result = await NfcHelper.read(timeout: const Duration(seconds: 15), maxRetries: 3);

      // 检查是否已关闭（不处理结果）
      if (_isUserClosed || !mounted) {
        return;
      }

      if (result.success) {
        if (result.isEmptyTag) {
          _handleEmptyTag(result);
        } else {
          _handleReadSuccess(result);
        }
      } else {
        _handleNfcError(result.error!);
      }
    } finally {
      // 标记NFC操作结束
      _isNfcOperationInProgress = false;
    }
  }

  /// 开始写入
  Future<void> _startWrite() async {
    // 检查是否已关闭
    if (_isUserClosed || !mounted) {
      return;
    }

    // 验证写入数据
    if (widget.writeJsonData != null) {
      final validSize = NfcHelper.validateJsonSize(widget.writeJsonData!);
      if (!validSize) {
        final size = NfcHelper.getJsonSize(widget.writeJsonData!);
        _handleWriteError(NfcError.dataTooLarge(size, NfcHelper.largeNdefMaxSize));
        return;
      }
    }

    setState(() {
      _currentState = _NfcScannerState.scanning;
    });

    // 检查NFC可用性
    final available = await NfcHelper.isNfcAvailable();

    // 再次检查是否已关闭
    if (_isUserClosed || !mounted) {
      return;
    }

    if (!available) {
      _handleWriteError(NfcError.nfcDisabled());
      return;
    }

    setState(() {
      _currentState = _NfcScannerState.writing;
    });

    // 标记NFC操作开始
    _isNfcOperationInProgress = true;

    try {
      // 执行写入
      NfcResult result;
      if (widget.writeJsonData != null) {
        result = await NfcHelper.writeJson(widget.writeJsonData!, timeout: const Duration(seconds: 15));
      } else if (widget.writeTextData != null) {
        result = await NfcHelper.writeText(widget.writeTextData!, timeout: const Duration(seconds: 15));
      } else {
        _handleWriteError(NfcError.invalidDataFormat('没有提供写入数据'));
        return;
      }

      // 检查是否已关闭（不处理结果）
      if (_isUserClosed || !mounted) {
        return;
      }

      if (result.success) {
        _handleWriteSuccess();
      } else {
        _handleWriteError(result.error!);
      }
    } finally {
      // 标记NFC操作结束
      _isNfcOperationInProgress = false;
    }
  }

  /// 处理读取成功
  void _handleReadSuccess(NfcReadResult result) {
    setState(() {
      _currentState = _NfcScannerState.success;
    });

    HapticFeedback.mediumImpact();

    // 延迟后关闭面板，然后在pop完成后执行回调
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _close(() {
          // 在pop完成后执行回调
          widget.onReadComplete?.call(result);
        });
      }
    });
  }

  /// 处理写入成功
  void _handleWriteSuccess() {
    setState(() {
      _currentState = _NfcScannerState.success;
    });

    HapticFeedback.mediumImpact();

    // 延迟后关闭面板，然后在pop完成后执行回调
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _close(() {
          // 在pop完成后执行回调
          widget.onWriteComplete?.call(true, null);
        });
      }
    });
  }

  /// 处理空标签
  void _handleEmptyTag(NfcReadResult result) {
    setState(() {
      _currentState = _NfcScannerState.emptyTag;
      _currentError = null; // 不是错误
    });

    // 轻微震动反馈（不是错误震动）
    HapticFeedback.lightImpact();

    // 显示友好提示
    HUDToast.show('NFC标签为空');

    // 3秒后自动关闭面板（给用户时间看到空标签选项）
    // 在关闭完成后执行回调
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _currentState == _NfcScannerState.emptyTag) {
        _close(() {
          // 在关闭完成后执行回调
          widget.onReadComplete?.call(result);
        });
      }
    });
  }

  /// 处理NFC错误
  void _handleNfcError(NfcError error) {
    setState(() {
      _currentState = _NfcScannerState.failed;
      _currentError = error;
    });

    // 显示错误提示
    HUDToast.show(error.message);

    HapticFeedback.heavyImpact();

    // 2秒后自动关闭面板
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _currentState == _NfcScannerState.failed) {
        _close();
      }
    });
  }

  /// 处理写入错误
  void _handleWriteError(NfcError error) {
    setState(() {
      _currentState = _NfcScannerState.failed;
      _currentError = error;
    });

    // 显示错误提示
    HUDToast.show(error.message);

    HapticFeedback.heavyImpact();

    // 2秒后自动关闭面板，在关闭完成后执行回调
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _currentState == _NfcScannerState.failed) {
        _close(() {
          // 在关闭完成后执行回调
          widget.onWriteComplete?.call(false, error);
        });
      }
    });
  }

  /// 关闭面板
  ///
  /// [callback] 可选的回调函数，在pop操作完成后执行
  void _close([VoidCallback? callback]) {
    // 标记为用户手动关闭，阻止后续NFC操作
    _isUserClosed = true;

    // 如果NFC操作正在进行，尝试终止会话
    if (_isNfcOperationInProgress) {
      FlutterNfcKit.finish().catchError((e) {
        // 忽略finish时的错误
      });
    }

    widget.onClosed?.call();
    _slideController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
        // 在pop完成后执行回调
        callback?.call();
      }
    });
  }

  /// 手动重试
  void _retry() {
    _startNfcOperation();
  }

  /// 切换到写入模式
  void _switchToWriteMode() {
    // 关闭当前面板
    Navigator.of(context).pop();

    // 延迟一小段时间后打开写入面板
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      // 打开写入面板
      NfcScannerWidget.show(
        context: context,
        title: '写入测试数据',
        isWriteMode: true,
        writeTextData: 'Hello NFC! ${DateTime.now().toIso8601String().substring(0, 19)}',
        onWriteComplete: (success, error) {
          if (success) {
            HUDToast.show('✅ 写入成功！现在可以读取数据了');
          } else {
            HUDToast.show('❌ 写入失败: ${error?.message}');
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Column(
          children: [
            // 顶部栏（标题 + 关闭按钮）
            _buildTopBar(),

            // 内容区域
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  /// 构建顶部栏
  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (widget.showCloseButton)
            GestureDetector(
              onTap: _close,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 脉冲动画 + NFC图标
          _buildPulseAnimation(),

          const SizedBox(height: 30),

          // 提示文字
          _buildHintText(),

          const SizedBox(height: 20),

          // 状态显示
          _buildStatusDisplay(),
        ],
      ),
    );
  }

  /// 构建脉冲动画
  Widget _buildPulseAnimation() {
    // 如果提供了GIF动画，显示GIF
    if (widget.gifAnimationAsset != null && widget.gifAnimationAsset!.isNotEmpty) {
      return _buildGifAnimation();
    }

    // 否则显示默认的脉冲动画
    return _buildDefaultPulseAnimation();
  }

  /// 构建GIF动画
  Widget _buildGifAnimation() {
    final gifSize = widget.gifWidth ?? 120;

    return Image.asset(
      widget.gifAnimationAsset!,
      width: gifSize,
      height: widget.gifHeight ?? gifSize,
      gaplessPlayback: true, // 避免GIF循环时的闪烁
      errorBuilder: (context, error, stackTrace) {
        // GIF加载失败时，回退到默认动画
        return _buildDefaultPulseAnimation();
      },
    );
  }

  /// 构建默认脉冲动画
  Widget _buildDefaultPulseAnimation() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 三个脉冲圆圈
          _buildPulseCircle(0),
          _buildPulseCircle(1),
          _buildPulseCircle(2),

          // 中心NFC图标
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: widget.primaryColor, shape: BoxShape.circle),
            child: const Icon(Icons.nfc, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  /// 构建单个脉冲圆圈
  Widget _buildPulseCircle(int index) {
    final delay = index * 0.5;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        // 计算当前圆圈的动画进度
        final animationValue = (_pulseController.value - delay).clamp(0.0, 1.0);

        return Transform.scale(
          scale: 1.0 + animationValue, // 从1.0缩放到2.0
          child: Opacity(
            opacity: 0.6 * (1.0 - animationValue), // 从0.6渐变到0
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: widget.primaryColor.withOpacity(0.6), width: 2),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建提示文字
  Widget _buildHintText() {
    String hintText;
    switch (_currentState) {
      case _NfcScannerState.init:
        hintText = widget.scanningHint;
        break;
      case _NfcScannerState.scanning:
        hintText = widget.scanningHint;
        break;
      case _NfcScannerState.reading:
        hintText = widget.readingHint;
        break;
      case _NfcScannerState.writing:
        hintText = widget.writeHint;
        break;
      case _NfcScannerState.success:
        hintText = widget.isWriteMode ? '写入成功!' : '读取成功!';
        break;
      case _NfcScannerState.emptyTag:
        hintText = 'NFC标签为空，可以写入数据';
        break;
      case _NfcScannerState.failed:
        hintText = _currentError?.message ?? '操作失败';
        break;
    }

    return Text(
      hintText,
      style: TextStyle(
        fontSize: 16,
        color: _currentState == _NfcScannerState.failed
            ? Colors.red
            : _currentState == _NfcScannerState.emptyTag
            ? Colors.orange
            : Colors.grey[700],
        fontWeight: (_currentState == _NfcScannerState.failed || _currentState == _NfcScannerState.emptyTag) ? FontWeight.w500 : FontWeight.normal,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// 构建状态显示
  Widget _buildStatusDisplay() {
    switch (_currentState) {
      case _NfcScannerState.init:
      case _NfcScannerState.scanning:
      case _NfcScannerState.reading:
      case _NfcScannerState.writing:
        // 显示加载指示器
        return const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.grey));

      case _NfcScannerState.success:
        // 显示成功图标
        return Icon(Icons.check_circle, size: 48, color: Colors.green);

      case _NfcScannerState.emptyTag:
        // 显示空标签状态：提供写入选项
        if (!widget.isWriteMode) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 空标签图标
              Icon(Icons.info_outline, size: 48, color: Colors.orange),
              const SizedBox(height: 8),
              const Text('这是一个空白标签', style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _switchToWriteMode,
                icon: const Icon(Icons.edit),
                label: const Text('写入数据'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          );
        } else {
          return Icon(Icons.info_outline, size: 48, color: Colors.orange);
        }

      case _NfcScannerState.failed:
        // 其他错误：显示重试按钮
        return ElevatedButton.icon(
          onPressed: _retry,
          icon: const Icon(Icons.refresh),
          label: const Text('重试'),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        );
    }
  }
}
