import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 键盘监听 - 方案3：动画完成后回调（最准确）
///
/// 这个方案确保只在键盘动画完全结束后才触发回调，
/// 能够准确捕捉"键盘已完全升起"和"键盘已完全隐藏"的状态。
///
/// 核心原理：
/// 1. 使用 SchedulerBinding.addPostFrameCallback 等待帧完成
/// 2. 额外延迟确保动画完全结束
/// 3. 二次验证状态，确保准确性
///
/// 优点：
/// ✅ 最准确，只在动画完成后触发
/// ✅ 避免动画过程中的误触发
/// ✅ 提供动画状态指示
/// ✅ 适合需要精确控制的场景

void main() {
  runApp(KeyboardAnimationCompleteApp());
}

class KeyboardAnimationCompleteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '键盘动画完成监听',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: KeyboardAnimationCompleteExample(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class KeyboardAnimationCompleteExample extends StatefulWidget {
  const KeyboardAnimationCompleteExample({Key? key}) : super(key: key);

  @override
  State<KeyboardAnimationCompleteExample> createState() =>
      _KeyboardAnimationCompleteExampleState();
}

class _KeyboardAnimationCompleteExampleState
    extends State<KeyboardAnimationCompleteExample>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // ==================== 状态变量 ====================
  bool _isKeyboardVisible = false;
  double _keyboardHeight = 0.0;

  // 动画状态
  bool _isAnimating = false;
  String _animationStatus = '';

  // 目标状态（动画最终会达到的状态）
  bool _targetIsVisible = false;
  double _targetHeight = 0.0;

  // 输入框
  final List<FocusNode> _focusNodes = List.generate(5, (index) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(5, (index) => TextEditingController());

  // 日志
  final List<String> _logs = [];
  int _currentFocusedIndex = -1;

  // 防止重复处理
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    print('🚀 初始化键盘动画监听器（方案3）');

    // 添加观察者
    WidgetsBinding.instance.addObserver(this);

    // 为每个焦点节点添加监听器
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() => _onFocusChange(i));
    }

    _addLog('✅ 键盘动画监听器已启动');
  }

  @override
  void dispose() {
    print('🛑 销毁键盘动画监听器');

    // 移除观察者
    WidgetsBinding.instance.removeObserver(this);

    // 释放资源
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  // ==================== 核心实现 ====================

  /// 监听键盘尺寸变化
  /// 当视图尺寸改变时触发（包括键盘显示/隐藏动画）
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    // 如果正在处理中，跳过（防止重复）
    if (_isProcessing) {
      print('⏸️  正在处理中，跳过本次触发');
      return;
    }

    final window = WidgetsBinding.instance.window;
    final bottomInset = window.viewInsets.bottom;
    final newHeight = bottomInset / window.devicePixelRatio;
    final newIsVisible = bottomInset > 0;

    // 状态没有变化，跳过
    if (newIsVisible == _isKeyboardVisible &&
        (newHeight - _keyboardHeight).abs() < 1.0) {
      return;
    }

    // 更新动画状态
    setState(() {
      _isAnimating = true;
      _animationStatus = newIsVisible ? '键盘升起中...' : '键盘隐藏中...';
      _targetIsVisible = newIsVisible;
      _targetHeight = newHeight;
    });

    print('🎬 键盘状态改变: ${newIsVisible ? "升起" : "隐藏"}，目标高度: $newHeight');
    _addLog('🎬 键盘开始${newIsVisible ? "升起" : "隐藏"}动画');

    // 核心逻辑：等待动画完成
    _waitForAnimationComplete(newIsVisible, newHeight);
  }

  /// 等待键盘动画完成
  /// 这是方案3的核心实现
  void _waitForAnimationComplete(bool targetIsVisible, double targetHeight) {
    _isProcessing = true;

    // 步骤1: 等待当前帧完成
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _isProcessing = false;
        return;
      }

      print('📍 当前帧完成，等待动画结束...');

      // 步骤2: 额外延迟，确保动画完全结束
      // 键盘动画通常需要 200-300ms
      Future.delayed(Duration(milliseconds: 300), () {
        if (!mounted) {
          _isProcessing = false;
          return;
        }

        // 步骤3: 二次验证，确认动画真的完成了
        final window = WidgetsBinding.instance.window;
        final finalBottomInset = window.viewInsets.bottom;
        final finalHeight = finalBottomInset / window.devicePixelRatio;
        final finalIsVisible = finalBottomInset > 0;

        // 检查是否达到了目标状态
        bool animationCompleted = false;

        if (targetIsVisible) {
          // 目标是升起：检查是否真的升起且高度合理
          animationCompleted = finalIsVisible && finalHeight > 50;
        } else {
          // 目标是隐藏：检查是否真的隐藏
          animationCompleted = !finalIsVisible;
        }

        if (animationCompleted) {
          // 动画确实完成了
          setState(() {
            _isKeyboardVisible = finalIsVisible;
            _keyboardHeight = finalHeight;
            _isAnimating = false;
            _animationStatus = finalIsVisible ? '动画完成：已升起' : '动画完成：已隐藏';
          });

          _isProcessing = false;

          if (finalIsVisible) {
            _onKeyboardShowComplete(finalHeight);
          } else {
            _onKeyboardHideComplete();
          }
        } else {
          // 动画可能还没完成，再等待一段时间
          print('⏳ 动画可能未完成，再等待 100ms...');
          Future.delayed(Duration(milliseconds: 100), () {
            if (!mounted) {
              _isProcessing = false;
              return;
            }

            // 第三次验证
            final checkBottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
            final checkHeight = checkBottomInset / window.devicePixelRatio;
            final checkIsVisible = checkBottomInset > 0;

            setState(() {
              _isKeyboardVisible = checkIsVisible;
              _keyboardHeight = checkHeight;
              _isAnimating = false;
              _animationStatus = checkIsVisible ? '已升起（延迟确认）' : '已隐藏（延迟确认）';
            });

            _isProcessing = false;

            if (checkIsVisible) {
              _onKeyboardShowComplete(checkHeight);
            } else {
              _onKeyboardHideComplete();
            }
          });
        }
      });
    });
  }

  /// 键盘完全升起后的回调
  void _onKeyboardShowComplete(double height) {
    _addLog('✅✅✅ 键盘已完全升起，动画结束，高度: ${height.toStringAsFixed(1)} px');
    print('✅✅✅ 键盘已完全升起 - 动画完成 - 高度: $height');

    // 在这里执行需要在键盘完全升起后才能做的操作
    // 例如：
    // - 滚动到聚焦的输入框
    // - 显示键盘上方工具栏
    // - 调整布局到最终位置
    // - 隐藏底部按钮
  }

  /// 键盘完全隐藏后的回调
  void _onKeyboardHideComplete() {
    _addLog('❌❌❌ 键盘已完全隐藏，动画结束');
    print('❌❌❌ 键盘已完全隐藏 - 动画完成');

    // 在这里执行需要在键盘完全隐藏后才能做的操作
    // 例如：
    // - 恢复布局
    // - 显示底部按钮
    // - 保存表单数据
    // - 验证输入内容
  }

  /// 焦点变化回调
  void _onFocusChange(int index) {
    if (_focusNodes[index].hasFocus) {
      _currentFocusedIndex = index;
      _addLog('🎯 输入框 ${index + 1} 获得焦点');
    }
  }

  /// 输入完成回调
  void _onSubmitted(int index, String value) {
    _addLog('✅ 输入框 ${index + 1} 完成: "$value"');

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
      Future.delayed(Duration(milliseconds: 100), () {
        _focusNodes[index + 1].requestFocus();
      });
    } else {
      _focusNodes[index].unfocus();
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
                  child: Text('${_getLabel(i)}: ${_controllers[i].text}'),
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

  /// 提交表单
  void _submitForm() {
    _addLog('📤 表单已提交');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ 表单提交成功！'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
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
      if (_logs.length > 50) _logs.removeLast();
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
        title: Text('键盘动画完成监听'),
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
          // 动画状态指示器
          _buildAnimationStatusIndicator(),

          // 输入表单
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: _isKeyboardVisible ? _keyboardHeight + 16 : 16,
              ),
              child: Column(
                children: [
                  _buildInputFields(),
                  SizedBox(height: 24),
                  if (!_isKeyboardVisible) _buildActionButtons(),
                ],
              ),
            ),
          ),

          // 日志面板
          _buildLogPanel(),
        ],
      ),
    );
  }

  /// 构建动画状态指示器
  Widget _buildAnimationStatusIndicator() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _isAnimating
            ? Colors.orange.shade50
            : _isKeyboardVisible
                ? Colors.green.shade50
                : Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(
            color: _isAnimating
                ? Colors.orange
                : _isKeyboardVisible
                    ? Colors.green
                    : Colors.grey.shade300,
            width: 2,
          ),
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // 状态行
          Row(
            children: [
              // 动画指示器
              if (_isAnimating)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                )
              else
                Icon(
                  _isKeyboardVisible ? Icons.keyboard : Icons.keyboard_hide,
                  size: 28,
                  color: _isKeyboardVisible ? Colors.green : Colors.grey,
                ),
              SizedBox(width: 16),

              // 状态文本
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isAnimating
                          ? '🎬 $_animationStatus'
                          : _isKeyboardVisible
                              ? '⌨️  键盘已完全升起'
                              : '⌨️  键盘已完全隐藏',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _isAnimating
                            ? Colors.orange
                            : _isKeyboardVisible
                                ? Colors.green
                                : Colors.grey.shade700,
                      ),
                    ),
                    if (_isKeyboardVisible && !_isAnimating) ...[
                      SizedBox(height: 4),
                      Text(
                        '高度: ${_keyboardHeight.toStringAsFixed(1)} px (动画已完成)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // 当前聚焦的输入框
              if (_currentFocusedIndex >= 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Text(
                    '输入框 ${_currentFocusedIndex + 1}',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          // 动画进度条
          if (_isAnimating)
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    backgroundColor: Colors.orange.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '等待键盘动画完成...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 构建输入框
  Widget _buildInputFields() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '表单输入（测试键盘动画）',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...List.generate(5, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: TextField(
                  focusNode: _focusNodes[index],
                  controller: _controllers[index],
                  keyboardType: _getKeyboardType(index),
                  textInputAction: _getTextInputAction(index),
                  maxLines: index == 4 ? 3 : 1,
                  obscureText: index == 3,
                  decoration: InputDecoration(
                    labelText: _getLabel(index),
                    hintText: _getHintText(index),
                    prefixIcon: Icon(_getIcon(index)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    filled: true,
                    fillColor: _focusNodes[index].hasFocus
                        ? Colors.green.shade50
                        : Colors.grey.shade50,
                  ),
                  onSubmitted: (value) => _onSubmitted(index, value),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons() {
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
                  '动画完成日志 (${_logs.length})',
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
          Expanded(
            child: _logs.isEmpty
                ? Center(
                    child: Text(
                      '暂无日志 - 点击输入框查看动画完成日志',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      // 高亮显示动画完成日志
                      final log = _logs[index];
                      final isHighlight = log.contains('✅✅✅') ||
                          log.contains('❌❌❌');

                      return Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          log,
                          style: TextStyle(
                            color: isHighlight
                                ? Colors.yellow
                                : Colors.green.shade400,
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight:
                                isHighlight ? FontWeight.bold : FontWeight.normal,
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

  String _getLabel(int index) {
    final labels = ['用户名', '邮箱', '手机号', '密码', '备注'];
    return labels[index];
  }

  IconData _getIcon(int index) {
    final icons = [Icons.person, Icons.email, Icons.phone, Icons.lock, Icons.note];
    return icons[index];
  }

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

  /// 显示说明对话框
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.green),
            SizedBox(width: 8),
            Text('方案3：动画完成回调'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoItem(
                '🎯 最准确',
                '只在键盘动画完全结束后才触发回调',
              ),
              _buildInfoItem(
                '📍 帧回调',
                '使用 SchedulerBinding.addPostFrameCallback 等待帧完成',
              ),
              _buildInfoItem(
                '⏱️  额外延迟',
                '再延迟 300ms 确保动画完全结束',
              ),
              _buildInfoItem(
                '✅ 二次验证',
                '多次检查状态，确保准确性',
              ),
              _buildInfoItem(
                '🎬 动画指示',
                '显示动画进行中的状态',
              ),
              _buildInfoItem(
                '🎨 视觉反馈',
                '橙色=动画中，绿色=已完成',
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
