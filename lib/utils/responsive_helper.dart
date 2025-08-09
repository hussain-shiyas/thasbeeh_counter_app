import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Screen size breakpoints
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768 &&
        MediaQuery.of(context).size.width < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1600;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // Responsive padding
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return EdgeInsets.all(24);
    } else if (isDesktop(context)) {
      return EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    } else {
      return EdgeInsets.symmetric(horizontal: 48, vertical: 32);
    }
  }

  // Responsive card width
  static double getCardMaxWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 600;
    } else {
      return 500;
    }
  }

  // Responsive grid columns
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else if (isDesktop(context)) {
      return 3;
    } else {
      return 4;
    }
  }

  // Responsive font sizes
  static double getTitleFontSize(BuildContext context) {
    if (isMobile(context)) {
      return 20;
    } else if (isTablet(context)) {
      return 24;
    } else {
      return 28;
    }
  }

  static double getSubtitleFontSize(BuildContext context) {
    if (isMobile(context)) {
      return 14;
    } else if (isTablet(context)) {
      return 16;
    } else {
      return 18;
    }
  }

  static double getBodyFontSize(BuildContext context) {
    if (isMobile(context)) {
      return 14;
    } else {
      return 16;
    }
  }

  // Responsive spacing
  static double getSpacing(BuildContext context, {double mobile = 16, double tablet = 24, double desktop = 32}) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }
}
