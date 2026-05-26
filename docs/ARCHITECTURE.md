# MVVM Demo 项目架构文档

> 本文档详细说明了项目的整体架构设计、分层结构、开发规范，旨在帮助开发者和AI助手理解项目规则并遵循架构规范进行开发。

---

## 目录

1. [架构概览](#1-架构概览)
2. [目录结构](#2-目录结构)
3. [分层职责详解](#3-分层职责详解)
4. [核心组件说明](#4-核心组件说明)
5. [开发规范](#5-开发规范)
6. [命名规范](#6-命名规范)
7. [代码示例](#7-代码示例)
8. [FAQ](#8-faq)

---

## 1. 架构概览

### 1.1 整体架构模式

本项目采用 **MVVM (Model-View-ViewModel)** 架构模式，结合 **Riverpod** 进行状态管理。

```
┌─────────────────────────────────────────────────────────────┐
│                         View 层                              │
│  (Screens/Widgets - 负责 UI 展示和用户交互)                   │
└─────────────────────────┬───────────────────────────────────┘
                          │ 观察/响应状态
┌─────────────────────────▼───────────────────────────────────┐
│                     ViewModel 层                             │
│  (Notifier/Provider - 负责业务逻辑和状态管理)                  │
│  使用 @riverpod 注解 + Riverpod 自动生成 Provider            │
└─────────────────────────┬───────────────────────────────────┘
                          │ 调用
┌─────────────────────────▼───────────────────────────────────┐
│                     Repository 层                            │
│  (数据仓库 - 负责数据获取和转换)                              │
└─────────────────────────┬───────────────────────────────────┘
                          │ 调用
┌─────────────────────────▼───────────────────────────────────┐
│                     Model 层                                 │
│  (数据模型 - 使用 Freezed 定义不可变数据类)                   │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 技术栈

| 类别 | 技术方案 | 作用 |
|------|----------|------|
| **状态管理** | Riverpod (riverpod_annotation) | 响应式状态管理，Provider自动生成 |
| **网络请求** | Dio | HTTP客户端封装 |
| **数据模型** | Freezed + json_serializable | 不可变数据类，JSON序列化 |
| **路由导航** | GoRouter | 声明式路由管理 |
| **消息通知** | EventBus | 发布-订阅模式，跨组件通信 |
| **日志** | Logger | 统一日志输出 |
| **UI提示** | flutter_easyloading | Loading/Toast统一管理 |

### 1.3 架构原则

1. **单一职责原则**: 每个类/文件只负责一件事
2. **依赖倒置原则**: 上层依赖抽象，下层实现抽象
3. **开闭原则**: 对扩展开放，对修改关闭
4. **分层清晰**: 严格遵守分层职责，禁止跨层调用

---

## 2. 目录结构

```
lib/
│
├── main.dart                          # 应用入口
├── demo.dart                          # 示例入口
├── test_page.dart                     # 功能测试页面
│
├── base/                              # ═══════════════════════════════
│   │                                  #     基础层 (Base Layer)
│   │                                  #     提供公共基础设施、工具类、组件
│   │                                  # ═══════════════════════════════
│   │
│   ├── network/                       # 网络层
│   │   ├── dio_client.dart            # Dio封装，提供GET/POST/上传/下载
│   │   ├── api_interceptor.dart       # API拦截器，自动添加Token
│   │   └── models/
│   │       ├── base_response.dart      # 统一响应模型
│   │       └── network_exception.dart  # 网络异常定义
│   │
│   ├── widgets/                       # 公共组件层
│   │   ├── hud/                       # HUD组件 (Loading/Toast)
│   │   ├── view/                      # 视图基类 (BaseView)
│   │   ├── qr_scanner/                # 二维码扫描组件
│   │   ├── nfc_scanner/               # NFC读写组件
│   │   ├── mediaViewer/               # 媒体浏览组件
│   │   ├── multiMediaPicker/          # 媒体选择组件
│   │   ├── imageViewer/               # 图片预览组件
│   │   └── swapCard/                  # 卡片交换动画
│   │
│   ├── utils/                         # 工具类
│   │   └── permission_util.dart       # 权限请求工具
│   │
│   └── notificationCenter/            # 通知中心 (发布-订阅)
│       └── notificationCenter.dart
│
├── business/                           # ═══════════════════════════════
│   │                                  #     业务层 (Business Layer)
│   │                                  #     包含功能模块的业务实现
│   │                                  # ═══════════════════════════════
│   │
│   ├── shared/                        # ═══════════════════════════════
│   │   │                              #     共享业务资源 (Shared Business)
│   │   │                              #     被多个功能模块共用的业务代码
│   │   │                              # ═══════════════════════════════
│   │   ├── application.dart           # 应用上下文 (App级全局数据)
│   │   ├── constants.dart            # 常量定义
│   │   ├── environment.dart          # 环境配置
│   │   ├── models/                   # 公共数据模型 (多模块共用)
│   │   │   └── xxx_model.dart        # 公共数据模型
│   │   ├── repositories/             # 公共数据仓库 (多模块共用)
│   │   │   └── xxx_repository.dart  # 公共数据仓库
│   │   └── widgets/                  # 共享业务组件
│   │       └── empty_data_widget.dart # 空数据占位组件
│   │
│   └── features/                      # ═══════════════════════════════
│       │                              #     功能模块 (Features)
│       │                              #     每个模块遵循 MVVM 架构
│       │                              # ═══════════════════════════════
│       └── userInfo/                  # 示例：用户信息模块
│           ├── views/
│           │   └── userInfo_view.dart # View层：UI展示、用户交互
│           ├── viewModels/
│           │   └── user_info_vm.dart  # ViewModel层：状态管理、业务逻辑
│           ├── models/
│           │   └── user.dart          # Model层：数据模型
│           └── repositories/
│               └── user_repository.dart # Repository层：数据获取
│
├── examples/                          # 组件使用示例
│
└── docs/                              # 文档目录
    └── ARCHITECTURE.md                # 本文档
```

---

## 3. 分层职责详解

### 3.1 Base 层 (基础设施层)

**位置**: `lib/base/`

**职责**:
- 提供公共基础设施和工具类
- 封装通用组件
- 定义网络请求规范
- 提供消息通知机制

**子层说明**:

#### 3.1.1 network/ - 网络层

```
base/network/
├── dio_client.dart          # 网络客户端封装
├── api_interceptor.dart      # 请求/响应拦截器
└── models/
    ├── base_response.dart    # 统一响应模型
    └── network_exception.dart # 网络异常
```

**核心功能**:
- `DioClient`: 封装Dio，提供统一的GET/POST/上传/下载接口
- `ApiInterceptor`: 自动添加Token、打印日志、错误处理
- `BaseResponse`: 统一响应格式 `{code, message, data}`
- `NetworkException`: 网络异常统一封装

#### 3.1.2 widgets/ - 公共组件

```
base/widgets/
├── hud/                      # HUD提示 (Loading/Toast)
├── view/                     # 视图基类
│   ├── base_view.dart        # BaseView + BaseViewState
│   └── demo_view.dart        # 使用示例
├── qr_scanner/               # 二维码扫描
├── nfc_scanner/              # NFC读写
├── mediaViewer/              # 媒体浏览
├── multiMediaPicker/         # 媒体选择
├── imageViewer/              # 图片预览
└── swapCard/                 # 卡片交换
```

#### 3.1.3 notificationCenter/ - 通知中心

基于EventBus的发布-订阅机制，用于跨组件通信。

### 3.2 Business Shared 层 (共享业务资源)

**位置**: `lib/business/shared/`

**职责**:
- 存放被多个功能模块共用的业务代码
- 包含跨模块使用的公共模型和仓库
- 提供应用级全局资源访问

**子目录说明**:

```
business/shared/
├── application.dart      # 应用上下文单例
├── constants.dart        # 常量定义
├── environment.dart      # 环境配置
├── models/              # 公共数据模型 (多模块共用)
│   └── xxx_model.dart
├── repositories/       # 公共数据仓库 (多模块共用)
│   └── xxx_repository.dart
└── widgets/            # 共享业务组件
    └── empty_data_widget.dart
```

#### 3.2.1 Shared Models (公共模型)

**位置**: `business/shared/models/`

**适用场景**:
- 多个功能模块需要使用相同的数据结构
- 跨模块的数据实体（如用户信息、配置项等）
- 全局配置数据模型

**示例**:

```dart
// business/shared/models/app_config_model.dart
part 'app_config.freezed.dart';
part 'app_config.g.dart';

@freezed
sealed class AppConfigModel with _$AppConfigModel {
  const factory AppConfigModel({
    required String appName,
    required String version,
    required int buildNumber,
    Map<String, String>? featureFlags,
  }) = _AppConfigModel;

  factory AppConfigModel.fromJson(Map<String, dynamic> json) =>
      _$AppConfigModelFromJson(json);
}
```

#### 3.2.2 Shared Repositories (公共仓库)

**位置**: `business/shared/repositories/`

**适用场景**:
- 多个模块需要访问相同的数据源
- 全局性数据获取（如用户信息、App配置）
- 跨模块共享的数据缓存逻辑

**示例**:

```dart
// business/shared/repositories/config_repository.dart
part 'config_repository.g.dart';

abstract class ConfigRepository {
  Future<AppConfigModel> getAppConfig();
  Future<void> saveConfig(AppConfigModel config);
}

class ConfigRepositoryImpl implements ConfigRepository {
  final DioClient _dioClient;

  ConfigRepositoryImpl(this._dioClient);

  @override
  Future<AppConfigModel> getAppConfig() async {
    // 实现...
  }
}

@riverpod
ConfigRepository configRepository(Ref ref) {
  return ConfigRepositoryImpl(ref.read(configDioClientProvider));
}
```

#### 3.2.3 Application (应用上下文)

**位置**: `business/shared/application.dart`

**职责**:
- 存放整个应用生命周期的全局数据
- 提供 Token 管理和持久化
- 提供 App 包信息访问

**使用方式**:

```dart
// 获取Token
String? token = Application().token;

// 设置Token (自动持久化)
Application().token = "your_token";

// 清除Token
Application().token = null;

// 获取包信息
PackageInfo info = Application().packageInfo;
```

#### 3.2.4 Environment (环境配置)

**位置**: `business/shared/environment.dart`

**职责**:
- 管理不同环境配置（开发/测试/生产）
- 提供环境切换机制
- 配置 API 地址、超时时间等

#### 3.2.5 Constants (常量定义)

**位置**: `business/shared/constants.dart`

**职责**:
- 存储应用中使用的常量
- SharedPreferences 键名定义
- 业务常量（如订单状态、用户角色等）

### 3.3 Business Features 层 (功能模块)

**位置**: `lib/business/features/`

**职责**:
- 包含具体业务功能的实现
- 每个功能模块独立且遵循 MVVM 架构
- 模块间通过接口依赖实现解耦

```
features/<moduleName>/
├── views/                    # View层 (页面/视图)
│   └── xxx_view.dart
├── viewModels/               # ViewModel层 (状态/逻辑)
│   └── xxx_vm.dart
├── models/                   # Model层 (数据模型)
│   └── xxx_model.dart
└── repositories/             # 数据仓库
    └── xxx_repository.dart
```

### 3.4 分层职责对照表

| 层级 | 目录 | 职责 | 依赖关系 |
|------|------|------|----------|
| **View** | `views/` | UI展示、用户交互、调用ViewModel | 依赖ViewModel |
| **ViewModel** | `viewModels/` | 业务逻辑、状态管理、数据转换 | 依赖Repository |
| **Model** | `models/` | 数据结构定义、JSON序列化 | 被Repository使用 |
| **Repository** | `repositories/` | 数据获取、缓存、数据转换 | 依赖网络层 |
| **Shared Model** | `business/shared/models/` | 多模块共用的数据模型 | 被多个Repository使用 |
| **Shared Repository** | `business/shared/repositories/` | 多模块共用的数据仓库 | 依赖网络层 |
| **Base** | `base/` | 基础设施、工具类、通用组件 | 被所有层依赖 |

### 3.5 分层依赖规则

```
┌────────────────────────────────────────────────────────────┐
│                        View 层                              │
│  views/xxx_view.dart                                        │
│                                                            │
│  职责：                                                    │
│  • 构建UI界面                                               │
│  • 监听ViewModel状态 (ref.watch)                           │
│  • 调用ViewModel方法处理用户操作 (ref.read)                │
│                                                            │
│  禁止：                                                    │
│  • 禁止直接调用Repository                                   │
│  • 禁止处理业务逻辑                                         │
│  • 禁止直接访问网络                                         │
└────────────────────────────────────────────────────────────┘
                              │
                              │ ref.watch() / ref.read()
                              ▼
┌────────────────────────────────────────────────────────────┐
│                      ViewModel 层                           │
│  viewModels/xxx_vm.dart                                    │
│                                                            │
│  职责：                                                    │
│  • 管理页面状态 (state)                                     │
│  • 处理业务逻辑                                             │
│  • 调用Repository获取数据                                   │
│  • 数据转换和格式化                                         │
│                                                            │
│  禁止：                                                    │
│  • 禁止直接构建UI                                           │
│  • 禁止处理用户输入                                         │
└────────────────────────────────────────────────────────────┘
                              │
                              │ 调用方法
                              ▼
┌────────────────────────────────────────────────────────────┐
│                      Repository 层                          │
│  repositories/xxx_repository.dart                          │
│                                                            │
│  职责：                                                    │
│  • 数据获取 (网络/本地)                                     │
│  • 数据缓存                                                 │
│  • 数据格式转换                                             │
│                                                            │
│  禁止：                                                    │
│  • 禁止构建UI                                               │
│  • 禁止处理业务逻辑                                         │
└────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP请求
                              ▼
┌────────────────────────────────────────────────────────────┐
│                       Model 层                              │
│  models/xxx_model.dart                                     │
│                                                            │
│  职责：                                                    │
│  • 定义数据结构                                              │
│  • JSON序列化/反序列化                                      │
│  • 数据校验                                                 │
│                                                            │
│  注意：使用Freezed生成不可变数据类                          │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│               Shared 层 (共享业务资源)                       │
│  business/shared/                                          │
│                                                            │
│  Shared Models (business/shared/models/):                  │
│  • 多个模块共用的数据模型                                   │
│  • 被多个 Repository 引用                                  │
│                                                            │
│  Shared Repositories (business/shared/repositories/):      │
│  • 多个模块共用的数据仓库                                   │
│  • 提供全局性数据访问（如用户信息、配置）                   │
│                                                            │
│  使用场景：                                                │
│  • 模块A 和 模块B 都需要的 UserInfoModel → Shared Model   │
│  • 模块A 和 模块B 都调用 /user/info → Shared Repository  │
└────────────────────────────────────────────────────────────┘
```

### 3.6 模块间依赖关系

```
┌──────────────────────────────────────────────────────────────────────┐
│                         模块依赖架构图                                 │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   ┌─────────────┐      ┌─────────────┐      ┌─────────────┐        │
│   │  Features   │      │  Features   │      │  Features   │        │
│   │    模块A     │      │    模块B     │      │    模块C     │        │
│   │  (userInfo) │      │   (order)   │      │  (product)  │        │
│   └──────┬──────┘      └──────┬──────┘      └──────┬──────┘        │
│          │                    │                    │                │
│          └──────────┬─────────┴─────────┬──────────┘                │
│                     │                   │                            │
│              ┌──────▼───────────────────▼──────┐                    │
│              │        Shared Layer             │                    │
│              │    (business/shared/)           │                    │
│              │                                 │                    │
│              │  ┌───────────┐  ┌───────────┐  │                    │
│              │  │  Shared   │  │  Shared   │  │                    │
│              │  │  Models   │  │ Repos     │  │                    │
│              │  └───────────┘  └───────────┘  │                    │
│              └───────────────┬────────────────┘                    │
│                              │                                     │
│   ┌──────────────────────────▼──────────────────────────────────┐  │
│   │                     Base Layer                                │  │
│   │                      (lib/base/)                              │  │
│   │                                                               │  │
│   │  ┌────────┐ ┌────────┐ ┌────────┐ ┌───────────────────┐    │  │
│   │  │Network │ │Widgets │ │ Notif. │ │     Utils        │    │  │
│   │  └────────┘ └────────┘ └────────┘ └───────────────────┘    │  │
│   └──────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────┘
```

**依赖规则说明**:
- Features 模块可以依赖 Shared Layer
- Shared Layer 依赖 Base Layer
- Features 模块之间禁止直接依赖（通过 Shared Layer 解耦）
- 所有层都可以依赖 Base Layer
```

---

---

## 4. 核心组件说明

### 4.1 BaseView - 视图基类

**位置**: `lib/base/widgets/view/base_view.dart`

**作用**: 提供页面生命周期管理和通用视图功能。

**核心方法**:

```dart
abstract class BaseView extends ConsumerStatefulWidget {
  const BaseView({super.key});

  @override
  BaseViewState createState();
}

abstract class BaseViewState<T extends BaseView> extends ConsumerState<T> {

  /// 页面首帧渲染完成后调用
  /// 适合在此处调用接口，避免页面切换卡顿
  void onReady() {
    // 子类重写
  }

  /// 页面销毁时调用
  /// 适合在此处释放资源、取消订阅
  void onClose() {
    // 子类重写
  }

  /// 构建页面主体内容 (必须重写)
  Widget buildBody(BuildContext context);

  /// 返回页面标题 (可选重写)
  String getTitle() => "标题";

  /// 是否显示返回按钮 (可选重写)
  bool showBackButton() => true;
}
```

**使用示例**:

```dart
class MyPage extends BaseView {
  const MyPage({super.key});

  @override
  BaseViewState createState() => _MyPageState();
}

class _MyPageState extends BaseViewState<MyPage> {

  @override
  void onReady() {
    super.onReady();
    // 页面渲染完成后调用接口
    _loadData();
  }

  @override
  void onClose() {
    super.onClose();
    // 释放资源
  }

  @override
  Widget buildBody(BuildContext context) {
    return Container();
  }

  @override
  String getTitle() => "我的页面";
}
```

### 4.2 Riverpod ViewModel

**位置**: `lib/business/features/<module>/viewModels/`

**使用方式**: 使用 `@riverpod` 注解自动生成 Provider

```dart
// UserInfoVM.dart
part 'user_info_vm.g.dart';

@riverpod
class UserInfoVM extends _$UserInfoVM {

  @override
  User build() {
    // 返回初始状态
    return const User(name: "", age: 0);
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateAge(int age) {
    state = state.copyWith(age: age);
  }

  Future<void> fetchUser() async {
    HUDLoading.show();
    User user = await ref.read(userRepositoryProvider).getUser();
    state = user;
    HUDLoading.dismiss();
  }
}
```

**在View中使用**:

```dart
class UserInfoView extends ConsumerWidget {
  const UserInfoView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听状态变化
    final user = ref.watch(userInfoVMProvider);

    return Scaffold(
      body: Column(
        children: [
          Text('姓名: ${user.name}'),
          Text('年龄: ${user.age}'),
          ElevatedButton(
            onPressed: () {
              // 调用ViewModel方法
              ref.read(userInfoVMProvider.notifier).updateName("张三");
            },
            child: Text('修改'),
          ),
        ],
      ),
    );
  }
}
```

### 4.3 Freezed 数据模型

**位置**: `lib/business/features/<module>/models/`

**使用方式**:

```dart
part 'user.freezed.dart';
part 'user.g.dart';

@freezed
sealed class User with _$User {
  const factory User({
    required String name,
    int? age,
    String? email,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

**生成的代码**:
- `User.freezed.dart`: 包含 `copyWith`、构造函数
- `User.g.dart`: 包含 `fromJson`/`toJson`

### 4.4 DioClient 网络客户端

**位置**: `lib/base/network/dio_client.dart`

**核心方法**:

```dart
class DioClient {
  final Dio _dio;
  final ServiceConfig config;

  DioClient({required this.config});

  /// GET请求
  Future<BaseResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJson,
    int successCode = 0,
  });

  /// POST请求
  Future<BaseResponse<T>> post<T>(...);

  /// 文件上传
  Future<BaseResponse<T>> upload<T>(...);

  /// 文件下载
  Future<BaseResponse<String>> download(...);
}
```

**使用示例**:

```dart
// 在Repository中使用
class UserRepositoryImpl implements UserRepository {
  final DioClient _dioClient;

  UserRepositoryImpl(this._dioClient);

  @override
  Future<User> getUser() async {
    var resp = await _dioClient.get<User>(
      "/user/info",
      fromJson: User.fromJson,
    );
    return resp.data!;
  }
}
```

### 4.5 HUD 提示组件

**位置**: `lib/base/widgets/hud/`

**使用方式**:

```dart
import 'package:mvvm_demo/base/widgets/hud/hud.dart';

// Loading
HUDLoading.show(status: '加载中...');
HUDLoading.dismiss();

// Toast
HUDToast.show('操作成功');
HUDToast.show('操作失败', status: HudStatus.error);
```

### 4.6 NotificationCenter 通知中心

**位置**: `lib/base/notificationCenter/notification_center.dart`

**使用方式**:

```dart
import 'package:mvvm_demo/base/notificationCenter/notification_center.dart';

// 定义消息类型
class UserUpdatedMessage extends Message {
  final int userId;
  UserUpdatedMessage({required this.userId});
}

// 订阅消息
final subscription = NotificationCenter().addListen<UserUpdatedMessage>(
  onReceived: (msg) {
    print('用户更新: ${msg.userId}');
  },
);

// 发送消息
NotificationCenter().sendNotification(UserUpdatedMessage(userId: 123));

// 取消订阅
subscription.cancel();
```

### 4.7 Application 应用上下文

**位置**: `lib/business/shared/application.dart`

**作用**: 存放整个应用生命周期的全局数据

```dart
// 获取Token
String? token = Application().token;

// 设置Token (会自动持久化)
Application().token = "your_token";

// 清除Token
Application().token = null;

// 获取包信息
PackageInfo info = Application().packageInfo;
```

---

## 5. 开发规范

### 5.1 通用规范

1. **单文件行数限制**: 单个Dart文件建议不超过300行
2. **类名命名**: 使用 PascalCase (如 `UserInfoView`)
3. **方法/变量命名**: 使用 camelCase (如 `fetchUserInfo`)
4. **常量命名**: 使用 kConstantName 或 CONSTANT_NAME
5. **文件命名**: 使用 snake_case (如 `user_info_view.dart`)

### 5.2 代码生成

本项目使用代码生成来减少样板代码。**每次创建或修改 `*_vm.dart`、`*_model.dart`、`*_repository.dart` 文件后，必须运行代码生成命令。**

#### 5.2.1 代码生成命令

```bash
# 完整生成（推荐首次或大规模修改后）
dart run build_runner build --delete-conflicting-outputs

# 增量生成（日常开发，推荐）
dart run build_runner build

# 监听文件变化自动生成（开发时使用）
dart run build_runner watch

# 清理并重新生成
dart run build_runner build --delete-conflicting-outputs
```

#### 5.2.2 需要代码生成的文件类型

| 文件类型 | 注解 | 生成文件 | 说明 |
|----------|------|----------|------|
| ViewModel | `@riverpod` | `xxx_vm.g.dart` | 自动生成 Provider |
| Model | `@freezed` | `xxx.freezed.dart` | 生成 copyWith、构造函数 |
| Model | `part 'xxx.g.dart'` | `xxx.g.dart` | 生成 fromJson/toJson |
| Repository | `@riverpod` | `xxx_repository.g.dart` | 自动生成 Provider |

#### 5.2.3 代码生成工作流

```
1. 创建/修改 xxx_model.dart
   ↓
2. 添加 @freezed 注解和 part 文件声明
   ↓
3. 创建/修改 xxx_vm.dart
   ↓
4. 添加 @riverpod 注解
   ↓
5. 运行: dart run build_runner build
   ↓
6. 生成的 .g.dart 文件被创建
   ↓
7. 提交代码时确保 .g.dart 文件一起提交
```

#### 5.2.4 注意事项

- **不要手动编辑 `.g.dart` 文件** - 这些是自动生成的
- **`.g.dart` 文件必须提交到仓库** - 其他开发者无需运行代码生成
- **修改源文件后需要重新生成** - 不会自动更新

### 5.3 路由规范

本项目使用 **GoRouter** 进行声明式路由管理。

#### 5.3.1 路由定义位置

| 路由类型 | 定义位置 | 说明 |
|----------|----------|------|
| 全局路由 | `main.dart` | 应用根路由配置 |
| 功能路由 | `test_page.dart` | 功能测试页面路由 |
| 模块路由 | `features/xxx/` | 可选，在独立文件定义模块路由 |

#### 5.3.2 路由命名规范

```
路径规则：
- 页面路径：小写 + 连字符分隔
- 动态参数：:paramName

示例：
/users              → 用户列表
/users/:id          → 用户详情
/user-profile       → 用户资料页（不是 userProfile）
```

#### 5.3.3 路由使用示例

**基础路由定义**:

```dart
GoRoute(
  path: "/users",
  pageBuilder: (context, state) => MaterialPage(
    child: const UsersView(),
  ),
),
```

**带参数路由**:

```dart
GoRoute(
  path: "/users/:id",
  pageBuilder: (context, state) {
    final userId = state.pathParameters['id']!;
    return MaterialPage(
      child: UserDetailView(userId: userId),
    );
  },
),
```

**嵌套路由**:

```dart
GoRoute(
  path: "/users",
  pageBuilder: (context, state) => MaterialPage(child: UsersView()),
  routes: [
    GoRoute(
      path: ":id",
      pageBuilder: (context, state) => MaterialPage(
        child: UserDetailView(userId: state.pathParameters['id']!),
      ),
    ),
  ],
),
```

#### 5.3.4 路由导航

```dart
// 导航到新页面
context.push('/users/123');

// 替换当前页面（无返回）
context.pushReplacement('/login');

// 返回上一页
context.pop();

// 返回到指定页面
context.go('/home');

// 导航到指定路由
GoRouter.of(context).go('/home');
```

#### 5.3.5 Query 参数传递

```dart
// 传递参数
context.push('/search?keyword=flutter&page=1');

// 获取参数
final keyword = state.uri.queryParameters['keyword'];
final page = state.uri.queryParameters['page'];
```

### 5.4 异步状态处理

本项目使用 `AsyncValue` 处理异步状态，这是 Riverpod 推荐的异步状态管理模式。

#### 5.4.1 AsyncValue 三种状态

```dart
enum AsyncValue<T> {
  /// 加载中状态
  AsyncLoading()

  /// 数据状态（包含数据）
  AsyncData(T value)

  /// 错误状态（包含错误和堆栈）
  AsyncError(Object error, StackTrace stackTrace)
}
```

#### 5.4.2 ViewModel 中的使用

**基础模式**:

```dart
@riverpod
class ProductListVM extends _$ProductListVM {
  @override
  AsyncValue<List<Product>> build() {
    // 初始加载
    Future.microtask(() => loadProducts());
    return const AsyncValue.loading();
  }

  Future<void> loadProducts() async {
    state = const AsyncValue.loading();

    try {
      final products = await ref.read(productRepositoryProvider).getList();
      state = AsyncValue.data(products);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
```

**带初始数据的模式**:

```dart
@riverpod
class ProductListVM extends _$ProductListVM {
  @override
  AsyncValue<List<Product>> build() {
    // 先返回空列表，立即加载数据
    Future.microtask(() => loadProducts());
    return const AsyncValue.data([]);
  }

  Future<void> loadProducts() async {
    try {
      final products = await ref.read(productRepositoryProvider).getList();
      state = AsyncValue.data(products);
    } catch (e, st) {
      // 保留之前的数据，显示错误
      state = AsyncValue.error(e, st);
    }
  }
}
```

#### 5.4.3 View 中的使用

**基础用法**:

```dart
class ProductListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProducts = ref.watch(productListVMProvider);

    return asyncProducts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $error'),
            ElevatedButton(
              onPressed: () => ref.read(productListVMProvider.notifier).loadProducts(),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
      data: (products) => ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(products[index].name),
        ),
      ),
    );
  }
}
```

**使用 switch 语法**:

```dart
class ProductListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProducts = ref.watch(productListVMProvider);

    return switch (asyncProducts) {
      AsyncLoading() => const Center(child: CircularProgressIndicator()),
      AsyncError(:final error) => Center(child: Text('错误: $error')),
      AsyncData(:final value) => ListView.builder(
        itemCount: value.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(value[index].name),
        ),
      ),
    };
  }
}
```

#### 5.4.4 常见场景处理

**下拉刷新**:

```dart
RefreshIndicator(
  onRefresh: () => ref.read(productListVMProvider.notifier).refresh(),
  child: asyncProducts.when(
    // ...
  ),
)
```

**分页加载**:

```dart
@riverpod
class ProductListVM extends _$ProductListVM {
  int _page = 1;
  bool _hasMore = true;

  @override
  AsyncValue<List<Product>> build() {
    Future.microtask(() => loadProducts());
    return const AsyncValue.data([]);
  }

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }

    if (!_hasMore) return;

    state = const AsyncValue.loading();

    try {
      final result = await ref.read(productRepositoryProvider).getProducts(page: _page);
      if (refresh) {
        state = AsyncValue.data(result.products);
      } else {
        state = AsyncValue.data([...state.value ?? [], ...result.products]);
      }
      _hasMore = result.hasMore;
      _page++;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    if (!state.isLoading && _hasMore) {
      await loadProducts();
    }
  }
}
```

**无数据状态**:

```dart
asyncProducts.when(
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (error, _) => ErrorWidget(error: error.toString()),
  data: (products) {
    if (products.isEmpty) {
      return const EmptyDataWidget();
    }
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (_, index) => ProductItem(product: products[index]),
    );
  },
)
```

### 5.5 新增功能模块

当新增一个新的功能模块时，需要创建以下结构：

```
lib/business/features/<moduleName>/
├── views/
│   └── <module_name>_view.dart      # 视图层
├── viewModels/
│   └── <module_name>_vm.dart        # ViewModel层
├── models/
│   └── <module_name>_model.dart     # 数据模型
└── repositories/
    └── <module_name>_repository.dart # 数据仓库
