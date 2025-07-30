import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/theme/app_theme.dart';

/// 首页
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('易思汇'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: 实现通知功能
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户欢迎卡片
            _buildWelcomeCard(context),
            
            const SizedBox(height: 24),
            
            // 快捷功能区
            _buildQuickActions(context),
            
            const SizedBox(height: 24),
            
            // 最新汇率
            _buildExchangeRates(context),
            
            const SizedBox(height: 24),
            
            // 最近交易
            _buildRecentTransactions(context),
          ],
        ),
      ),
    );
  }

  /// 构建欢迎卡片
  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '欢迎回来！',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '让留学缴费变得更简单',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildBalanceInfo('钱包余额', '¥ 0.00'),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildBalanceInfo('可用额度', '¥ 50,000.00'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建余额信息
  Widget _buildBalanceInfo(String title, String amount) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// 构建快捷功能
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快捷功能',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.school,
                title: '学费缴费',
                subtitle: '安全便捷',
                color: AppTheme.primaryColor,
                onTap: () {
                  // TODO: 跳转到学费缴费页面
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.send_to_mobile,
                title: '汇款转账',
                subtitle: '快速到账',
                color: AppTheme.secondaryColor,
                onTap: () {
                  // TODO: 跳转到汇款转账页面
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.account_balance_wallet,
                title: '钱包充值',
                subtitle: '多种方式',
                color: AppTheme.accentColor,
                onTap: () {
                  // TODO: 跳转到钱包充值页面
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.currency_exchange,
                title: '汇率查询',
                subtitle: '实时更新',
                color: Colors.purple,
                onTap: () {
                  // TODO: 跳转到汇率查询页面
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建功能卡片
  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.grey500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建汇率信息
  Widget _buildExchangeRates(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '实时汇率',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: 跳转到汇率详情页
              },
              child: const Text('查看更多'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildRateItem('USD/CNY', '7.2456', '+0.0123'),
                const Divider(),
                _buildRateItem('EUR/CNY', '7.8901', '-0.0045'),
                const Divider(),
                _buildRateItem('GBP/CNY', '9.1234', '+0.0087'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建汇率项目
  Widget _buildRateItem(String pair, String rate, String change) {
    final isPositive = change.startsWith('+');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          pair,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              rate,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              change,
              style: TextStyle(
                fontSize: 12,
                color: isPositive ? AppTheme.secondaryColor : AppTheme.errorColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建最近交易
  Widget _buildRecentTransactions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '最近交易',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: 跳转到交易记录页
              },
              child: const Text('查看全部'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: AppTheme.grey400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无交易记录',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.grey500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '开始您的第一笔交易吧',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.grey400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}