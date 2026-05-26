# NfcReadResult - 标签ID和协议信息使用指南

## 新增字段

`NfcReadResult` 现在包含两个新字段：

```dart
class NfcReadResult {
  final String? id;            // 标签ID（例如：04:A3:5B:B2:C1:D0）
  final String? protocolInfo;  // 协议信息（例如：ISO 14443-4A, ISO 15693等）

  // ... 其他字段
}
```

## 字段说明

### id - 标签ID
- **类型**: `String?`
- **说明**: NFC标签的唯一标识符
- **格式**: 通常是十六进制字符串，用冒号分隔
- **示例**:
  - `04:A3:5B:B2:C1:D0` (MIFARE Ultralight/NFC Forum Type 2)
  - `04:A3:5B:B2:C1:D0:80` (MIFARE Classic)
  - `01:02:03:04:05:06:07:08` (ISO 15693标签)

### protocolInfo - 协议信息
- **类型**: `String?`
- **说明**: NFC标签使用的通信协议
- **常见值**:
  - `ISO 14443-4A` - Type 4A标签（如NXP DESFire）
  - `ISO 14443-4B` - Type 4B标签
  - `ISO 15693` - 远距离NFC标签（ Vicinity Card）
  - `ISO 18092` - NFCIP-1协议（P2P模式）
  - `NfcA` - NFC Type A (MIFARE Classic, Ultralight等)
  - `NfcB` - NFC Type B
  - `NfcF` - NFC Type F (FeliCa)
  - `NfcV` - NFC Type V (ISO 15693)

## 使用示例

### 1. 基本用法

```dart
NfcScannerWidget.show(
  context: context,
  title: '扫描NFC标签',
  onReadComplete: (result) {
    if (result.success) {
      print('标签ID: ${result.id}');
      print('协议信息: ${result.protocolInfo}');
      print('数据内容: ${result.content}');
    }
  },
);
```

### 2. 标签白名单验证

```dart
// 允许的标签ID列表
final allowedTagIds = [
  '04:A3:5B:B2:C1:D0',
  '04:12:34:56:78:90',
];

NfcScannerWidget.show(
  context: context,
  title: '员工卡扫描',
  onReadComplete: (result) {
    if (!result.success) return;

    // 检查标签ID是否在白名单中
    if (result.id != null && allowedTagIds.contains(result.id)) {
      // 验证通过
      _processEmployeeCard(result);
    } else {
      // 验证失败
      _showUnauthorizedDialog();
    }
  },
);
```

### 3. 标签类型识别

```dart
NfcScannerWidget.show(
  context: context,
  title: '标签识别',
  onReadComplete: (result) {
    if (!result.success) return;

    final tagType = _identifyTagType(result.protocolInfo);
    final tagId = result.id ?? 'Unknown';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('检测到 $tagType 标签\nID: $tagId'),
        duration: Duration(seconds: 3),
      ),
    );
  },
);

String _identifyTagType(String? protocolInfo) {
  if (protocolInfo == null) return '未知类型';

  switch (protocolInfo.toUpperCase()) {
    case 'ISO 14443-4A':
    case 'NFCA':
      return 'Type A (MIFARE)';
    case 'ISO 14443-4B':
    case 'NFCB':
      return 'Type B';
    case 'ISO 15693':
    case 'NFCV':
      return 'ISO 15693';
    case 'NFCF':
      return 'Type F (FeliCa)';
    default:
      return protocolInfo;
  }
}
```

### 4. 标签去重（防止重复读取）