```

**创建步骤**:

1. **Model层**: 使用Freezed定义数据模型
   ```dart
   // models/xxx_model.dart
   part 'xxx.freezed.dart';
   part 'xxx.g.dart';

   @freezed
   sealed class XxxModel with _$XxxModel {
     const factory XxxModel({required String id, String? name}) = _XxxModel;
     factory XxxModel.fromJson(Map<String, dynamic> json) => _$XxxModelFromJson(json);
   }
   ```

2. **Repository层**: 创建数据仓库接口和实现
   ```dart
   // repositories/xxx_repository.dart
   abstract class XxxRepository {
     Future<List<XxxModel>> getList();
     Future<XxxModel> getById(String id);
   }

   class XxxRepositoryImpl implements XxxRepository {
     final DioClient _dioClient;
     XxxRepositoryImpl(this._dioClient);

     @override
     Future<List<XxxModel>> getList() async {
       // 实现
     }
   }

   @riverpod
   XxxRepository xxxRepository(Ref ref) {
     return XxxRepositoryImpl(ref.read(xxxDioClientProvider));
   }
   ```

3. **ViewModel层**: 创建状态管理
   ```dart
   // viewModels/xxx_vm.dart
   part 'xxx_vm.g.dart';

   @riverpod
   class XxxVM extends _$XxxVM {
     @override
     List<XxxModel> build() => [];

     Future<void> loadList() async {
       state = await ref.read(xxxRepositoryProvider).getList();
     }
   }
   ```

4. **View层**: 创建UI视图
   ```dart
   // views/xxx_view.dart
   class XxxView extends ConsumerWidget {
     const XxxView({super.key});

     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final list = ref.watch(xxxVMProvider);

       return ListView.builder(
         itemCount: list.length,
         itemBuilder: (context, index) {
           return ListTile(title: Text(list[index].name ?? ''));
         },
       );
     }
   }
   ```

### 5.6 网络请求规范

1. **统一使用 BaseResponse**: 所有API响应使用统一格式
2. **在Repository中处理网络请求**: ViewModel不直接发起网络请求
3. **使用DioClient封装**: 不直接使用Dio实例
4. **错误处理**: Repository层统一处理错误，返回可用的数据或抛出异常

```dart
// 正确示例
class UserRepositoryImpl implements UserRepository {
  final DioClient _dioClient;

