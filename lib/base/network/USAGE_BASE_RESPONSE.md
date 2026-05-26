# 网络请求客户端使用指南（BaseResponse 返回方式）

## 📦 新特性

**所有网络请求方法现在都返回 `BaseResponse<T>`**，不再需要 try-catch！

### 优势

✅ **不需要 try-catch** - 通过 `isSuccess` 判断即可
✅ **统一的返回格式** - 所有方法都返回 BaseResponse
✅ **更好的类型安全** - 编译时就能知道返回类型
✅ **简化错误处理** - 通过 code 和 message 统一处理
✅ **支持链式调用** - 使用扩展方法简化代码

## 🚀 快速开始

### 1. 基本使用

```dart
import 'package:riverpod_base/common/api/user_service.dart';
import 'package:riverpod_base/common/network/models/base_response.dart';
import 'package:riverpod_base/common/network/models/base_response_extension.dart';

final userService = UserService();

// 获取用户信息
final response = await userService.getUserInfo('123');

if (response.isSuccess) {
  // 成功：使用数据
  final user = response.data!;
  print('用户名: ${user.username}');
} else {
  // 失败：处理错误
  print('错误码: ${response.code}');
  print('错误信息: ${response.message}');
}
```

### 2. 使用扩展方法（推荐）

```dart
// 链式调用
await userService.getUserInfo('123')
  ..onSuccess((user) {
    print('用户名: ${user.username}');
  })
  ..onFailure((code, message) {
    print('错误[$code]: $message');
  });

// 获取数据或默认值
final user = await userService.getUserInfo('123')
    .getDataOrElse(User(id: '', username: '默认用户'));
```

### 3. 使用 switch 处理错误码

```dart
final response = await userService.login('admin', '123456');

switch (response.code) {
  case 0:
    // 登录成功
    final loginResponse = response.data!;
    print('Token: ${loginResponse.token}');
    break;

  case 1001:
    print('用户名或密码错误');
    break;

  case 1002:
    print('账号已被禁用');
    break;

  case -1001:
    print('网络超时，请检查网络连接');
    break;

  case -1002:
    print('网络连接失败');
    break;

  default:
    print('登录失败: ${response.message}');
}
```

### 4. 在 Flutter Widget 中使用

```dart
class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserService _userService = UserService();
  BaseResponse<User>? _response;
  bool _loading = false;

  Future<void> _loadUser() async {
    setState(() => _loading = true);

    // 不需要 try-catch！
    final response = await _userService.getUserInfo('123');

    setState(() {
      _response = response;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('用户信息')),
      body: _loading
          ? CircularProgressIndicator()
          : _response == null
              ? ElevatedButton(
                  onPressed: _loadUser,
                  child: Text('加载用户'),
                )
              : _response!.isSuccess
                  ? Column(
                      children: [
                        Text('用户ID: ${_response!.data!.id}'),
                        Text('用户名: ${_response!.data!.username}'),
                      ],
                    )
                  : Text('错误: ${_response!.message}'),
    );
  }
}
```

## 📋 API 参考

### DioClient 方法签名变化

**之前（抛出异常）：**
```dart
Future<T> get<T>(...);
Future<T> post<T>(...);
```

**现在（返回 BaseResponse）：**
```dart
Future<BaseResponse<T>> get<T>(...);
Future<BaseResponse<T>> post<T>(...);
Future<BaseResponse<T>> put<T>(...);
Future<BaseResponse<T>> delete<T>(...);
Future<BaseResponse<T>> upload<T>(...);
Future<BaseResponse<String>> download(...);
```

### BaseResponse 属性

```dart
class BaseResponse<T> {
  final int code;           // 业务状态码或错误码
  final String message;     // 响应消息或错误信息
  final T? data;            // 响应数据（成功时有效）

  bool get isSuccess;       // code == 0
  bool get isFailure;       // code != 0
}
```

### 错误码定义

| 错误码 | 类型 | 说明 |
|--------|------|------|
| 0 | 成功 | 请求成功 |
| > 0 | 业务错误 | code != 0，如 1001=参数错误 |
| -1 | 未知错误 | 其他未知错误 |
| -1001 | 超时 | 请求超时 |
| -1002 | 网络错误 | 网络连接失败 |
| -1003 | HTTP错误 | 4xx、5xx 错误 |
| -1004 | 取消 | 请求被取消 |

