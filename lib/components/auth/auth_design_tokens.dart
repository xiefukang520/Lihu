import 'package:flutter/material.dart';

/// 认证页通用设计 Token（提取自项目设计规范）。
abstract final class AuthDesignTokens {
  static const double horizontalPadding = 16;
  static const double fieldSpacing = 12;
  static const double cornerRadius = 16;

  static const TextStyle h1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: Color(0xFF15182E),
    fontFamily: 'PingFang SC',
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: Color(0xFF15182E),
    fontFamily: 'PingFang SC',
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: Color(0xFF15182E),
    fontFamily: 'PingFang SC',
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: Color(0xFF15182E),
    fontFamily: 'PingFang SC',
  );

  static const TextStyle note = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.0,
    color: Color(0xFFA4A9BD),
    fontFamily: 'PingFang SC',
  );

  static const Color textPrimary = Color(0xFF15182E);
  static const Color textSecondary = Color(0xFF8D92A3);
  static const Color inputFill = Color(0xFFFFFFFF);
  static const Color actionBlue = Color(0xFF6E8DF5);
  static const Color actionBlueLight = Color(0xFF86A9FF);
  static const Color divider = Color(0xFFD6DAE6);
}
