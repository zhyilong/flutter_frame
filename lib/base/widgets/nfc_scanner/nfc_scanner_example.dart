/*
 * Created by zhyilong on 2026/5/19
 * NFC扫描组件使用示例
 */

import 'package:flutter/material.dart';
import 'nfc_scanner_widget.dart';
import 'nfc_helper.dart';

/// NFC扫描组件使用示例
class NfcScannerExample extends StatelessWidget {
  const NfcScannerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NFC扫描示例')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('NFC功能示例', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            // 读取NFC标签示例
            ElevatedButton(
              onPressed: () => _readNfcExample(context),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('读取NFC标签', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),

            // 写入文本示例
            ElevatedButton(
              onPressed: () => _writeTextExample(context),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('写入文本到NFC', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),

            // 写入URL示例
            ElevatedButton(
              onPressed: () => _writeUrlExample(context),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('写入URL到NFC', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),

            // 写入JSON示例
            ElevatedButton(
              onPressed: () => _writeJsonExample(context),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('写入JSON到NFC', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 30),

            // 说明文字
            const Text(
              '使用说明：\n'
              '1. 点击上方按钮打开NFC扫描面板\n'
              '2. 将手机靠近NFC标签\n'
              '3. 等待读取或写入完成\n'
              '4. 操作完成后面板会自动关闭\n\n'
              '注意：\n'
              '- 确保设备支持NFC功能\n'
              '- 确保NFC功能已在系统设置中开启\n'
              '- 确保应用具有NFC权限',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// 读取NFC标签示例
  void _readNfcExample(BuildContext context) {
    NfcScannerWidget.show(
      context: context,
      title: '扫描NFC标签',
      scanningHint: '请将手机靠近NFC标签',
      readingHint: '正在读取...',
      onReadComplete: (result) {
        if (result.success) {
          _showResultDialog(context, result);
        } else {
          _showErrorDialog(context, result.error);
        }
      },
    );
  }

  /// 写入文本示例
  void _writeTextExample(BuildContext context) {
    NfcScannerWidget.show(
      context: context,
      title: '写入文本到NFC',
      isWriteMode: true,
      writeTextData: 'Hello, NFC!',
      writeHint: '正在写入文本...',
      onWriteComplete: (success, error) {
        if (success) {
          _showSimpleDialog(context, '写入成功', '文本已成功写入NFC标签');
        } else {
          _showErrorDialog(context, error);
        }
      },
    );
  }

  /// 写入URL示例
  void _writeUrlExample(BuildContext context) {
    NfcScannerWidget.show(
      context: context,
      title: '写入URL到NFC',
      isWriteMode: true,
      writeTextData: 'https://github.com',
      writeHint: '正在写入URL...',
      onWriteComplete: (success, error) {
        if (success) {
          _showSimpleDialog(context, '写入成功', 'URL已成功写入NFC标签');
        } else {
          _showErrorDialog(context, error);
        }
      },
    );
  }

  /// 写入JSON示例
  void _writeJsonExample(BuildContext context) {
    // 构建JSON数据
    final jsonData = {'id': '12345', 'name': '张三', 'age': 25, 'email': 'zhangsan@example.com', 'timestamp': DateTime.now().toIso8601String()};

    // 验证JSON大小
    if (!NfcHelper.validateJsonSize(jsonData)) {
      _showSimpleDialog(context, '数据太大', 'JSON数据超出NFC标签容量，请减少数据量');
      return;
    }

    NfcScannerWidget.show(
      context: context,
      title: '写入JSON到NFC',
      isWriteMode: true,
      writeJsonData: jsonData,
      writeHint: '正在写入JSON数据...',
      onWriteComplete: (success, error) {
        if (success) {
          _showSimpleDialog(context, '写入成功', 'JSON数据已成功写入NFC标签');
        } else {
          _showErrorDialog(context, error);
        }
      },
    );
  }

  /// 显示读取结果对话框
  void _showResultDialog(BuildContext context, NfcReadResult result) {
    String content;
    switch (result.type) {
      case NfcDataType.text:
        content = '类型: 文本\n内容: ${result.content}';
        break;
      case NfcDataType.url:
        content = '类型: URL\n内容: ${result.content}';
        break;
      case NfcDataType.json:
        content = '类型: JSON\n数据: ${result.jsonData}';
        break;
      default:
        content = '类型: 未知\n内容: ${result.content}';
    }

    _showSimpleDialog(context, '读取成功', content);
  }

  /// 显示错误对话框
  void _showErrorDialog(BuildContext context, NfcError? error) {
    _showSimpleDialog(context, '操作失败', error?.message ?? '未知错误');
  }

  /// 显示简单对话框
  void _showSimpleDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('确定'))],
      ),
    );
  }
}

/// 完整示例：在实际项目中使用
class RealWorldExample extends StatelessWidget {
  const RealWorldExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('实际应用示例')),
      body: Center(
        child: ElevatedButton(onPressed: () => _scanEmployeeCard(context), child: const Text('扫描员工卡')),
      ),
    );
  }

  /// 扫描员工卡（实际业务场景）
  void _scanEmployeeCard(BuildContext context) {
    NfcScannerWidget.show(
      context: context,
      title: '扫描员工卡',
      scanningHint: '请将员工卡靠近手机',
      readingHint: '正在读取员工信息...',
      onReadComplete: (result) {
        if (result.success && result.type == NfcDataType.json) {
          final employeeData = result.jsonData!;
          _handleEmployeeData(context, employeeData);
        } else if (result.hasError) {
          _showErrorToast(context, result.error!);
        } else {
          _showErrorToast(context, NfcError.invalidDataFormat('员工卡数据格式错误'));
        }
      },
    );
  }

  /// 处理员工数据
  void _handleEmployeeData(BuildContext context, Map<String, dynamic> data) {
    // 验证数据格式
    if (!data.containsKey('employeeId') || !data.containsKey('name')) {
      _showErrorToast(context, NfcError.invalidDataFormat('员工卡缺少必要字段'));
      return;
    }

    // 显示员工信息
    final employeeId = data['employeeId'];
    final name = data['name'];

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('员工: $name ($employeeId)'), backgroundColor: Colors.green, duration: const Duration(seconds: 3)));

    // 这里可以继续处理业务逻辑，比如：
    // 1. 查询数据库获取完整员工信息
    // 2. 记录考勤
    // 3. 跳转到员工详情页面
    // 等等
  }

  /// 显示错误提示
  void _showErrorToast(BuildContext context, NfcError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(label: '重试', textColor: Colors.white, onPressed: () => _scanEmployeeCard(context)),
      ),
    );
  }
}
