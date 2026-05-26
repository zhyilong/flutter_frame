# NFC协议信息简化格式说明

## 格式化规则

### Standard字段映射

| 原始格式 | 简化格式 | 说明 |
|---------|---------|------|
| `ISO 14443-4 (Type A)` | `14443-4A` | Type 4A标签 |
| `ISO 14443-3 (Type A)` | `14443-3A` | Type 3A标签（你的标签） |
| `ISO 14443-4 (Type B)` | `14443-4B` | Type 4B标签 |
| `ISO 14443-3 (Type B)` | `14443-3B` | Type 3B标签 |
| `ISO 15693` | `15693` | 远距离标签 |
| `unknown` | `unknown` | 未知类型 |
| 其他 | 原始值（清理空格） | 保留原始数据 |

### 完整输出格式

```
{standard简化} | {NDEF类型} | {容量}
```

## 实际示例

### 你的标签（492字节Type 2）

**输入数据**：
```json
{
  "standard": "ISO 14443 - 3(Type A)",
  "ndefType": "org.nfcforum.ndef.type2",
  "ndefCapacity": 492
}
```

**输出**：
```
14443-3A | NFC Forum Type 2 | 492B
```

### MIFARE DESFire标签

**输入数据**：
```json
{
  "standard": "ISO 14443-4 (Type A)",
  "ndefType": "org.nfcforum.ndef.type4",
  "ndefCapacity": 8192
}
```

**输出**：
```
14443-4A | NFC Forum Type 4 | 8192B
```

### FeliCa标签

**输入数据**：
```json
{
  "standard": "ISO 18092",
  "ndefType": "org.nfcforum.ndef.type3",
  "ndefCapacity": 2048
}
```

**输出**：
```
ISO18092 | NFC Forum Type 3 | 2048B
```

### ISO 15693标签

**输入数据**：
```json
{
  "standard": "ISO 15693",
  "ndefType": "org.nfcforum.ndef.type2",
  "ndefCapacity": 512
}
```

**输出**：
```
15693 | NFC Forum Type 2 | 512B
```

## 代码使用示例

### 基本使用

```dart
NfcScannerWidget.show(
  context: context,
  title: '扫描NFC标签',
  onReadComplete: (result) {
    print('标签ID: ${result.id}');
    print('协议: ${result.protocolInfo}');
  },
);
```

**输出**：
```
标签ID: 1D87BC0CA70000
协议: 14443-3A | NFC Forum Type 2 | 492B
```

### 解析协议信息

```dart
void _parseProtocolInfo(NfcReadResult result) {
  final parts = result.protocolInfo?.split(' | ') ?? [];

  if (parts.isNotEmpty) {
    final standard = parts[0]; // "14443-3A"
    print('标准: $standard');
  }

  if (parts.length > 1) {
    final type = parts[1]; // "NFC Forum Type 2"
    print('类型: $type');
  }

  if (parts.length > 2) {
    final capacity = parts[2]; // "492B"
    print('容量: $capacity');
  }
}
```

### 根据协议类型判断

```dart
String? _getTagCategory(NfcReadResult result) {
  final protocol = result.protocolInfo ?? '';

  if (protocol.contains('14443-4A')) {
    return '高安全性标签（DESFire/Plus）';
  }

  if (protocol.contains('14443-3A')) {
    return '常用标签（MIFARE Ultralight/NTAG）';
  }

  if (protocol.contains('15693')) {
    return '远距离标签（ISO 15693）';
  }

  return 'NFC标签';
}
```

## 映射规则说明

### 映射优先级

1. **精确匹配优先**：先尝试完全匹配标准化格式
2. **模糊匹配兜底**：如果精确匹配失败，尝试去除空格后匹配
3. **保留原始值**：如果都不匹配，返回清理后的原始值

### 特殊处理

```dart
// 1. 去除空格进行统一处理
final normalized = standard.replaceAll(' ', '').toLowerCase();

// 2. 匹配多种可能的格式
'iso14443-4(typea)'  // 有空格，有括号
'iso14443-4a'        // 无空格，小写
'iso14443-4(Typea)'  // 混合格式

// 3. 都映射到同一结果
// -> "14443-4A"
```

### 未知格式处理

```dart
// 如果不在映射表中
// 去掉 "ISO " 前缀
// 去掉所有空格
// 简化括号格式

// 示例：
// "ISO 18092" -> "ISO18092"
// "ISO 14443 (Type A)" -> "14443(TypeA)"
```

## 日志输出

### 原始日志（调试用）
```
Info of tag: {
    standard: ISO 14443 - 3(Type A),
    ndefType: org.nfcforum.ndef.type2,
    ndefCapacity: 492
}
```

### 简化后（用户显示）
```
Protocol Info: 14443-3A | NFC Forum Type 2 | 492B
```

## 常见协议对比

| 协议 | 简化格式 | 典型应用 |
|-----|---------|---------|
| ISO 14443-3A | 14443-3A | MIFARE Ultralight, NTAG |
| ISO 14443-4A | 14443-4A | MIFARE DESFire, Plus |
| ISO 14443-3B | 14443-3B | 某些Type B标签 |
| ISO 14443-4B | 14443-4B | 某些Type B标签 |
| ISO 15693 | 15693 | 远距离标签 |
| ISO 18092 | ISO18092 | FeliCa（日本） |

## 迁移说明

### 旧格式（详细）
```
ISO 14443 - 3(Type A) - NFC Forum Type 2 (MIFARE Ultralight/NTAG) - 容量: 492字节
```

### 新格式（简洁）✨
```
14443-3A | NFC Forum Type 2 | 492B
```

### 优势

- ✅ 更简洁，易于阅读
- ✅ 减少显示空间占用
- ✅ 便于程序解析
- ✅ 保留关键信息
- ✅ 统一格式规范

## 开发建议

### 1. 显示给用户
```dart
Text('协议: ${result.protocolInfo}')
// 显示: 14443-3A | NFC Forum Type 2 | 492B
```

### 2. 日志记录
```dart
_logger.i('Tag scanned: ${result.id} (${result.protocolInfo})');
// 记录: Tag scanned: 1D87BC0CA70000 (14443-3A | NFC Forum Type 2 | 492B)
```

### 3. 数据存储
```dart
await database.insert({
  'tag_id': result.id,
  'protocol': result.protocolInfo, // 直接存储简化格式
  'scanned_at': DateTime.now(),
});
```

### 4. API传输
```dart
// 简洁格式更适合API
{
  "tagId": "1D87BC0CA70000",
  "protocol": "14443-3A | NFC Forum Type 2 | 492B"
}
```

## 扩展映射

如需添加更多映射规则，在 `_simplifyStandard` 方法的 `mappings` 中添加：

```dart
final mappings = {
  // 现有映射...

  // 新增映射示例
  'iso18092': 'ISO18092',           // FeliCa
  'iso15693-2': '15693-2',          // ISO 15693-2
  'iso15693-3': '15693-3',          // ISO 15693-3
  'iso14443-2': '14443-2',          // ISO 14443-2
};
```

## 总结

- ✅ 简化格式更实用
- ✅ 保留所有关键信息
- ✅ 易于解析和显示
- ✅ 支持未知格式回退
- ✅ 适合生产环境使用

**你的标签输出**: `14443-3A | NFC Forum Type 2 | 492B`