  @override
  Future<User> getUser(String id) async {
    try {
      final resp = await _dioClient.get<User>(
        '/user/$id',
        fromJson: User.fromJson,
      );
      if (resp.isSuccess && resp.data != null) {
        return resp.data!;
      }
      throw NetworkException(message: resp.message);
    } catch (e) {
      rethrow;
    }
  }
}
```

### 5.7 状态管理规范

1. **使用 @riverpod 注解**: 自动生成 Provider 代码
2. **状态不可变**: 使用 Freezed 的 `copyWith` 更新状态
3. **在 View 中监听状态**: 使用 `ref.watch()` 监听变化
4. **调用方法使用 ref.read()**: 事件处理时使用

```dart
// 监听状态
final user = ref.watch(userInfoVMProvider);

// 调用方法
ref.read(userInfoVMProvider.notifier).updateName("张三");

// 异步操作
ref.read(userInfoVMProvider.notifier).fetchUser();
```

### 5.8 组件使用规范

1. **公共组件放 base/widgets/**: 多个功能使用的组件
2. **功能专用组件放 features/**: 仅单个功能使用的组件
3. **每个组件独立目录**: 包含组件文件、模型、工具、README
4. **提供使用示例**: 在组件目录中包含 `example_xxx.dart`

---

## 6. 命名规范

### 6.1 文件命名

| 类型 | 规范 | 示例 |
|------|------|------|
| Dart 文件 | snake_case | `user_info_view.dart` |
| Part 文件 | xxx.g.dart / xxx.freezed.dart | `user.g.dart` |
| README | README.md | `README.md` |

### 6.2 类命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 视图类 | XxxView | `UserInfoView` |
| ViewModel类 | XxxVM / XxxNotifier | `UserInfoVM` |
| 模型类 | XxxModel / Xxx (业务) | `User` |
| 仓库类 | XxxRepository | `UserRepository` |
| 组件类 | XxxWidget | `SwapCardWidget` |

### 6.3 变量/方法命名

| 类型 | 规范 | 示例 |
|------|------|------|
| Provider | xxxProvider | `userInfoVMProvider` |
| Repository | xxxRepositoryProvider | `userRepositoryProvider` |
| DioClient | xxxDioClientProvider | `userDioClientProvider` |

### 6.4 目录命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 功能模块 | snake_case | `user_info/` |
| 组件目录 | snake_case | `qr_scanner/` |
| 工具目录 | snake_case | `utils/` |

---

## 7. 代码示例

### 7.1 完整的 MVVM 模块示例

假设要创建一个「商品列表」功能：

**1. 创建目录结构**

```
lib/business/features/product/
├── views/
│   └── product_list_view.dart
├── viewModels/
│   └── product_list_vm.dart
├── models/
│   └── product.dart
└── repositories/
    └── product_repository.dart
