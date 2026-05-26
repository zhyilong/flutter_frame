/*
 * Created by zhyilong on 2026/5/21
 */

import 'package:flutter/material.dart';

/// 空数据类型枚举
enum EmptyDataType {
  /// 暂无数据
  noData,

  /// 搜索无结果
  noSearch,

  /// 加载失败
  error,

  /// 完全自定义
  custom,
}

/// 空数据展示组件
///
/// 用于展示列表、页面等为空时的占位UI，支持多种预设类型和自定义配置。
///
/// 示例：
/// ```dart
/// // 使用预设类型
/// EmptyDataWidget(type: EmptyDataType.noData)
///
/// // 自定义文字和按钮
/// EmptyDataWidget(
///   type: EmptyDataType.noData,
///   title: '还没有订单哦',
///   subtitle: '快去逛逛吧~',
///   buttonText: '去逛逛',
///   onButtonTap: () {},
/// )
///
/// // 设置高度
/// EmptyDataWidget(
///   type: EmptyDataType.noData,
///   height: 400,
/// )
/// ```
class EmptyDataWidget extends StatelessWidget {
  /// 预设类型（默认为无数据）
  final EmptyDataType type;

  /// 自定义图标（覆盖预设）
  final Widget? icon;

  /// 主标题（覆盖预设）
  final String? title;

  /// 副标题/描述文字
  final String? subtitle;

  /// 操作按钮文字
  final String? buttonText;

  /// 操作按钮点击回调
  final VoidCallback? onButtonTap;

  /// 内边距
  final EdgeInsets padding;

  /// 是否垂直居中（默认居中）
  final bool centered;

  /// Container 宽度
  final double? width;

  /// Container 高度
  final double? height;

  /// Container 装饰
  final BoxDecoration? decoration;

  const EmptyDataWidget({
    super.key,
    this.type = EmptyDataType.noData,
    this.icon,
    this.title,
    this.subtitle,
    this.buttonText,
    this.onButtonTap,
    this.padding = const EdgeInsets.all(24.0),
    this.centered = true,
    this.width,
    this.height,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 获取预设配置
    final defaultConfig = _getDefaultConfig();

    // 构建内容
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 图标
        if (icon != null) icon! else Icon(defaultConfig['icon'], size: 80, color: colorScheme.outline.withOpacity(0.5)),

        // const SizedBox(height: 5),

        // 主标题
        Text(
          title ?? defaultConfig['title'],
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: colorScheme.onSurface.withOpacity(0.6)),
          textAlign: TextAlign.center,
        ),

        // 副标题
        if (subtitle != null || defaultConfig['subtitle'] != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle ?? defaultConfig['subtitle'],
            style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.4)),
            textAlign: TextAlign.center,
          ),
        ],

        // 操作按钮
        if (buttonText != null || onButtonTap != null) ...[
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onButtonTap,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            child: Text(buttonText ?? defaultConfig['buttonText'] ?? '确定'),
          ),
        ],
      ],
    );

    // 根据是否居中构建内容容器
    final contentWidget = centered
        ? Center(
            child: Padding(padding: padding, child: content),
          )
        : Padding(padding: padding, child: content);

    // 使用 Container 包裹，支持设置宽高和装饰
    return Container(width: width, height: height, decoration: decoration, child: contentWidget);
  }

  /// 获取预设类型的默认配置
  Map<String, dynamic> _getDefaultConfig() {
    switch (type) {
      case EmptyDataType.noData:
        return {'icon': Icons.inbox_outlined, 'title': '暂无数据', 'subtitle': null, 'buttonText': null};

      case EmptyDataType.noSearch:
        return {'icon': Icons.search_off_rounded, 'title': '未找到相关内容', 'subtitle': '换个关键词试试吧', 'buttonText': null};

      case EmptyDataType.error:
        return {'icon': Icons.error_outline_rounded, 'title': '加载失败', 'subtitle': '请稍后重试', 'buttonText': '重试'};

      case EmptyDataType.custom:
        return {'icon': Icons.info_outline_rounded, 'title': '', 'subtitle': null, 'buttonText': null};
    }
  }
}
