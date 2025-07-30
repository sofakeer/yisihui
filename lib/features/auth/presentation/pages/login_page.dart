import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/custom_text_field.dart';

/// 登录页面
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Logo和标题
                _buildHeader(),
                
                const SizedBox(height: 48),
                
                // 登录表单
                _buildLoginForm(),
                
                const SizedBox(height: 24),
                
                // 登录按钮
                _buildLoginButton(),
                
                const SizedBox(height: 16),
                
                // 其他登录方式
                _buildAlternativeLogin(),
                
                const SizedBox(height: 32),
                
                // 注册链接
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: 32,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 标题
        const Text(
          '欢迎回来',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.grey900,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // 副标题
        Text(
          '登录您的易思汇账户',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.grey600,
          ),
        ),
      ],
    );
  }

  /// 构建登录表单
  Widget _buildLoginForm() {
    return Column(
      children: [
        // 手机号输入框
        CustomTextField(
          controller: _phoneController,
          labelText: '手机号',
          hintText: '请输入手机号',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入手机号';
            }
            if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
              return '请输入正确的手机号';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // 密码输入框
        CustomTextField(
          controller: _passwordController,
          labelText: '密码',
          hintText: '请输入密码',
          prefixIcon: Icons.lock_outlined,
          obscureText: !_isPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: AppTheme.grey500,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入密码';
            }
            if (value.length < 6) {
              return '密码长度不能少于6位';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 8),
        
        // 忘记密码
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // TODO: 跳转到忘记密码页面
            },
            child: const Text('忘记密码？'),
          ),
        ),
      ],
    );
  }

  /// 构建登录按钮
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('登录'),
      ),
    );
  }

  /// 构建其他登录方式
  Widget _buildAlternativeLogin() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '或',
                style: TextStyle(
                  color: AppTheme.grey500,
                  fontSize: 14,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 验证码登录
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: 跳转到验证码登录页面
            },
            icon: const Icon(Icons.sms_outlined),
            label: const Text('验证码登录'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.grey300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建注册链接
  Widget _buildRegisterLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '还没有账户？',
            style: TextStyle(
              color: AppTheme.grey600,
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: () {
              context.push('/register');
            },
            child: const Text('立即注册'),
          ),
        ],
      ),
    );
  }

  /// 处理登录
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 实现登录逻辑
      await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求
      
      if (mounted) {
        // 登录成功，跳转到首页
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登录失败：${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}