```dart
class NfcScannerPage extends StatefulWidget {
  @override
  _NfcScannerPageState createState() => _NfcScannerPageState();
}

class _NfcScannerPageState extends State<NfcScannerPage> {
  String? _lastScannedTagId;
  DateTime? _lastScanTime;

  void _handleNfcScan(NfcReadResult result) {
    if (!result.success || result.id == null) return;

    // 检查是否在2秒内扫描了同一标签
    if (_lastScannedTagId == result.id &&
        _lastScanTime != null &&
        DateTime.now().difference(_lastScanTime!) < Duration(seconds: 2)) {
      // 忽略重复扫描
      return;
    }

    // 记录扫描信息
    _lastScannedTagId = result.id;
    _lastScanTime = DateTime.now();

    // 处理新的扫描
    _processNewTag(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            NfcScannerWidget.show(
              context: context,
              onReadComplete: _handleNfcScan,
            );
          },
          child: Text('扫描NFC标签'),
        ),
      ),
    );
  }
}
```

### 5. 标签数据库记录

```dart
class NfcTagDatabase {
  // 记录扫描的标签信息
  static Future<void> recordTagScan(NfcReadResult result) async {
    final tagData = {
      'id': result.id,
      'protocol': result.protocolInfo,
      'type': result.type.toString(),
      'content': result.content,
      'jsonData': result.jsonData,
      'scannedAt': DateTime.now().toIso8601String(),
    };

    // 保存到本地数据库或发送到服务器
    await _saveToDatabase(tagData);
  }

  // 查询标签历史
  static Future<List<Map<String, dynamic>>> getTagHistory(String tagId) async {
    // 从数据库查询该标签的历史记录
    return await _queryDatabase(tagId);
  }
}

// 使用
NfcScannerWidget.show(
  context: context,
  title: '扫描标签',
  onReadComplete: (result) async {
    if (result.success) {
      // 记录到数据库
      await NfcTagDatabase.recordTagScan(result);

      // 显示历史记录
      final history = await NfcTagDatabase.getTagHistory(result.id!);
      _showTagHistory(history);
    }
  },
);
```

### 6. 多标签识别系统

```dart
class TagRecognizer {
  // 定义不同标签的用途
  static const Map<String, String> tagPurposes = {
    '04:A3:5B:B2:C1:D0': '会议室门禁',
    '04:12:34:56:78:90': '考勤打卡',
    '04:AA:BB:CC:DD:EE': '资产追踪',
  };

  // 定义支持的协议
  static const List<String> supportedProtocols = [
    'ISO 14443-4A',
    'ISO 14443-4B',
    'ISO 15693',
  ];

  static String? getPurpose(String? tagId) {
    if (tagId == null) return null;
    return tagPurposes[tagId];
  }

  static bool isSupportedProtocol(String? protocol) {
    if (protocol == null) return false;
    return supportedProtocols.any((p) => protocol.contains(p));
  }
}

// 使用
NfcScannerWidget.show(
  context: context,
  title: '多标签识别',
  onReadComplete: (result) {
    if (!result.success) return;

    // 检查标签用途
    final purpose = TagRecognizer.getPurpose(result.id);
    if (purpose != null) {
      _executeAction(purpose, result);
      return;
    }

    // 检查协议支持
    if (!TagRecognizer.isSupportedProtocol(result.protocolInfo)) {
      _showUnsupportedDialog();
      return;
    }

    // 未知标签
    _showUnknownTagDialog(result);
  },
);
```

## 错误处理

### 检查字段是否存在

```dart
NfcScannerWidget.show(
  context: context,
  onReadComplete: (result) {
    if (!result.success) return;

    // 安全地访问id和protocolInfo
    final tagId = result.id ?? '未知ID';
    final protocol = result.protocolInfo ?? '未知协议';

    print('扫描到标签: $tagId ($protocol)');
  },
);
```

### 空标签处理

```dart
NfcScannerWidget.show(
  context: context,
  onReadComplete: (result) {
    if (!result.success) {
      // 处理错误
      return;
    }

    if (result.isEmptyTag) {
      // 空标签，但仍可以获取ID和协议信息
      print('空标签: ID=${result.id}, Protocol=${result.protocolInfo}');
      _showEmptyTagPrompt(result);
      return;
    }

    // 有数据的标签
    _processTagData(result);
  },
);
```

## 完整示例：NFC标签管理系统

