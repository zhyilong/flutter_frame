/*
 * Created by zhyilong on 2026/5/20
 */

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// 二维码生成工具类
/// 提供静态方法快速生成二维码 Widget
class QRGenerator {
  QRGenerator._();

  /// 生成默认样式的二维码
  ///
  /// [data] 二维码内容（支持文本、URL、JSON等）
  /// [size] 二维码尺寸（默认 200）
  static Widget generate(
    String data, {
    double size = 200.0,
  }) {
    return QrImageView(
      data: data,
      size: size,
    );
  }

  /// 生成自定义颜色的二维码
  ///
  /// [data] 二维码内容
  /// [size] 二维码尺寸
  /// [color] 二维码颜色（默认黑色）
  /// [backgroundColor] 二维码背景色（默认白色）
  static Widget generateWithColor(
    String data, {
    double size = 200.0,
    Color color = Colors.black,
    Color backgroundColor = Colors.white,
  }) {
    return QrImageView(
      data: data,
      size: size,
      backgroundColor: backgroundColor,
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: color,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: color,
      ),
    );
  }

  /// 生成带自定义错误纠正级别的二维码
  ///
  /// [data] 二维码内容
  /// [size] 二维码尺寸
  /// [errorCorrectionLevel] 错误纠正级别（默认中等）
  static Widget generateWithErrorLevel(
    String data, {
    double size = 200.0,
    int errorCorrectionLevel = QrErrorCorrectLevel.M,
  }) {
    return QrImageView(
      data: data,
      size: size,
      errorCorrectionLevel: errorCorrectionLevel,
    );
  }

  /// 生成带圆角的二维码
  ///
  /// [data] 二维码内容
  /// [size] 二维码尺寸
  /// [radius] 圆角半径（默认 8）
  static Widget generateWithRadius(
    String data, {
    double size = 200.0,
    double radius = 8.0,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: QrImageView(
        data: data,
        size: size,
      ),
    );
  }

  /// 生成带边框的二维码
  ///
  /// [data] 二维码内容
  /// [size] 二维码尺寸
  /// [borderWidth] 边框宽度（默认 4）
  /// [borderColor] 边框颜色（默认灰色）
  static Widget generateWithBorder(
    String data, {
    double size = 200.0,
    double borderWidth = 4.0,
    Color borderColor = Colors.grey,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: QrImageView(
        data: data,
        size: size,
      ),
    );
  }

  /// 生成完整的自定义二维码
  ///
  /// [data] 二维码内容
  /// [size] 二维码尺寸
  /// [color] 前景色
  /// [backgroundColor] 背景色
  /// [errorCorrectionLevel] 错误纠正级别
  /// [padding] 内边距
  /// [radius] 圆角半径
  /// [eyeShape] QR眼形状
  /// [dataModuleShape] QR码元形状
  static Widget generateCustom(
    String data, {
    double size = 200.0,
    Color? color,
    Color? backgroundColor,
    int? errorCorrectionLevel,
    EdgeInsets? padding,
    double? radius,
    QrEyeShape? eyeShape,
    QrDataModuleShape? dataModuleShape,
  }) {
    Widget qrWidget = QrImageView(
      data: data,
      size: size,
      backgroundColor: backgroundColor ?? Colors.white,
      errorCorrectionLevel: errorCorrectionLevel ?? QrErrorCorrectLevel.M,
      padding: padding ?? const EdgeInsets.all(8),
      eyeStyle: QrEyeStyle(
        eyeShape: eyeShape ?? QrEyeShape.square,
        color: color ?? Colors.black,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: dataModuleShape ?? QrDataModuleShape.square,
        color: color ?? Colors.black,
      ),
    );

    if (radius != null && radius > 0) {
      qrWidget = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: qrWidget,
      );
    }

    return qrWidget;
  }

  /// 生成带中心 Logo 的二维码
  ///
  /// [data] 二维码内容
  /// [size] 二维码尺寸
  /// [logo] Logo Widget
  /// [logoSize] Logo 尺寸（默认为二维码的 20%）
  static Widget generateWithLogo(
    String data, {
    double size = 200.0,
    required Widget logo,
    double? logoSize,
  }) {
    final actualLogoSize = logoSize ?? size * 0.2;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          QrImageView(
            data: data,
            size: size,
          ),
          Container(
            width: actualLogoSize,
            height: actualLogoSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: logo,
            ),
          ),
        ],
      ),
    );
  }

  /// 生成可交互的二维码（点击复制内容）
  ///
  /// [data] 二维码内容
  /// [size] 二维码尺寸
  /// [onTap] 点击回调
  /// [tooltip] 提示文本
  static Widget generateInteractive(
    String data, {
    double size = 200.0,
    VoidCallback? onTap,
    String tooltip = '点击复制',
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: QrImageView(
          data: data,
          size: size,
        ),
      ),
    );
  }

  /// 生成带嵌入图片的二维码（使用 qr_flutter 内置功能）
  ///
  /// [data] 二维码内容
  /// [size] 二维码尺寸
  /// [imageProvider] 图片提供者
  /// [embeddedImageStyle] 嵌入图片样式
  static Widget generateWithEmbeddedImage(
    String data, {
    double size = 200.0,
    required ImageProvider<Object> imageProvider,
    QrEmbeddedImageStyle? embeddedImageStyle,
  }) {
    return QrImageView(
      data: data,
      size: size,
      embeddedImage: imageProvider,
      embeddedImageStyle: embeddedImageStyle,
    );
  }

  /// 生成圆形样式二维码
  ///
  /// [data] 二维码内容
  /// [size] 二维码尺寸
  /// [color] 二维码颜色
  /// [backgroundColor] 背景色
  static Widget generateCircularStyle(
    String data, {
    double size = 200.0,
    Color color = Colors.black,
    Color backgroundColor = Colors.white,
  }) {
    return QrImageView(
      data: data,
      size: size,
      backgroundColor: backgroundColor,
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.circle,
        color: color,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.circle,
        color: color,
      ),
    );
  }

  /// 生成方形样式二维码（默认样式）
  ///
  /// [data] 二维码内容
  /// [size] 二维码尺寸
  /// [color] 二维码颜色
  /// [backgroundColor] 背景色
  static Widget generateSquareStyle(
    String data, {
    double size = 200.0,
    Color color = Colors.black,
    Color backgroundColor = Colors.white,
  }) {
    return QrImageView(
      data: data,
      size: size,
      backgroundColor: backgroundColor,
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: color,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: color,
      ),
    );
  }
}

