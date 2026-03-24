import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'change_password_page.dart';

class EmailLoginPage extends StatefulWidget {
  const EmailLoginPage({
    super.key,
    this.backgroundAsset = 'assent/背景.png',
    this.mascotAsset = 'assent/email_login.png',
    this.onSkipLogin,
    this.onForgetPassword,
    this.onRegister,
    this.onSubmit,
    this.onAgreementLinkTap,
  });

  final String backgroundAsset;
  final String mascotAsset;
  final VoidCallback? onSkipLogin;
  final VoidCallback? onForgetPassword;
  final VoidCallback? onRegister;
  final VoidCallback? onSubmit;
  final VoidCallback? onAgreementLinkTap;

  @override
  State<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  static const double _hPad = 24.0;
  static final _emailReg = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');

  bool _agreed = false;
  bool _obscurePassword = true;
  bool _loading = false;

  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _pwdFocus = FocusNode();

  String? _emailError;
  String? _pwdError;

  bool get _canSubmit =>
      _emailCtrl.text.isNotEmpty && _pwdCtrl.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(() => setState(() {}));
    _pwdCtrl.addListener(() => setState(() {}));
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) {
        _validateEmail();
      } else {
        setState(() {});
      }
    });
    _pwdFocus.addListener(() {
      if (!_pwdFocus.hasFocus) {
        _validatePassword();
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _emailFocus.dispose();
    _pwdFocus.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final v = _emailCtrl.text.trim();
    setState(() {
      _emailError = v.isEmpty
          ? null
          : _emailReg.hasMatch(v)
              ? null
              : '请输入正确的邮箱格式';
    });
  }

  void _validatePassword() {
    final v = _pwdCtrl.text;
    setState(() {
      _pwdError = v.isEmpty
          ? null
          : v.length < 6
              ? '密码至少6位'
              : null;
    });
  }

  Future<void> _handleSubmit() async {
    _validateEmail();
    _validatePassword();
    if (_emailError != null || _pwdError != null) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先阅读并同意用户协议与隐私条款')),
      );
      return;
    }
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);
    widget.onSubmit?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8FA),
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(widget.backgroundAsset, fit: BoxFit.cover),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2, right: 16),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: widget.onSkipLogin,
                        behavior: HitTestBehavior.opaque,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('跳过登陆',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF05051A),
                                    fontFamily: 'PingFang SC')),
                            SizedBox(width: 4),
                            Icon(Icons.chevron_right,
                                size: 14, color: Color(0xFF05051A)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildBody(context),
                    ),
                  ),
                  _buildOtherLogin(),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    const double clipH = 190.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: clipH,
          child: ClipRect(
            child: Stack(
              children: [
                Positioned(
                  top: 12,
                  right: _hPad,
                  child: Image.asset(widget.mascotAsset,
                      width: 228, fit: BoxFit.fitWidth),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _hPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const SizedBox(
                        height: 80,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text('邮箱登陆',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF05051A),
                                  fontFamily: 'PingFang SC',
                                  height: 1.0)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _label('邮箱号'),
                      const SizedBox(height: 12),
                      _buildEmailField(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _hPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_emailError != null) ...[
                const SizedBox(height: 4),
                _errorText(_emailError!),
              ],
              const SizedBox(height: 26),
              _label('密码'),
              const SizedBox(height: 12),
              _buildPasswordField(),
              if (_pwdError != null) ...[
                const SizedBox(height: 4),
                _errorText(_pwdError!),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _grayText('忘记密码',
                      onTap: widget.onForgetPassword ??
                          () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const ChangePasswordPage()),
                              )),
                  _grayText('注册账号',
                      onTap: widget.onRegister ??
                          () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                    builder: (_) => const ChangePasswordPage(
                                        title: '注册',
                                        mascotAsset: 'assent/register.png')),
                              )),
                ],
              ),
              const SizedBox(height: 24),
              _submitButton(),
              const SizedBox(height: 24),
              Center(child: _agreementRow()),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _emailFocus.hasFocus
              ? const Color(0xFF6E8DF5)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _emailCtrl,
        focusNode: _emailFocus,
        keyboardType: TextInputType.emailAddress,
        onChanged: (_) {
          if (_emailError != null) _validateEmail();
        },
        style: const TextStyle(
            fontSize: 14, color: Color(0xFF05051A), fontFamily: 'PingFang SC'),
        decoration: const InputDecoration(
          hintText: '请输入邮箱号',
          hintStyle: TextStyle(
              fontSize: 14,
              color: Color(0xFF9292A6),
              fontFamily: 'PingFang SC'),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _pwdFocus.hasFocus
              ? const Color(0xFF6E8DF5)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _pwdCtrl,
        focusNode: _pwdFocus,
        obscureText: _obscurePassword,
        onChanged: (_) {
          if (_pwdError != null) _validatePassword();
        },
        style: const TextStyle(
            fontSize: 14, color: Color(0xFF05051A), fontFamily: 'PingFang SC'),
        decoration: InputDecoration(
          hintText: '请输入密码',
          hintStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9292A6),
              fontFamily: 'PingFang SC'),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
              color: const Color(0xFF9292A6),
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF05051A),
          fontFamily: 'PingFang SC',
          height: 1.0));

  Widget _errorText(String msg) =>
      Text(msg, style: const TextStyle(fontSize: 12, color: Color(0xFFFF4D4F)));

  Widget _grayText(String text, {VoidCallback? onTap}) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Text(text,
            style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9292A6),
                fontFamily: 'PingFang SC')),
      );

  Widget _submitButton() {
    final enabled = _canSubmit && !_loading;
    return GestureDetector(
      onTap: enabled ? _handleSubmit : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: enabled
                ? [const Color(0xFF96ADFF), const Color(0xFF6E8DF5)]
                : [const Color(0xFFCDD5F5), const Color(0xFFCDD5F5)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Center(
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('完成',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'PingFang SC')),
        ),
      ),
    );
  }

  Widget _agreementRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => setState(() => _agreed = !_agreed),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _agreed ? const Color(0xFF6E8DF5) : Colors.white,
              border: Border.all(
                color: _agreed
                    ? const Color(0xFF6E8DF5)
                    : const Color(0xFFD6DAE6),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: _agreed
                ? const Icon(Icons.check, size: 13, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(
                fontSize: 14, fontFamily: 'PingFang SC', height: 1.0),
            children: [
              const TextSpan(
                  text: '我已阅读并同意',
                  style: TextStyle(color: Color(0xFF9292A6))),
              TextSpan(
                text: '用户协议',
                style: const TextStyle(color: Color(0xFF4D79FF)),
                recognizer: TapGestureRecognizer()
                  ..onTap = widget.onAgreementLinkTap,
              ),
              const TextSpan(
                  text: '&', style: TextStyle(color: Color(0xFF9292A6))),
              TextSpan(
                text: '隐私条款',
                style: const TextStyle(color: Color(0xFF4D79FF)),
                recognizer: TapGestureRecognizer()
                  ..onTap = widget.onAgreementLinkTap,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtherLogin() {
    const icons = [
      'assent/apple.png',
      'assent/google.png',
      'assent/facebook.png',
      'assent/weixin.png',
      'assent/qq.png',
    ];
    return Column(
      children: [
        Row(
          children: const [
            Expanded(
                child: Divider(
                    color: Color(0xFFD6DAE6), thickness: 0.5, indent: 40)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('其他登陆方式',
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9292A6),
                      fontFamily: 'PingFang SC')),
            ),
            Expanded(
                child: Divider(
                    color: Color(0xFFD6DAE6),
                    thickness: 0.5,
                    endIndent: 40)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: icons.map((path) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Image.asset(path,
                      width: 24, height: 24, fit: BoxFit.contain),
                ),
              ),
            );
          }).toList(growable: false),
        ),
      ],
    );
  }
}
