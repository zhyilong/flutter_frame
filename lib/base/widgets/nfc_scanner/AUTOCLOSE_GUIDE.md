# NFC扫描组件 - 回调执行时机说明

## 自动行为说明

组件已经优化了回调执行时机，**无需任何额外参数**。

### 核心机制

回调会在NFC面板**完全关闭后**（pop操作完成）执行，确保：

1. 面板先关闭（包括关闭动画）
2. pop操作完成
3. 然后才执行回调

这样避免了半透明背景残留问题。

## 使用方式

### 方式1：显示Dialog（推荐）

```dart
NfcScannerWidget.show(
  context: context,
  title: '扫描NFC标签',
  onReadComplete: (result) {
    if (result.success) {
      // ✅ 直接显示dialog，不会有问题
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('读取成功'),
          content: Text('内容: ${result.content}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('确定'),
            ),
          ],
        ),
      );
    }
  },
);
// 流程：
// 1. 读取成功
// 2. 800ms后关闭NFC面板
// 3. 面板pop完成后执行回调
// 4. 显示dialog ✅
```

### 方式2：使用Toast/SnackBar

```dart
NfcScannerWidget.show(
  context: context,
  title: '扫描NFC标签',
  onReadComplete: (result) {
    if (result.success) {
      // ✅ 使用Toast
      Fluttertoast.showToast(
        msg: '读取成功: ${result.content}',
      );
    }
  },
);
// 流程：
// 1. 读取成功
// 2. 800ms后关闭NFC面板
// 3. 面板pop完成后执行回调
// 4. 显示Toast ✅
```

### 方式3：多步骤操作

```dart
NfcScannerWidget.show(
  context: context,
  title: '扫描标签',
  onReadComplete: (result) async {
    if (!result.success) return;

    // ✅ 先显示dialog
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('读取成功'),
        content: Text('内容: ${result.content}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('确定'),
          ),
        ],
      ),
    );

    // ✅ dialog关闭后继续其他操作
    await _processData(result);

    // ✅ 显示结果
    Fluttertoast.showToast(msg: '处理完成');
  },
);
```

## 实际应用示例

### 示例1：显示详细信息dialog

```dart
void _scanNfcTag(BuildContext context) {
  NfcScannerWidget.show(
    context: context,
    title: '扫描标签',
    onReadComplete: (result) {
      if (result.success) {
        _showTagDetailDialog(context, result);
      }
    },
  );
}

void _showTagDetailDialog(BuildContext context, NfcReadResult result) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('标签信息'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('标签ID: ${result.id}'),
          Text('协议: ${result.protocolInfo}'),
          Text('类型: ${result.type}'),
          Text('内容: ${result.content}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('确定'),
        ),
      ],
    ),
  );
}
```

### 示例2：多步骤操作

```dart
void _scanAndProcess(BuildContext context) {
  NfcScannerWidget.show(
    context: context,
    title: '扫描标签',
    onReadComplete: (result) async {
      if (!result.success) return;

      // ✅ 面板已关闭，可以安全地显示多个dialog
      await _showProcessingDialog(context);

      // ✅ 处理数据
      await _processData(result);

      // ✅ 显示结果
      _showResultDialog(context);
    },
  );
}

Future<void> _showProcessingDialog(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('正在处理数据...'),
        ],
      ),
    ),
  );

  // 模拟处理
  await Future.delayed(Duration(seconds: 2));

  if (context.mounted) {
    Navigator.of(context).pop();
  }
}

Future<void> _processData(NfcReadResult result) async {
  // 处理数据逻辑
  await Future.delayed(Duration(seconds: 1));
}

void _showResultDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('处理完成'),
      content: Text('数据处理成功！'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('完成'),
        ),
      ],
    ),
  );
}
```

### 示例3：简单的Toast提示（推荐）

```dart
void _simpleScan(BuildContext context) {
  NfcScannerWidget.show(
    context: context,
    title: '扫描标签',
    onReadComplete: (result) {
      if (result.success) {
        // ✅ 使用Toast，最简单
        Fluttertoast.showToast(
          msg: '✅ 读取成功\n${result.content}',
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    },
  );
}
```

## 关键优势

### ✅ 用户体验更好

1. **无需关心参数**：不需要设置 `autoClose` 参数
2. **代码更简洁**：不需要手动关闭面板
3. **行为一致**：所有场景下行为一致

### ✅ 技术实现更优

1. **时机准确**：回调在面板完全关闭后执行
2. **无副作用**：不会出现半透明背景残留
3. **兼容性好**：对Dialog和Toast都适用

## 最佳实践

### ✅ 推荐

1. **显示Dialog**：直接在回调中显示
   ```dart
   onReadComplete: (result) {
     showDialog(...);  // ✅ 完全没问题
   },
   ```

2. **使用Toast**：直接在回调中显示
   ```dart
   onReadComplete: (result) {
     Fluttertoast.showToast(msg: '成功');  // ✅ 完全没问题
   },
   ```

3. **多步骤操作**：使用 async/await
   ```dart
   onReadComplete: (result) async {
     await showDialog(...);
     await _processData();
     Fluttertoast.showToast(msg: '完成');
   },
   ```

## 总结

- ✅ **无需额外参数**：自动处理所有场景
- ✅ **面板先关闭**：确保关闭动画完成
- ✅ **然后执行回调**：避免UI冲突
- ✅ **支持所有场景**：Dialog、Toast、多步骤操作
- ✅ **代码更简洁**：调用者无需关心关闭逻辑
