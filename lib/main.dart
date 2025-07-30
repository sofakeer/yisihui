import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/utils/app_startup_optimizer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置状态栏和导航栏样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // 设置屏幕方向为竖屏
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 优化启动性能
  await AppStartupOptimizer.optimizeStartup();
  
  // 运行应用
  runApp(
    const ProviderScope(
      child: YisihuiApp(),
    ),
  );
}