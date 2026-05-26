/*
 * Created by zhyilong on 2026/5/19
 * NFC读写功能类 - 纯Dart实现
 */

import 'dart:async';
import 'dart:convert';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;
import 'package:logger/logger.dart';

/// NFC数据类型枚举
enum NfcDataType { text, url, json, unknown }

/// NFC错误类型枚举
enum NfcErrorType {
  // 权限相关
  nfcNotAvailable,
  nfcDisabled,
  permissionDenied,

  // 操作相关
  readFailed,
  writeFailed,
  tagLost,
  operationTimeout,
  maxRetriesExceeded,

  // 数据相关
  invalidDataFormat,
  dataTooLarge,
  tagTooSmall,

  // 其他
  unknownError,
}

/// NFC错误类
class NfcError {
  final NfcErrorType type;
  final String message;
  final String? technicalDetails;
  final dynamic originalException;

  NfcError({required this.type, required this.message, this.technicalDetails, this.originalException});

  factory NfcError.nfcNotAvailable() {
    return NfcError(type: NfcErrorType.nfcNotAvailable, message: '设备不支持NFC功能', technicalDetails: 'Device does not support NFC');
  }

  factory NfcError.nfcDisabled() {
    return NfcError(type: NfcErrorType.nfcDisabled, message: '请在系统设置中开启NFC功能', technicalDetails: 'NFC is disabled in system settings');
  }

  factory NfcError.permissionDenied() {
    return NfcError(type: NfcErrorType.permissionDenied, message: 'NFC权限未授予，请在设置中允许', technicalDetails: 'NFC permission denied');
  }

  factory NfcError.readFailed(String details) {
    return NfcError(type: NfcErrorType.readFailed, message: '读取NFC标签失败', technicalDetails: details);
  }

  factory NfcError.writeFailed(String details) {
    return NfcError(type: NfcErrorType.writeFailed, message: '写入NFC标签失败', technicalDetails: details);
  }

  factory NfcError.tagLost() {
    return NfcError(type: NfcErrorType.tagLost, message: 'NFC标签已移开，请重新靠近', technicalDetails: 'Tag lost during operation');
  }

  factory NfcError.operationTimeout() {
    return NfcError(type: NfcErrorType.operationTimeout, message: '操作超时，请重试', technicalDetails: 'NFC operation timeout');
  }

  factory NfcError.maxRetriesExceeded(int retries) {
    return NfcError(type: NfcErrorType.maxRetriesExceeded, message: '读取失败，已重试$retries次', technicalDetails: 'Maximum retries ($retries) exceeded');
  }

  factory NfcError.invalidDataFormat(String details) {
    return NfcError(type: NfcErrorType.invalidDataFormat, message: '数据格式无效: $details', technicalDetails: details);
  }

  factory NfcError.dataTooLarge(int size, int maxSize) {
    return NfcError(
      type: NfcErrorType.dataTooLarge,
      message: '数据太大（${size}字节），超出NFC标签容量（最大${maxSize}字节）',
      technicalDetails: 'Data size ($size bytes) exceeds max NDEF size ($maxSize bytes)',
    );
  }

  factory NfcError.tagTooSmall(int requiredSize) {
    return NfcError(
      type: NfcErrorType.tagTooSmall,
      message: 'NFC标签容量不足，需要至少${requiredSize}字节',
      technicalDetails: 'Tag capacity too small, requires at least $requiredSize bytes',
    );
  }

  factory NfcError.unknownError(String details, {dynamic exception}) {
    return NfcError(type: NfcErrorType.unknownError, message: '未知错误: $details', technicalDetails: details, originalException: exception);
  }

  @override
  String toString() {
    return 'NfcError(type: $type, message: $message, technicalDetails: $technicalDetails)';
  }
}

/// NFC读取结果
class NfcReadResult {
  final NfcDataType type;
  final String? content;
  final Map<String, dynamic>? jsonData;
  final NfcError? error;
  final bool isEmptyTag;

