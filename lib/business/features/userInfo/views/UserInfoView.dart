/*
 * Created by zhyilong on 2026/5/13
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewModels/UserInfoVM.dart';

class UserInfoView extends ConsumerWidget {
  const UserInfoView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoVMProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('用户信息')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: '姓名', border: OutlineInputBorder()),
              onChanged: (value) {
                ref.read(userInfoVMProvider.notifier).updateName(value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: '年龄', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final age = int.tryParse(value);
                if (age != null) {
                  ref.read(userInfoVMProvider.notifier).updateAge(age);
                }
              },
            ),
            const SizedBox(height: 32),
            Text('姓名: ${user.name}', style: const TextStyle(fontSize: 18)),
            Text('年龄: ${user.age ?? "未设置"}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref.read(userInfoVMProvider.notifier).reset();
              },
              child: const Text('重置'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref.read(userInfoVMProvider.notifier).reset();
              },
              child: const Text('关闭'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref.read(userInfoVMProvider.notifier).createUser("rivepod", 24);
              },
              child: const Text('createUser'),
            ),
          ],
        ),
      ),
    );
  }

  void test() {
    //
  }
}
