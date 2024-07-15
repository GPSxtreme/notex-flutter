import 'package:flutter/material.dart';

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static double? blockSizeHorizontal;
  static double? blockSizeVertical;
  static double? textScaleFactor;
  static double? spaceScaleFactor;

  final List<Map<String, dynamic>> _deviceScales = [
    {'width': 430.0, 'height': 932.0, 'scale': 1.0}, // iPhone 15 Pro Max
    {'width': 320.0, 'height': 568.0, 'scale': 0.85}, // iPhone SE
    {'width': 375.0, 'height': 667.0, 'scale': 0.85}, // iPhone 6/7/8
    {'width': 375.0, 'height': 812.0, 'scale': 0.9}, // iPhone X/XS/11 Pro
    {'width': 414.0, 'height': 896.0, 'scale': 0.95}, // iPhone XR/11/11 Pro Max
    {'width': 360.0, 'height': 640.0, 'scale': 0.75}, // Android small screen
    {'width': 360.0, 'height': 720.0, 'scale': 0.8}, // Android medium screen
    {'width': 411.0, 'height': 731.0, 'scale': 0.9}, // Pixel 2/3
    {'width': 411.0, 'height': 823.0, 'scale': 0.95}, // Pixel 2/3 XL
    {'width': 768.0, 'height': 1024.0, 'scale': 1.2}, // iPad (7th generation)
    {'width': 834.0, 'height': 1112.0, 'scale': 1.3}, // iPad Pro 10.5-inch
    {'width': 1024.0, 'height': 1366.0, 'scale': 1.4}, // iPad Pro 12.9-inch
  ];

  double computeScaleFactor(double screenWidth, double screenHeight) {
    double minDiff = double.infinity;
    double closestScale = 1.0;

    for (var device in _deviceScales) {
      double widthDiff = (device['width'] - screenWidth).abs();
      double heightDiff = (device['height'] - screenHeight).abs();
      double diff = widthDiff + heightDiff;

      if (diff < minDiff) {
        minDiff = diff;
        closestScale = device['scale'];
      }
    }

    return closestScale;
  }

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenHeight = _mediaQueryData!.size.height;
    screenWidth = _mediaQueryData!.size.width;
    blockSizeHorizontal = screenWidth! / 100;
    blockSizeVertical = screenHeight! / 100;
    textScaleFactor = computeScaleFactor(screenWidth!, screenHeight!);
    spaceScaleFactor = computeScaleFactor(screenWidth!, screenHeight!);
  }
}

/// Provides standard spacing values across the application.
class AppSpacing {
  static double scaledSpace(double baseSpace) =>
      baseSpace * SizeConfig.spaceScaleFactor!;

  /// Extra small space: 4.0 logical pixels.
  /// Typically used for very tight spacing between small elements.
  static double get xs => scaledSpace(4.0);

  /// Small space: 8.0 logical pixels.
  /// Good for inner elements spacing or tight groups.
  static double get sm => scaledSpace(8.0);

  /// Medium space: 16.0 logical pixels.
  /// Ideal for default spacing between medium-sized elements.
  static double get md => scaledSpace(16.0);

  /// Large space: 24.0 logical pixels.
  /// Suitable for larger gaps between grouped elements or sections.
  static double get lg => scaledSpace(24.0);

  /// Extra large space: 32.0 logical pixels.
  /// Used for significant spacing in layout design.
  static double get xl => scaledSpace(32.0);

  /// Double extra large space: 40.0 logical pixels.
  /// Perfect for extra-large gaps or as a spacious separator.
  static double get xxl => scaledSpace(40.0);

  /// Triple extra large space: 48.0 logical pixels.
  /// Ideal for maximum spacing within layouts.
  static double get xxxl => scaledSpace(48.0);

  static double get iconSizeXs => scaledSpace(12.0);

  /// Small icon size: 16.0 logical pixels.
  /// Suitable for smaller icons in lists or in smaller layouts.
  static double get iconSizeSm => scaledSpace(14.0);

  /// Standard icon size: 24.0 logical pixels.
  /// Commonly used for icons in app bars, lists, etc.
  static double get iconSizeBase => scaledSpace(16.0);

  /// Medium icon size: 28.0 logical pixels.
  /// Suitable for larger icons in lists or in larger layouts.
  static double get iconSizeMd => scaledSpace(18.0);

  /// Large icon size: 32.0 logical pixels.
  /// Useful for more prominent icons where extra visibility is needed.
  static double get iconSizeLg => scaledSpace(20.0);

  /// Extra large icon size: 40.0 logical pixels.
  /// Best for key interactive icons or important navigation elements.
  static double get iconSizeXl => scaledSpace(24.0);

  /// Double extra large icon size: 48.0 logical pixels.
  /// Ideal for key actions or important elements.
  static double get iconSize2Xl => scaledSpace(30.0);

  /// Triple extra large icon size: 56.0 logical pixels.
  /// Ideal for key actions or important elements.
  static double get iconSize3Xl => scaledSpace(36.0);

  /// Quadruple extra large icon size: 64.0 logical pixels.
  /// Ideal for key actions or important elements.
  static double get iconSize4Xl => scaledSpace(48.0);

  static double get iconSize5Xl => scaledSpace(60.0);

  static double get iconSize6Xl => scaledSpace(72.0);

  static double get iconSize7Xl => scaledSpace(80.0);
}

/// Provides standard border radius values across the application.
class AppBorderRadius {
  static BorderRadius scaledRadius(double radius) =>
      BorderRadius.circular(radius * SizeConfig.spaceScaleFactor!);

  /// No border radius, equivalent to sharp corners.
  static BorderRadius get none => BorderRadius.zero;

  /// Small border radius: 4.0 logical pixels.
  /// Creates a subtle curve at corners, suitable for small containers.
  static BorderRadius get sm => scaledRadius(2.0);
  static BorderRadius get base => scaledRadius(4.0);

  /// Medium border radius: 8.0 logical pixels.
  /// Commonly used for moderate rounding of element edges.
  static BorderRadius get md => scaledRadius(6.0);

  /// Large border radius: 12.0 logical pixels.
  /// Provides a more pronounced rounded effect, good for modal dialogs.
  static BorderRadius get lg => scaledRadius(8.0);

  /// Extra large border radius: 16.0 logical pixels.
  /// Ideal for cards and other elements requiring softer edges.
  static BorderRadius get xl => scaledRadius(12.0);

  /// Double extra large border radius: 20.0 logical pixels.
  /// Used for elements needing very rounded corners.
  static BorderRadius get xxl => scaledRadius(16.0);

  /// Triple extra large border radius: 24.0 logical pixels.
  /// Provides maximum rounding, suitable for special containers.
  static BorderRadius get xxxl => scaledRadius(24.0);

  /// Full border radius: 9999.0 logical pixels.
  /// Creates a perfect circle or oval when applied, depending on element size.
  static BorderRadius get full => scaledRadius(9999.0);
}
