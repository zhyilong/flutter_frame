# 网络请求客户端使用指南

## 📦 目录结构

```
lib/common/
├── network/
│   ├── models/
│   │   ├── base_response.dart      # 统一响应模型
│   │   └── network_exception.dart  # 网络异常处理
│   ├── dio_client.dart             # Dio客户端封装
│   └── api_interceptor.dart        # 请求拦截器
└── api/
    ├── user_api.dart               # 用户数据模型
    └── user_service.dart           # 用户API服务
```

## 🚀 快速开始

### 1. 初始化配置

在 `main.dart` 中初始化网络客户端：

```dart
import 'package:riverpod_base/common/network/dio_client.dart';

void main() {
  // 初始化网络客户端
  DioClient.initialize(
    baseUrl: 'https://your-api.com',
    enableLog: true,  // 开发环境开启日志
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    // 可选：添加Token
    tokenProvider: () => 'your-token-here',
    // 可选：添加通用请求头
    headers: {
      'app-version': '1.0.0',
      'device-id': 'unique-device-id',
    },
  );

  runApp(MyApp());
}
```

### 2. 定义数据模型

使用 `json_annotation` 创建数据模型：

```dart
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String name;
  final String? email;

  User({
    required this.id,
    required this.name,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

### 3. 创建API服务

```dart
import '../network/dio_client.dart';
import '../network/models/network_exception.dart';

class UserService {
  final DioClient _client = DioClient.instance;

  Future<User> getUserInfo(String userId) async {
    return await _client.get<User>(
      '/user/$userId',
      fromJson: (json) => User.fromJson(json),
    );
  }

  Future<List<User>> getUserList() async {
    return await _client.get<List<User>>(
      '/users',
      fromJson: (json) => (json as List)
          .map((e) => User.fromJson(e))
          .toList(),
    );
  }

  Future<User> createUser({
    required String name,
    String? email,
  }) async {
    return await _client.post<User>(
      '/user/create',
      data: {'name': name, if (email != null) 'email': email},
      fromJson: (json) => User.fromJson(json),
    );
  }
}
```

### 4. 调用API

```dart
// 在Widget或业务逻辑中调用
final userService = UserService();

try {
  // 获取用户信息
  final user = await userService.getUserInfo('123');
  print('用户名: ${user.name}');

  // 获取用户列表
  final users = await userService.getUserList();
  print('用户数量: ${users.length}');

  // 创建用户
  final newUser = await userService.createUser(
    name: 'John',
    email: 'john@example.com',
  );
  print('创建成功: ${newUser.id}');

} on NetworkException catch (e) {
  // 处理网络异常
  print('错误类型: ${e.type}');
  print('错误信息: ${e.message}');

  if (e.isBusinessError) {
    // 业务错误（code != 0）
    print('业务错误码: ${e.code}');
  } else if (e.isNetworkError) {
    // 网络错误
    print('请检查网络连接');
  } else if (e.isTimeout) {
    // 超时错误
    print('请求超时，请重试');
  }
} catch (e) {
  // 其他异常
  print('未知错误: $e');
}
```

## 📖 API 说明

### DioClient

#### GET 请求

```dart
final response = await DioClient.instance.get<User>(
  '/user/1',
  queryParameters: {'page': 1, 'size': 10},  // 可选
  fromJson: (json) => User.fromJson(json),
);
```

#### POST 请求

```dart
final response = await DioClient.instance.post<User>(
  '/user/create',
  data: {'name': 'John', 'age': 30},
  fromJson: (json) => User.fromJson(json),
);
```

#### PUT 请求

```dart
final response = await DioClient.instance.put<User>(
  '/user/1',
  data: {'name': 'John Updated'},
  fromJson: (json) => User.fromJson(json),
);
```

#### DELETE 请求

```dart
await DioClient.instance.delete<void>(
  '/user/1',
  fromJson: (_) => {},
);
```

#### 文件上传

```dart
import 'dart:io';

