import 'dart:core';

/// 验证工具类
/// 提供各种表单验证功能
class ValidatorUtils {
  
  /// 验证手机号
  /// [phone] 手机号码
  /// [countryCode] 国家代码 (默认中国)
  static ValidationResult validatePhone(String phone, {String countryCode = 'CN'}) {
    if (phone.isEmpty) {
      return const ValidationResult(false, '请输入手机号');
    }

    RegExp phoneRegex;
    switch (countryCode.toUpperCase()) {
      case 'CN':
        // 中国手机号: 1开头的11位数字
        phoneRegex = RegExp(r'^1[3-9]\d{9}$');
        if (!phoneRegex.hasMatch(phone)) {
          return const ValidationResult(false, '请输入正确的手机号');
        }
        break;
      case 'US':
        // 美国手机号: 10位数字
        phoneRegex = RegExp(r'^\d{10}$');
        if (!phoneRegex.hasMatch(phone)) {
          return const ValidationResult(false, '请输入正确的美国手机号');
        }
        break;
      case 'UK':
        // 英国手机号: 7开头的11位数字
        phoneRegex = RegExp(r'^07\d{9}$');
        if (!phoneRegex.hasMatch(phone)) {
          return const ValidationResult(false, '请输入正确的英国手机号');
        }
        break;
      default:
        // 通用验证: 7-15位数字
        phoneRegex = RegExp(r'^\d{7,15}$');
        if (!phoneRegex.hasMatch(phone)) {
          return const ValidationResult(false, '请输入正确的手机号');
        }
    }

    return const ValidationResult(true, '');
  }

  /// 验证邮箱
  /// [email] 邮箱地址
  static ValidationResult validateEmail(String email) {
    if (email.isEmpty) {
      return const ValidationResult(false, '请输入邮箱地址');
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return const ValidationResult(false, '请输入正确的邮箱地址');
    }

    return const ValidationResult(true, '');
  }

  /// 验证密码强度
  /// [password] 密码
  /// [minLength] 最小长度
  /// [requireUppercase] 是否需要大写字母
  /// [requireLowercase] 是否需要小写字母
  /// [requireNumbers] 是否需要数字
  /// [requireSpecialChars] 是否需要特殊字符
  static ValidationResult validatePassword(
    String password, {
    int minLength = 8,
    bool requireUppercase = false,
    bool requireLowercase = true,
    bool requireNumbers = true,
    bool requireSpecialChars = false,
  }) {
    if (password.isEmpty) {
      return const ValidationResult(false, '请输入密码');
    }

    if (password.length < minLength) {
      return ValidationResult(false, '密码长度不能少于$minLength位');
    }

    if (requireUppercase && !password.contains(RegExp(r'[A-Z]'))) {
      return const ValidationResult(false, '密码必须包含大写字母');
    }

    if (requireLowercase && !password.contains(RegExp(r'[a-z]'))) {
      return const ValidationResult(false, '密码必须包含小写字母');
    }

    if (requireNumbers && !password.contains(RegExp(r'[0-9]'))) {
      return const ValidationResult(false, '密码必须包含数字');
    }

    if (requireSpecialChars && !password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return const ValidationResult(false, '密码必须包含特殊字符');
    }

    return const ValidationResult(true, '');
  }

  /// 验证中国身份证号
  /// [idCard] 身份证号码
  static ValidationResult validateChineseIdCard(String idCard) {
    if (idCard.isEmpty) {
      return const ValidationResult(false, '请输入身份证号码');
    }

    // 18位身份证号码正则
    final idCardRegex = RegExp(r'^\d{17}[\dXx]$');
    if (!idCardRegex.hasMatch(idCard)) {
      return const ValidationResult(false, '请输入正确的18位身份证号码');
    }

    // 验证校验码
    if (!_validateIdCardChecksum(idCard)) {
      return const ValidationResult(false, '身份证号码校验失败');
    }

    // 验证生日
    final birthDate = idCard.substring(6, 14);
    if (!_validateBirthDate(birthDate)) {
      return const ValidationResult(false, '身份证号码中的生日不合法');
    }

    return const ValidationResult(true, '');
  }

  /// 验证银行卡号
  /// [cardNumber] 银行卡号
  static ValidationResult validateBankCard(String cardNumber) {
    if (cardNumber.isEmpty) {
      return const ValidationResult(false, '请输入银行卡号');
    }

    // 移除空格
    final cleanCardNumber = cardNumber.replaceAll(' ', '');

    // 银行卡号长度验证 (通常15-19位)
    if (cleanCardNumber.length < 15 || cleanCardNumber.length > 19) {
      return const ValidationResult(false, '银行卡号长度不正确');
    }

    // 只能包含数字
    if (!RegExp(r'^\d+$').hasMatch(cleanCardNumber)) {
      return const ValidationResult(false, '银行卡号只能包含数字');
    }

    // Luhn算法验证
    if (!_validateLuhnAlgorithm(cleanCardNumber)) {
      return const ValidationResult(false, '银行卡号校验失败');
    }

    return const ValidationResult(true, '');
  }

