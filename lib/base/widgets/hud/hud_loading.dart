import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

/// Loading 提示（基于 flutter_easyloading）
class HUDLoading {
  HUDLoading._();

  static void show({String? status, Widget? indicator, EasyLoadingMaskType? maskType = EasyLoadingMaskType.black}) {
    EasyLoading.show(status: status, indicator: indicator, maskType: maskType);
  }

  static void showSuccess(String status, {Duration duration = const Duration(milliseconds: 1500)}) {
    EasyLoading.showSuccess(status, duration: duration);
  }

  static void showError(String status, {Duration duration = const Duration(milliseconds: 1500)}) {
    EasyLoading.showError(status, duration: duration);
  }

  static void showInfo(String status, {Duration duration = const Duration(milliseconds: 1500)}) {
    EasyLoading.showInfo(status, duration: duration);
  }

  static void showProgress(double value, {String? status}) {
    EasyLoading.showProgress(value, status: status);
  }

  static void dismiss() {
    EasyLoading.dismiss();
  }
}
