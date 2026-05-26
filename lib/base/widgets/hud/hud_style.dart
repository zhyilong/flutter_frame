import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

/// HUD 全局样式与 MaterialApp 集成
class HudStyle {
  HudStyle._();

  /// 用于 [MaterialApp.builder]
  static TransitionBuilder get appBuilder => EasyLoading.init();

  /// 应用启动后调用一次
  static void apply() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 1500)
      ..animationStyle = EasyLoadingAnimationStyle.opacity
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorSize = 40.0
      ..radius = 10.0
      ..progressColor = Colors.white
      ..backgroundColor = Colors.black.withValues(alpha: 0.8)
      ..textColor = Colors.white
      ..maskColor = Colors.black.withValues(alpha: 0.5)
      ..userInteractions = false
      ..dismissOnTap = false
      ..toastPosition = EasyLoadingToastPosition.center;
  }
}
