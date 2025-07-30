import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// 存储工具类
/// 提供安全存储、普通存储、缓存管理等功能
class StorageUtils {
  static const String _userTokenKey = 'user_token';
  static const String _userInfoKey = 'user_info';
  static const String _settingsKey = 'app_settings';
  static const String _cacheBoxName = 'app_cache';

  // 安全存储实例
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// 初始化存储
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(_cacheBoxName);
  }

  /// 安全存储 - 保存用户Token
  static Future<void> saveUserToken(String token) async {
    await _secureStorage.write(key: _userTokenKey, value: token);
  }

  /// 安全存储 - 获取用户Token
  static Future<String?> getUserToken() async {
    return await _secureStorage.read(key: _userTokenKey);
  }

  /// 安全存储 - 删除用户Token
  static Future<void> deleteUserToken() async {
    await _secureStorage.delete(key: _userTokenKey);
  }

  /// 安全存储 - 保存用户信息
  static Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    final jsonString = json.encode(userInfo);
    await _secureStorage.write(key: _userInfoKey, value: jsonString);
  }

  /// 安全存储 - 获取用户信息
  static Future<Map<String, dynamic>?> getUserInfo() async {
    final jsonString = await _secureStorage.read(key: _userInfoKey);
    if (jsonString != null) {
      try {
        return json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// 安全存储 - 删除用户信息
  static Future<void> deleteUserInfo() async {
    await _secureStorage.delete(key: _userInfoKey);
  }

  /// 安全存储 - 保存敏感数据
  static Future<void> saveSensitiveData(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// 安全存储 - 获取敏感数据
  static Future<String?> getSensitiveData(String key) async {
    return await _secureStorage.read(key: key);
  }

  /// 安全存储 - 删除敏感数据
  static Future<void> deleteSensitiveData(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// 安全存储 - 清空所有安全存储数据
  static Future<void> clearSecureStorage() async {
    await _secureStorage.deleteAll();
  }

  /// 普通存储 - 保存字符串
  static Future<bool> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, value);
  }

  /// 普通存储 - 获取字符串
  static Future<String?> getString(String key, {String? defaultValue}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? defaultValue;
  }

  /// 普通存储 - 保存整数
  static Future<bool> saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(key, value);
  }

  /// 普通存储 - 获取整数
  static Future<int> getInt(String key, {int defaultValue = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? defaultValue;
  }

  /// 普通存储 - 保存布尔值
  static Future<bool> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(key, value);
  }

  /// 普通存储 - 获取布尔值
  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  /// 普通存储 - 保存双精度浮点数
  static Future<bool> saveDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setDouble(key, value);
  }

  /// 普通存储 - 获取双精度浮点数
  static Future<double> getDouble(String key, {double defaultValue = 0.0}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key) ?? defaultValue;
  }

  /// 普通存储 - 保存字符串列表
  static Future<bool> saveStringList(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList(key, value);
  }

  /// 普通存储 - 获取字符串列表
  static Future<List<String>> getStringList(String key, {List<String>? defaultValue}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? defaultValue ?? [];
  }

  /// 普通存储 - 保存JSON对象
  static Future<bool> saveJson(String key, Map<String, dynamic> value) async {
    final jsonString = json.encode(value);
    return await saveString(key, jsonString);
  }

  /// 普通存储 - 获取JSON对象
  static Future<Map<String, dynamic>?> getJson(String key) async {
    final jsonString = await getString(key);
    if (jsonString != null) {
      try {
        return json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// 普通存储 - 删除指定键
  static Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(key);
  }

  /// 普通存储 - 清空所有数据
  static Future<bool> clear() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }

  /// 普通存储 - 检查键是否存在
  static Future<bool> containsKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  /// 缓存 - 保存缓存数据
  static Future<void> saveCache(String key, dynamic value, {Duration? expiry}) async {
    try {
      final box = Hive.box(_cacheBoxName);
      final cacheData = CacheData(
        value: value,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        expiry: expiry?.inMilliseconds,
      );
      await box.put(key, cacheData.toJson());
    } catch (e) {
      // 缓存失败不影响主流程
    }
  }

  /// 缓存 - 获取缓存数据
  static Future<T?> getCache<T>(String key) async {
    try {
      final box = Hive.box(_cacheBoxName);
      final cacheJson = box.get(key);
      if (cacheJson != null) {
        final cacheData = CacheData.fromJson(cacheJson);
        
        // 检查是否过期
        if (cacheData.expiry != null) {
          final expiredTime = cacheData.timestamp + cacheData.expiry!;
          if (DateTime.now().millisecondsSinceEpoch > expiredTime) {
            await box.delete(key);
            return null;
          }
        }
        
        return cacheData.value as T?;
      }
    } catch (e) {
      // 读取缓存失败
    }
    return null;
  }

  /// 缓存 - 删除指定缓存
  static Future<void> deleteCache(String key) async {
    try {
      final box = Hive.box(_cacheBoxName);
      await box.delete(key);
    } catch (e) {
      // 删除失败
    }
  }

  /// 缓存 - 清空所有缓存
  static Future<void> clearCache() async {
    try {
      final box = Hive.box(_cacheBoxName);
      await box.clear();
    } catch (e) {
      // 清空失败
    }
  }

  /// 缓存 - 获取缓存大小
  static Future<int> getCacheSize() async {
    try {
      final box = Hive.box(_cacheBoxName);
      return box.length;
    } catch (e) {
      return 0;
    }
  }

  /// 缓存 - 清理过期缓存
  static Future<void> cleanExpiredCache() async {
    try {
      final box = Hive.box(_cacheBoxName);
      final keys = box.keys.toList();
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      
      for (final key in keys) {
        final cacheJson = box.get(key);
        if (cacheJson != null) {
          final cacheData = CacheData.fromJson(cacheJson);
          if (cacheData.expiry != null) {
            final expiredTime = cacheData.timestamp + cacheData.expiry!;
            if (currentTime > expiredTime) {
              await box.delete(key);
            }
          }
        }
      }
    } catch (e) {
      // 清理失败
    }
  }

  /// 应用设置 - 保存应用设置
  static Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    await saveJson(_settingsKey, settings);
  }

  /// 应用设置 - 获取应用设置
  static Future<Map<String, dynamic>> getAppSettings() async {
    return await getJson(_settingsKey) ?? {};
  }

  /// 用户偏好 - 保存主题模式
  static Future<void> saveThemeMode(String themeMode) async {
    await saveString('theme_mode', themeMode);
  }

  /// 用户偏好 - 获取主题模式
  static Future<String> getThemeMode() async {
    return await getString('theme_mode', defaultValue: 'system') ?? 'system';
  }

  /// 用户偏好 - 保存语言设置
  static Future<void> saveLanguage(String language) async {
    await saveString('language', language);
  }

  /// 用户偏好 - 获取语言设置
  static Future<String> getLanguage() async {
    return await getString('language', defaultValue: 'zh') ?? 'zh';
  }

  /// 用户偏好 - 保存生物识别设置
  static Future<void> saveBiometricEnabled(bool enabled) async {
    await saveBool('biometric_enabled', enabled);
  }

  /// 用户偏好 - 获取生物识别设置
  static Future<bool> getBiometricEnabled() async {
    return await getBool('biometric_enabled', defaultValue: false);
  }

  /// 完全清空所有存储数据
  static Future<void> clearAllData() async {
    await clearSecureStorage();
    await clear();
    await clearCache();
  }
}

/// 缓存数据模型
class CacheData {
  final dynamic value;
  final int timestamp;
  final int? expiry; // 过期时间(毫秒)

  CacheData({
    required this.value,
    required this.timestamp,
    this.expiry,
  });

  Map<String, dynamic> toJson() => {
    'value': value,
    'timestamp': timestamp,
    'expiry': expiry,
  };

  factory CacheData.fromJson(Map<String, dynamic> json) => CacheData(
    value: json['value'],
    timestamp: json['timestamp'],
    expiry: json['expiry'],
  );
}