```

**2. Model: product.dart**

```dart
part 'product.freezed.dart';
part 'product.g.dart';

@freezed
sealed class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required double price,
    String? imageUrl,
    String? description,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
```

**3. Repository: product_repository.dart**

```dart
part 'product_repository.g.dart';

abstract class ProductRepository {
  Future<List<Product>> getProductList({int page = 1, int pageSize = 20});
  Future<Product> getProductDetail(String id);
}

class ProductRepositoryImpl implements ProductRepository {
  final DioClient _dioClient;

  ProductRepositoryImpl(this._dioClient);

  @override
  Future<List<Product>> getProductList({
    int page = 1,
    int pageSize = 20,
  }) async {
    final resp = await _dioClient.get<List<Product>>(
      '/products',
      queryParameters: {'page': page, 'pageSize': pageSize},
      fromJson: (json) => (json as List)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return resp.data ?? [];
  }

  @override
  Future<Product> getProductDetail(String id) async {
    final resp = await _dioClient.get<Product>(
      '/products/$id',
      fromJson: Product.fromJson,
    );
    return resp.data!;
  }
}

@riverpod
ProductRepository productRepository(Ref ref) {
  return ProductRepositoryImpl(ref.read(productDioClientProvider));
}

@riverpod
DioClient productDioClient(Ref ref) {
  final config = AppEnv.config;
  return DioClient(
    config: ServiceConfig(
      baseUrl: config.apiBaseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
      enableLog: config.enableLogging,
      tokenProvider: () => Application().token,
    ),
  );
}
```

**4. ViewModel: product_list_vm.dart**

```dart
part 'product_list_vm.g.dart';

@riverpod
class ProductListVM extends _$ProductListVM {
  @override
  AsyncValue<List<Product>> build() {
    // 初始加载
    Future.microtask(() => loadProducts());
    return const AsyncValue.loading();
  }

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      state = const AsyncValue.loading();
    }

