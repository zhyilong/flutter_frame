# Flutter 键盘监听完整示例

这是一个功能完整、可以直接运行的 Flutter 手机键盘监听示例代码。

## 📁 文件位置

```
lib/examples/keyboard_listener_example.dart
```

## 🚀 快速开始

### 方法 1：直接运行（推荐）

修改 `lib/main.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:mvvm_demo/examples/keyboard_listener_example.dart';

void main() {
  runApp(KeyboardListenerApp());
}
```

### 方法 2：作为路由添加

在您的现有项目中添加路由：

```dart
import 'package:mvvm_demo/examples/keyboard_listener_example.dart';

// 在 MaterialApp 中添加路由
MaterialApp(
  routes: {
    '/': (context) => YourHomePage(),
    '/keyboard-example': (context) => KeyboardListenerExample(),
  },
),
```

然后导航到示例：

```dart
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, '/keyboard-example');
  },
  child: Text('查看键盘监听示例'),
)
```

## ✨ 功能特性

### 1. **精准的键盘状态监听**

- ✅ 键盘升起事件
- ✅ 键盘隐藏事件
- ✅ 键盘高度检测
- ✅ 实时状态更新

### 2. **完整的焦点管理**

- ✅ 每个输入框独立焦点节点
- ✅ 焦点变化监听
- ✅ 当前聚焦输入框高亮显示
- ✅ 自动焦点切换

### 3. **输入完成处理**

- ✅ TextInputAction 支持（next、done、search 等）
- ✅ 自动跳转到下一个输入框
- ✅ 最后一个输入框完成提示
- ✅ 表单提交处理

### 4. **实用的 UI 功能**

- ✅ 键盘状态实时指示器
- ✅ 流畅的动画效果
- ✅ 键盘升起时自动调整布局
- ✅ 智能隐藏/显示底部按钮

### 5. **事件日志系统**

- ✅ 实时显示所有键盘事件
- ✅ 带时间戳的日志记录
- ✅ 日志面板可清空
- ✅ 最多保留 50 条日志

## 📱 使用场景示例

### 场景 1：登录表单

```dart
TextField(
  focusNode: _usernameFocus,
  textInputAction: TextInputAction.next,
  onSubmitted: (_) {
    // 用户名输入完成，跳转到密码框
    _passwordFocus.requestFocus();
  },
)
```

### 场景 2：搜索功能

```dart
TextField(
  textInputAction: TextInputAction.search,
  onSubmitted: (query) {
    // 执行搜索
    performSearch(query);
  },
)
```

### 场景 3：多步表单

```dart
// 使用示例代码中的自动跳转功能
// 用户按完成键后自动进入下一个输入框
```

### 场景 4：聊天应用

```dart
// 监听键盘升起，调整聊天界面
@override
void didChangeMetrics() {
  final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
  if (bottomInset > 0) {
    // 键盘升起，滚动到底部消息
    scrollToBottom();
  }
}
```

## 🔑 核心代码解析

### 1. **监听键盘升起/隐藏**

```dart
class _MyState extends State<MyWidget> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    // 添加观察者
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // 移除观察者（重要！）
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // 获取键盘高度
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;

    // 判断键盘是否可见
    final isKeyboardVisible = bottomInset > 0;
    final keyboardHeight = bottomInset / window.devicePixelRatio;

    if (isKeyboardVisible) {
      // 键盘升起
      print('键盘升起，高度: $keyboardHeight');
    } else {
      // 键盘隐藏
      print('键盘隐藏');
    }
  }
}
```

### 2. **处理输入完成**

```dart
TextField(
  textInputAction: TextInputAction.done,  // 或 next, search 等
  onSubmitted: (value) {
    print('输入完成: $value');
    // 处理输入完成逻辑
  },
)
```

### 3. **焦点管理**

```dart
// 创建焦点节点
final _focusNode = FocusNode();

// 监听焦点变化
_focusNode.addListener(() {
  if (_focusNode.hasFocus) {
    print('获得焦点');
  } else {
    print('失去焦点');
  }
});

// 请求焦点
_focusNode.requestFocus();

// 取消焦点
_focusNode.unfocus();
```

