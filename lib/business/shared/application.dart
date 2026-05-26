/*
 * Created by zhyilong on 2026/5/20
 */

import 'dart:async';

import 'package:logger/logger.dart';
import 'package:mvvm_demo/business/shared/constants.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 程序上下文，存放生命周期整个app的信息
class Application {
  static Application? _instance;

  Application._() {
    _init();
  }

  factory Application() {
    return _instance ??= Application._();
  }

  late final SharedPreferences prefs;
  late final PackageInfo packageInfo;

  final Completer _completer = Completer();

  /// init
  void _init() async {
    prefs = await SharedPreferences.getInstance();

    packageInfo = await PackageInfo.fromPlatform();
    Logger().d(
      "[PackageInfo]: (appName: ${packageInfo.appName} version: ${packageInfo.version} buildNumber: ${packageInfo.buildNumber} packageName: ${packageInfo.packageName})",
    );

    _completer.complete(() => Logger().d("[_init] Application初始化完成"));
  }

  // Future<void> _initCompleted() async {
  //   if (_completer.isCompleted) return;
  //   return _completer.future;
  // }

  /// 获取token
  String? get token {
    if (!_completer.isCompleted) {
      return null;
    }
    return prefs.getString("${Constants.STORE_PREFIX}${Constants.TOKEN}");
  }

  /// token持久化，null或""删除token
  set token(String? token) {
    if (!_completer.isCompleted) {
      Logger().e("[token] prefs为初始化完成");
      _completer.future.then((_) {
        Logger().d("[token] prefs初始化完成");
        _updateToken(token);
      });
      return;
    }

    _updateToken(token);
  }

  void _updateToken(String? token) {
    if (token == null || token.isEmpty) {
      prefs.remove("${Constants.STORE_PREFIX}${Constants.TOKEN}");
    } else {
      prefs.setString("${Constants.STORE_PREFIX}${Constants.TOKEN}", token);
    }
  }
}
