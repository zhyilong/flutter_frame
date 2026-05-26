# NFC Forum Type 类型说明

## 官方NFC Forum规范

NFC Forum（NFC标准化组织）定义了4种NFC标签类型（NFC Forum Tag Types）：

### Type 1 - NFC Forum Type 1 Tag
- **官方名称**: NFC Forum Type 1 Tag
- **典型芯片**: Topaz ( Innovision/Jewel)
- **NDEF类型标识**: `org.nfcforum.ndef.type1`
- **特点**:
  - 96字节内存，可扩展到2KB
  - 读写速度快
  - 不支持加密
  - 已基本淘汰

### Type 2 - NFC Forum Type 2 Tag
- **官方名称**: NFC Forum Type 2 Tag
- **典型芯片**:
  - MIFARE Ultralight (EV1/EV0)
  - NTAG 213/215/216 (NXP)
  - Fudan FM11xx系列
- **NDEF类型标识**: `org.nfcforum.ndef.type2`
- **特点**:
  - 48字节到8KB内存
  - 支持只读锁定位
  - 不支持原生加密（但可应用层加密）
  - **最常用的标签类型**
  - 成本低，应用广泛

### Type 3 - NFC Forum Type 3 Tag
- **官方名称**: NFC Forum Type 3 Tag
- **典型芯片**: FeliCa (Sony)
- **NDEF类型标识**: `org.nfcforum.ndef.type3`
- **特点**:
  - 2KB内存（可扩展）
  - 支持加密服务
  - 在日本广泛应用（Suica、Pasmo等交通卡）
  - 读写速度快

### Type 4 - NFC Forum Type 4 Tag
- **官方名称**: NFC Forum Type 4 Tag
- **典型芯片**:
  - MIFARE DESFire (EV1/EV2/EV3)
  - MIFARE Plus
  - ST25DV系列
- **NDEF类型标识**: `org.nfcforum.ndef.type4`
- **特点**:
  - 4KB以上内存
  - 支持ISO-DEP协议
  - 支持复杂加密
  - 通常符合ISO 14443-4标准
  - 适合高安全性应用

## ⚠️ 原映射的不准确之处

### 问题1: Type 2 ≠ MIFARE Ultralight
原映射：`'org.nfcforum.ndef.type2': 'NFC Forum Type 2 (MIFARE Ultralight)'`

**不准确！** Type 2不只是MIFARE Ultralight，还包括：
- NTAG 213/215/216
- Fudan FM11xx
- 其他兼容Type 2规范的芯片

**更准确的描述**：
```dart
'org.nfcforum.ndef.type2': 'NFC Forum Type 2'
// 或
'org.nfcforum.ndef.type2': 'NFC Forum Type 2 (兼容MIFARE Ultralight/NTAG)'
```

### 问题2: Type 4 ≠ ISO 14443-4
原映射：`'org.nfcforum.ndef.type4': 'NFC Forum Type 4 (ISO 14443-4)'`

**不完整！** Type 4标签确实基于ISO 14443-4，但：
- ISO 14443-4是协议层
- Type 4是NFC Forum的应用层规范
- 并非所有ISO 14443-4标签都是Type 4

## 更准确的映射方案

### 方案1: 保守方案（推荐）

```dart
final ndefTypeMap = {
  'org.nfcforum.ndef.type1': 'NFC Forum Type 1',
  'org.nfcforum.ndef.type2': 'NFC Forum Type 2',
  'org.nfcforum.ndef.type3': 'NFC Forum Type 3',
  'org.nfcforum.ndef.type4': 'NFC Forum Type 4',
};
```

### 方案2: 详细方案（添加常见芯片信息）

```dart
final ndefTypeMap = {
  'org.nfcforum.ndef.type1': 'NFC Forum Type 1 (Topaz/Jewel)',
  'org.nfcforum.ndef.type2': 'NFC Forum Type 2 (MIFARE Ultralight/NTAG)',
  'org.nfcforum.ndef.type3': 'NFC Forum Type 3 (FeliCa)',
  'org.nfcforum.ndef.type4': 'NFC Forum Type 4 (DESFire/Plus)',
};
```

### 方案3: 分层信息（最准确）

