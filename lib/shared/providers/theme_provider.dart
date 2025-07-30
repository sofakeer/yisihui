import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

/// 主题模式状态管理
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const String _themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    _loadThemeMode();
    return ThemeMode.system; // 默认跟随系统
  }

  /// 加载保存的主题模式
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
      state = ThemeMode.values[themeIndex];
    } catch (e) {
      // 加载失败则使用默认主题
      state = ThemeMode.system;
    }
  }

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
      state = mode;
    } catch (e) {
      // 保存失败但仍更新状态
      state = mode;
    }
  }

  /// 切换到亮色主题
  Future<void> setLightTheme() => setThemeMode(ThemeMode.light);

  /// 切换到暗色主题
  Future<void> setDarkTheme() => setThemeMode(ThemeMode.dark);

  /// 跟随系统主题
  Future<void> setSystemTheme() => setThemeMode(ThemeMode.system);

  /// 获取当前是否为暗色主题
  bool get isDarkMode {
    switch (state) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
  }
}