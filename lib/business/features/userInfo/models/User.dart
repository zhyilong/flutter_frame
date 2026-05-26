/*
 * Created by zhyilong on 2026/5/13
 */

import 'package:freezed_annotation/freezed_annotation.dart';

// build_runner生成的User的子类(_$User)
part 'User.freezed.dart';
// build_runner生成的json序列化和反序列化
part 'User.g.dart';

// freezed注解（主要生成copywith，rivepod使用都是const对象，减轻copy函数的重复编码）
@freezed
sealed class User with _$User {
  // 生成User.freezed.dart
  const factory User({required String name, int? age}) = _User;

  // 必须写的，否则不能生成User.g.dart
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
