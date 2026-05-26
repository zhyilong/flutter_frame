/*
 * Created by zhyilong on 2026/5/23
 */

import 'dart:async';

import 'package:flutter/cupertino.dart';

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
    this.loop = false,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final void Function(int centerIndex)? onSlideStop;
  final void Function(int index)? onCenterCardTap;
  final double minScale;
  final int initialPage;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool loop;

  @override
  State<StatefulWidget> createState() => _SwapCardWidgetState();
}

class _SwapCardWidgetState extends State<SwapCardWidget> {
  late final PageController _pageController;
  final List<double> _scales = [];
  Timer? _debounceTimer;
  Timer? _autoPlayTimer;
  late final int _displayCount;
  late final int _realStartIndex;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();

    // 前后各加2个副本，总数量 = 真实数量 + 4
    _displayCount = widget.loop ? widget.itemCount + 4 : widget.itemCount;
    _realStartIndex = widget.loop ? 2 : 0; // 真实数据的起始索引

    // 初始化缩放值列表
    final int scaleCount = widget.loop ? widget.itemCount + 4 : widget.itemCount;
    for (int i = 0; i < scaleCount; i++) {
      _scales.add(1.0);
    }

    _pageController = PageController(
      viewportFraction: 0.6,
      initialPage: widget.loop ? 2 : widget.initialPage,
    );

    // 首帧渲染后计算初始缩放
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScales();
      if (widget.autoPlay) {
        _startAutoPlay();
      }
    });

    _pageController.addListener(() {
      _updateScales();
      if (widget.loop) {
        _handleLoopScroll();
      }
      _notifySlideStop();
    });
  }

  // 将显示索引映射到真实数据索引
  int _getRealIndex(int displayIndex) {
    if (!widget.loop) return displayIndex;

    // 前2个是最后2张的副本
    if (displayIndex < _realStartIndex) {
      return widget.itemCount - _realStartIndex + displayIndex;
    }
    // 后2个是前2张的副本
    else if (displayIndex >= _realStartIndex + widget.itemCount) {
      return displayIndex - _realStartIndex - widget.itemCount;
    }
    // 中间是真实数据
    else {
      return displayIndex - _realStartIndex;
    }
  }

  // 处理循环滚动跳转
  void _handleLoopScroll() {
    if (_isScrolling) return;

    final double page = _pageController.page ?? 0;
    final int currentPage = page.round();

    // 滚动到最右边的副本时，跳转到左边真实位置
    if (currentPage >= _realStartIndex + widget.itemCount) {
      _isScrolling = true;
      final int offset = currentPage - (_realStartIndex + widget.itemCount);
      _pageController.jumpToPage(_realStartIndex + offset);
      _isScrolling = false;
    }
    // 滚动到最左边的副本时，跳转到右边真实位置
    else if (currentPage < _realStartIndex) {
      _isScrolling = true;
      final int offset = _realStartIndex - currentPage;
      _pageController.jumpToPage(_realStartIndex + widget.itemCount - offset);
      _isScrolling = false;
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

  void _updateScales() {
    final double page = _pageController.page ?? 0.0;

    setState(() {
      for (int i = 0; i < _displayCount; i++) {
        double distance = (page - i).abs();
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
    _stopAutoPlay();
    _pageController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        // 滚动结束通知 - 防抖定时器也会捕获
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
              return GestureDetector(
                onTap: () {
                  final double page = _pageController.page ?? 0.0;
                  final int centerIndex = page.round();
                  if (index == centerIndex && widget.onCenterCardTap != null) {
                    widget.onCenterCardTap!(realIndex);
                  }
                },
                child: Transform.scale(
                  scale: _scales[index],
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