    try {
      final products = await ref.read(productRepositoryProvider).getProductList();
      state = AsyncValue.data(products);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await loadProducts(refresh: true);
  }
}
```

**5. View: product_list_view.dart**

```dart
class ProductListView extends ConsumerWidget {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProducts = ref.watch(productListVMProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('商品列表')),
      body: asyncProducts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('加载失败: $error')),
        data: (products) => RefreshIndicator(
          onRefresh: () => ref.read(productListVMProvider.notifier).refresh(),
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: product.imageUrl != null
                    ? Image.network(product.imageUrl!)
                    : const Icon(Icons.shopping_bag),
                title: Text(product.name),
                subtitle: Text('¥${product.price.toStringAsFixed(2)}'),
                onTap: () {
                  // 导航到详情页
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
```

---

## 8. FAQ

### Q1: 为什么使用 Freezed 而不是普通 class？

Freezed 提供：
- **不可变性**: 减少bugs，数据不可随意修改
- **copyWith**: 便捷的状态更新
- **equals/hashCode**: 自动实现
- **toString**: 便于调试
- **fromJson/toJson**: 自动生成序列化代码

### Q2: 为什么 ViewModel 用 @riverpod 而不是 Provider？

`riverpod_annotation` 提供：
- **类型安全**: 编译时检查
- **代码生成**: 自动生成 Provider 代码
- **易于测试**: 状态可独立测试
- **更好的性能**: 精准依赖追踪

### Q3: Repository 和 ViewModel 的区别？

| 方面 | Repository | ViewModel |
|------|------------|-----------|
| 职责 | 数据获取、缓存、转换 | 业务逻辑、状态管理 |
| 位置 | business/features/xxx/repositories/ | business/features/xxx/viewModels/ |
| 依赖 | DioClient | Repository |
| 调用者 | ViewModel | View |

### Q4: 什么时候使用 NotificationCenter？

- 跨页面通信
- 全局事件通知（如登录状态变化）
- 组件间解耦通信

**注意**: 不要滥用，能用 Provider 解决的优先用 Provider。

### Q5: 如何处理网络错误？

```dart
// 在 Repository 中
@override
Future<User> getUser(String id) async {
  try {
    final resp = await _dioClient.get<User>('/user/$id', fromJson: User.fromJson);
    if (resp.isSuccess) {
      return resp.data!;
    }
    throw NetworkException(message: resp.message);
  } on DioException catch (e) {
    throw NetworkException.fromDioError(e);
  }
}

// 在 ViewModel 中
@override
Future<void> loadUser(String id) async {
  state = const AsyncValue.loading();
  try {
    final user = await ref.read(userRepositoryProvider).getUser(id);
    state = AsyncValue.data(user);
  } catch (e, st) {
    state = AsyncValue.error(e, st);
  }
}
```

### Q6: 什么时候使用 Shared Models / Shared Repositories？

**Shared Models** 适用于：
- 多个功能模块需要使用相同的数据结构（如 User、AppConfig）
- 跨模块的数据实体定义
- 全局配置数据模型

**Shared Repositories** 适用于：
- 多个模块需要访问相同的数据源（如获取当前用户信息）
- 全局性数据获取逻辑
- 跨模块共享的数据缓存

**判断标准**：
- 如果某个 Model/Repository 只被一个功能模块使用 → 放在 `features/xxx/models/` 或 `features/xxx/repositories/`
- 如果某个 Model/Repository 被两个或以上模块使用 → 放在 `business/shared/models/` 或 `business/shared/repositories/`

**示例场景**：
```
场景：用户模块和订单模块都需要获取用户信息

方案A (不推荐)：每个模块独立获取
  - userInfo 模块有自己的 UserRepository
  - order 模块也有自己的 UserRepository (重复代码)

方案B (推荐)：使用 Shared Repository
  - userInfo 模块和 order 模块都依赖 shared/UserRepository
  - 避免代码重复，保持数据一致性
```

### Q7: Shared Repositories 和 Features Repositories 的区别？

| 方面 | Shared Repository | Features Repository |
|------|-------------------|---------------------|
| **位置** | `business/shared/repositories/` | `business/features/xxx/repositories/` |
| **使用范围** | 多个功能模块共用 | 仅当前模块使用 |
| **生命周期** | 应用级 | 模块级 |
| **示例** | UserRepository、ConfigRepository | ProductRepository、OrderRepository |

---

## 更新日志

| 日期 | 版本 | 更新内容 |
|------|------|----------|
| 2026-05-26 | 1.0.0 | 初始版本 |

---

**文档版本**: 1.0.0
**最后更新**: 2026-05-26
