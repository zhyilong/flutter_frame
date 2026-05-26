/*
 * Created by zhyilong on 2026/5/20
 */

import 'dart:async';

import 'package:event_bus/event_bus.dart';

/// 消息接收回调函数类型
typedef OnReceived<T extends Message> = void Function(T notification);

/// 通知消息基类
///
/// 所有通过 NotificationCenter 发送的消息必须继承此类
class Message {
  /// 消息标识符，用于区分不同的消息通道
  final String key;

  /// 创建消息实例
  ///
  /// [key] 消息标识符，如果为空则使用默认标识符
  const Message({String? key}) : this.key = key ?? NotificationCenter._defaultKey;
}

/// 订阅者封装类
///
/// 用于管理单个订阅的生命周期，调用 [cancel] 可取消订阅
class Subscriber {
  final StreamSubscription _streamSubscription;
  final String _key;

  Subscriber({required StreamSubscription streamSubscription, required String key})
      : _streamSubscription = streamSubscription,
        _key = key;

  /// 取消订阅
  ///
  /// 取消后将不再接收通知，此方法可安全地多次调用
  void cancel() {
    NotificationCenter().cancel(this);
  }
}

/// 通知中心单例类
///
/// 提供发布-订阅模式的消息通知机制，支持按 key 分组管理订阅者
///
/// **重要说明**：EventBus 默认使用异步模式，消息发送后不会立即触发监听器。
/// 如果在发送通知后立即取消订阅，可能会错过消息处理。建议：
/// - 延迟取消订阅（使用 Future.delayed）
/// - 或在消息处理完成后再取消订阅
///
/// 示例：
/// ```dart
/// final subscription = NotificationCenter().addListen<Message>(
///   onReceived: (msg) => print(msg.key),
/// );
/// NotificationCenter().sendNotification(Message());
/// await Future.delayed(Duration(milliseconds: 100)); // 等待消息处理
/// subscription.cancel();
/// ```
class NotificationCenter {
  final EventBus _eventBus = EventBus();

  static NotificationCenter? _instance;

  NotificationCenter._();

  /// 默认的消息 key（编译时常量，支持 const 构造函数）
  static const String _defaultKey = "default";

  /// 按 key 分组的订阅者列表
  final Map<String, List<Subscriber>> _listeners = {};

  /// 获取 NotificationCenter 单例实例
  factory NotificationCenter() {
    return _instance ??= NotificationCenter._();
  }

  /// 订阅默认通道的消息
  ///
  /// [T] 消息类型，必须是 [Message] 的子类
  /// [onReceived] 消息接收回调
  ///
  /// 返回 [Subscriber] 对象，用于后续取消订阅
  ///
  /// 示例：
  /// ```dart
  /// final subscription = NotificationCenter().addListen<MyMessage>(
  ///   onReceived: (msg) => print('收到: ${msg.key}'),
  /// );
  /// ```
  Subscriber addListen<T extends Message>({required OnReceived<T> onReceived}) {
    try {
      final streamSubscription = _eventBus.on<T>().listen(onReceived);
      final subscriber = Subscriber(
        streamSubscription: streamSubscription,
        key: _defaultKey,
      );

      final list = _listeners[_defaultKey] ?? [];
      list.add(subscriber);
      _listeners[_defaultKey] = list;

      return subscriber;
    } catch (e) {
      throw Exception('订阅消息失败: $e');
    }
  }

  /// 订阅指定 key 通道的消息
  ///
  /// [T] 消息类型，必须是 [Message] 的子类
  /// [key] 通道标识符，用于区分不同的订阅组
  /// [onReceived] 消息接收回调
  ///
  /// 返回 [Subscriber] 对象，用于后续取消订阅
  ///
  /// 示例：
  /// ```dart
  /// final subscription = NotificationCenter().addListenForKey<MyMessage>(
  ///   key: 'user_updates',
  ///   onReceived: (msg) => print('用户更新: ${msg.key}'),
  /// );
  /// ```
  Subscriber addListenForKey<T extends Message>({
    required String key,
    required OnReceived<T> onReceived,
  }) {
    try {
      final streamSubscription = _eventBus.on<T>().listen(onReceived);
      final subscriber = Subscriber(
        streamSubscription: streamSubscription,
        key: key,
      );

      final list = _listeners[key] ?? [];
      list.add(subscriber);
      _listeners[key] = list;

      return subscriber;
    } catch (e) {
      throw Exception('订阅消息失败 (key: $key): $e');
    }
  }

  /// 发送通知消息
  ///
  /// [T] 消息类型
  /// [notification] 要发送的消息实例
  ///
  /// 注意：由于 EventBus 使用异步模式，消息不会立即触发监听器
  ///
  /// 示例：
  /// ```dart
  /// NotificationCenter().sendNotification(MyMessage(key: 'test'));
  /// ```
  void sendNotification<T extends Message>(T notification) {
    try {
      _eventBus.fire(notification);
    } catch (e) {
      throw Exception('发送通知失败: $e');
    }
  }

  /// 取消指定 key 的所有订阅
  ///
  /// [key] 通道标识符
  ///
  /// 示例：
  /// ```dart
  /// NotificationCenter().cancelForKey('user_updates');
  /// ```
  void cancelForKey(String key) {
    final list = _listeners[key];
    if (list == null) return;

    for (final item in list) {
      try {
        item._streamSubscription.cancel();
      } catch (e) {
        // 忽略取消订阅时的异常
      }
    }
    _listeners.remove(key);
  }

  /// 取消指定订阅者的订阅
  ///
  /// [subscriber] 要取消的订阅者对象
  ///
  /// 注意：此方法可安全地多次调用同一订阅者
  ///
  /// 示例：
  /// ```dart
  /// subscription.cancel();
  /// ```
  void cancel(Subscriber subscriber) {
    final list = _listeners[subscriber._key];
    if (list == null) return;

    final index = list.indexWhere((s) => s == subscriber);
    if (index >= 0) {
      try {
        list[index]._streamSubscription.cancel();
      } catch (e) {
        // 忽略取消订阅时的异常
      }
      list.removeAt(index);
    }

    if (list.isEmpty) {
      _listeners.remove(subscriber._key);
    }
  }
}
