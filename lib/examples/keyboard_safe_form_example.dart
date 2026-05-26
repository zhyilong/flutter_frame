import 'package:flutter/material.dart';

/// 键盘避免示例 - 方案二：SingleChildScrollView + reverse: true
/// 这是最简单且自动化的键盘避免方案
class KeyboardSafeFormExample extends StatefulWidget {
  const KeyboardSafeFormExample({super.key});

  @override
  State<KeyboardSafeFormExample> createState() => _KeyboardSafeFormExampleState();
}

class _KeyboardSafeFormExampleState extends State<KeyboardSafeFormExample> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('表单提交成功！')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 点击空白处收起键盘
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('注册表单'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
        // 关键点：使用 SingleChildScrollView + reverse: true
        body: SingleChildScrollView(
          reverse: true, // 核心：键盘弹出时自动滚动到输入框
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 顶部Logo和说明
                const FlutterLogo(size: 80),
                const SizedBox(height: 20),
                const Text(
                  '创建新账户',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  '请填写以下信息完成注册',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // 用户名输入框
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '用户名', hintText: '请输入用户名', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入用户名';
                    }
                    if (value.length < 3) {
                      return '用户名至少3个字符';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 邮箱输入框
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: '邮箱', hintText: '请输入邮箱', prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入邮箱';
                    }
                    if (!value.contains('@')) {
                      return '请输入有效的邮箱地址';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 手机号输入框
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: '手机号', hintText: '请输入手机号', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入手机号';
                    }
                    if (value.length < 11) {
                      return '请输入有效的手机号';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 地址输入框
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: '详细地址', hintText: '请输入详细地址', prefixIcon: Icon(Icons.location_on), border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入地址';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 密码输入框
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: '密码', hintText: '请输入密码', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入密码';
                    }
                    if (value.length < 6) {
                      return '密码至少6个字符';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // 提交按钮
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('注册', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),

                // 提示信息
                Card(
                  color: Colors.blue,
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              '键盘自动避免',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '此页面使用了 SingleChildScrollView + reverse: true 方案。\n\n'
                          '当键盘弹出时，页面会自动滚动，确保当前输入的输入框始终可见。\n\n'
                          '点击空白处可以收起键盘。',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),

                // 添加额外的高度，确保最后的输入框也能被滚动到
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
