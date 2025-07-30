import 'dart:math';
import 'package:intl/intl.dart';

/// 金融计算工具类
/// 处理金额格式化、汇率计算、精度控制等
class MoneyUtils {
  /// 默认货币精度
  static const int defaultScale = 2;
  
  /// 汇率计算精度
  static const int exchangeRateScale = 6;

  /// 格式化金额显示
  /// [amount] 金额
  /// [currencyCode] 货币代码 (如 'CNY', 'USD')
  /// [locale] 本地化 (如 'zh_CN', 'en_US')
  /// [scale] 小数位数
  static String formatMoney(
    double amount, {
    String currencyCode = 'CNY',
    String locale = 'zh_CN',
    int scale = defaultScale,
  }) {
    try {
      final formatter = NumberFormat.currency(
        locale: locale,
        symbol: _getCurrencySymbol(currencyCode),
        decimalDigits: scale,
      );
      return formatter.format(amount);
    } catch (e) {
      // 降级处理
      return '${_getCurrencySymbol(currencyCode)} ${amount.toStringAsFixed(scale)}';
    }
  }

  /// 格式化金额 (无货币符号)
  /// [amount] 金额
  /// [scale] 小数位数
  /// [useThousandsSeparator] 是否使用千分位分隔符
  static String formatAmount(
    double amount, {
    int scale = defaultScale,
    bool useThousandsSeparator = true,
  }) {
    if (useThousandsSeparator) {
      final formatter = NumberFormat('#,##0.${'0' * scale}');
      return formatter.format(amount);
    } else {
      return amount.toStringAsFixed(scale);
    }
  }

  /// 解析金额字符串为double
  /// [amountStr] 金额字符串
  static double parseAmount(String amountStr) {
    if (amountStr.isEmpty) return 0.0;
    
    // 移除货币符号和千分位分隔符
    String cleanStr = amountStr
        .replaceAll(RegExp(r'[¥$€£,\s]'), '')
        .trim();
    
    try {
      return double.parse(cleanStr);
    } catch (e) {
      return 0.0;
    }
  }

  /// 汇率转换
  /// [amount] 原始金额
  /// [rate] 汇率
  /// [scale] 结果保留小数位数
  static double convertCurrency(
    double amount,
    double rate, {
    int scale = defaultScale,
  }) {
    if (rate <= 0) return 0.0;
    
    final result = amount * rate;
    final factor = pow(10, scale);
    return (result * factor).round() / factor;
  }

  /// 计算汇率
  /// [fromAmount] 原货币金额
  /// [toAmount] 目标货币金额
  static double calculateExchangeRate(double fromAmount, double toAmount) {
    if (fromAmount <= 0) return 0.0;
    return toAmount / fromAmount;
  }

  /// 金额加法 (避免浮点数精度问题)
  static double add(double a, double b, {int scale = defaultScale}) {
    final factor = pow(10, scale);
    final result = ((a * factor) + (b * factor)) / factor;
    return double.parse(result.toStringAsFixed(scale));
  }

  /// 金额减法 (避免浮点数精度问题)
  static double subtract(double a, double b, {int scale = defaultScale}) {
    final factor = pow(10, scale);
    final result = ((a * factor) - (b * factor)) / factor;
    return double.parse(result.toStringAsFixed(scale));
  }

  /// 金额乘法 (避免浮点数精度问题)
  static double multiply(double a, double b, {int scale = defaultScale}) {
    final result = (a * b);
    return double.parse(result.toStringAsFixed(scale));
  }

  /// 金额除法 (避免浮点数精度问题)
  static double divide(double a, double b, {int scale = defaultScale}) {
    if (b == 0) return 0.0;
    final result = a / b;
    return double.parse(result.toStringAsFixed(scale));
  }

