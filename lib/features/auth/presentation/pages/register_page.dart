import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/custom_text_field.dart';

/// 注册页面
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  int _countdown = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                _buildHeader(),
                
                const SizedBox(height: 32),
                
                // 注册表单
                _buildRegisterForm(),
                
                const SizedBox(height: 16),
                
                // 服务条款
                _buildTermsAgreement(),
                
                const SizedBox(height: 24),
                
                // 注册按钮
                _buildRegisterButton(),
                
                const SizedBox(height: 24),
                
                // 登录链接
                _buildLoginLink(),
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
        const Text(
          '创建账户',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.grey900,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          '加入易思汇，让留学缴费更简单',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.grey600,
          ),
        ),
      ],
    );
  }

  /// 构建注册表单
  Widget _buildRegisterForm() {
    return Column(
      children: [
        // 手机号输入框
        Row(
          children: [
            Expanded(
              child: CustomTextField(
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
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: _countdown > 0 ? null : _sendVerificationCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _countdown > 0 ? AppTheme.grey300 : AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  _countdown > 0 ? '${_countdown}s' : '获取验证码',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 验证码输入框
        CustomTextField(
          controller: _codeController,
          labelText: '验证码',
          hintText: '请输入验证码',
          prefixIcon: Icons.verified_user_outlined,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入验证码';
            }
            if (value.length != 6) {
              return '请输入6位验证码';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // 密码输入框
        CustomTextField(
          controller: _passwordController,
          labelText: '设置密码',
          hintText: '请设置登录密码',
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
            if (value.length < 8) {
              return '密码长度不能少于8位';
            }
            if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
              return '密码必须包含字母和数字';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // 确认密码输入框
        CustomTextField(
          controller: _confirmPasswordController,
          labelText: '确认密码',
          hintText: '请再次输入密码',
          prefixIcon: Icons.lock_outlined,
          obscureText: !_isConfirmPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: AppTheme.grey500,
            ),
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请确认密码';
            }
            if (value != _passwordController.text) {
              return '两次输入的密码不一致';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 构建服务条款同意
  Widget _buildTermsAgreement() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (value) {
            setState(() {
              _agreeToTerms = value ?? false;
            });
          },
          activeColor: AppTheme.primaryColor,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _agreeToTerms = !_agreeToTerms;
              });
            },
            child: Text.rich(
              TextSpan(
                text: '我已阅读并同意',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.grey600,
                ),
                children: [
                  TextSpan(
                    text: '《用户协议》',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: '和'),
                  TextSpan(
                    text: '《隐私政策》',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建注册按钮
  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: (_isLoading || !_agreeToTerms) ? null : _handleRegister,
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('注册'),
      ),
    );
  }

  /// 构建登录链接
  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '已有账户？',
            style: TextStyle(
              color: AppTheme.grey600,
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: const Text('立即登录'),
          ),
        ],
      ),
    );
  }

  /// 发送验证码
  Future<void> _sendVerificationCode() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入手机号')),
      );
      return;
    }

    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(_phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入正确的手机号')),
      );
      return;
    }

    // TODO: 实现发送验证码逻辑
    setState(() {
      _countdown = 60;
    });

    // 倒计时
    _startCountdown();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('验证码已发送')),
    );
  }

  /// 开始倒计时
  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_countdown > 0 && mounted) {
        setState(() {
          _countdown--;
        });
        _startCountdown();
      }
    });
  }

  /// 处理注册
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请同意用户协议和隐私政策')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 实现注册逻辑
      await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求
      
      if (mounted) {
        // 注册成功
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('注册成功！'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
        
        // 跳转到登录页面
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('注册失败：${e.toString()}'),
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