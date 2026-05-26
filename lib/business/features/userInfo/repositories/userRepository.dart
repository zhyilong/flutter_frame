/*
 * Created by zhyilong on 2026/5/22
 */

import 'package:logger/logger.dart';
import 'package:mvvm_demo/base/network/dio_client.dart';
import 'package:mvvm_demo/business/features/userInfo/models/User.dart';
import 'package:mvvm_demo/business/shared/environment.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'userRepository.g.dart';

abstract class UserRepository {
  Future<User> createUser({required String name, required int age});
}

class UserRepositoryImpl implements UserRepository {
  final DioClient _dioClient;

  UserRepositoryImpl(this._dioClient);

  @override
  Future<User> createUser({required String name, required int age}) async {
    // TODO: implement createUser
    var resp = await _dioClient.getRaw("/packages", queryParameters: {"q": "image"});
    return User(name: name, age: age);
  }
}

@riverpod
UserRepository userRepository(Ref ref) {
  return UserRepositoryImpl(ref.read(userDioClientProvider));
}

@riverpod
DioClient userDioClient(Ref ref) {
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
