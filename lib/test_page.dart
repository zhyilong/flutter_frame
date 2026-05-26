import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:mvvm_demo/base/swapCard/swapcard_example.dart';
import 'base/network/dio_client.dart';
import 'base/widgets/hud/hud.dart';
import 'base/widgets/qr_scanner/qr_scanner_view.dart';
import 'base/widgets/qr_scanner/example_usage.dart';
import 'base/widgets/view/demo_view.dart';
import 'package:mvvm_demo/examples/keyboard_animation_complete_example.dart';
import 'package:mvvm_demo/examples/keyboard_safe_form_example.dart';

import 'base/widgets/mediaViewer/media_viewer_example.dart';
import 'base/widgets/multiMediaPicker/example_usage.dart';
import 'base/widgets/nfc_scanner/nfc_test_complete.dart';
import 'business/features/userInfo/views/UserInfoView.dart';
import 'business/shared/widgets/empty_data_widget.dart';

/// 测试页面
///
/// 包含所有功能测试的入口
class TestPage extends StatelessWidget {
  const TestPage({super.key});

  static GoRoute TEST_ROUTES = GoRoute(
    path: "/test",
    pageBuilder: (context, state) {
      return MaterialPage(child: const TestPage());
    },
    routes: [
      GoRoute(
        path: "mvvm",
        pageBuilder: (context, state) {
          return MaterialPage(child: UserInfoView());
        },
      ),
      GoRoute(
        path: "keyboard",
        pageBuilder: (context, state) {
          return MaterialPage(child: KeyboardAnimationCompleteExample());
        },
      ),
      GoRoute(
        path: "keyboard-safe",
        pageBuilder: (context, state) {
          return MaterialPage(child: KeyboardSafeFormExample());
        },
      ),
      GoRoute(
        path: "demo",
        pageBuilder: (context, state) {
          return MaterialPage(child: const DemoView());
        },
      ),
      GoRoute(
        path: "mediaPicker",
        pageBuilder: (context, state) {
          return MaterialPage(child: const MultiMediaPickerExample());
        },
      ),
      GoRoute(
        path: "mediaPreview",
        pageBuilder: (context, state) {
          return MaterialPage(child: const MediaViewerExamplePage());
        },
      ),
      GoRoute(
        path: "nfc",
        pageBuilder: (context, state) {
          return MaterialPage(child: const NfcCompleteTest());
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('功能测试'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          //
          EmptyDataWidget(
            type: EmptyDataType.custom,
            icon: Icon(Icons.shopping_basket_outlined, size: 80),
            title: '购物车是空的',
            subtitle: '快去添加心仪的商品吧',
            buttonText: '去逛逛',
            height: 260,
            onButtonTap: () {},
          ),

          // 功能测试分组
          _buildTestGroup(
            context,
            title: '架构模式',
            icon: Icons.architecture,
            children: [
              _buildTestButton(context, title: 'MVVM 示例', subtitle: 'Riverpod 状态管理 + MVVM 架构', icon: Icons.layers, onTap: () => context.push("/test/mvvm")),
              _buildTestButton(
                context,
                title: 'BaseView Demo',
                subtitle: 'BaseView 状态基类使用示例',
                icon: Icons.view_agenda,
                onTap: () => context.push("/test/demo"),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildTestGroup(
            context,
            title: '键盘处理',
            icon: Icons.keyboard,
            children: [
              _buildTestButton(context, title: '键盘动画', subtitle: '键盘弹出动画完整示例', icon: Icons.animation, onTap: () => context.push("/test/keyboard")),
              _buildTestButton(
                context,
                title: '键盘避免表单',
                subtitle: 'Safe Form 键盘避让示例',
                icon: Icons.keyboard_hide,
                onTap: () => context.push("/test/keyboard-safe"),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildTestGroup(
            context,
            title: '扫码功能',
            icon: Icons.qr_code_scanner,
            children: [
              _buildTestButton(
                context,
                title: '全屏扫码',
                subtitle: '独立的扫码页面',
                icon: Icons.qr_code,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QRScannerView(
                        onScanned: (code) {
                          Logger().d('扫描结果: $code');
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('扫描结果: $code')));
                        },
                      ),
                    ),
                  );
                },
              ),
              _buildTestButton(
                context,
                title: '扫码组件示例',
                subtitle: '查看所有扫码功能示例',
                icon: Icons.qr_code_2,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerExample()));
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildTestGroup(
            context,
            title: '网络请求',
            icon: Icons.cloud,
            children: [
              _buildTestButton(
                context,
                title: '网络请求测试',
                subtitle: '测试 Dio 网络请求',
                icon: Icons.http,
                onTap: () {
                  HUDLoading.show();
                  DioClient dioClient = DioClient(config: ServiceConfigs.defaultConfig);
                  dioClient
                      .getRaw("/packages", queryParameters: {"q": "image"})
                      .then((value) {
                        HUDLoading.dismiss();
                        Logger().d("$value");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('请求成功: ${value.data}'), duration: const Duration(seconds: 2)));
                      })
                      .catchError((error) {
                        HUDLoading.dismiss();
                        Logger().e("请求失败: $error");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('请求失败: $error'), backgroundColor: Colors.red));
                      });
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildTestGroup(
            context,
            title: '图片选择',
            icon: Icons.keyboard,
            children: [
              _buildTestButton(context, title: '图片选择', subtitle: '图片视频选择完整示例', icon: Icons.picture_as_pdf, onTap: () => context.push("/test/mediaPicker")),
            ],
          ),

          const SizedBox(height: 24),

          _buildTestGroup(
            context,
            title: '媒体浏览',
            icon: Icons.keyboard,
            children: [
              _buildTestButton(
                context,
                title: '媒体浏览',
                subtitle: '图片视频浏览完整示例',
                icon: Icons.view_array_outlined,
                onTap: () => context.push("/test/mediaPreview"),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildTestGroup(
            context,
            title: 'NFC',
            icon: Icons.nfc,
            children: [_buildTestButton(context, title: 'NFC测试', subtitle: 'NFC读写完整测试流程', icon: Icons.nfc_rounded, onTap: () => context.push("/test/nfc"))],
          ),

          const SizedBox(height: 24),

          _buildTestGroup(
            context,
            title: 'Toast',
            icon: Icons.two_mp_outlined,
            children: [
              _buildTestButton(
                context,
                title: 'Toast',
                subtitle: 'Toast测试',
                icon: Icons.nfc_rounded,
                onTap: () {
                  HUDToast.show("Toast测试");
                },
              ),
              _buildTestButton(
                context,
                title: 'Toast',
                subtitle: 'Toast测试(多行)',
                icon: Icons.nfc_rounded,
                onTap: () {
                  HUDToast.show("中国大约太老了，社会上事无大小，都恶劣不堪，像一只黑色的染缸，无论加进甚么新东西去，都变成漆黑。");
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildTestGroup(
            context,
            title: 'Loading',
            icon: Icons.assured_workload,
            children: [
              _buildTestButton(
                context,
                title: 'Loading',
                subtitle: 'Loading测试',
                icon: Icons.nfc_rounded,
                onTap: () {
                  HUDLoading.show(status: "Loading");
                  Future.delayed(Duration(seconds: 5), () {
                    HUDLoading.dismiss();
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildTestGroup(
            context,
            title: 'swapCard',
            icon: Icons.swap_calls,
            children: [
              _buildTestButton(
                context,
                title: 'swapCard',
                subtitle: 'swapCard',
                icon: Icons.nfc_rounded,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return SwapcardExample();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建测试分组
  Widget _buildTestGroup(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  /// 构建测试按钮
  Widget _buildTestButton(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