### 4. **使用 KeyboardVisibilityBuilder**

```dart
KeyboardVisibilityBuilder(
  builder: (context, isKeyboardVisible, keyboardHeight) {
    return YourWidget();
  },
)
```

## 📊 TextInputAction 类型

```dart
// 常用的 TextInputAction
TextInputAction.none       // 无操作
TextInputAction.unspecified // 未指定
TextInputAction.done       // 完成
TextInputAction.go         // 前往
TextInputAction.search     // 搜索
TextInputAction.send       // 发送
TextInputAction.next       // 下一个
TextInputAction.previous   // 上一个
TextInputAction.continueAction // 继续
TextInputAction.join       // 加入
TextInputAction.route      // 路由
TextInputAction.emergencyCall // 紧急呼叫
TextInputAction.newline    // 换行
```

## 🎯 最佳实践

### ✅ DO（推荐做法）

1. **总是移除观察者**
   ```dart
   @override
   void dispose() {
     WidgetsBinding.instance.removeObserver(this);
     super.dispose();
   }
   ```

2. **使用 FocusNode 管理焦点**
   ```dart
   final _focusNode = FocusNode();
   // 在 dispose 中释放
   @override
   void dispose() {
     _focusNode.dispose();
     super.dispose();
   }
   ```

3. **提供良好的用户反馈**
   ```dart
   onSubmitted: (value) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('输入完成')),
     );
   }
   ```

### ❌ DON'T（避免的做法）

1. **不要忘记释放资源**
   ```dart
   // ❌ 错误
   @override
   void dispose() {
     super.dispose();
     // 忘记移除观察者
   }
   ```

2. **不要在 build 方法中创建 FocusNode**
   ```dart
   // ❌ 错误
   @override
   Widget build(BuildContext context) {
     final focusNode = FocusNode(); // 每次 build 都创建新的
     return TextField(focusNode: focusNode);
   }

   // ✅ 正确
   final _focusNode = FocusNode(); // 在 State 类中创建

   @override
   Widget build(BuildContext context) {
     return TextField(focusNode: _focusNode);
   }
   ```

## 🐛 常见问题

### Q1: 键盘事件不触发？

**A:** 确保正确添加了观察者：

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this); // 必须添加
}

@override
void dispose() {
  WidgetsBinding.instance.removeObserver(this); // 必须移除
  super.dispose();
}
```

### Q2: 如何判断键盘是否完全升起？

**A:** 检查 `viewInsets.bottom`：

```dart
final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
final isKeyboardVisible = bottomInset > 0;
```

### Q3: 如何获取准确的键盘高度？

**A:** 考虑设备像素比：

```dart
final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
final keyboardHeight = bottomInset / window.devicePixelRatio;
```

### Q4: 键盘遮挡了输入框怎么办？

**A:** 使用 `padding` 或滚动：

```dart
SingleChildScrollView(
  padding: EdgeInsets.only(
    bottom: MediaQuery.of(context).viewInsets.bottom,
  ),
  child: YourForm(),
)
```

## 📚 扩展阅读

- [Flutter 官方文档 - TextInputAction](https://api.flutter.dev/flutter/services/TextInputAction.html)
- [Flutter 官方文档 - FocusNode](https://api.flutter.dev/flutter/widgets/FocusNode-class.html)
- [WidgetsBindingObserver 使用指南](https://api.flutter.dev/flutter/widgets/WidgetsBindingObserver-mixin.html)

## 🎨 自定义和扩展

您可以基于这个示例：

1. **添加更多输入验证**
2. **集成表单验证库**
3. **添加自动保存功能**
4. **实现复杂的表单逻辑**
5. **添加语音输入支持**

## 💡 提示

- 这个示例是完全独立的，可以直接复制到任何项目中使用
- 所有代码都有详细注释，方便学习和理解
- 包含了生产环境需要的最佳实践
- 事件日志功能有助于调试和学习

## 📞 反馈

如有问题或建议，欢迎反馈！

---

**享受编码！** 🚀
