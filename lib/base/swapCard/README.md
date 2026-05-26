# SwapCardWidget

一个支持左右滑动、智能缩放的卡片轮播组件。

## 功能特性

- ✨ **智能缩放**：卡片越靠近中心越大，距离中心越远越小
- 🎨 **完全自定义**：使用者只需提供卡片 widget，缩放自动处理
- 📢 **滑动停止回调**：滑动结束后通知当前中心卡片索引
- 🖱️ **中心卡片点击**：只响应中心卡片的点击事件
- ⚙️ **可配置参数**：支持自定义最小缩放值、初始页码
- 🎬 **自动播放**：支持自动轮播，可配置播放间隔
- 🔄 **无限循环**：支持首尾相连的无限滚动（基于首尾副本跳转方案）
- 🎭 **流畅动画**：基于 AnimatedBuilder 实现平滑的缩放过渡

## 依赖

组件本身无额外依赖，仅使用 Flutter SDK。

**示例代码依赖：**
```yaml
dependencies:
  flutter:
    sdk: flutter
  cached_network_image: ^3.3.0  # 仅示例中使用，用于加载网络图片
```

## 使用方法

### 基础用法

```dart
SwapCardWidget(
  itemCount: 5,
  itemBuilder: (context, index) {
    return Container(
      child: YourCardWidget(),
    );
  },
)
```

### 完整示例

```dart
SwapCardWidget(
  itemCount: urls.length,
  minScale: 0.5,              // 可选：最小缩放值，默认 0.5
  initialPage: 0,             // 可选：初始页码，默认 0
  autoPlay: true,             // 可选：自动播放，默认 false
  autoPlayInterval: const Duration(seconds: 3),  // 可选：播放间隔，默认 3秒
  loop: true,                 // 可选：无限循环，默认 false
  itemBuilder: (context, index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          urls[index],
          fit: BoxFit.cover,
        ),
      ),
    );
  },
  onSlideStop: (centerIndex) {
    print('滑动停止，当前卡片：$centerIndex');
  },
  onCenterCardTap: (index) {
    print('点击了中心卡片：$index');
  },
)
```

## API 参数说明

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| `itemCount` | `int` | ✅ | - | 卡片总数 |
| `itemBuilder` | `Widget Function(BuildContext, int)` | ✅ | - | 卡片构建器，返回每个卡片的 widget |
| `minScale` | `double` | ❌ | `0.5` | 最小缩放值（范围 0.0-1.0） |
| `initialPage` | `int` | ❌ | `0` | 初始显示的页码 |
| `autoPlay` | `bool` | ❌ | `false` | 是否自动播放 |
| `autoPlayInterval` | `Duration` | ❌ | `3秒` | 自动播放间隔时间 |
| `onSlideStop` | `void Function(int)?` | ❌ | `null` | 滑动停止回调，返回中心卡片索引 |
| `onCenterCardTap` | `void Function(int)?` | ❌ | `null` | 中心卡片点击回调，返回被点击的卡片索引 |

## 核心实现原理

### 1. 缩放计算系统

```
distance = |current_page - card_index|
```

**分段缩放曲线：**
- **距离 < 0.5**：几乎不缩放（1.0 - distance × 0.1）
  - 中心卡片保持接近 100% 大小
- **距离 ≥ 0.5**：明显缩小（0.95 - (distance - 0.5) × 0.2）
  - 距离越远缩放越明显
- **最终范围**：限制在 `minScale` ~ 1.0 之间

**缩放效果示例：**
```
卡片在中心(距离0)   → scale = 1.0  (100%)
卡片略偏移(距离0.3) → scale ≈ 0.97 (97%)
卡片较远(距离1.0)   → scale ≈ 0.85 (85%)
卡片很远(距离2.0)   → scale ≈ 0.65 (65%, minScale=0.5时为0.5)
```

### 2. 实时监听与更新

```dart
_pageController.addListener(() {
  _updateScales();      // 每次滚动更新缩放
  _notifySlideStop();   // 防抖检测停止
});
```

- PageController 每次滚动触发 listener
- `setState()` 重建 widget，传递新的 scale 值
- `AnimatedBuilder` 确保平滑动画过渡

### 3. 滑动停止检测（防抖模式）

```dart
void _notifySlideStop() {
  _debounceTimer?.cancel();  // 取消之前的定时器
  _debounceTimer = Timer(Duration(milliseconds: 150), () {
    // 150ms 无新滚动事件 → 判定为停止
    widget.onSlideStop!(centerIndex);
  });
}
```

**为什么需要防抖？**
- PageController 在滚动时会连续触发事件
- 用户手动滑动结束后会有惯性动画
- 防抖确保只在完全停止后才触发回调

### 4. 中心卡片点击检测

```dart
GestureDetector(
  onTap: () {
    final int centerIndex = (_pageController.page ?? 0.0).round();
    if (index == centerIndex) {  // 只响应中心卡片
      widget.onCenterCardTap!(index);
    }
  },
)
```

### 5. 自动播放实现

```dart
void _startAutoPlay() {
  _stopAutoPlay();
  _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (timer) {
    final int currentPage = (_pageController.page ?? widget.initialPage).round();
    final int nextPage = (currentPage + 1) % widget.itemCount;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  });
}
```

**关键点：**
- 使用 `Timer.periodic` 定时触发翻页
- 使用模运算 `(currentPage + 1) % itemCount` 实现循环播放
- 使用 `animateToPage` 实现平滑翻页动画
- 在组件销毁时自动取消定时器

### 6. 数据流

```
用户滑动
   ↓
PageController.page 改变
   ↓
listener 触发
   ↓
计算每个卡片的 distance
   ↓
根据 distance 计算 scale
   ↓
setState() 更新 _scales[]
   ↓
PageView.builder 重建
   ↓
Transform.scale 应用缩放
   ↓
用户看到流畅的缩放动画
```

## 性能优化

1. **分离关注点**：缩放计算与 UI 渲染分离
2. **局部更新**：使用 `AnimatedBuilder` 而非全局重建
3. **防抖机制**：避免频繁的回调触发
4. **首帧计算**：使用 `addPostFrameCallback` 确保初始化时正确显示缩放

## 使用场景

- 图片轮播器
- 卡片选择器
- 产品展示
- 相册浏览
- 教程引导

## 扩展建议

基于此实现可以轻松扩展：
- 添加 3D 旋转效果
- 支持垂直滚动
- 添加指示器（dots indicator）
- 用户触摸时暂停自动播放
- 自定义滚动曲线
- 添加页面切换动画效果

## 文件结构

```
lib/base/swapCard/
├── swapCardWidget.dart      # 主组件实现
├── swapCard.dart            # 旧的 Card 类（已废弃）
├── swapcard_example.dart    # 使用示例
└── README.md                # 本文档
```

## 版本历史

- **v1.1** - 新增自动播放功能
  - 添加 `autoPlay` 参数控制是否自动播放
  - 添加 `autoPlayInterval` 参数控制播放间隔
  - 支持循环播放（到最后一张自动回到第一张）

- **v1.0** - 初始版本
  - 基础滑动和缩放功能
  - 自定义卡片 widget
  - 滑动停止和点击回调
  - 可配置最小缩放值
  - 可配置初始页码
