# 环境配置说明

本项目支持多环境配置：开发（development）、测试（testing）、生产（production）。

## 目录结构

```
lib/
└── business/
    └── shared/
        └── environment.dart    # 环境配置类
```

## 环境配置类使用

### 1. 获取当前环境配置

```dart
import 'package:mvvm_demo/business/shared/environment.dart';

void main() {
  final config = AppEnv.config;

  print('当前环境: ${config.environmentName}');
  print('API地址: ${config.apiBaseUrl}');
  print('调试模式: ${config.debugMode}');
}
```

### 2. 判断当前环境

```dart
final config = AppEnv.config;

if (config.isDevelopment) {
  // 开发环境特定逻辑
  print('开发环境');
} else if (config.isTesting) {
  // 测试环境特定逻辑
  print('测试环境');
} else if (config.isProduction) {
  // 生产环境特定逻辑
  print('生产环境');
}
```

### 3. 在网络层使用环境配置

```dart
@riverpod
DioClient apiClient(Ref ref) {
  final config = AppEnv.config;
  return DioClient(
    config: ServiceConfig(
      baseUrl: config.apiBaseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
      enableLog: config.enableLogging,
    ),
  );
}
```

## 运行不同环境

### 方式 1：使用命令行脚本

#### Windows
```bash
# 开发环境
scripts\build.bat dev run

# 测试环境
scripts\build.bat test run

# 生产环境
scripts\build.bat prod run

# 构建 APK
scripts\build.bat dev build apk
scripts\build.bat test build apk
scripts\build.bat prod build apk
```

#### Linux/Mac
```bash
# 开发环境
./scripts/build.sh dev run

# 测试环境
./scripts/build.sh test run

# 生产环境
./scripts/build.sh prod run

# 构建 APK
./scripts/build.sh dev build apk
./scripts/build.sh test build apk
./scripts/build.sh prod build apk
```

### 方式 2：使用 Flutter 命令

```bash
# 开发环境
flutter run --dart-define=ENVIRONMENT=development

# 测试环境
flutter run --dart-define=ENVIRONMENT=testing

# 生产环境
flutter run --dart-define=ENVIRONMENT=production

# 构建不同环境的 APK
flutter build apk --dart-define=ENVIRONMENT=development --release
flutter build apk --dart-define=ENVIRONMENT=testing --release
flutter build apk --dart-define=ENVIRONMENT=production --release
```

### 方式 3：使用 VS Code

1. 打开 VS Code
2. 按 `F5` 或点击调试面板
3. 选择环境：
   - `开发环境`
   - `测试环境`
   - `生产环境`

## 自定义环境配置

### 修改默认 API 地址

编辑 `lib/business/shared/environment.dart`：

```dart
factory AppConfig.development({String? apiBaseUrl}) {
  return AppConfig(
    environment: Environment.development,
    apiBaseUrl: apiBaseUrl ?? 'https://dev-api.example.com', // 修改这里
    // ...
  );
}
```

### 运行时自定义 API 地址

```bash
# 使用编译参数覆盖默认地址
flutter run --dart-define=ENVIRONMENT=development --dart-define=API_BASE_URL=https://custom-api.com
```

### 添加新的环境配置项

在 `AppConfig` 类中添加新字段：

```dart
class AppConfig {
  // ... 现有字段

  /// 是否启用崩溃上报
  final bool enableCrashReporting;

  /// 是否启用性能监控
  final bool enablePerformanceMonitoring;

  const AppConfig({
    // ... 现有参数
    required this.enableCrashReporting,
    required this.enablePerformanceMonitoring,
  });

  factory AppConfig.development() {
    return AppConfig(
      // ...
      enableCrashReporting: false,
      enablePerformanceMonitoring: false,
    );
  }
}
```

## 环境标识

- **开发环境**：AppBar 右上角显示蓝色"开发环境"标签
- **测试环境**：AppBar 右上角显示橙色"测试环境"标签
- **生产环境**：不显示环境标签

## 调试信息

开发环境和测试环境会在控制台打印详细信息：

```
═══════════════════════════════════════════════════
应用启动 - MVVM Demo (Dev)
当前环境: 开发环境
API地址: https://dev-api.example.com
调试模式: true
日志启用: true
═══════════════════════════════════════════════════
```

## 注意事项

1. **生产环境构建前**：
   - 检查 API 地址是否正确
   - 确认 `enableLogging` 为 false
   - 确认 `debugMode` 为 false
   - 移除所有测试代码

2. **版本管理**：
   - 不同环境应使用不同的版本号或版本后缀
   - 建议使用应用名称区分环境

3. **安全检查**：
   - 生产环境不应打印敏感信息
   - Token、密钥等不应硬编码
   - 使用安全的存储方式（如 flutter_secure_storage）

## 常见问题

**Q: 如何在代码中获取当前环境？**
```dart
final config = AppEnv.config;
print(config.environment); // Environment.development
```

**Q: 如何动态切换环境？**
编译时环境已确定，无法动态切换。如需测试多个环境，请使用不同的命令运行。

**Q: 生产环境仍然显示调试信息？**
检查是否正确使用 `--dart-define=ENVIRONMENT=production` 参数。

**Q: 如何添加更多环境（如预发布环境）？**
1. 在 `Environment` 枚举中添加 `staging`
2. 添加对应的工厂方法 `AppConfig.staging()`
3. 在 `fromConstants()` 中添加相应逻辑