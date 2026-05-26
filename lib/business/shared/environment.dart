/*
 * Created by zhyilong on 2026/5/26
 * 环境配置
 */

/// 应用环境
enum Environment {
  /// 开发环境
  development,

  /// 测试环境
  testing,

  /// 生产环境
  production,
}

/// 环境配置
class AppConfig {
  /// 当前环境
  final Environment environment;

  /// API 基础 URL
  final String apiBaseUrl;

  /// 是否启用日志
  final bool enableLogging;

  /// 是否启用调试模式
  final bool debugMode;

  /// 应用名称
  final String appName;

  /// 应用版本
  final String appVersion;

  /// 超时配置
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.enableLogging = true,
    this.debugMode = false,
    required this.appName,
    required this.appVersion,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
  });

  /// 是否为开发环境
  bool get isDevelopment => environment == Environment.development;

  /// 是否为测试环境
  bool get isTesting => environment == Environment.testing;

  /// 是否为生产环境
  bool get isProduction => environment == Environment.production;

  /// 获取环境名称
  String get environmentName {
    switch (environment) {
      case Environment.development:
        return '开发环境';
      case Environment.testing:
        return '测试环境';
      case Environment.production:
        return '生产环境';
    }
  }

  /// 开发环境配置
  factory AppConfig.development({String? apiBaseUrl}) {
    return AppConfig(
      environment: Environment.development,
      apiBaseUrl: apiBaseUrl ?? 'https://dev-api.example.com',
      enableLogging: true,
      debugMode: true,
      appName: 'MVVM Demo (Dev)',
      appVersion: '1.0.0',
    );
  }

  /// 测试环境配置
  factory AppConfig.testing({String? apiBaseUrl}) {
    return AppConfig(
      environment: Environment.testing,
      apiBaseUrl: apiBaseUrl ?? 'https://test-api.example.com',
      enableLogging: true,
      debugMode: true,
      appName: 'MVVM Demo (Test)',
      appVersion: '1.0.0',
    );
  }

  /// 生产环境配置
  factory AppConfig.production({String? apiBaseUrl}) {
    return AppConfig(
      environment: Environment.production,
      apiBaseUrl: apiBaseUrl ?? 'https://api.example.com',
      enableLogging: false,
      debugMode: false,
      appName: 'MVVM Demo',
      appVersion: '1.0.0',
    );
  }

  /// 从编译参数创建配置
  factory AppConfig.fromConstants() {
    // 从编译常量获取环境，默认为开发环境
    const environmentStr = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');

    // 获取自定义 API 地址（可选）
    const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

    switch (environmentStr.toLowerCase()) {
      case 'production':
      case 'prod':
        return AppConfig.production(apiBaseUrl: apiBaseUrl.isEmpty ? null : apiBaseUrl);
      case 'testing':
      case 'test':
        return AppConfig.testing(apiBaseUrl: apiBaseUrl.isEmpty ? null : apiBaseUrl);
      case 'development':
      case 'dev':
      default:
        return AppConfig.development(apiBaseUrl: apiBaseUrl.isEmpty ? null : apiBaseUrl);
    }
  }

  @override
  String toString() {
    return 'AppConfig(environment: $environment, apiBaseUrl: $apiBaseUrl, '
        'enableLogging: $enableLogging, debugMode: $debugMode)';
  }
}

/// 当前应用配置
///
/// 使用示例：
/// ```dart
/// final config = AppEnv.config;
/// print(config.apiBaseUrl);
/// ```
class AppEnv {
  static AppConfig? _config;

  /// 获取当前配置
  static AppConfig get config {
    _config ??= AppConfig.fromConstants();
    return _config!;
  }

  /// 初始化配置（可选，用于动态设置）
  static void init(AppConfig config) {
    _config = config;
  }

  /// 重置配置（主要用于测试）
  static void reset() {
    _config = null;
  }
}