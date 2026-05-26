/*
 * Created by zhyilong on 2026/5/16
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 基础页面视图，提供生命周期管理
/// 页面渲染完成后自动调用 onReady()，适合在此处调用接口避免页面切换卡顿
abstract class BaseView extends ConsumerStatefulWidget {
  const BaseView({super.key});

  static BuildContext? context;

  @override
  BaseViewState createState();
}

/// 基础视图状态类
abstract class BaseViewState<T extends BaseView> extends ConsumerState<T> {
  @override
  void initState() {
    super.initState();
    // 首帧渲染完成后调用，避免阻塞页面渲染
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onReady();
    });
  }

  @override
  void dispose() {
    onClose();
    super.dispose();
  }

  /// 页面首帧渲染完成后调用
  /// 可在此处调用接口或执行初始化操作，避免页面切换卡顿
  void onReady() {
    // 子类重写
  }

  /// 页面销毁时调用
  /// 可在此处释放资源、取消订阅等
  void onClose() {
    // 子类重写
  }

  @override
  Widget build(BuildContext context) {
    BaseView.context = context;
    return Scaffold(appBar: buildAppbar(), body: buildBody(context));
  }

  /// 子类重写：返回页面标题
  String getTitle() {
    return "标题";
  }

  /// 内部方法：构建 AppBar 标题 Widget
  Widget buildAppbarTitle() {
    return Text(getTitle());
  }

  /// 子类重写：是否显示返回按钮（默认显示）
  bool showBackButton() {
    return true;
  }

  /// 子类重写：自定义返回按钮 Widget，返回 null 则使用默认返回按钮
  Widget? buildCustomBackButton() {
    return null;
  }

  /// 内部方法：构建 AppBar 的 leading
  Widget? buildAppbarLeading() {
    // 不显示返回按钮
    if (!showBackButton()) {
      return null;
    }

    // 使用自定义返回按钮
    if (buildCustomBackButton() != null) {
      return buildCustomBackButton();
    }

    // 使用默认返回按钮
    return const BackButton();
  }

  /// 子类重写：构建 AppBar，返回 null 则不显示
  PreferredSizeWidget? buildAppbar() {
    return AppBar(title: buildAppbarTitle(), centerTitle: true, leading: buildAppbarLeading());
  }

  /// 子类重写：构建页面主体内容
  Widget buildBody(BuildContext context);
}
