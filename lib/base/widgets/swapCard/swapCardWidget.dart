/*
 * Created by zhyilong on 2026/5/23
 */

import 'dart:async';

import 'package:flutter/cupertino.dart';

// 无限循环模式枚举
enum LoopMode {
  disabled, // 关闭无限循环
  largeNumber, // 方案一：虚拟能量放大法（大数法）
  copyJump, // 方案二：首尾副本跳转法
}

class SwapCardWidget extends StatefulWidget {
  const SwapCardWidget({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.onSlideStop,
    this.onCenterCardTap,
    this.minScale = 0.5,
    this.initialPage = 0,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.loopMode = LoopMode.disabled,
  }) : assert(itemCount > 0, 'itemCount must be greater than 0');

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final void Function(int centerIndex)? onSlideStop;
  final void Function(int index)? onCenterCardTap;
  final double minScale;
  final int initialPage;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final LoopMode loopMode;

  @override
  State<StatefulWidget> createState() => _SwapCardWidgetState();
}

class _SwapCardWidgetState extends State<SwapCardWidget> {
  late final PageController _pageController;
  Timer? _debounceTimer;
  Timer? _autoPlayTimer;
  Timer? _loopJumpTimer;
  late final int _displayCount;
  late final int _initialPage;
  late final LoopMode _effectiveLoopMode;  // 实际使用的循环模式
  bool _isScrolling = false;

  // 方案一（大数法）专用
  static const int _largeNumber = 1000;

  @override
  void initState() {
    super.initState();

    // 根据不同的循环模式初始化
    _initByLoopMode();

    _pageController = PageController(viewportFraction: 0.6, initialPage: _initialPage);

    // 首帧渲染后启动自动播放
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.autoPlay) {
        _startAutoPlay();
      }
    });

    // 不再需要 _updateScales，因为使用动态计算
    _pageController.addListener(() {
      _notifySlideStop();
    });
  }

  // 根据循环模式初始化参数
  void _initByLoopMode() {
    // 当卡片数量少于 2 张时，禁用无限循环
    if (widget.itemCount < 2) {
      _effectiveLoopMode = LoopMode.disabled;
      _displayCount = widget.itemCount;
      _initialPage = widget.initialPage;
      return;
    }

    _effectiveLoopMode = widget.loopMode;

    switch (_effectiveLoopMode) {
      case LoopMode.largeNumber:
        // 方案一：大数法
        _displayCount = _largeNumber;
        _initialPage = _largeNumber ~/ 2;
        break;
      case LoopMode.copyJump:
        // 方案二：副本跳转法
        _displayCount = widget.itemCount + 4;
        _initialPage = 2;
        break;
      case LoopMode.disabled:
        // 不开启循环
        _displayCount = widget.itemCount;
        _initialPage = widget.initialPage;
        break;
    }
  }

  // 将显示索引映射到真实数据索引
  int _getRealIndex(int displayIndex) {
    switch (_effectiveLoopMode) {
      case LoopMode.largeNumber:
        // 方案一：使用取模运算
        return displayIndex % widget.itemCount;
      case LoopMode.copyJump:
        // 方案二：副本映射
        if (displayIndex < 2) {
          return widget.itemCount - 2 + displayIndex;
        } else if (displayIndex >= 2 + widget.itemCount) {
          return displayIndex - 2 - widget.itemCount;
        } else {
          return displayIndex - 2;
        }
      case LoopMode.disabled:
        return displayIndex;
    }
  }

  // 处理循环滚动跳转（仅方案二需要）
  void _handleLoopScroll() {
    if (_effectiveLoopMode != LoopMode.copyJump) return;
    if (_isScrolling) return;

    final double page = _pageController.page ?? _initialPage.toDouble();
    final int currentPage = page.round();

    // 滚动到最右边的副本时，跳转到左边真实位置
    if (currentPage >= 2 + widget.itemCount) {
      _isScrolling = true;
      final int offset = currentPage - (2 + widget.itemCount);
      _loopJumpTimer?.cancel();
      _loopJumpTimer = Timer(const Duration(milliseconds: 50), () {
        _pageController.jumpToPage(2 + offset);
        _isScrolling = false;
      });
      return;
    }
    // 滚动到最左边的副本时，跳转到右边真实位置
    else if (currentPage < 2) {
      _isScrolling = true;
      final int offset = 2 - currentPage;
      _loopJumpTimer?.cancel();
      _loopJumpTimer = Timer(const Duration(milliseconds: 50), () {
        _pageController.jumpToPage(2 + widget.itemCount - offset);
        _isScrolling = false;
      });
      return;
    }
  }

  void _startAutoPlay() {
    _stopAutoPlay();
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (timer) {
      final int currentPage = (_pageController.page ?? _initialPage.toDouble()).round();
      final int nextPage = currentPage + 1;
      _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  // 动态计算指定索引的缩放值
  double _calculateScale(int index) {
    // 使用 initialPage 作为默认值，确保初始化时正确显示
    final double page = _pageController.page ?? _initialPage.toDouble();
    double distance;

    if (_effectiveLoopMode == LoopMode.largeNumber) {
      // 方案一：大数法，计算相对距离
      // 使用 truncate 而不是 round，避免 page 值变化时突然跳变
      final int currentPage = page.truncate();
      final double relativePosition = index - page;
      final int halfCount = widget.itemCount ~/ 2;

      // 将相对位置映射到 [-halfCount, halfCount] 范围内
      if (relativePosition > halfCount) {
        distance = (relativePosition - widget.itemCount).abs();
      } else if (relativePosition < -halfCount) {
        distance = (relativePosition + widget.itemCount).abs();
      } else {
        distance = relativePosition.abs();
      }
    } else {
      // 方案二和无循环模式，直接计算距离
      distance = (page - index).abs();
    }

    // 越靠近中心缩放越接近1.0，越远越小
    // 使用分段曲线保持中心卡片更大
    double scale;
    if (distance < 0.5) {
      // 非常接近中心，保持接近原始大小
      scale = 1.0 - (distance * 0.1);
    } else {
      // 距离较远，明显缩小
      scale = 0.95 - ((distance - 0.5) * 0.2);
    }
    // 限制缩放范围在 minScale 到 1.0 之间
    return scale.clamp(widget.minScale, 1.0);
  }

  void _notifySlideStop() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (widget.onSlideStop != null) {
        final int displayIndex = (_pageController.page ?? _initialPage.toDouble()).round();
        final int realIndex = _getRealIndex(displayIndex);
        widget.onSlideStop!(realIndex);
      }
    });
  }

  @override
  void dispose() {
    _loopJumpTimer?.cancel();
    _stopAutoPlay();
    _pageController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        // 滚动结束后处理循环跳转（仅方案二需要）
        if (_effectiveLoopMode == LoopMode.copyJump) {
          _handleLoopScroll();
        }
        return true;
      },
      child: PageView.builder(
        controller: _pageController,
        itemCount: _displayCount,
        itemBuilder: (context, index) {
          final int realIndex = _getRealIndex(index);
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              // 所有模式都使用动态计算缩放，保证实时效果
              final double scale = _calculateScale(index);

              return GestureDetector(
                onTap: () {
                  final double page = _pageController.page ?? _initialPage.toDouble();
                  final int centerIndex = page.round();
                  if (index == centerIndex && widget.onCenterCardTap != null) {
                    widget.onCenterCardTap!(realIndex);
                  }
                },
                child: Transform.scale(scale: scale, child: widget.itemBuilder(context, realIndex)),
              );
            },
          );
        },
      ),
    );
  }
}
