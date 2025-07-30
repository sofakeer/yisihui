import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../shared/theme/app_theme.dart';
import '../shared/providers/theme_provider.dart';
import 'router/app_router.dart';

class YisihuiApp extends ConsumerWidget {
  const YisihuiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: '易思汇',
      debugShowCheckedModeBanner: false,
      
      // 主题配置
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      
      // 国际化配置
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'), // 简体中文
        Locale('en', 'US'), // 英语
      ],
      locale: const Locale('zh', 'CN'),
      
      // 路由配置
      routerConfig: router,
    );
  }
}