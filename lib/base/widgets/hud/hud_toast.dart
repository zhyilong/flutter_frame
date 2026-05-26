import 'package:flutter_easyloading/flutter_easyloading.dart';

/// Toast 轻提示（基于 flutter_easyloading）
class HUDToast {
  HUDToast._();

  static void show(
    String message, {
    Duration duration = const Duration(milliseconds: 1500),
    EasyLoadingToastPosition position = EasyLoadingToastPosition.center,
  }) {
    EasyLoading.showToast(
      message,
      duration: duration,
      toastPosition: position,
      maskType: EasyLoadingMaskType.none,
    );
  }

  static void showShort(String message) {
    show(message, duration: const Duration(seconds: 1));
  }

  static void showLong(String message) {
    show(message, duration: const Duration(seconds: 3));
  }
}
