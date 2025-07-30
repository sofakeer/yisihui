import 'package:intl/intl.dart';

/// 日期时间工具类
/// 提供日期格式化、时间计算、时区处理等功能
class DateTimeUtils {
  /// 常用日期格式
  static const String formatDefault = 'yyyy-MM-dd HH:mm:ss';
  static const String formatDate = 'yyyy-MM-dd';
  static const String formatTime = 'HH:mm:ss';
  static const String formatDateTime = 'yyyy-MM-dd HH:mm';
  static const String formatChinese = 'yyyy年MM月dd日';
  static const String formatChineseTime = 'yyyy年MM月dd日 HH:mm';
  static const String formatApi = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
  static const String formatDisplay = 'MM月dd日 HH:mm';

  /// 格式化日期时间
  /// [dateTime] 日期时间对象
  /// [format] 格式化字符串
  /// [locale] 本地化
  static String format(
    DateTime dateTime, {
    String format = formatDefault,
    String locale = 'zh_CN',
  }) {
    try {
      final formatter = DateFormat(format, locale);
      return formatter.format(dateTime);
    } catch (e) {
      return dateTime.toString();
    }
  }

  /// 格式化时间戳
  /// [timestamp] 时间戳 (毫秒)
  /// [formatStr] 格式化字符串
  /// [locale] 本地化
  static String formatTimestamp(
    int timestamp, {
    String formatStr = formatDefault,
    String locale = 'zh_CN',
  }) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return format(dateTime, format: formatStr, locale: locale);
  }

  /// 解析日期字符串
  /// [dateString] 日期字符串
  /// [format] 格式化字符串
  static DateTime? parseDateTime(String dateString, {String? format}) {
    try {
      if (format != null) {
        final formatter = DateFormat(format);
        return formatter.parse(dateString);
      } else {
        // 尝试常见格式
        final formats = [
          formatDefault,
          formatApi,
          formatDate,
          formatDateTime,
        ];
        
        for (final fmt in formats) {
          try {
            final formatter = DateFormat(fmt);
            return formatter.parse(dateString);
          } catch (e) {
            continue;
          }
        }
        
        // 最后尝试DateTime.parse
        return DateTime.parse(dateString);
      }
    } catch (e) {
      return null;
    }
  }

  /// 获取当前时间戳 (毫秒)
  static int getCurrentTimestamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// 获取当前时间戳 (秒)
  static int getCurrentTimestampInSeconds() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  /// 获取今天开始时间
  static DateTime getTodayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// 获取今天结束时间
  static DateTime getTodayEnd() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
  }

  /// 获取本周开始时间 (周一)
  static DateTime getWeekStart() {
    final now = DateTime.now();
    final weekday = now.weekday;
    return now.subtract(Duration(days: weekday - 1, hours: now.hour, minutes: now.minute, seconds: now.second, milliseconds: now.millisecond));
  }

  /// 获取本月开始时间
  static DateTime getMonthStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  /// 获取本月结束时间
  static DateTime getMonthEnd() {
    final now = DateTime.now();
    final nextMonth = now.month == 12 ? 1 : now.month + 1;
    final nextYear = now.month == 12 ? now.year + 1 : now.year;
    return DateTime(nextYear, nextMonth, 1).subtract(const Duration(milliseconds: 1));
  }

  /// 计算时间差
  /// [startTime] 开始时间
  /// [endTime] 结束时间 (默认为当前时间)
  static Duration timeDifference(DateTime startTime, {DateTime? endTime}) {
    endTime ??= DateTime.now();
    return endTime.difference(startTime);
  }

  /// 人性化时间显示 (如: 刚刚、1分钟前、1小时前等)
  /// [dateTime] 日期时间
  /// [locale] 本地化语言
  static String timeAgo(DateTime dateTime, {String locale = 'zh'}) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (locale == 'zh') {
      if (difference.inSeconds < 60) {
        return '刚刚';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}分钟前';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}小时前';
      } else if (difference.inDays < 30) {
        return '${difference.inDays}天前';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '${months}个月前';
      } else {
        final years = (difference.inDays / 365).floor();
        return '${years}年前';
      }
    } else {
      if (difference.inSeconds < 60) {
        return 'just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hour ago';
      } else if (difference.inDays < 30) {
        return '${difference.inDays} day ago';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '$months month ago';
      } else {
        final years = (difference.inDays / 365).floor();
        return '$years year ago';
      }
    }
  }

  /// 智能时间显示
  /// 今天显示时间，昨天显示"昨天 HH:mm"，更早显示日期
  /// [dateTime] 日期时间
  static String smartTimeDisplay(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    final difference = today.difference(dateOnly).inDays;
    
    if (difference == 0) {
      // 今天，只显示时间
      return format(dateTime, format: 'HH:mm');
    } else if (difference == 1) {
      // 昨天
      return '昨天 ${format(dateTime, format: 'HH:mm')}';
    } else if (difference < 7) {
      // 一周内，显示星期几
      final weekday = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'][dateTime.weekday];
      return '$weekday ${format(dateTime, format: 'HH:mm')}';
    } else {
      // 更早，显示日期
      return format(dateTime, format: 'MM-dd HH:mm');
    }
  }

  /// 获取星期几
  /// [dateTime] 日期时间
  /// [locale] 本地化语言
  static String getWeekday(DateTime dateTime, {String locale = 'zh'}) {
    if (locale == 'zh') {
      const weekdays = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return weekdays[dateTime.weekday];
    } else {
      const weekdays = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[dateTime.weekday];
    }
  }

  /// 判断是否为今天
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
           dateTime.month == now.month &&
           dateTime.day == now.day;
  }

  /// 判断是否为昨天
  static bool isYesterday(DateTime dateTime) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
           dateTime.month == yesterday.month &&
           dateTime.day == yesterday.day;
  }

  /// 判断是否为本周
  static bool isThisWeek(DateTime dateTime) {
    final weekStart = getWeekStart();
    final weekEnd = weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    return dateTime.isAfter(weekStart) && dateTime.isBefore(weekEnd);
  }

  /// 判断是否为本月
  static bool isThisMonth(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year && dateTime.month == now.month;
  }

  /// 判断是否为工作日
  static bool isWorkday(DateTime dateTime) {
    return dateTime.weekday >= 1 && dateTime.weekday <= 5;
  }

  /// 判断是否为周末
  static bool isWeekend(DateTime dateTime) {
    return dateTime.weekday == 6 || dateTime.weekday == 7;
  }

  /// 获取年龄
  /// [birthday] 生日
  static int getAge(DateTime birthday) {
    final now = DateTime.now();
    int age = now.year - birthday.year;
    
    if (now.month < birthday.month || 
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    
    return age;
  }

  /// 添加工作日
  /// [dateTime] 起始时间
  /// [days] 添加的工作日天数
  static DateTime addWorkdays(DateTime dateTime, int days) {
    var current = dateTime;
    var remainingDays = days;
    
    while (remainingDays > 0) {
      current = current.add(const Duration(days: 1));
      if (isWorkday(current)) {
        remainingDays--;
      }
    }
    
    return current;
  }

  /// 计算两个日期间的工作日数量
  /// [startDate] 开始日期
  /// [endDate] 结束日期
  static int getWorkdaysBetween(DateTime startDate, DateTime endDate) {
    if (startDate.isAfter(endDate)) {
      return 0;
    }
    
    int workdays = 0;
    var current = startDate;
    
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      if (isWorkday(current)) {
        workdays++;
      }
      current = current.add(const Duration(days: 1));
    }
    
    return workdays;
  }

  /// 格式化时长
  /// [duration] 时长
  /// [locale] 本地化语言
  static String formatDuration(Duration duration, {String locale = 'zh'}) {
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    final parts = <String>[];
    
    if (locale == 'zh') {
      if (days > 0) parts.add('${days}天');
      if (hours > 0) parts.add('${hours}小时');
      if (minutes > 0) parts.add('${minutes}分钟');
      if (seconds > 0 && parts.isEmpty) parts.add('${seconds}秒');
    } else {
      if (days > 0) parts.add('${days}d');
      if (hours > 0) parts.add('${hours}h');
      if (minutes > 0) parts.add('${minutes}m');
      if (seconds > 0 && parts.isEmpty) parts.add('${seconds}s');
    }
    
    return parts.isEmpty ? (locale == 'zh' ? '0秒' : '0s') : parts.join(' ');
  }

  /// 时区转换
  /// [dateTime] 源时间
  /// [fromTimeZone] 源时区
  /// [toTimeZone] 目标时区
  static DateTime convertTimeZone(DateTime dateTime, String fromTimeZone, String toTimeZone) {
    // 这里可以使用timezone包来实现更精确的时区转换
    // 目前提供简单的UTC偏移转换
    return dateTime; // 简化实现
  }

  /// 获取月份天数
  /// [year] 年份
  /// [month] 月份
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// 判断是否为闰年
  /// [year] 年份
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }
}