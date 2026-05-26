/// HUD（Heads-Up Display）— 屏幕浮层提示
///
/// 指叠在页面之上的非阻塞 UI：Loading、Toast、成功/失败提示等。
/// 本模块基于 [flutter_easyloading] 统一实现。
///
/// ```dart
/// import 'package:mvvm_demo/base/widgets/hud/hud.dart';
///
/// // main.dart
/// HudStyle.apply();
/// MaterialApp.router(builder: HudStyle.appBuilder, ...);
///
/// HUDLoading.show(status: '加载中');
/// HUDToast.show('完成');
/// ```
library;

export 'hud_loading.dart';
export 'hud_style.dart';
export 'hud_toast.dart';
