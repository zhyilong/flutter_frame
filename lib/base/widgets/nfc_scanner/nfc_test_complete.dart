/*
 * Created by zhyilong on 2026/5/19
 * NFC完整测试示例 - 演示完整的写入和读取流程
 */

import 'package:flutter/material.dart';
import 'package:mvvm_demo/base/widgets/hud/hud.dart';

import 'nfc_scanner_widget.dart';
import 'nfc_helper.dart';

/// NFC完整测试示例
class NfcCompleteTest extends StatelessWidget {
  const NfcCompleteTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NFC完整测试')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('NFC功能测试', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // 步骤1：写入测试数据
              _buildStepCard(
                context,
                step: '1',
                title: '写入测试数据',
                description: '先向空白NFC标签写入测试数据',
                icon: Icons.edit,
                color: Colors.blue,
                onPressed: () => _writeTestData(context),
              ),
              const SizedBox(height: 16),

              // 步骤2：读取刚才写入的数据
              _buildStepCard(
                context,
                step: '2',
                title: '读取刚才写入的数据',
                description: '读取标签中刚才写入的数据',
                icon: Icons.read_more,
                color: Colors.green,
                onPressed: () => _readWrittenData(context),
              ),
              const SizedBox(height: 16),

              // 步骤3：写入JSON数据
              _buildStepCard(
                context,
                step: '3',
                title: '写入JSON数据',
                description: '向标签写入结构化JSON数据',
                icon: Icons.data_object,
                color: Colors.purple,
                onPressed: () => _writeJsonData(context),
              ),
              const SizedBox(height: 16),

              // 步骤4：读取JSON数据
              _buildStepCard(
                context,
                step: '4',
                title: '读取JSON数据',
                description: '读取并解析标签中的JSON数据',
                icon: Icons.code,
                color: Colors.orange,
                onPressed: () => _readJsonData(context),
              ),
              const SizedBox(height: 30),

              // 检查NFC可用性
              ElevatedButton.icon(
                onPressed: () => _checkNfcAvailability(context),
                icon: const Icon(Icons.check_circle),
                label: const Text('检查NFC可用性'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required String step,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      step,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
                child: const Text('开始测试'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 步骤1：写入测试数据
  void _writeTestData(BuildContext context) {
    final testData = 'Hello NFC! 测试数据 - ${DateTime.now().toIso8601String()}';

    NfcScannerWidget.show(
      context: context,
      title: '写入测试数据',
      isWriteMode: true,
      writeTextData: testData,
      writeHint: '请将空白NFC标签靠近手机...',
      onWriteComplete: (success, error) {
        if (success) {
          HUDToast.showLong('✅ 写入成功！数据: $testData');
        } else {
          HUDToast.showLong('❌ 写入失败: ${error?.message}');
        }
      },
    );
  }

  /// 步骤2：读取刚才写入的数据
  void _readWrittenData(BuildContext context) {
    NfcScannerWidget.show(
      context: context,
      title: '读取刚才写入的数据',
      onReadComplete: (result) {
        if (result.success) {
          HUDToast.showLong('✅ 读取成功！\n类型: ${result.type}\n内容: ${result.content}');

          // 显示详细信息对话框
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('读取成功'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildInfoRow('数据类型', result.type.toString()), const SizedBox(height: 8), _buildInfoRow('内容', result.content ?? 'N/A')],
              ),
              actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('确定'))],
            ),
          );
        } else {
          HUDToast.showLong('❌ 读取失败: ${result.error?.message}');
        }
      },
    );
  }

  /// 步骤3：写入JSON数据
  void _writeJsonData(BuildContext context) {
    final jsonData = {'userId': '12345', 'userName': '张三', 'timestamp': DateTime.now().toIso8601String(), 'department': '技术部', 'role': '工程师'};

    // 验证数据大小
    if (!NfcHelper.validateJsonSize(jsonData)) {
      HUDToast.showLong('❌ 数据太大，超出NFC标签容量');
      return;
    }

    NfcScannerWidget.show(
      context: context,
      title: '写入JSON数据',
      isWriteMode: true,
      writeJsonData: jsonData,
      writeHint: '请将NFC标签靠近手机...',
      onWriteComplete: (success, error) {
        if (success) {
          HUDToast.showLong('✅ JSON数据写入成功！\n用户ID: ${jsonData['userId']}');
        } else {
          HUDToast.showLong('❌ 写入失败: ${error?.message}');
        }
      },
    );
  }

  /// 步骤4：读取JSON数据
  void _readJsonData(BuildContext context) {
    NfcScannerWidget.show(
      context: context,
      title: '读取JSON数据',
      onReadComplete: (result) {
        if (result.success) {
          if (result.type == NfcDataType.json && result.jsonData != null) {
            final data = result.jsonData!;
            HUDToast.showShort('✅ JSON数据读取成功！');

            // 显示详细信息对话框
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('JSON数据读取成功'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('用户ID', data['userId']?.toString() ?? 'N/A'),
                      const SizedBox(height: 8),
                      _buildInfoRow('用户名', data['userName']?.toString() ?? 'N/A'),
                      const SizedBox(height: 8),
                      _buildInfoRow('部门', data['department']?.toString() ?? 'N/A'),
                      const SizedBox(height: 8),
                      _buildInfoRow('角色', data['role']?.toString() ?? 'N/A'),
                      const SizedBox(height: 8),
                      _buildInfoRow('时间戳', data['timestamp']?.toString() ?? 'N/A'),
                    ],
                  ),
                ),
                actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('确定'))],
              ),
            );
          } else {
            // 读取到的不是JSON数据
            HUDToast.showLong('⚠️ 标签中的数据不是JSON格式\n内容: ${result.content}');
          }
        } else {
          HUDToast.showLong('❌ 读取失败: ${result.error?.message}');
        }
      },
    );
  }

  /// 检查NFC可用性
  Future<void> _checkNfcAvailability(BuildContext context) async {
    final isAvailable = await NfcHelper.isNfcAvailable();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAvailable ? '✅ NFC可用' : '❌ NFC不可用'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isAvailable ? '设备支持NFC功能且已开启' : '设备不支持NFC或NFC未开启'),
            if (isAvailable) ...[
              const SizedBox(height: 16),
              const Text('提示：', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('1. 请确保使用空白NFC标签进行写入测试'),
              const Text('2. 标签ID: 1D87BC0CA70000 (已检测到)'),
              const Text('3. 标签支持NDEF格式且可写入'),
            ],
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('确定'))],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}