```dart
import 'package:flutter/material.dart';
import 'package:mvvm_demo/base/widgets/nfc_scanner/nfc_scanner_widget.dart';
import 'package:mvvm_demo/base/widgets/nfc_scanner/nfc_helper.dart';

class NfcTagManager extends StatefulWidget {
  @override
  _NfcTagManagerState createState() => _NfcTagManagerState();
}

class _NfcTagManagerState extends State<NfcTagManager> {
  List<Map<String, dynamic>> _scannedTags = [];

  void _scanTag() {
    NfcScannerWidget.show(
      context: context,
      title: '扫描NFC标签',
      scanningHint: '请将标签靠近手机',
      onReadComplete: (result) {
        if (!result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('扫描失败: ${result.error?.message}')),
          );
          return;
        }

        // 添加到扫描记录
        setState(() {
          _scannedTags.add({
            'id': result.id ?? '未知',
            'protocol': result.protocolInfo ?? '未知',
            'type': result.type.toString(),
            'content': result.content ?? '空',
            'time': DateTime.now(),
          });
        });

        // 显示详细信息
        _showTagDetailDialog(result);
      },
    );
  }

  void _showTagDetailDialog(NfcReadResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('标签信息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('标签ID', result.id ?? '未知'),
            SizedBox(height: 8),
            _buildInfoRow('协议', result.protocolInfo ?? '未知'),
            SizedBox(height: 8),
            _buildInfoRow('类型', result.type.toString()),
            SizedBox(height: 8),
            if (result.isEmptyTag)
              Text('状态: 空标签', style: TextStyle(color: Colors.orange))
            else
              _buildInfoRow('内容', result.content ?? 'N/A'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC标签管理'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                _scannedTags.clear();
              });
            },
            tooltip: '清空记录',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_scannedTags.isEmpty)
            Expanded(
              child: Center(
                child: Text('暂无扫描记录\n点击下方按钮扫描标签'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _scannedTags.length,
                itemBuilder: (context, index) {
                  final tag = _scannedTags[index];
                  return ListTile(
                    leading: Icon(Icons.nfc),
                    title: Text(tag['id']),
                    subtitle: Text('${tag['protocol']} - ${tag['type']}'),
                    trailing: Text(
                      DateFormat('HH:mm:ss').format(tag['time']),
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanTag,
        child: Icon(Icons.nfc),
        tooltip: '扫描标签',
      ),
    );
  }
}
```

## 字段获取时机

| 场景 | id | protocolInfo | 说明 |
|------|-----|--------------|------|
| 成功读取文本 | ✅ | ✅ | 完整信息 |
| 成功读取JSON | ✅ | ✅ | 完整信息 |
| 成功读取URL | ✅ | ✅ | 完整信息 |
| 空标签 | ✅ | ✅ | 标签存在但无数据 |
| 读取失败 | ❌ | ❌ | 错误时无法获取 |
| NFC不可用 | ❌ | ❌ | 无法读取标签 |

## 最佳实践

1. **始终检查null**: `id` 和 `protocolInfo` 可能为null
2. **使用标签ID去重**: 避免重复处理同一标签
3. **记录协议信息**: 有助于调试和标签识别
4. **验证标签类型**: 根据协议信息选择合适的处理方式
5. **错误处理**: 在字段为null时提供默认值

## 注意事项

- **iOS限制**: iOS上`protocolInfo`可能不如Android详细
- **标签兼容性**: 不同类型标签返回的ID格式可能不同
- **隐私保护**: 标签ID可能包含敏感信息，需谨慎处理
- **大小写敏感**: ID和协议信息的字符串可能包含大写字母

## 更新日志

### v1.2.0 (2024-05-19)
- ✨ 新增 `id` 字段 - 标签唯一标识符
- ✨ 新增 `protocolInfo` 字段 - 通信协议信息
- 📝 完善文档和使用示例
- 🐛 修复空标签时信息丢失的问题