  // NFC标签信息
  final String? id; // 标签ID（例如：04:A3:5B:B2:C1:D0）
  final String? protocolInfo; // 协议信息（例如：ISO 14443-4A, ISO 15693等）

  NfcReadResult({
    required this.type,
    this.content,
    this.jsonData,
    this.error,
    this.isEmptyTag = false,
    this.id,
    this.protocolInfo,
  });

  bool get hasError => error != null;
  bool get success => error == null;

  factory NfcReadResult.text(
    String content, {
    String? id,
    String? protocolInfo,
  }) {
    return NfcReadResult(
      type: NfcDataType.text,
      content: content,
      id: id,
      protocolInfo: protocolInfo,
    );
  }

  factory NfcReadResult.url(
    String url, {
    String? id,
    String? protocolInfo,
  }) {
    return NfcReadResult(
      type: NfcDataType.url,
      content: url,
      id: id,
      protocolInfo: protocolInfo,
    );
  }

  factory NfcReadResult.json(
    Map<String, dynamic> data, {
    String? id,
    String? protocolInfo,
  }) {
    return NfcReadResult(
      type: NfcDataType.json,
      jsonData: data,
      id: id,
      protocolInfo: protocolInfo,
    );
  }

  factory NfcReadResult.emptyTag({
    String? tagId,
    String? protocolInfo,
  }) {
    return NfcReadResult(
      type: NfcDataType.unknown,
      isEmptyTag: true,
      id: tagId,
      protocolInfo: protocolInfo,
    );
  }

  factory NfcReadResult.failure(NfcError error) {
    return NfcReadResult(
      type: NfcDataType.unknown,
      error: error,
    );
  }

  @override
  String toString() {
    return 'NfcReadResult(type: $type, content: $content, jsonData: $jsonData, error: $error, id: $id, protocolInfo: $protocolInfo)';
  }
}

/// NFC操作结果
class NfcResult {
  final bool success;
  final NfcError? error;

  const NfcResult({required this.success, this.error});

  factory NfcResult.success() {
    return const NfcResult(success: true);
  }

  factory NfcResult.failure(NfcError error) {
    return NfcResult(success: false, error: error);
  }

  @override
  String toString() {
    return 'NfcResult(success: $success, error: $error)';
  }
}