  /// 验证验证码
  /// [code] 验证码
  /// [length] 期望长度
  static ValidationResult validateVerificationCode(String code, {int length = 6}) {
    if (code.isEmpty) {
      return const ValidationResult(false, '请输入验证码');
    }

    if (code.length != length) {
      return ValidationResult(false, '请输入$length位验证码');
    }

    if (!RegExp(r'^\d+$').hasMatch(code)) {
      return const ValidationResult(false, '验证码只能包含数字');
    }

    return const ValidationResult(true, '');
  }

  /// 验证姓名
  /// [name] 姓名
  /// [type] 姓名类型 ('chinese', 'english', 'mixed')
  static ValidationResult validateName(String name, {String type = 'chinese'}) {
    if (name.isEmpty) {
      return const ValidationResult(false, '请输入姓名');
    }

    switch (type.toLowerCase()) {
      case 'chinese':
        // 中文姓名: 2-4个中文字符
        if (!RegExp(r'^[\u4e00-\u9fa5]{2,4}$').hasMatch(name)) {
          return const ValidationResult(false, '请输入正确的中文姓名');
        }
        break;
      case 'english':
        // 英文姓名: 字母和空格
        if (!RegExp(r'^[a-zA-Z\s]{2,50}$').hasMatch(name)) {
          return const ValidationResult(false, '请输入正确的英文姓名');
        }
        break;
      case 'mixed':
        // 混合姓名: 中文、字母、空格
        if (!RegExp(r'^[\u4e00-\u9fa5a-zA-Z\s]{2,50}$').hasMatch(name)) {
          return const ValidationResult(false, '请输入正确的姓名');
        }
        break;
    }

    return const ValidationResult(true, '');
  }

  /// 验证交易密码
  /// [password] 交易密码
  /// [length] 期望长度 (通常6位)
  static ValidationResult validateTradingPassword(String password, {int length = 6}) {
    if (password.isEmpty) {
      return const ValidationResult(false, '请输入交易密码');
    }

    if (password.length != length) {
      return ValidationResult(false, '交易密码必须是$length位数字');
    }

    if (!RegExp(r'^\d+$').hasMatch(password)) {
      return const ValidationResult(false, '交易密码只能包含数字');
    }

    // 检查是否为简单密码 (如123456, 111111等)
    if (_isWeakTradingPassword(password)) {
      return const ValidationResult(false, '交易密码过于简单，请重新设置');
    }

    return const ValidationResult(true, '');
  }

  /// 验证URL
  /// [url] URL地址
  static ValidationResult validateUrl(String url) {
    if (url.isEmpty) {
      return const ValidationResult(false, '请输入URL地址');
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(url)) {
      return const ValidationResult(false, '请输入正确的URL地址');
    }

    return const ValidationResult(true, '');
  }

  /// 验证IP地址
  /// [ip] IP地址
  static ValidationResult validateIpAddress(String ip) {
    if (ip.isEmpty) {
      return const ValidationResult(false, '请输入IP地址');
    }

    final ipRegex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );

    if (!ipRegex.hasMatch(ip)) {
      return const ValidationResult(false, '请输入正确的IP地址');
    }

    return const ValidationResult(true, '');
  }

  /// 身份证校验码验证
  static bool _validateIdCardChecksum(String idCard) {
    const weights = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2];
    const checkCodes = ['1', '0', 'X', '9', '8', '7', '6', '5', '4', '3', '2'];

    int sum = 0;
    for (int i = 0; i < 17; i++) {
      sum += int.parse(idCard[i]) * weights[i];
    }

    final checkCodeIndex = sum % 11;
    final expectedCheckCode = checkCodes[checkCodeIndex];
    final actualCheckCode = idCard[17].toUpperCase();

    return actualCheckCode == expectedCheckCode;
  }

  /// 验证生日格式
  static bool _validateBirthDate(String birthDate) {
    if (birthDate.length != 8) return false;

    try {
      final year = int.parse(birthDate.substring(0, 4));
      final month = int.parse(birthDate.substring(4, 6));
      final day = int.parse(birthDate.substring(6, 8));

      // 年份范围验证
      final currentYear = DateTime.now().year;
      if (year < 1900 || year > currentYear) return false;

      // 月份验证
      if (month < 1 || month > 12) return false;

      // 日期验证
      final date = DateTime(year, month, day);
      return date.year == year && date.month == month && date.day == day;
    } catch (e) {
      return false;
    }
  }

  /// Luhn算法验证银行卡号
  static bool _validateLuhnAlgorithm(String cardNumber) {
    int sum = 0;
    bool alternate = false;

    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  /// 检查是否为弱交易密码
  static bool _isWeakTradingPassword(String password) {
    // 连续数字
    final consecutive = RegExp(r'^(012345|123456|234567|345678|456789|567890)$');
    if (consecutive.hasMatch(password)) return true;

    // 相同数字
    final same = RegExp(r'^(\d)\1+$');
    if (same.hasMatch(password)) return true;

    // 常见弱密码
    const weakPasswords = ['123456', '000000', '111111', '888888', '666666'];
    return weakPasswords.contains(password);
  }
}

/// 验证结果
class ValidationResult {
  final bool isValid;
  final String message;

  const ValidationResult(this.isValid, this.message);

  @override
  String toString() => 'ValidationResult(isValid: $isValid, message: $message)';
}