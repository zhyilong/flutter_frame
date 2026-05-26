/*
 * Created by zhyilong on 2026/5/20
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// 二维码图片解析工具类
///
/// 使用 mobile_scanner 从图片中解析二维码
class QRImageParser {
  QRImageParser._();

  /// 从图片路径解析二维码
  ///
  /// [path] 图片文件路径
  ///
  /// 返回解析到的二维码列表，如果没有解析到则返回空列表
  ///
  /// 示例：
  /// ```dart
  /// final codes = await QRImageParser.fromPath('/path/to/image.png');
  /// if (codes.isNotEmpty) {
  ///   print('解析到二维码: ${codes.first}');
  /// }
  /// ```
  static Future<List<String>> fromPath(String path) async {
    try {
      // 检查文件是否存在
      final file = File(path);
      if (!await file.exists()) {
        debugPrint('QRImageParser: 文件不存在 - $path');
        return [];
      }

      // 创建扫描控制器
      final controller = MobileScannerController();

      // 分析图片
      final capture = await controller.analyzeImage(path);

      // 释放控制器
      await controller.dispose();

      // 检查是否有结果
      if (capture == null || capture.barcodes.isEmpty) {
        return [];
      }

      // 提取二维码数据
      final codes = <String>[];
      for (final barcode in capture.barcodes) {
        if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
          codes.add(barcode.rawValue!);
        }
      }

      return codes;
    } catch (e) {
      debugPrint('QRImageParser.fromPath 错误: $e');
      return [];
    }
  }

  /// 从图片路径解析单个二维码（便捷方法）
  ///
  /// 如果图片中有多个二维码，只返回第一个
  /// 如果没有解析到，返回 null
  ///
  /// 示例：
  /// ```dart
  /// final code = await QRImageParser.parseOne('/path/to/image.png');
  /// if (code != null) {
  ///   print('解析到二维码: $code');
  /// }
  /// ```
  static Future<String?> parseOne(String path) async {
    final codes = await fromPath(path);
    return codes.isNotEmpty ? codes.first : null;
  }

  /// 批量从多个图片路径解析二维码
  ///
  /// [paths] 图片文件路径列表
  ///
  /// 返回 Map，key 为图片路径，value 为该图片中解析到的二维码列表
  ///
  /// 示例：
  /// ```dart
  /// final results = await QRImageParser.batchFromPaths([
  ///   '/path/to/image1.png',
  ///   '/path/to/image2.png',
  /// ]);
  /// results.forEach((path, codes) {
  ///   print('$path: ${codes.length} 个二维码');
  /// });
  /// ```
  static Future<Map<String, List<String>>> batchFromPaths(List<String> paths) async {
    final results = <String, List<String>>{};

    for (final path in paths) {
      final codes = await fromPath(path);
      results[path] = codes;
    }

    return results;
  }
}

/// 二维码解析结果类
///
/// 包含解析的详细信息和原始数据
class QRParseResult {
  /// 解析到的二维码文本内容
  final String content;

  /// 二维码类型
  final String type;

  /// 原始捕获数据
  final BarcodeCapture? rawCapture;

  const QRParseResult({
    required this.content,
    required this.type,
    this.rawCapture,
  });

  /// 从 Barcode 创建 QRParseResult
  factory QRParseResult.fromBarcode(Barcode barcode, {BarcodeCapture? capture}) {
    return QRParseResult(
      content: barcode.rawValue ?? '',
      type: barcode.type.name,
      rawCapture: capture,
    );
  }

  @override
  String toString() {
    return 'QRParseResult(content: $content, type: $type)';
  }
}

/// 高级二维码图片解析工具
///
/// 提供更详细的解析结果信息
class QRImageParserAdvanced {
  QRImageParserAdvanced._();

  /// 从图片路径解析并返回详细信息
  ///
  /// 返回 QRParseResult 列表
  static Future<List<QRParseResult>> parse(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        debugPrint('QRImageParserAdvanced: 文件不存在 - $path');
        return [];
      }

      final controller = MobileScannerController();
      final capture = await controller.analyzeImage(path);
      await controller.dispose();

      if (capture == null || capture.barcodes.isEmpty) {
        return [];
      }

      final results = <QRParseResult>[];
      for (final barcode in capture.barcodes) {
        if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
          results.add(QRParseResult.fromBarcode(barcode, capture: capture));
        }
      }

      return results;
    } catch (e) {
      debugPrint('QRImageParserAdvanced.parse 错误: $e');
      return [];
    }
  }

  /// 从图片路径解析单个二维码并返回详细信息
  ///
  /// 如果图片中有多个二维码，只返回第一个
  /// 如果没有解析到，返回 null
  static Future<QRParseResult?> parseOne(String path) async {
    final results = await parse(path);
    return results.isNotEmpty ? results.first : null;
  }
}
