import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

/// 加密工具类
/// 提供AES加密、RSA加密、MD5、SHA256等加密功能
class CryptoUtils {
  static const String _charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  static final Random _random = Random.secure();

  /// 生成随机字符串
  /// [length] 生成字符串的长度
  static String generateRandomString(int length) {
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _charset.codeUnitAt(_random.nextInt(_charset.length)),
      ),
    );
  }

  /// 生成随机数字字符串
  /// [length] 生成字符串的长度
  static String generateRandomNumbers(int length) {
    const numbers = '0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => numbers.codeUnitAt(_random.nextInt(numbers.length)),
      ),
    );
  }

  /// MD5加密
  /// [input] 待加密的字符串
  static String md5Hash(String input) {
    var bytes = utf8.encode(input);
    var digest = md5.convert(bytes);
    return digest.toString();
  }

  /// SHA256加密
  /// [input] 待加密的字符串
  static String sha256Hash(String input) {
    var bytes = utf8.encode(input);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// HMAC-SHA256签名
  /// [data] 待签名的数据
  /// [key] 签名密钥
  static String hmacSha256(String data, String key) {
    var keyBytes = utf8.encode(key);
    var dataBytes = utf8.encode(data);
    var hmacSha256 = Hmac(sha256, keyBytes);
    var digest = hmacSha256.convert(dataBytes);
    return digest.toString();
  }

  /// AES加密
  /// [plainText] 明文
  /// [key] 密钥 (32字节)
  /// [iv] 初始化向量 (16字节)
  static String aesEncrypt(String plainText, String key, String iv) {
    try {
      final keyBytes = utf8.encode(key.padRight(32, '0').substring(0, 32));
      final ivBytes = utf8.encode(iv.padRight(16, '0').substring(0, 16));
      final plainBytes = utf8.encode(plainText);

      final cipher = PaddedBlockCipher('AES/CBC/PKCS7');
      final params = PaddedBlockCipherParameters(
        ParametersWithIV(KeyParameter(Uint8List.fromList(keyBytes)), Uint8List.fromList(ivBytes)),
        null,
      );

      cipher.init(true, params);
      final encrypted = cipher.process(Uint8List.fromList(plainBytes));
      return base64.encode(encrypted);
    } catch (e) {
      throw Exception('AES加密失败: $e');
    }
  }

  /// AES解密
  /// [cipherText] 密文
  /// [key] 密钥 (32字节)
  /// [iv] 初始化向量 (16字节)
  static String aesDecrypt(String cipherText, String key, String iv) {
    try {
      final keyBytes = utf8.encode(key.padRight(32, '0').substring(0, 32));
      final ivBytes = utf8.encode(iv.padRight(16, '0').substring(0, 16));
      final cipherBytes = base64.decode(cipherText);

      final cipher = PaddedBlockCipher('AES/CBC/PKCS7');
      final params = PaddedBlockCipherParameters(
        ParametersWithIV(KeyParameter(Uint8List.fromList(keyBytes)), Uint8List.fromList(ivBytes)),
        null,
      );

      cipher.init(false, params);
      final decrypted = cipher.process(Uint8List.fromList(cipherBytes));
      return utf8.decode(decrypted);
    } catch (e) {
      throw Exception('AES解密失败: $e');
    }
  }

  /// 生成请求签名
  /// [params] 请求参数Map
  /// [secretKey] 密钥
  /// [timestamp] 时间戳
  static String generateSignature(Map<String, dynamic> params, String secretKey, int timestamp) {
    // 1. 参数排序
    final sortedKeys = params.keys.toList()..sort();
    
    // 2. 构建查询字符串
    final queryParts = <String>[];
    for (final key in sortedKeys) {
      if (params[key] != null && params[key].toString().isNotEmpty) {
        queryParts.add('$key=${params[key]}');
      }
    }
    
    // 3. 添加时间戳和密钥
    final queryString = queryParts.join('&');
    final signString = '$queryString&timestamp=$timestamp&key=$secretKey';
    
    // 4. 生成签名
    return sha256Hash(signString).toUpperCase();
  }

  /// 验证签名
  /// [params] 请求参数
  /// [signature] 待验证的签名
  /// [secretKey] 密钥  
  /// [timestamp] 时间戳
  /// [timeWindow] 时间窗口 (秒，默认300秒)
  static bool verifySignature(
    Map<String, dynamic> params,
    String signature,
    String secretKey,
    int timestamp, {
    int timeWindow = 300,
  }) {
    // 1. 验证时间戳
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if ((currentTime - timestamp).abs() > timeWindow) {
      return false;
    }

    // 2. 生成期望的签名
    final expectedSignature = generateSignature(params, secretKey, timestamp);
    
    // 3. 比较签名
    return signature.toUpperCase() == expectedSignature;
  }

  /// 敏感信息脱敏
  /// [data] 原始数据
  /// [type] 脱敏类型 ('phone', 'idCard', 'bankCard', 'email')
  static String maskSensitiveData(String data, String type) {
    if (data.isEmpty) return data;

    switch (type.toLowerCase()) {
      case 'phone':
        // 手机号脱敏: 138****1234
        if (data.length >= 11) {
          return '${data.substring(0, 3)}****${data.substring(data.length - 4)}';
        }
        break;
      
      case 'idcard':
        // 身份证脱敏: 110***********1234
        if (data.length >= 8) {
          return '${data.substring(0, 3)}***********${data.substring(data.length - 4)}';
        }
        break;
      
      case 'bankcard':
        // 银行卡脱敏: 6225****1234
        if (data.length >= 8) {
          return '${data.substring(0, 4)}****${data.substring(data.length - 4)}';
        }
        break;
      
      case 'email':
        // 邮箱脱敏: abc***@example.com
        final atIndex = data.indexOf('@');
        if (atIndex > 3) {
          return '${data.substring(0, 3)}***${data.substring(atIndex)}';
        }
        break;
        
      case 'name':
        // 姓名脱敏: 张*三
        if (data.length > 2) {
          return '${data.substring(0, 1)}${'*' * (data.length - 2)}${data.substring(data.length - 1)}';
        } else if (data.length == 2) {
          return '${data.substring(0, 1)}*';
        }
        break;
    }
    
    return data;
  }

  /// Base64编码
  static String base64Encode(String input) {
    return base64.encode(utf8.encode(input));
  }

  /// Base64解码
  static String base64Decode(String input) {
    return utf8.decode(base64.decode(input));
  }

  /// URL安全的Base64编码
  static String base64UrlEncode(String input) {
    return base64Url.encode(utf8.encode(input));
  }

  /// URL安全的Base64解码
  static String base64UrlDecode(String input) {
    return utf8.decode(base64Url.decode(input));
  }
}