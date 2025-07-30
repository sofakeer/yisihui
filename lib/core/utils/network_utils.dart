import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

/// 网络工具类
/// 提供网络状态检查、网络请求配置、错误处理等功能
class NetworkUtils {
  /// 检查网络连接状态
  static Future<NetworkStatus> checkNetworkStatus() async {
    try {
      final connectivity = Connectivity();
      final connectivityResult = await connectivity.checkConnectivity();
      
      if (connectivityResult == ConnectivityResult.none) {
        return NetworkStatus.disconnected;
      }
      
      // 进一步检查网络可达性
      final isReachable = await isNetworkReachable();
      if (isReachable) {
        if (connectivityResult == ConnectivityResult.wifi) {
          return NetworkStatus.wifi;
        } else if (connectivityResult == ConnectivityResult.mobile) {
          return NetworkStatus.mobile;
        } else {
          return NetworkStatus.connected;
        }
      } else {
        return NetworkStatus.disconnected;
      }
    } catch (e) {
      return NetworkStatus.unknown;
    }
  }

  /// 检查网络是否可达
  /// [host] 测试主机 (默认使用Google DNS)
  /// [port] 测试端口
  /// [timeout] 超时时间
  static Future<bool> isNetworkReachable({
    String host = '8.8.8.8',
    int port = 53,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 检查指定URL是否可访问
  /// [url] 要检查的URL
  /// [timeout] 超时时间
  static Future<bool> isUrlReachable(
    String url, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = timeout;
      dio.options.receiveTimeout = timeout;
      
      final response = await dio.head(url);
      return response.statusCode != null && response.statusCode! < 400;
    } catch (e) {
      return false;
    }
  }

  /// 获取网络类型描述
  /// [status] 网络状态
  /// [locale] 本地化语言
  static String getNetworkStatusDescription(NetworkStatus status, {String locale = 'zh'}) {
    if (locale == 'zh') {
      switch (status) {
        case NetworkStatus.wifi:
          return 'WiFi连接';
        case NetworkStatus.mobile:
          return '移动网络';
        case NetworkStatus.connected:
          return '已连接';
        case NetworkStatus.disconnected:
          return '无网络连接';
        case NetworkStatus.unknown:
          return '网络状态未知';
      }
    } else {
      switch (status) {
        case NetworkStatus.wifi:
          return 'WiFi Connected';
        case NetworkStatus.mobile:
          return 'Mobile Connected';
        case NetworkStatus.connected:
          return 'Connected';
        case NetworkStatus.disconnected:
          return 'No Connection';
        case NetworkStatus.unknown:
          return 'Unknown';
      }
    }
  }

  /// 监听网络状态变化
  /// [onChanged] 状态变化回调
  static Stream<NetworkStatus> watchNetworkStatus() async* {
    final connectivity = Connectivity();
    await for (final connectivityResult in connectivity.onConnectivityChanged) {
      if (connectivityResult == ConnectivityResult.none) {
        yield NetworkStatus.disconnected;
      } else {
        final isReachable = await isNetworkReachable();
        if (isReachable) {
          if (connectivityResult == ConnectivityResult.wifi) {
            yield NetworkStatus.wifi;
          } else if (connectivityResult == ConnectivityResult.mobile) {
            yield NetworkStatus.mobile;
          } else {
            yield NetworkStatus.connected;
          }
        } else {
          yield NetworkStatus.disconnected;
        }
      }
    }
  }

  /// 创建基础Dio配置
  /// [baseUrl] 基础URL
  /// [connectTimeout] 连接超时时间
  /// [receiveTimeout] 接收超时时间
  /// [sendTimeout] 发送超时时间
  static Dio createDio({
    String? baseUrl,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 10),
    Duration sendTimeout = const Duration(seconds: 10),
  }) {
    final dio = Dio();
    
    dio.options.baseUrl = baseUrl ?? '';
    dio.options.connectTimeout = connectTimeout;
    dio.options.receiveTimeout = receiveTimeout;
    dio.options.sendTimeout = sendTimeout;
    
    // 添加通用请求头
    dio.options.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });
    
    return dio;
  }

  /// 添加请求拦截器
  /// [dio] Dio实例
  /// [onRequest] 请求拦截回调
  /// [onResponse] 响应拦截回调
  /// [onError] 错误拦截回调
  static void addInterceptors(
    Dio dio, {
    Function(RequestOptions)? onRequest,
    Function(Response)? onResponse,
    Function(DioException)? onError,
  }) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          onRequest?.call(options);
          handler.next(options);
        },
        onResponse: (response, handler) {
          onResponse?.call(response);
          handler.next(response);
        },
        onError: (error, handler) {
          onError?.call(error);
          handler.next(error);
        },
      ),
    );
  }

  /// 处理网络错误
  /// [error] Dio错误对象
  /// [locale] 本地化语言
  static NetworkError handleDioError(DioException error, {String locale = 'zh'}) {
    String message;
    NetworkErrorType type;
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        type = NetworkErrorType.connectionTimeout;
        message = locale == 'zh' ? '连接超时' : 'Connection timeout';
        break;
      case DioExceptionType.sendTimeout:
        type = NetworkErrorType.sendTimeout;
        message = locale == 'zh' ? '发送超时' : 'Send timeout';
        break;
      case DioExceptionType.receiveTimeout:
        type = NetworkErrorType.receiveTimeout;
        message = locale == 'zh' ? '接收超时' : 'Receive timeout';
        break;
      case DioExceptionType.badResponse:
        type = NetworkErrorType.badResponse;
        final statusCode = error.response?.statusCode ?? 0;
        message = _getStatusCodeMessage(statusCode, locale);
        break;
      case DioExceptionType.cancel:
        type = NetworkErrorType.cancelled;
        message = locale == 'zh' ? '请求已取消' : 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        type = NetworkErrorType.connectionError;
        message = locale == 'zh' ? '连接错误' : 'Connection error';
        break;
      case DioExceptionType.badCertificate:
        type = NetworkErrorType.badCertificate;
        message = locale == 'zh' ? '证书验证失败' : 'Bad certificate';
        break;
      case DioExceptionType.unknown:
      default:
        type = NetworkErrorType.unknown;
        message = locale == 'zh' ? '未知错误' : 'Unknown error';
        break;
    }
    
    return NetworkError(
      type: type,
      message: message,
      statusCode: error.response?.statusCode,
      data: error.response?.data,
    );
  }

  /// 获取HTTP状态码对应的错误信息
  static String _getStatusCodeMessage(int statusCode, String locale) {
    if (locale == 'zh') {
      switch (statusCode) {
        case 400:
          return '请求参数错误';
        case 401:
          return '未授权，请重新登录';
        case 403:
          return '拒绝访问';
        case 404:
          return '请求的资源不存在';
        case 405:
          return '请求方法不允许';
        case 408:
          return '请求超时';
        case 409:
          return '请求冲突';
        case 422:
          return '请求参数验证失败';
        case 429:
          return '请求过于频繁';
        case 500:
          return '服务器内部错误';
        case 502:
          return '网关错误';
        case 503:
          return '服务暂时不可用';
        case 504:
          return '网关超时';
        default:
          return '服务器错误 ($statusCode)';
      }
    } else {
      switch (statusCode) {
        case 400:
          return 'Bad Request';
        case 401:
          return 'Unauthorized';
        case 403:
          return 'Forbidden';
        case 404:
          return 'Not Found';
        case 405:
          return 'Method Not Allowed';
        case 408:
          return 'Request Timeout';
        case 409:
          return 'Conflict';
        case 422:
          return 'Unprocessable Entity';
        case 429:
          return 'Too Many Requests';
        case 500:
          return 'Internal Server Error';
        case 502:
          return 'Bad Gateway';
        case 503:
          return 'Service Unavailable';
        case 504:
          return 'Gateway Timeout';
        default:
          return 'Server Error ($statusCode)';
      }
    }
  }

  /// 创建取消令牌
  static CancelToken createCancelToken() {
    return CancelToken();
  }

  /// 下载文件
  /// [url] 下载URL
  /// [savePath] 保存路径
  /// [onProgress] 进度回调
  /// [cancelToken] 取消令牌
  static Future<bool> downloadFile(
    String url,
    String savePath, {
    Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final dio = createDio();
      await dio.download(
        url,
        savePath,
        onReceiveProgress: onProgress,
        cancelToken: cancelToken,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 上传文件
  /// [url] 上传URL
  /// [filePath] 文件路径
  /// [fieldName] 表单字段名
  /// [onProgress] 进度回调
  /// [cancelToken] 取消令牌
  static Future<Response?> uploadFile(
    String url,
    String filePath, {
    String fieldName = 'file',
    Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
    Map<String, dynamic>? data,
  }) async {
    try {
      final dio = createDio();
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (data != null) ...data,
      });
      
      return await dio.post(
        url,
        data: formData,
        onSendProgress: onProgress,
        cancelToken: cancelToken,
      );
    } catch (e) {
      return null;
    }
  }

  /// 获取网络速度 (简单测试)
  /// [testUrl] 测试URL
  /// [testSize] 测试数据大小 (字节)
  static Future<NetworkSpeed> measureNetworkSpeed({
    String testUrl = 'https://www.google.com',
    int testSize = 1024 * 1024, // 1MB
  }) async {
    try {
      final stopwatch = Stopwatch()..start();
      
      final dio = createDio();
      await dio.get(testUrl);
      
      stopwatch.stop();
      
      final timeInSeconds = stopwatch.elapsedMilliseconds / 1000.0;
      final speedBps = testSize / timeInSeconds;
      final speedKbps = speedBps / 1024;
      final speedMbps = speedKbps / 1024;
      
      return NetworkSpeed(
        bytesPerSecond: speedBps,
        kilobytesPerSecond: speedKbps,
        megabytesPerSecond: speedMbps,
      );
    } catch (e) {
      return const NetworkSpeed(
        bytesPerSecond: 0,
        kilobytesPerSecond: 0,
        megabytesPerSecond: 0,
      );
    }
  }
}

/// 网络状态枚举
enum NetworkStatus {
  wifi,
  mobile,
  connected,
  disconnected,
  unknown,
}

/// 网络错误类型
enum NetworkErrorType {
  connectionTimeout,
  sendTimeout,
  receiveTimeout,
  badResponse,
  cancelled,
  connectionError,
  badCertificate,
  unknown,
}

/// 网络错误信息
class NetworkError {
  final NetworkErrorType type;
  final String message;
  final int? statusCode;
  final dynamic data;

  const NetworkError({
    required this.type,
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'NetworkError(type: $type, message: $message, statusCode: $statusCode)';
}

/// 网络速度信息
class NetworkSpeed {
  final double bytesPerSecond;
  final double kilobytesPerSecond;
  final double megabytesPerSecond;

  const NetworkSpeed({
    required this.bytesPerSecond,
    required this.kilobytesPerSecond,
    required this.megabytesPerSecond,
  });

  @override
  String toString() => 'NetworkSpeed(${megabytesPerSecond.toStringAsFixed(2)} Mbps)';
}