import 'package:flutter/material.dart';

/// 完整的手机键盘监听示例
/// 演示如何精准监听键盘的升起、隐藏、输入完成等事件
///
/// 使用方法：
/// 1. 在 main.dart 中导入：
///    import 'package:mvvm_demo/examples/keyboard_listener_example.dart';
/// 2. 设置 home：
///    home: KeyboardListenerExample()
/// 3. 或作为路由：
///    '/keyboard': (context) => KeyboardListenerExample()

void main() {
  runApp(KeyboardListenerApp());
}

class KeyboardListenerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '键盘监听示例',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: KeyboardListenerExample(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class KeyboardListenerExample extends StatefulWidget {
  const KeyboardListenerExample({Key? key}) : super(key: key);

  @override
  State<KeyboardListenerExample> createState() =>
      _KeyboardListenerExampleState();
}

class _KeyboardListenerExampleState extends State<KeyboardListenerExample>
    with WidgetsBindingObserver {
  // ==================== 状态变量 ====================
  bool _isKeyboardVisible = false;
  double _keyboardHeight = 0.0;

  // 焦点节点列表
  final List<FocusNode> _focusNodes = List.generate(5, (index) => FocusNode());

  // 输入框控制器
  final List<TextEditingController> _controllers =
      List.generate(5, (index) => TextEditingController());

  // 日志列表
  final List<String> _logs = [];

  // 当前聚焦的输入框索引
  int? _currentFocusedIndex;

  @override
  void initState() {
    super.initState();
    print('🚀 初始化键盘监听器');

    // 添加观察者
    WidgetsBinding.instance.addObserver(this);

    // 为每个焦点节点添加监听器
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() => _onFocusChange(i));
    }

    // 添加初始日志
    _addLog('✅ 键盘监听器已启动');
  }

  @override
  void dispose() {
    print('🛑 销毁键盘监听器');

    // 移除观察者（重要！防止内存泄漏）
    WidgetsBinding.instance.removeObserver(this);

    // 释放焦点节点
    for (var node in _focusNodes) {
      node.dispose();
    }

    // 释放控制器
    for (var controller in _controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  // ==================== 键盘事件监听 ====================

  /// 监听键盘升起和隐藏
  /// 当视图尺寸改变时触发（包括键盘显示/隐藏）
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    // 获取窗口实例
    final window = WidgetsBinding.instance.window;

    // 获取底部内边距（键盘高度）
    final bottomInset = window.viewInsets.bottom;

    // 计算实际键盘高度（考虑设备像素比）
    final newKeyboardHeight = bottomInset / window.devicePixelRatio;

    // 判断键盘是否可见
    final newIsKeyboardVisible = bottomInset > 0;

    // 只在状态真正改变时更新
    if (newIsKeyboardVisible != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = newIsKeyboardVisible;
        _keyboardHeight = newKeyboardHeight;
      });

      if (newIsKeyboardVisible) {
        _onKeyboardShow(newKeyboardHeight);
      } else {
        _onKeyboardHide();
      }
    } else if (newIsKeyboardVisible &&
        (newKeyboardHeight - _keyboardHeight).abs() > 1.0) {
      // 键盘高度改变（例如切换输入法）
      setState(() {
        _keyboardHeight = newKeyboardHeight;
      });
      _addLog('🔄 键盘高度改变: ${_keyboardHeight.toStringAsFixed(1)} px');
    }
  }

  /// 键盘升起回调
  void _onKeyboardShow(double height) {
    _addLog('⌨️  键盘已升起，高度: ${height.toStringAsFixed(1)} px');
    print('✅ 键盘升起 - 高度: $height');

    // 可以在这里执行操作：
    // - 滚动到聚焦的输入框
    // - 显示键盘上方工具栏
    // - 调整布局
    // - 隐藏底部按钮
  }

  /// 键盘隐藏回调
  void _onKeyboardHide() {
    _addLog('⌨️  键盘已隐藏');
    print('❌ 键盘隐藏');

    // 可以在这里执行操作：
    // - 保存表单数据
    // - 验证输入内容
    // - 恢复布局
    // - 显示底部按钮
  }

  /// 焦点变化回调
  void _onFocusChange(int index) {
    if (_focusNodes[index].hasFocus) {
      _currentFocusedIndex = index;
      _addLog('🎯 输入框 ${index + 1} 获得焦点');
      print('📝 输入框 $index 获得焦点');

      // 可以在这里执行操作：
      // - 滚动到该输入框
      // - 显示辅助信息
      // - 加载相关数据
    }
  }

  /// 输入完成回调
  void _onSubmitted(int index, String value) {
    _addLog('✅ 输入框 ${index + 1} 输入完成: "$value"');
    print('✅ 输入框 $index 完成: $value');

    if (value.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('输入框 ${index + 1}: $value'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    // 自动跳转到下一个输入框
    if (index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
      _addLog('➡️  自动跳转到输入框 ${index + 2}');
    } else {
      // 最后一个输入框，完成输入
      _focusNodes[index].unfocus();
      _addLog('🎉 所有输入完成！');
      _showCompletionDialog();
    }
  }

  /// 显示完成对话框
  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('输入完成'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('所有输入框已完成：'),
            SizedBox(height: 12),
            for (int i = 0; i < _controllers.length; i++)
              if (_controllers[i].text.trim().isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${_getLabel(i)}: ${_controllers[i].text}',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllInputs();
            },
            child: Text('清空'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitForm();
            },
            child: Text('提交'),
          ),
        ],
      ),
    );
  }

  /// 获取输入框标签
  String _getLabel(int index) {
    final labels = ['用户名', '邮箱', '手机号', '密码', '备注'];
    return labels[index];
  }

  /// 获取输入框图标
  IconData _getIcon(int index) {
    final icons = [
      Icons.person,
      Icons.email,
      Icons.phone,
      Icons.lock,
      Icons.note,
    ];
    return icons[index];
  }

  /// 获取输入框键盘类型
  TextInputType _getKeyboardType(int index) {
    final types = [
      TextInputType.text,
      TextInputType.emailAddress,
      TextInputType.phone,
      TextInputType.visiblePassword,
      TextInputType.multiline,
    ];
    return types[index];
  }

  /// 获取输入框的 TextInputAction
  TextInputAction _getTextInputAction(int index) {
    final actions = [
      TextInputAction.next,
      TextInputAction.next,
      TextInputAction.next,
      TextInputAction.next,
      TextInputAction.done,
    ];
    return actions[index];
  }

  /// 提交表单
  void _submitForm() {
    _addLog('📤 表单已提交');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ 表单提交成功！'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 清空所有输入
  void _clearAllInputs() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _addLog('🗑️  已清空所有输入');
  }

  /// 添加日志
  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    setState(() {
      _logs.insert(0, '[$timestamp] $message');
      // 只保留最近 50 条日志
      if (_logs.length > 50) {
        _logs.removeLast();
      }
    });
  }

  /// 清空日志
  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  // ==================== UI 构建 ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('手机键盘监听示例'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: _clearLogs,
            tooltip: '清空日志',
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
            tooltip: '说明',
          ),
        ],
      ),
      body: Column(
        children: [
          // ==================== 键盘状态指示器 ====================
          _buildKeyboardStatusIndicator(),

          // ==================== 输入表单 ====================
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: _isKeyboardVisible ? _keyboardHeight + 16 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 输入框列表
                  _buildInputFields(),

                  SizedBox(height: 24),

                  // 功能按钮
                  _buildActionButtons(),
                ],
              ),
            ),
          ),

          // ==================== 日志面板 ====================
          _buildLogPanel(),
        ],
      ),
    );
  }

  /// 构建键盘状态指示器
  Widget _buildKeyboardStatusIndicator() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _isKeyboardVisible ? Colors.blue.shade50 : Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(
            color: _isKeyboardVisible ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // 键盘图标
          AnimatedScale(
            scale: _isKeyboardVisible ? 1.2 : 1.0,
            duration: Duration(milliseconds: 300),
            child: Icon(
              _isKeyboardVisible ? Icons.keyboard : Icons.keyboard_hide,
              size: 32,
              color: _isKeyboardVisible ? Colors.blue : Colors.grey,
            ),
          ),
          SizedBox(width: 16),

          // 状态文本
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isKeyboardVisible ? '⌨️  键盘已升起' : '⌨️  键盘已隐藏',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isKeyboardVisible ? Colors.blue : Colors.grey.shade700,
                  ),
                ),
                if (_isKeyboardVisible) ...[
                  SizedBox(height: 4),
                  Text(
                    '高度: ${_keyboardHeight.toStringAsFixed(1)} px',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 聚焦指示器
          if (_currentFocusedIndex != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, size: 16, color: Colors.green),
                  SizedBox(width: 4),
                  Text(
                    '输入框 ${_currentFocusedIndex! + 1}',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 构建输入框列表
  Widget _buildInputFields() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '表单输入',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // 生成 5 个输入框
            ...List.generate(5, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: TextField(
                  focusNode: _focusNodes[index],
                  controller: _controllers[index],
                  keyboardType: _getKeyboardType(index),
                  textInputAction: _getTextInputAction(index),
                  maxLines: index == 4 ? 3 : 1, // 备注框多行
                  obscureText: index == 3, // 密码框隐藏
                  decoration: InputDecoration(
                    labelText: _getLabel(index),
                    hintText: _getHintText(index),
                    prefixIcon: Icon(_getIcon(index)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    filled: true,
                    fillColor: _focusNodes[index].hasFocus
                        ? Colors.blue.shade50
                        : Colors.grey.shade50,
                  ),
                  onChanged: (value) {
                    // 输入变化时可以执行操作
                    if (value.length % 10 == 0 && value.isNotEmpty) {
                      _addLog('✏️  输入框 ${index + 1}: 已输入 ${value.length} 个字符');
                    }
                  },
                  onSubmitted: (value) => _onSubmitted(index, value),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 获取提示文本
  String _getHintText(int index) {
    final hints = [
      '请输入用户名',
      '请输入邮箱地址',
      '请输入手机号码',
      '请输入密码',
      '请输入备注信息（可多行）',
    ];
    return hints[index];
  }

  /// 构建操作按钮
  Widget _buildActionButtons() {
    // 键盘升起时隐藏主要按钮
    if (_isKeyboardVisible) {
      return SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _clearAllInputs,
            icon: Icon(Icons.clear),
            label: Text('清空'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _submitForm,
            icon: Icon(Icons.send),
            label: Text('提交表单'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建日志面板
  Widget _buildLogPanel() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border(
          top: BorderSide(color: Colors.grey.shade700, width: 2),
        ),
      ),
      child: Column(
        children: [
          // 日志标题栏
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
            ),
            child: Row(
              children: [
                Icon(Icons.terminal, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text(
                  '事件日志 (${_logs.length})',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey, size: 16),
                  onPressed: _clearLogs,
                  tooltip: '清空日志',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),

          // 日志内容
          Expanded(
            child: _logs.isEmpty
                ? Center(
                    child: Text(
                      '暂无日志',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          _logs[index],
                          style: TextStyle(
                            color: Colors.green.shade400,
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// 显示说明对话框
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('使用说明'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoItem(
                '⌨️  键盘监听',
                '使用 WidgetsBindingObserver 精准监听键盘的升起和隐藏事件',
              ),
              _buildInfoItem(
                '🎯 焦点管理',
                '每个输入框都有独立的 FocusNode，可以精确追踪焦点变化',
              ),
              _buildInfoItem(
                '➡️  自动跳转',
                '按完成键后自动跳转到下一个输入框',
              ),
              _buildInfoItem(
                '📝 输入完成',
                '使用 TextInputAction 和 onSubmitted 处理输入完成事件',
              ),
              _buildInfoItem(
                '🎨 动画效果',
                '键盘状态变化时有流畅的动画过渡',
              ),
              _buildInfoItem(
                '📊 事件日志',
                '实时显示所有键盘和焦点事件的日志',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('知道了'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// ==================== 扩展：自定义键盘可见性监听器 ====================

/// 键盘可见性构建器
/// 可以在任何地方使用，自动监听键盘状态
class KeyboardVisibilityBuilder extends StatefulWidget {
  final Widget Function(
    BuildContext context,
    bool isKeyboardVisible,
    double keyboardHeight,
  ) builder;

  const KeyboardVisibilityBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  State<KeyboardVisibilityBuilder> createState() =>
      _KeyboardVisibilityBuilderState();
}

class _KeyboardVisibilityBuilderState extends State<KeyboardVisibilityBuilder>
    with WidgetsBindingObserver {
  bool _isKeyboardVisible = false;
  double _keyboardHeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final window = WidgetsBinding.instance.window;

    setState(() {
      _isKeyboardVisible = bottomInset > 0;
      _keyboardHeight = bottomInset / window.devicePixelRatio;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _isKeyboardVisible, _keyboardHeight);
  }
}

/// ==================== 使用示例 ====================

/// 简单使用示例
class SimpleKeyboardExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('简单键盘监听')),
      body: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible, keyboardHeight) {
          return Column(
            children: [
              // 状态指示
              Container(
                padding: EdgeInsets.all(20),
                color: isKeyboardVisible ? Colors.green : Colors.grey,
                child: Text(
                  isKeyboardVisible ? '键盘已升起' : '键盘已隐藏',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),

              // 输入框
              Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: '点击测试',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
