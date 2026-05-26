/*
 * Created by zhyilong on 2026/5/23
 */

import 'dart:async';

import 'package:flutter/cupertino.dart';

// 无限循环模式枚举
enum LoopMode {
  disabled,    // 关闭无限循环
  largeNumber, // 方案一：虚拟能量放大法（大数法）
  copyJump,    // 方案二：首尾副本跳转法
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
  });

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
  final List<double> _scales = [];
  Timer? _debounceTimer;
  Timer? _autoPlayTimer;
  Timer? _loopJumpTimer;
  late final int _displayCount;
  late final int _initialPage;
  bool _isScrolling = false;

  // 方案一（大数法）专用
  static const int _largeNumber = 100000;

  @override
  void initState() {
    super.initState();

    // 根据不同的循环模式初始化
    _initByLoopMode();

    // 初始化缩放值列表（只初始化需要的数量）
    final int scaleCount = widget.loopMode == LoopMode.largeNumber
        ? widget.itemCount
        : _displayCount;
    for (int i = 0; i < scaleCount; i++) {
      _scales.add(1.0);
    }

    _pageController = PageController(
      viewportFraction: 0.6,
      initialPage: _initialPage,
    );

    // 首帧渲染后计算初始缩放
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.autoPlay) {
        _startAutoPlay();
      }
    });

    _pageController.addListener(() {
      _notifySlideStop();
    });
  }

  // 根据循环模式初始化参数
  void _initByLoopMode() {
    switch (widget.loopMode) {
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
    switch (widget.loopMode) {
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
    if (widget.loopMode != LoopMode.copyJump) return;
    if (_isScrolling) return;

    final double page = _pageController.page ?? 0;
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
      final int currentPage = (_pageController.page ?? 0).round();
      final int nextPage = currentPage + 1;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  // 动态计算指定索引的缩放值
  double _calculateScale(int index) {
    final double page = _pageController.page ?? 0.0;
    double distance;

    if (widget.loopMode == LoopMode.largeNumber) {
      // 方案一：大数法，计算相对距离
      final int currentPage = page.round();
      final int relativeIndex = index - currentPage;
      final int halfCount = widget.itemCount ~/ 2;

      // 将相对索引映射到 [-halfCount, halfCount] 范围内
      if (relativeIndex > halfCount) {
        distance = (relativeIndex - widget.itemCount).abs().toDouble();
      } else if (relativeIndex < -halfCount) {
        distance = (relativeIndex + widget.itemCount).abs().toDouble();
      } else {
        distance = relativeIndex.abs().toDouble();
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

  // 更新缩放值（仅方案二和关闭循环需要）
  void _updateScales() {
    if (widget.loopMode == LoopMode.largeNumber) return; // 方案一不需要

    final double page = _pageController.page ?? 0.0;
    setState(() {
      for (int i = 0; i < _displayCount; i++) {
        double distance = (page - i).abs();
        double scale;
        if (distance < 0.5) {
          scale = 1.0 - (distance * 0.1);
        } else {
          scale = 0.95 - ((distance - 0.5) * 0.2);
        }
        _scales[i] = scale.clamp(widget.minScale, 1.0);
      }
    });
  }

  void _notifySlideStop() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (widget.onSlideStop != null) {
        final int displayIndex = (_pageController.page ?? 0.0).round();
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
    // 使用局部变量避免重复访问 widget
    final bool useLargeNumberMode = widget.loopMode == LoopMode.largeNumber;

    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        // 滚动结束后处理循环跳转（仅方案二需要）
        if (widget.loopMode == LoopMode.copyJump) {
          _handleLoopScroll();
        }
        // 方案二和关闭循环模式需要更新缩放
        if (!useLargeNumberMode) {
          _updateScales();
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
              // 获取当前索引的缩放值
              final double scale = useLargeNumberMode
                  ? _calculateScale(index)
                  : _scales[index];

              return GestureDetector(
                onTap: () {
                  final double page = _pageController.page ?? 0.0;
                  final int centerIndex = page.round();
                  if (index == centerIndex && widget.onCenterCardTap != null) {
                    widget.onCenterCardTap!(realIndex);
                  }
                },
                child: Transform.scale(
                  scale: scale,
                  child: widget.itemBuilder(context, realIndex),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