## 🔥 扩展方法

### isSuccess / isFailure

```dart
if (response.isSuccess) {
  // 成功处理
}
```

### onSuccess / onFailure

```dart
response
  .onSuccess((data) {
    // 成功回调
  })
  .onFailure((code, message) {
    // 失败回调
  });
```

### getDataOrElse

```dart
final user = response.getDataOrElse(defaultUser);
```

### 错误判断方法

```dart
if (response.isNetworkError) {
  // 网络错误（code <= -1000）
}

if (response.isBusinessError) {
  // 业务错误（code > 0）
}

if (response.isTimeout) {
  // 超时错误（code == -1001）
}

if (response.isHttpError) {
  // HTTP 错误（400-599）
}
```

## 📝 对比：之前 vs 现在

### 之前（抛出异常）

```dart
try {
  final user = await userService.getUserInfo('123');
  print('用户名: ${user.username}');
} on NetworkException catch (e) {
  if (e.isBusinessError) {
    print('业务错误: ${e.message}');
  } else if (e.isNetworkError) {
    print('网络错误');
  } else {
    print('其他错误');
  }
} catch (e) {
  print('未知错误');
}
```

### 现在（返回 BaseResponse）

```dart
final response = await userService.getUserInfo('123');

if (response.isSuccess) {
  print('用户名: ${response.data!.username}');
} else {
  print('错误: ${response.message}');
}

// 或者使用扩展方法
response.onSuccess((user) {
  print('用户名: ${user.username}');
}).onFailure((code, message) {
  print('错误[$code]: $message');
});
```

## 🎯 最佳实践

### 1. 统一错误处理

```dart
class ApiHelper {
  static void handleError(BaseResponse response) {
    if (response.isNetworkError) {
      showToast('网络错误，请检查网络连接');
    } else if (response.isBusinessError) {
      showToast(response.message);
    } else {
      showToast('请求失败，请稍后重试');
    }
  }
}

// 使用
final response = await userService.getUserInfo('123');
if (response.isSuccess) {
  // 处理数据
} else {
  ApiHelper.handleError(response);
}
```

### 2. 安全获取数据

```dart
// 方式1：使用 dataOrNull
final user = response.dataOrNull;
if (user != null) {
  print(user.username);
}

// 方式2：使用 getDataOrElse
final user = response.getDataOrElse(User.defaultUser());

// 方式3：直接判断
if (response.isSuccess && response.data != null) {
  final user = response.data!;
  print(user.username);
}
```

### 3. 链式 API 调用

```dart
// 先登录，再获取用户信息
final loginResponse = await userService.login('admin', '123456');

if (loginResponse.isSuccess) {
  final userResponse = await userService.getCurrentUser();

  userResponse.onSuccess((user) {
    print('登录成功: ${user.username}');
  }).onFailure((code, message) {
    print('获取用户信息失败: $message');
  });
} else {
  print('登录失败: ${loginResponse.message}');
}
```

### 4. 封装常用操作

```dart
extension UserServiceExtension on UserService {
  Future<User?> getUserSafely(String userId) async {
    final response = await getUserInfo(userId);
    return response.dataOrNull;
  }

  Future<bool> loginSafely(String username, String password) async {
    final response = await login(username, password);
    return response.isSuccess;
  }
}

// 使用
final user = await userService.getUserSafely('123');
if (user != null) {
  print('用户存在');
}
```

## ⚠️ 注意事项

1. **不再需要 try-catch** - 除非你想要捕获更底层的异常
2. **data 可能为 null** - 即使 isSuccess 为 true，也要检查 data
3. **错误码规范** - 建议统一使用上述错误码定义
4. **扩展方法导入** - 使用扩展方法需要导入 `base_response_extension.dart`

## 🎉 总结

现在所有的网络请求都返回统一的 `BaseResponse<T>`，不再需要 try-catch，代码更简洁、更安全！

```dart
// 简单三步走
final response = await api.getData();  // 1. 获取响应
if (response.isSuccess) {                // 2. 判断成功
  final data = response.data!;           // 3. 使用数据
} else {
  print(response.message);               // 或处理错误
}
```
