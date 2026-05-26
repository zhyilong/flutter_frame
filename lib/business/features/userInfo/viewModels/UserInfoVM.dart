/*
 * Created by zhyilong on 2026/5/13
 */

import 'package:mvvm_demo/base/widgets/hud/hud.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/User.dart';
import '../repositories/userRepository.dart';

// build_runner识别@riverpod注解生成的抽象类(notifierProvider)
part 'UserInfoVM.g.dart';

// 被riverpod托管注解
@riverpod
class UserInfoVM extends _$UserInfoVM {
  @override
  User build() {
    return const User(name: "", age: 0);
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateAge(int age) {
    state = state.copyWith(age: age);
  }

  void reset() {
    state = const User(name: "", age: 0);
  }

  void createUser(String name, int age) async {
    HUDLoading.show();
    User user = await ref.read(userRepositoryProvider).createUser(name: name, age: age);
    state = user;
    HUDLoading.dismiss();
  }
}