  /// 验证金额格式
  /// [amountStr] 金额字符串
  /// [maxAmount] 最大金额限制
  /// [minAmount] 最小金额限制
  static AmountValidationResult validateAmount(
    String amountStr, {
    double? maxAmount,
    double? minAmount,
  }) {
    if (amountStr.isEmpty) {
      return const AmountValidationResult(false, '请输入金额');
    }

    // 验证格式
    final amountRegex = RegExp(r'^\d+(\.\d{1,2})?$');
    if (!amountRegex.hasMatch(amountStr)) {
      return const AmountValidationResult(false, '金额格式不正确');
    }

    final amount = double.tryParse(amountStr);
    if (amount == null) {
      return const AmountValidationResult(false, '金额格式不正确');
    }

    // 验证范围
    if (minAmount != null && amount < minAmount) {
      return AmountValidationResult(false, '金额不能小于${formatAmount(minAmount)}');
    }

    if (maxAmount != null && amount > maxAmount) {
      return AmountValidationResult(false, '金额不能大于${formatAmount(maxAmount)}');
    }

    return const AmountValidationResult(true, '');
  }

  /// 计算手续费
  /// [amount] 交易金额
  /// [feeRate] 手续费率 (如 0.001 表示 0.1%)
  /// [minFee] 最小手续费
  /// [maxFee] 最大手续费
  static double calculateFee(
    double amount,
    double feeRate, {
    double minFee = 0.0,
    double? maxFee,
  }) {
    double fee = multiply(amount, feeRate);
    
    if (fee < minFee) {
      fee = minFee;
    }
    
    if (maxFee != null && fee > maxFee) {
      fee = maxFee;
    }
    
    return fee;
  }

  /// 格式化汇率显示
  /// [rate] 汇率
  /// [scale] 保留小数位数
  static String formatExchangeRate(double rate, {int scale = 4}) {
    if (rate <= 0) return '0.0000';
    return rate.toStringAsFixed(scale);
  }

  /// 计算汇率差异百分比
  /// [currentRate] 当前汇率
  /// [previousRate] 之前汇率
  static double calculateRateChangePercentage(double currentRate, double previousRate) {
    if (previousRate <= 0) return 0.0;
    return ((currentRate - previousRate) / previousRate) * 100;
  }

  /// 格式化汇率变化
  /// [changePercentage] 变化百分比
  static String formatRateChange(double changePercentage) {
    final sign = changePercentage >= 0 ? '+' : '';
    return '$sign${changePercentage.toStringAsFixed(2)}%';
  }

  /// 获取货币符号
  static String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'CNY':
        return '¥';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'KRW':
        return '₩';
      case 'HKD':
        return 'HK\$';
      case 'SGD':
        return 'S\$';
      case 'AUD':
        return 'A\$';
      case 'CAD':
        return 'C\$';
      default:
        return currencyCode;
    }
  }

  /// 检查是否为有效的金额
  static bool isValidAmount(double amount) {
    return amount.isFinite && amount >= 0;
  }

  /// 转换为分 (避免小数计算误差)
  static int toCents(double amount) {
    return (amount * 100).round();
  }

  /// 从分转换为元
  static double fromCents(int cents) {
    return cents / 100.0;
  }

  /// 比较两个金额是否相等 (考虑精度)
  static bool isEqual(double a, double b, {int scale = defaultScale}) {
    final factor = pow(10, scale);
    return ((a * factor).round() - (b * factor).round()).abs() < 1;
  }

  /// 获取支持的货币列表
  static List<CurrencyInfo> getSupportedCurrencies() {
    return [
      const CurrencyInfo('CNY', '人民币', '¥'),
      const CurrencyInfo('USD', '美元', '\$'),
      const CurrencyInfo('EUR', '欧元', '€'),
      const CurrencyInfo('GBP', '英镑', '£'),
      const CurrencyInfo('JPY', '日元', '¥'),
      const CurrencyInfo('KRW', '韩元', '₩'),
      const CurrencyInfo('HKD', '港币', 'HK\$'),
      const CurrencyInfo('SGD', '新加坡元', 'S\$'),
      const CurrencyInfo('AUD', '澳元', 'A\$'),
      const CurrencyInfo('CAD', '加元', 'C\$'),
    ];
  }
}

/// 金额验证结果
class AmountValidationResult {
  final bool isValid;
  final String message;

  const AmountValidationResult(this.isValid, this.message);
}

/// 货币信息
class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;

  const CurrencyInfo(this.code, this.name, this.symbol);
}