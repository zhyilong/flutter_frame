# 环境配置实现总结

## 实现的功能

### ✅ 1. 环境配置类
- **位置**: `lib/business/shared/environment.dart`
- **支持环境**:
  - Development (开发环境)
  - Testing (测试环境)
  - Production (生产环境)

### ✅ 2. 配置项
- API 基础 URL
- 日志开关
- 调试模式
- 应用名称
- 网络超时配置

### ✅ 3. UI 指示器
- AppBar 环境标签（开发/测试环境显示）
- 环境信息卡片（显示 API 地址、调试状态）
- 生产环境不显示调试信息

### ✅ 4. 运行脚本
- **Windows**: `scripts/build.bat`
- **Linux/Mac**: `scripts/build.sh`
- **VS Code**: `.vscode/launch.json`

## 快速开始

### 运行开发环境
```bash
# Windows
scripts\build.bat dev run

# Linux/Mac
./scripts/build.sh dev run

# 或直接使用 Flutter 命令
flutter run --dart-define=ENVIRONMENT=development
```

### 构建生产环境 APK
```bash
# Windows
scripts\build.bat prod build apk

# Linux/Mac
./scripts/build.sh prod build apk
```

## 文件变更清单

### 新增文件
```
lib/business/shared/environment.dart       # 环境配置类
scripts/build.bat                          # Windows 构建脚本
scripts/build.sh                           # Linux/Mac 构建脚本
.vscode/launch.json                        # VS Code 配置
docs/ENV_SETUP.md                          # 详细使用说明
```

### 修改文件
```
lib/main.dart                              # 集成环境配置
lib/business/features/userInfo/repositories/userRepository.dart  # 使用环境配置
```

## 架构优势

### 1. 编译时确定环境
- 使用 `--dart-define` 编译参数
- 环境信息在编译时固化
- 无法通过运行时修改，更安全

### 2. 集中管理
- 所有环境配置在一个文件中
- 易于维护和扩展
- 类型安全

### 3. 灵活性
- 支持编译参数覆盖配置
- 可轻松添加新环境
- 支持自定义配置项

### 4. 可视化
- 开发/测试环境有明显的视觉标识
- 防止混淆环境
- 便于调试

## 最佳实践

### ✅ 推荐做法
1. **生产构建前检查环境**
   ```dart
   assert(AppEnv.config.isProduction, '不应在生产环境执行此操作');
   ```

2. **根据环境启用/禁用功能**
   ```dart
   final config = AppEnv.config;
   if (config.enableLogging) {
     Logger().d('调试信息');
   }
   ```

3. **使用环境配置初始化服务**
   ```dart
   final config = AppEnv.config;
   final service = MyService(
     baseUrl: config.apiBaseUrl,
     enableDebug: config.debugMode,
   );
   ```

### ❌ 避免做法
1. 硬编码环境判断字符串
   ```dart
   // ❌ 错误
   if (config.environment == 'development') { }

   // ✅ 正确
   if (config.isDevelopment) { }
   ```

2. 在运行时修改环境配置
   ```dart
   // ❌ 环境应在编译时确定
   AppEnv.init(AppConfig.production());

   // ✅ 使用编译参数
   flutter run --dart-define=ENVIRONMENT=production
   ```

## 扩展指南

### 添加新环境（如预发布环境）

1. 在 `Environment` 枚举中添加：
```dart
enum Environment {
  development,
  testing,
  staging,    // 新增
  production,
}
```

2. 添加工厂方法：
```dart
factory AppConfig.staging({String? apiBaseUrl}) {
  return AppConfig(
    environment: Environment.staging,
    apiBaseUrl: apiBaseUrl ?? 'https://staging-api.example.com',
    enableLogging: true,
    debugMode: false,
    appName: 'MVVM Demo (Staging)',
    appVersion: '1.0.0',
  );
}
```

3. 更新 `fromConstants()`：
```dart
case 'staging':
  return AppConfig.staging(apiBaseUrl: apiBaseUrl.isEmpty ? null : apiBaseUrl);
```

### 添加新配置项

1. 在 `AppConfig` 中添加字段：
```dart
final bool enableAnalytics;
```

2. 在构造函数中添加参数：
```dart
const AppConfig({
  // ...
  required this.enableAnalytics,
});
```

3. 在各工厂方法中设置值：
```dart
factory AppConfig.development() {
  return AppConfig(
    // ...
    enableAnalytics: false,
  );
}
```

## 总结

这个环境配置实现：
- ✅ 简单易用
- ✅ 类型安全
- ✅ 编译时确定
- ✅ 集中管理
- ✅ 易于扩展
- ✅ 可视化标识

完美适用于中小型 Flutter 项目的环境管理需求！