/// NFC功能辅助类
class NfcHelper {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, errorMethodCount: 5, lineLength: 80, colors: true, printEmojis: true, printTime: true, noBoxingByDefault: false),
    level: Level.debug,
  );

  /// 标准NFC标签NDEF记录最大容量（字节）
  /// 大多数NFC标签支持至少137字节，有些可达2KB
  static const int standardNdefMaxSize = 137; // 保守值
  static const int largeNdefMaxSize = 2048; // 大容量标签

  /// 检查NFC是否可用
  static Future<bool> isNfcAvailable() async {
    try {
      final availability = await FlutterNfcKit.nfcAvailability;
      _logger.d('NFC availability: $availability');
      return availability == NFCAvailability.available;
    } catch (e) {
      _logger.e('Failed to check NFC availability', error: e);
      return false;
    }
  }

  /// 简化standard字段为简短格式
  /// 映射规则：
  /// "ISO 14443-4 (Type A)" -> "14443-4A"
  /// "ISO 14443-3 (Type A)" -> "14443-3A"
  /// "ISO 14443-4 (Type B)" -> "14443-4B"
  /// "ISO 14443-3 (Type B)" -> "14443-3B"
  /// "ISO 15693" -> "15693"
  static String _simplifyStandard(String standard) {
    // 去除空格，统一处理
    final normalized = standard.replaceAll(' ', '').toLowerCase();

    // 映射规则
    final mappings = {
      // ISO 14443-4系列
      'iso14443-4(typea)': '14443-4A',
      'iso14443-4(typeb)': '14443-4B',
      'iso14443-4a': '14443-4A',
      'iso14443-4b': '14443-4B',

      // ISO 14443-3系列
      'iso14443-3(typea)': '14443-3A',
      'iso14443-3(typeb)': '14443-3B',
      'iso14443-3a': '14443-3A',
      'iso14443-3b': '14443-3B',

      // ISO 15693
      'iso15693': '15693',

      // Unknown
      'unknown': 'unknown',
    };

    // 尝试精确匹配
    if (mappings.containsKey(normalized)) {
      return mappings[normalized]!;
    }

    // 如果映射关系不存在，返回原始数据（但做基本清理）
    // 去掉 "ISO " 前缀，简化括号格式
    var result = standard;
    if (result.startsWith('ISO ')) {
      result = result.substring(4);
    }
    // 去掉空格
    result = result.replaceAll(' ', '');
    // 替换 "(Type " 为小写括号
    result = result.replaceAll('(Type', '(');
    // 替换 ")" 为空或保留
    // 最终简化

    return result.isEmpty ? standard : result;
  }

  /// 验证JSON数据大小
  /// 返回：是否可以在标准标签上存储
  static bool validateJsonSize(Map<String, dynamic> json, {int maxSize = standardNdefMaxSize}) {
    try {
      final jsonString = jsonEncode(json);
      final byteSize = utf8.encode(jsonString).length;
      _logger.d('JSON size: $byteSize bytes, max: $maxSize bytes');
      return byteSize <= maxSize;
    } catch (e) {
      _logger.e('Failed to validate JSON size', error: e);
      return false;
    }
  }

  /// 获取JSON数据的字节大小
  static int getJsonSize(Map<String, dynamic> json) {
    try {
      final jsonString = jsonEncode(json);
      return utf8.encode(jsonString).length;
    } catch (e) {
      _logger.e('Failed to calculate JSON size', error: e);
      return -1;
    }
  }

  /// 解析NDEF记录为可读数据
  static NfcReadResult _parseNdefRecord(
    ndef.NDEFRecord record, {
    String? id,
    String? protocolInfo,
  }) {
    try {
      _logger.d('Parsing NDEF record: ${record.toString()}');

      // 判断记录类型
      if (record is ndef.UriRecord) {
        final uri = record.uri.toString();
        _logger.d('Parsed as URI: $uri');
        return NfcReadResult.url(uri, id: id, protocolInfo: protocolInfo);
      }

      if (record is ndef.TextRecord) {
        final text = record.text ?? '';
        _logger.d('Parsed as text: $text');
        return NfcReadResult.text(text, id: id, protocolInfo: protocolInfo);
      }

      if (record is ndef.MimeRecord) {
        try {
          if (record.payload != null) {
            final dataString = String.fromCharCodes(record.payload!);
            final jsonData = jsonDecode(dataString) as Map<String, dynamic>;
            _logger.d('Parsed as JSON from MIME: $jsonData');
            return NfcReadResult.json(jsonData, id: id, protocolInfo: protocolInfo);
          }
        } catch (e) {
          if (record.payload != null) {
            final text = String.fromCharCodes(record.payload!);
            _logger.d('MIME record as text: $text');
            return NfcReadResult.text(text, id: id, protocolInfo: protocolInfo);
          }
        }
      }

      // 尝试解析为通用数据
      try {
        if (record.payload != null) {
          final dataString = String.fromCharCodes(record.payload!);
          final jsonData = jsonDecode(dataString) as Map<String, dynamic>;
          _logger.d('Parsed as JSON: $jsonData');
          return NfcReadResult.json(jsonData, id: id, protocolInfo: protocolInfo);
        }
      } catch (e) {
        // 作为普通文本返回
        if (record.payload != null) {
          final text = String.fromCharCodes(record.payload!);
          _logger.d('Parsed as text: $text');
          return NfcReadResult.text(text, id: id, protocolInfo: protocolInfo);
        }
      }

      // 默认返回空文本
      return NfcReadResult.text('', id: id, protocolInfo: protocolInfo);
    } catch (e) {
      _logger.e('Failed to parse NDEF record', error: e);
      return NfcReadResult.failure(NfcError.invalidDataFormat('无法解析NFC数据: ${e.toString()}'));
    }
  }

  /// 读取NFC标签
  /// [timeout] 超时时间，默认15秒
  /// [maxRetries] 最大重试次数，默认3次
  static Future<NfcReadResult> read({Duration timeout = const Duration(seconds: 15), int maxRetries = 3}) async {
    _logger.i('Starting NFC read, maxRetries: $maxRetries, timeout: ${timeout.inSeconds}s');

    // 检查NFC可用性
    final available = await isNfcAvailable();
    if (!available) {
      final availability = await FlutterNfcKit.nfcAvailability;
      if (availability == NFCAvailability.disabled) {
        return NfcReadResult.failure(NfcError.nfcDisabled());
      }
      return NfcReadResult.failure(NfcError.nfcNotAvailable());
    }

    // 尝试读取，带重试机制
    NfcError? lastError;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        _logger.d('Read attempt $attempt/$maxRetries');

        // 轮询NFC标签
        final pollResult = await FlutterNfcKit.poll(timeout: timeout, iosAlertMessage: "请将手机靠近NFC标签");

        _logger.d('Info of tag: ${pollResult.toJson()}');
        _logger.d('Polled tag: ${pollResult.type}');
        _logger.d('Tag ID: ${pollResult.id}');

        // 获取并简化协议信息
        final protocolInfo = _simplifyStandard(pollResult.standard.toString());
        _logger.d('Protocol Info: $protocolInfo');

        // 读取NDEF数据
        if (pollResult.ndefAvailable != true) {
          _logger.w('NDEF not available on this tag');
          await FlutterNfcKit.finish(iosAlertMessage: "读取完成");
          return NfcReadResult.failure(NfcError.readFailed('此NFC标签不支持NDEF格式或未格式化'));
        }

        _logger.d('NDEF available: ${pollResult.ndefAvailable}');
        _logger.d('NDEF writable: ${pollResult.ndefWritable}');

        // 先快速尝试读取NDEF记录，检查是否有数据
        final ndefRecords = await FlutterNfcKit.readNDEFRecords(cached: false);
        _logger.d('NDEF records count: ${ndefRecords.length}');

        // 如果标签为空，返回空标签状态（不是错误）
        if (ndefRecords.isEmpty) {
          _logger.i('Tag is empty - returning empty tag status');
          await FlutterNfcKit.finish(iosAlertMessage: "读取完成");

          // 空标签不是错误，而是正常状态
          return NfcReadResult.emptyTag(
            tagId: pollResult.id,
            protocolInfo: protocolInfo,
          );
        }

        // 解析第一个NDEF记录，传递标签ID和协议信息
        final result = _parseNdefRecord(
          ndefRecords.first,
          id: pollResult.id,
          protocolInfo: protocolInfo,
        );

        // 完成后结束NFC会话
        await FlutterNfcKit.finish(iosAlertMessage: "读取成功");

        _logger.i('NFC read successful: $result');
        return result;
      } catch (e) {
        _logger.e('Read attempt $attempt failed', error: e);
        lastError = _handleReadException(e, attempt);

        // 最后一次尝试失败，返回错误
        if (attempt >= maxRetries) {
          await FlutterNfcKit.finish(iosAlertMessage: "读取失败");
          return NfcReadResult.failure(lastError);
        }

        // 等待一小段时间后重试
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    // 理论上不会到这里，但为了类型安全
    return NfcReadResult.failure(lastError ?? NfcError.unknownError('Unknown read error'));
  }

  /// 写入文本数据到NFC标签
  /// [text] 要写入的文本内容
  /// [timeout] 超时时间
  /// [language] 语言代码，默认'en'（英文），中文使用'zh'
  static Future<NfcResult> writeText(String text, {Duration timeout = const Duration(seconds: 15), String language = 'en'}) async {
    _logger.i('Starting NFC write text, length: ${text.length}, language: $language');

    // 验证数据大小
    final textSize = utf8.encode(text).length;
    if (textSize > largeNdefMaxSize) {
      return NfcResult.failure(NfcError.dataTooLarge(textSize, largeNdefMaxSize));
    }

    try {
      // 使用ndef包编码NDEF记录，必须指定language参数
      final record = ndef.TextRecord(text: text, language: language);
      _logger.d('Created TextRecord: text=$text, language=$language');

      return _writeNdefRecords([record], timeout: timeout);
    } catch (e) {
      _logger.e('Failed to create TextRecord', error: e);
      return NfcResult.failure(NfcError.invalidDataFormat('创建文本记录失败: ${e.toString()}'));
    }
  }

  /// 写入URL数据到NFC标签
  /// [url] 要写入的URL
  /// [timeout] 超时时间
  static Future<NfcResult> writeUrl(String url, {Duration timeout = const Duration(seconds: 15)}) async {
    _logger.i('Starting NFC write URL: $url');

    // 验证数据大小
    final urlSize = utf8.encode(url).length;
    if (urlSize > largeNdefMaxSize) {
      return NfcResult.failure(NfcError.dataTooLarge(urlSize, largeNdefMaxSize));
    }

    try {
      final record = ndef.UriRecord.fromString(url);
      _logger.d('Created UriRecord: $url');
      return _writeNdefRecords([record], timeout: timeout);
    } catch (e) {
      _logger.e('Failed to create UriRecord, trying with payload', error: e);

      // 尝试手动构建
      try {
        final urlBytes = utf8.encode(url);
        final uri = Uri.parse(url);
        final record = ndef.UriRecord(content: url);
        _logger.d('Created UriRecord with manual payload: url=$url, payload=[${urlBytes.length} bytes]');
        return _writeNdefRecords([record], timeout: timeout);
      } catch (e2) {
        _logger.e('Failed to create UriRecord with payload', error: e2);
        return NfcResult.failure(NfcError.invalidDataFormat('创建URL记录失败: ${e.toString()}'));
      }
    }
  }

  /// 写入JSON数据到NFC标签
  /// [json] 要写入的JSON数据
  /// [timeout] 超时时间
  /// [language] 语言代码，默认'en'（英文），中文使用'zh'
  static Future<NfcResult> writeJson(Map<String, dynamic> json, {Duration timeout = const Duration(seconds: 15), String language = 'en'}) async {
    _logger.i('Starting NFC write JSON, language: $language');

    // 验证JSON数据大小
    final jsonSize = getJsonSize(json);
    if (jsonSize < 0) {
      return NfcResult.failure(NfcError.invalidDataFormat('无法序列化JSON数据'));
    }

    if (jsonSize > largeNdefMaxSize) {
      return NfcResult.failure(NfcError.dataTooLarge(jsonSize, largeNdefMaxSize));
    }

    try {
      final jsonString = jsonEncode(json);

      // 使用TextRecord存储JSON数据，必须指定language参数
      final record = ndef.TextRecord(text: jsonString, language: language);
      _logger.d('Created TextRecord for JSON: text=$jsonString, language=$language');

      return _writeNdefRecords([record], timeout: timeout);
    } catch (e) {
      _logger.e('Failed to create JSON TextRecord', error: e);
      return NfcResult.failure(NfcError.invalidDataFormat('创建JSON记录失败: ${e.toString()}'));
    }
  }

  /// 内部方法：写入NDEF记录到标签
  static Future<NfcResult> _writeNdefRecords(List<ndef.NDEFRecord> records, {required Duration timeout}) async {
    // 检查NFC可用性
    final available = await isNfcAvailable();
    if (!available) {
      final availability = await FlutterNfcKit.nfcAvailability;
      if (availability == NFCAvailability.disabled) {
        return NfcResult.failure(NfcError.nfcDisabled());
      }
      return NfcResult.failure(NfcError.nfcNotAvailable());
    }

    try {
      // 轮询NFC标签
      final pollResult = await FlutterNfcKit.poll(timeout: timeout, iosAlertMessage: "请将手机靠近NFC标签");

      // 获取并简化协议信息
      final protocolInfo = _simplifyStandard(pollResult.standard.toString());
      _logger.d('Polled tag for writing: ${pollResult.type}');
      _logger.d('Protocol Info: $protocolInfo');

      // 安全地记录标签信息
      try {
        _logger.d('Tag info: ${pollResult.toJson()}');
      } catch (_) {
        _logger.d('Tag info: (unable to serialize)');
      }

      _logger.d('NDEF available: ${pollResult.ndefAvailable}');
      _logger.d('NDEF writable: ${pollResult.ndefWritable}');
      _logger.d('Tag ID: ${pollResult.id}');

      // 检查标签是否可写（添加空安全检查）
      if (pollResult.ndefWritable != true) {
        _logger.w('Tag is not writable');
        await FlutterNfcKit.finish(iosAlertMessage: "写入失败");
        return NfcResult.failure(NfcError.writeFailed('NFC标签不可写或只读'));
      }

      _logger.d('Starting to write NDEF records...');

      // 写入NDEF记录
      await FlutterNfcKit.writeNDEFRecords(records);

      _logger.d('NDEF records written successfully');

      // 完成后结束NFC会话
      await FlutterNfcKit.finish(iosAlertMessage: "写入成功");

      _logger.i('NFC write successful');
      return NfcResult.success();
    } catch (e, stackTrace) {
      _logger.e('NFC write failed', error: e, stackTrace: stackTrace);
      try {
        await FlutterNfcKit.finish(iosAlertMessage: "写入失败");
      } catch (_) {
        _logger.w('Failed to finish NFC session after write error');
      }
      return NfcResult.failure(_handleWriteException(e));
    }
  }

  /// 处理读取异常
  static NfcError _handleReadException(dynamic exception, int attempt) {
    // 使用类型检查而不是字符串匹配
    if (exception is TimeoutException) {
      return NfcError.operationTimeout();
    }

    // 检查NFC特定异常
    final exceptionStr = exception.toString().toLowerCase();
    if (exceptionStr.contains('tag') && (exceptionStr.contains('lost') || exceptionStr.contains('disconnect') || exceptionStr.contains('not found'))) {
      return NfcError.tagLost();
    }

    if (exceptionStr.contains('timeout')) {
      return NfcError.operationTimeout();
    }

    return NfcError.readFailed('Attempt $attempt failed: ${exception.toString()}');
  }

  /// 处理写入异常
  static NfcError _handleWriteException(dynamic exception) {
    // 使用类型检查而不是字符串匹配
    if (exception is TimeoutException) {
      return NfcError.operationTimeout();
    }

    // 检查NFC特定异常
    final exceptionStr = exception.toString().toLowerCase();
    if (exceptionStr.contains('tag') && (exceptionStr.contains('lost') || exceptionStr.contains('disconnect') || exceptionStr.contains('not found'))) {
      return NfcError.tagLost();
    }

    // 检查容量/大小相关错误
    if (exceptionStr.contains('capacity') || exceptionStr.contains('size') || exceptionStr.contains('too large') || exceptionStr.contains('overflow')) {
      return NfcError.tagTooSmall(0);
    }

    if (exceptionStr.contains('timeout')) {
      return NfcError.operationTimeout();
    }

    return NfcError.writeFailed(exception.toString());
  }
}