/// 二维码生成器配置类
/// 用于封装复杂的二维码生成配置
class QRGeneratorConfig {
  /// 二维码尺寸
  final double size;

  /// 前景色
  final Color? color;

  /// 背景色
  final Color? backgroundColor;

  /// 错误纠正级别
  final int? errorCorrectionLevel;

  /// 内边距
  final EdgeInsets? padding;

  /// 圆角半径
  final double? radius;

  /// 是否显示边框
  final bool showBorder;

  /// 边框宽度
  final double borderWidth;

  /// 边框颜色
  final Color borderColor;

  /// 中心 Logo Widget（用于自定义 Stack 方式）
  final Widget? logo;

  /// Logo 尺寸
  final double? logoSize;

  /// 嵌入图片（使用 qr_flutter 内置功能）
  final ImageProvider<Object>? embeddedImage;

  /// 嵌入图片样式
  final QrEmbeddedImageStyle? embeddedImageStyle;

  /// QR 码元样式
  final QrDataModuleShape? dataModuleShape;

  /// QR 眼样式
  final QrEyeShape? eyeShape;

  /// 是否有间隙
  final bool gapless;

  const QRGeneratorConfig({
    this.size = 200.0,
    this.color,
    this.backgroundColor,
    this.errorCorrectionLevel,
    this.padding,
    this.radius,
    this.showBorder = false,
    this.borderWidth = 4.0,
    this.borderColor = Colors.grey,
    this.logo,
    this.logoSize,
    this.embeddedImage,
    this.embeddedImageStyle,
    this.dataModuleShape,
    this.eyeShape,
    this.gapless = true,
  });

  /// 根据配置生成二维码 Widget
  Widget generate(String data) {
    Widget qrWidget = QrImageView(
      data: data,
      size: size,
      backgroundColor: backgroundColor ?? Colors.white,
      errorCorrectionLevel: errorCorrectionLevel ?? QrErrorCorrectLevel.M,
      padding: padding ?? const EdgeInsets.all(8),
      gapless: gapless,
      eyeStyle: QrEyeStyle(
        eyeShape: eyeShape ?? QrEyeShape.square,
        color: color ?? Colors.black,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: dataModuleShape ?? QrDataModuleShape.square,
        color: color ?? Colors.black,
      ),
      embeddedImage: embeddedImage,
      embeddedImageStyle: embeddedImageStyle,
    );

    // 添加圆角
    if (radius != null && radius! > 0) {
      qrWidget = ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: qrWidget,
      );
    }

    // 添加边框
    if (showBorder) {
      qrWidget = Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(radius ?? 8),
        ),
        child: qrWidget,
      );
    }

    // 添加自定义 Logo（Stack 方式）
    if (logo != null) {
      final actualLogoSize = logoSize ?? size * 0.2;
      qrWidget = SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            qrWidget,
            Container(
              width: actualLogoSize,
              height: actualLogoSize,
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: logo,
              ),
            ),
          ],
        ),
      );
    }

    return qrWidget;
  }

  /// 创建默认配置
  static const QRGeneratorConfig defaultConfig = QRGeneratorConfig();

  /// 创建深色主题配置
  static const QRGeneratorConfig darkTheme = QRGeneratorConfig(
    color: Colors.white,
    backgroundColor: Colors.black,
  );

  /// 创建品牌色配置示例
  static QRGeneratorConfig brandTheme(Color brandColor) => QRGeneratorConfig(
        color: brandColor,
        backgroundColor: Colors.white,
        showBorder: true,
        borderColor: brandColor,
      );

  /// 创建圆形样式配置
  static QRGeneratorConfig circularStyle({
    Color color = Colors.black,
    Color backgroundColor = Colors.white,
  }) =>
      QRGeneratorConfig(
        color: color,
        backgroundColor: backgroundColor,
        eyeShape: QrEyeShape.circle,
        dataModuleShape: QrDataModuleShape.circle,
      );
}