```dart
String _getNdefTypeName(String ndefType) {
  final typeInfo = {
    'org.nfcforum.ndef.type1': {
      'name': 'NFC Forum Type 1',
      'chips': ['Topaz', 'Jewel'],
      'memory': '96B-2KB',
      'features': '低成本，已淘汰',
    },
    'org.nfcforum.ndef.type2': {
      'name': 'NFC Forum Type 2',
      'chips': ['MIFARE Ultralight', 'NTAG 213/215/216', 'Fudan FM11xx'],
      'memory': '48B-8KB',
      'features': '最常用，成本低',
    },
    'org.nfcforum.ndef.type3': {
      'name': 'NFC Forum Type 3',
      'chips': ['FeliCa'],
      'memory': '2KB+',
      'features': '支持加密，日本常用',
    },
    'org.nfcforum.ndef.type4': {
      'name': 'NFC Forum Type 4',
      'chips': ['MIFARE DESFire', 'MIFARE Plus', 'ST25DV'],
      'memory': '4KB+',
      'features': '高安全性，ISO 14443-4',
    },
  };

  return typeInfo[ndefType]?['name'];
}
```

## 特殊情况说明

### MIFARE Classic
- **注意**: MIFARE Classic **不是**标准的NFC Forum Type
- 它有自己专有格式，不符合NDEF标准
- 但可以通过特殊的NDEF包装器使用
- 在实际应用中常被识别为Type 2（但不完全兼容）

### 识别方式
```dart
// 通过mifareInfo字段判断
if (pollResult.mifareInfo != null) {
  // 这是MIFARE Classic
  return 'MIFARE Classic (专有格式)';
}
```

## 根据实际数据优化

根据你提供的实际数据：
```json
{
  "ndefType": "org.nfcforum.ndef.type2",
  "standard": "ISO 14443 - 3(Type A)",
  "ndefCapacity": 492
}
```

492字节的Type 2标签很可能是：
- **MIFARE Ultralight EV1** (有48/128/256/512字节版本)
- **NTAG 216** (888字节)
- 或者是自定义容量的标签

## 建议的最佳实践

```dart
/// 根据NDEF类型返回友好的标签名称
static String? _getNdefTypeName(String ndefType) {
  // 基础映射（符合NFC Forum规范）
  final typeMap = {
    'org.nfcforum.ndef.type1': 'NFC Forum Type 1 (Topaz)',
    'org.nfcforum.ndef.type2': 'NFC Forum Type 2 (MIFARE Ultralight/NTAG)',
    'org.nfcforum.ndef.type3': 'NFC Forum Type 3 (FeliCa)',
    'org.nfcforum.ndef.type4': 'NFC Forum Type 4 (DESFire/ISO 14443-4)',
  };

  // 精确匹配
  if (typeMap.containsKey(ndefType)) {
    return typeMap[ndefType];
  }

  // 模糊匹配
  for (var entry in typeMap.entries) {
    if (ndefType.toLowerCase().contains(entry.key.toLowerCase())) {
      return entry.value;
    }
  }

  return null;
}

/// 获取详细的芯片信息（可选）
static String _getDetailedChipInfo(dynamic pollResult) {
  final ndefType = pollResult.ndefType?.toString() ?? '';
  final standard = pollResult.standard?.toString() ?? '';
  final capacity = pollResult.ndefCapacity ?? 0;

  // Type 2 + 492字节 → 可能是MIFARE Ultralight EV1 512字节版本
  if (ndefType.contains('type2') && capacity >= 480 && capacity <= 520) {
    return '可能是 MIFARE Ultralight EV1 (512字节)';
  }

  // Type 2 + 小容量 → 可能是标准MIFARE Ultralight
  if (ndefType.contains('type2') && capacity <= 64) {
    return '可能是 MIFARE Ultralight (48/64字节)';
  }

  // Type 2 + 大容量 → 可能是NTAG系列
  if (ndefType.contains('type2') && capacity >= 800) {
    return '可能是 NTAG 216或兼容芯片';
  }

  // Type 3 → FeliCa
  if (ndefType.contains('type3')) {
    return 'FeliCa系列';
  }

  // Type 4 → DESFire/Plus
  if (ndefType.contains('type4')) {
    return '可能是 MIFARE DESFire或Plus系列';
  }

  return 'NFC标签';
}
```

## 总结

1. **原映射基本正确**，但描述不够准确
2. **Type 2** 不只等于MIFARE Ultralight，还包括NTAG等
3. **Type 4** 不只等于ISO 14443-4，是更上层的应用规范
4. 建议使用**保守方案**或**添加更多芯片信息**的详细方案
5. 对于生产环境，建议只显示NFC Forum Type，不猜测具体芯片型号

## 参考资料

- NFC Forum Type 1 Specification: https://nfctype1.com/
- NFC Forum Type 2 Specification: https://nfctype2.com/
- NFC Forum Type 3 Specification: https://nfctype3.com/
- NFC Forum Type 4 Specification: https://nfctype4.com/
- MIFARE Family: https://www.nxp.com/products/rfid-nfc/
