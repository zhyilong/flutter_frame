/*
 * Created by zhyilong on 2026/5/16
 * BaseView 使用示例
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'BaseView.dart';

part 'demo_view.g.dart';

/// Demo 数据 Notifier（使用 @riverpod 注解）
@riverpod
class DemoNotifier extends _$DemoNotifier {
  @override
  DemoData build() {
    return DemoData(message: '等待加载...', isLoading: false, loadTime: '');
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setData(String message, String time) {
    state = DemoData(message: message, isLoading: false, loadTime: time);
  }
}

/// Demo 数据模型
class DemoData {
  final String message;
  final bool isLoading;
  final String loadTime;

  DemoData({required this.message, required this.isLoading, required this.loadTime});

  DemoData copyWith({String? message, bool? isLoading, String? loadTime}) {
    return DemoData(message: message ?? this.message, isLoading: isLoading ?? this.isLoading, loadTime: loadTime ?? this.loadTime);
  }
}

/// Demo 页面 - 展示如何使用 BaseView
class DemoView extends BaseView {
  const DemoView({super.key});

  @override
  BaseViewState createState() => _DemoViewState();
}

class _DemoViewState extends BaseViewState<DemoView> {
  int _counter = 0;

  @override
  void onReady() {
    super.onReady();
    // 页面渲染完成后执行，可以在这里调用接口
    debugPrint('DemoView 页面已渲染完成，开始加载数据');

    // 模拟接口调用
    _loadData();
  }

  /// 模拟异步数据加载
  Future<void> _loadData() async {
    // 1. 设置加载状态
    ref.read(demoProvider.notifier).state = ref.read(demoProvider).copyWith(isLoading: true);

    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));

    // 2. 更新数据
    if (mounted) {
      final now = DateTime.now();
      ref.read(demoProvider.notifier).state = DemoData(
        message: '🎉 数据加载成功！这是在 onReady 中调用的模拟接口',
        isLoading: false,
        loadTime: '${now.hour}:${now.minute}:${now.second}',
      );

      // 显示提示
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ 数据加载完成！'), duration: Duration(seconds: 2), backgroundColor: Colors.green));
    }
  }

  @override
  void onClose() {
    super.onClose();
    // 页面销毁时执行，可以在这里清理资源
    debugPrint('DemoView 页面即将销毁');
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget buildBody(BuildContext context) {
    // 监听 provider 状态，自动更新 UI
    final demoData = ref.watch(demoProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          const Center(
            child: Text('BaseView 使用示例', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),

          // onReady 演示区域
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text('onReady 演示', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('页面渲染完成后自动调用 onReady()'),
                  const SizedBox(height: 8),
                  const Text('在 onReady 中调用模拟接口加载数据'),
                  const SizedBox(height: 16),

                  // 加载状态
                  if (demoData.isLoading) ...[
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 8),
                    const Center(child: Text('正在加载数据...')),
                  ] else ...[
                    // 数据展示
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(demoData.message, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Text('加载时间: ${demoData.loadTime}', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 本地状态演示区域
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('本地状态演示', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Center(child: Text('点击次数: $_counter', style: const TextStyle(fontSize: 32))),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(onPressed: _incrementCounter, icon: const Icon(Icons.add), label: const Text('增加计数')),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // context 演示区域
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Context 使用演示', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('这是 context 的使用示例')));
                          },
                          icon: const Icon(Icons.message),
                          label: const Text('显示 SnackBar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showDialog();
                          },
                          icon: const Icon(Icons.add_alert),
                          label: const Text('显示 Dialog'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 生命周期说明
          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('生命周期说明', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text('• onReady: 页面首帧渲染完成后调用，适合调用接口'),
                  Text('• onClose: 页面销毁时调用，适合释放资源'),
                  Text('• buildBody: 构建页面主体内容'),
                  Text('• getTitle: 返回页面标题'),
                  Text('• showBackButton: 控制是否显示返回按钮'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示对话框
  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Context 测试'),
        content: const Text('这是在 BaseView 中使用 context 显示的对话框'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭'))],
      ),
    );
  }

  @override
  String getTitle() {
    return "DemoView 示例";
  }
}
