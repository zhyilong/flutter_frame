import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:mvvm_demo/base/notificationCenter/notificationCenter.dart';
import 'package:mvvm_demo/base/widgets/hud/hud.dart';
import 'package:mvvm_demo/business/shared/application.dart';
import 'package:mvvm_demo/business/shared/environment.dart';
import 'package:mvvm_demo/test_page.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter router = GoRouter(
    initialLocation: "/",
    routes: [
      GoRoute(
        path: "/",
        pageBuilder: (context, state) {
          return MaterialPage(child: MyHomePage(title: 'MVVM Demo'));
        },
      ),
      TestPage.TEST_ROUTES,
    ],
  );

  @override
  void initState() {
    super.initState();

    // 打印环境配置信息
    final config = AppEnv.config;
    Logger().d("═══════════════════════════════════════════════════");
    Logger().d("应用启动 - ${config.appName}");
    Logger().d("当前环境: ${config.environmentName}");
    Logger().d("API地址: ${config.apiBaseUrl}");
    Logger().d("调试模式: ${config.debugMode}");
    Logger().d("日志启用: ${config.enableLogging}");
    Logger().d("═══════════════════════════════════════════════════");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Logger().d("addPostFrameCallback 执行");

      /// 程序上下文
      Application();

      /// loading配置
      HudStyle.apply();

      Future.delayed(Duration(seconds: 1), () {
        Application().token = "1234567890";
        Logger().d("[token]: ${Application().token}");
        Application().token = null;
        Logger().d("[token]: ${Application().token}");
      });

      Subscriber subscription = NotificationCenter().addListen<Message>(
        onReceived: (notification) {
          Logger().d("[Notification] 接收到通知: ${notification.key}");
        },
      );

      Future.delayed(Duration(seconds: 5), () {
        NotificationCenter().sendNotification(Message());

        Future.delayed(Duration(seconds: 1), () {
          Logger().d("1秒后取消订阅");
          subscription.cancel();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = AppEnv.config;

    return MaterialApp.router(
      title: config.appName,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      routerConfig: router,
      builder: HudStyle.appBuilder, // loading初始化
      debugShowCheckedModeBanner: config.debugMode,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final config = AppEnv.config;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          // 环境指示器（仅非生产环境显示）
          if (!config.isProduction)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getEnvironmentColor(config.environment),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  config.environmentName,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flutter_dash, size: 100, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text('MVVM Demo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text('Flutter 应用开发示例', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey)),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => context.push("/test"),
              icon: const Icon(Icons.science_outlined),
              label: const Text('功能测试'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), textStyle: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            Text('点击上方按钮查看所有功能示例', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
            // 环境信息（仅开发/测试环境显示）
            if (!config.isProduction) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Text('API: ${config.apiBaseUrl}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                    if (config.debugMode)
                      Text('调试模式: 开启', style: const TextStyle(fontSize: 12, color: Colors.red)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 获取环境对应的颜色
  Color _getEnvironmentColor(Environment environment) {
    switch (environment) {
      case Environment.development:
        return Colors.blue;
      case Environment.testing:
        return Colors.orange;
      case Environment.production:
        return Colors.green;
    }
  }
}
