import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'permissionUtil.dart';

/// 权限工具类使用示例
///
/// 演示如何使用 PermissionUtil 进行权限检查和请求
class PermissionExample extends StatelessWidget {
  const PermissionExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('权限管理示例'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 说明卡片
          _buildInfoCard(context),

          const SizedBox(height: 24),

          // 单个权限检查
          _buildSection(
            context,
            title: '单个权限检查',
            children: [
              _buildPermissionButton(
                context,
                title: '检查相机权限',
                icon: Icons.camera_alt,
                onTap: () => _checkCamera(context),
              ),
              _buildPermissionButton(
                context,
                title: '请求相机权限',
                icon: Icons.camera_enhance,
                onTap: () => _requestCamera(context),
              ),
              _buildPermissionButton(
                context,
                title: '检查相册权限',
                icon: Icons.photo_library,
                onTap: () => _checkPhoto(context),
              ),
              _buildPermissionButton(
                context,
                title: '请求相册权限',
                icon: Icons.photo,
                onTap: () => _requestPhoto(context),
              ),
              _buildPermissionButton(
                context,
                title: '检查位置权限',
                icon: Icons.location_on,
                onTap: () => _checkLocation(context),
              ),
              _buildPermissionButton(
                context,
                title: '检查麦克风权限',
                icon: Icons.mic,
                onTap: () => _checkMicrophone(context),
              ),
              _buildPermissionButton(
                context,
                title: '检查存储权限',
                icon: Icons.storage,
                onTap: () => _checkStorage(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 批量权限检查
          _buildSection(
            context,
            title: '批量权限检查',
            children: [
              _buildPermissionButton(
                context,
                title: '检查相机+麦克风',
                icon: Icons.playlist_add_check,
                onTap: () => _checkMultiple(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 工具方法
          _buildSection(
            context,
            title: '工具方法',
            children: [
              _buildPermissionButton(
                context,
                title: '打开系统设置',
                icon: Icons.settings,
                onTap: () => _openSettings(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建说明卡片
  Widget _buildInfoCard(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  '使用说明',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('• 检查权限：仅查看权限状态，不主动请求'),
            const Text('• 请求权限：如果未授权，会弹出权限请求对话框'),
            const Text('• 永久拒绝：用户勾选"不再询问"后，需要引导到设置开启'),
          ],
        ),
      ),
    );
  }

  /// 构建分组
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  /// 构建权限按钮
  Widget _buildPermissionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  /// 检查相机权限（不请求）
  void _checkCamera(BuildContext context) {
    PermissionUtil.checkCamera(
      (isGrant, message) {
        _showResult(context, '相机权限', isGrant, message);
      },
      isRequest: false,
    );
  }

  /// 请求相机权限
  void _requestCamera(BuildContext context) {
    PermissionUtil.checkCamera(
      (isGrant, message) {
        _showResult(context, '相机权限', isGrant, message);
      },
      isRequest: true,
    );
  }

  /// 检查相册权限（不请求）
  void _checkPhoto(BuildContext context) {
    PermissionUtil.checkPhotoalbum(
      (isGrant, message) {
        _showResult(context, '相册权限', isGrant, message);
      },
      isRequest: false,
    );
  }

  /// 请求相册权限
  void _requestPhoto(BuildContext context) {
    PermissionUtil.checkPhotoalbum(
      (isGrant, message) {
        _showResult(context, '相册权限', isGrant, message);
      },
      isRequest: true,
    );
  }

  /// 检查位置权限
  void _checkLocation(BuildContext context) {
    PermissionUtil.checkLocation(
      (isGrant, message) {
        _showResult(context, '位置权限', isGrant, message);
      },
      isRequest: false,
    );
  }

  /// 检查麦克风权限
  void _checkMicrophone(BuildContext context) {
    PermissionUtil.checkMicrophone(
      (isGrant, message) {
        _showResult(context, '麦克风权限', isGrant, message);
      },
      isRequest: false,
    );
  }

  /// 检查存储权限
  void _checkStorage(BuildContext context) {
    PermissionUtil.checkStorage(
      (isGrant, message) {
        _showResult(context, '存储权限', isGrant, message);
      },
      isRequest: false,
    );
  }

  /// 批量检查权限
  void _checkMultiple(BuildContext context) {
    PermissionUtil.checkMultiple(
      [Permission.camera, Permission.microphone],
      (statuses, message) {
        final cameraStatus = statuses[Permission.camera];
        final micStatus = statuses[Permission.microphone];

        final cameraText = cameraStatus?.isGranted == true ? '已授权' : '未授权';
        final micText = micStatus?.isGranted == true ? '已授权' : '未授权';

        _showResult(
          context,
          '批量权限',
          cameraStatus?.isGranted == true && micStatus?.isGranted == true,
          '相机: $cameraText, 麦克风: $micText',
        );
      },
      isRequest: true,
    );
  }

  /// 打开系统设置
  void _openSettings(BuildContext context) async {
    final result = await PermissionUtil.openSystemSettings();
    _showResult(
      context,
      '打开设置',
      result,
      result ? '已打开系统设置' : '打开设置失败',
    );
  }

  /// 显示结果对话框
  void _showResult(
    BuildContext context,
    String title,
    bool isSuccess,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
          // 如果权限被永久拒绝，显示"去设置"按钮
          if (!isSuccess && message.contains('永久拒绝'))
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                PermissionUtil.openSystemSettings();
              },
              child: const Text('去设置'),
            ),
        ],
      ),
    );
  }
}

/// 实际应用示例：扫码前检查相机权限
class ScannerPermissionExample extends StatelessWidget {
  const ScannerPermissionExample({super.key});

  Future<void> startScanner(BuildContext context) async {
    // 先检查相机权限
    PermissionUtil.checkCamera(
      (isGrant, message) async {
        if (isGrant) {
          // 权限已授权，打开扫码页面
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => ScannerView(...)),
          // );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('可以打开扫码页面')),
          );
        } else {
          // 权限未授权，显示提示
          if (message.contains('永久拒绝')) {
            // 显示对话框，引导用户打开设置
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('权限受限'),
                content: const Text('相机权限被永久拒绝，请前往设置开启'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      PermissionUtil.openSystemSettings();
                    },
                    child: const Text('去设置'),
                  ),
                ],
              ),
            );
          } else {
            // 显示普通提示
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        }
      },
      isRequest: true, // 主动请求权限
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('扫码权限示例')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => startScanner(context),
          child: const Text('扫码（带权限检查）'),
        ),
      ),
    );
  }
}