final file = File('/path/to/file.jpg');
final response = await DioClient.instance.upload(
  '/upload',
  file: file,
  fileName: 'avatar.jpg',
  data: {'userId': '123'},  // 可选的表单数据
  onSendProgress: (sent, total) {
    print('上传进度: ${(sent / total * 100).toStringAsFixed(2)}%');
  },
  fromJson: (json) => UploadResponse.fromJson(json),
);
```

#### 文件下载

```dart
await DioClient.instance.download(
  'https://example.com/file.pdf',
  '/path/to/save/file.pdf',
  onReceiveProgress: (received, total) {
    print('下载进度: ${(received / total * 100).toStringAsFixed(2)}%');
  },
);
```

## 🔥 高级用法

### 1. 自定义成功码

```dart
final response = await DioClient.instance.get<User>(
  '/user/1',
  fromJson: (json) => User.fromJson(json),
  successCode: 200,  // 自定义成功码
);
```

### 2. 取消请求

```dart
final cancelToken = CancelToken();

// 发起请求
DioClient.instance.get('/user/1',
  cancelToken: cancelToken,
  fromJson: (json) => User.fromJson(json),
);

// 取消请求
cancelToken.cancel('用户取消操作');
```

### 3. 直接访问 Dio 实例

```dart
final dio = DioClient.instance.dio;

// 使用Dio原生功能
final response = await dio.get('/some-endpoint');
```

## 🛡️ 错误处理

### NetworkException 类型

- `NetworkErrorType.unknown` - 未知错误
- `NetworkErrorType.networkError` - 网络连接错误
- `NetworkErrorType.timeout` - 请求超时
- `NetworkErrorType.serverError` - 服务器错误（4xx、5xx）
- `NetworkErrorType.businessError` - 业务错误（code != 0）
- `NetworkErrorType.emptyData` - 数据为空
- `NetworkErrorType.cancel` - 取消请求

### 错误判断方法

```dart
try {
  // ...
} on NetworkException catch (e) {
  // 类型判断
  if (e.isNetworkError) {
    // 处理网络错误
  } else if (e.isTimeout) {
    // 处理超时
  } else if (e.isBusinessError) {
    // 处理业务错误
  } else if (e.isServerError) {
    // 处理服务器错误
  }
}
```

## 📝 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:riverpod_base/common/network/dio_client.dart';
import 'package:riverpod_base/common/network/models/network_exception.dart';
import 'package:riverpod_base/common/api/user_service.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserService _userService = UserService();
  User? _user;
  String? _errorMessage;

  Future<void> _loadUserInfo() async {
    try {
      final user = await _userService.getUserInfo('123');
      setState(() {
        _user = user;
        _errorMessage = null;
      });
    } on NetworkException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('用户信息')),
      body: Center(
        child: _errorMessage != null
            ? Text('错误: $_errorMessage')
            : _user != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('用户ID: ${_user!.id}'),
                      Text('用户名: ${_user!.name}'),
                      if (_user!.email != null)
                        Text('邮箱: ${_user!.email}'),
                    ],
                  )
                : CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadUserInfo,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
```

## ✨ 特性总结

- ✅ **简洁易用** - 一行代码完成请求
- ✅ **类型安全** - 泛型支持，编译时检查
- ✅ **自动化** - 统一处理响应、错误、序列化
- ✅ **拦截器** - 自动添加Token、日志等
- ✅ **错误处理** - 完善的异常分类和处理
- ✅ **文件上传下载** - 支持进度回调
- ✅ **取消请求** - 支持请求取消
- ✅ **单例模式** - 全局共享配置

## 📚 生成的文件

运行以下命令生成序列化代码：

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

生成的文件：
- `base_response.g.dart`
- `user_api.g.dart`
- `network_test.mocks.dart`

## 🧪 运行测试

```bash
flutter test test/network_test.dart
```
