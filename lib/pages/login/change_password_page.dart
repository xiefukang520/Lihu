import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({
    super.key,
    this.title = '修改密码',
    this.mascotAsset = 'assent/change_passworld.png',
  });

  final String title;
  final String mascotAsset;

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  static const double _hPad = 24.0;
  static final _emailReg = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');

  bool _obscurePassword = true;
  bool _agreed = false;
  bool _loading = false;

  int _countdown = 0;
  Timer? _timer;

  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  final _emailFocus = FocusNode();
  final _codeFocus = FocusNode();
  final _pwdFocus = FocusNode();

  String? _emailError;
  String? _codeError;
  String? _pwdError;

  bool get _isRegister => widget.title == '注册';

  bool get _canSubmit =>
      _emailCtrl.text.isNotEmpty &&
      _codeCtrl.text.isNotEmpty &&
      _pwdCtrl.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(() => setState(() {}));
    _codeCtrl.addListener(() => setState(() {}));
    _pwdCtrl.addListener(() => setState(() {}));
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) {
        _validateEmail();
      } else {
        setState(() {});
      }
    });
    _codeFocus.addListener(() {
      if (!_codeFocus.hasFocus) {
        _validateCode();
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
    _timer?.cancel();
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _pwdCtrl.dispose();
    _emailFocus.dispose();
    _codeFocus.dispose();
    _pwdFocus.dispose();
    super.dispose();
  }

  bool _validateEmail() {
    final v = _emailCtrl.text.trim();
    final err = v.isEmpty
        ? '请输入邮箱号'
        : !_emailReg.hasMatch(v)
            ? '请输入正确的邮箱格式'
            : null;
    setState(() => _emailError = err);
    return err == null;
  }

  bool _validateCode() {
    final v = _codeCtrl.text.trim();
    final err = v.isEmpty ? '请输入验证码' : v.length < 4 ? '验证码格式不正确' : null;
    setState(() => _codeError = err);
    return err == null;
  }

  bool _validatePassword() {
    final v = _pwdCtrl.text;
    final err = v.isEmpty
        ? '请输入密码'
        : v.length < 6
            ? '密码至少6位'
            : null;
    setState(() => _pwdError = err);
    return err == null;
  }

  void _sendCode() {
    if (!_validateEmail()) return;
    if (_countdown > 0) return;
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 1) {
        t.cancel();
        setState(() => _countdown = 0);
      } else {
        setState(() => _countdown--);
      }
    });
    // TODO: 调用发送验证码接口
  }

  Future<void> _handleSubmit() async {
    final emailOk = _validateEmail();
    final codeOk = _validateCode();
    final pwdOk = _validatePassword();
    if (!emailOk || !codeOk || !pwdOk) return;
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
    if (_isRegister) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
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
              child: Image.asset('assent/背景.png', fit: BoxFit.cover),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 14),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: const Icon(Icons.arrow_back_ios,
                          size: 13, color: Color(0xFF05051A)),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildContent(),
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

  Widget _buildContent() {
    const double clipH = 194.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: clipH,
          child: ClipRect(
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  right: _hPad,
                  child: Image.asset(widget.mascotAsset,
                      width: 225, fit: BoxFit.fitWidth),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _hPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 80,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(widget.title,
                              style: const TextStyle(
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
                      _buildInputField(
                        controller: _emailCtrl,
                        focusNode: _emailFocus,
                        hint: '请输入邮箱号',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) {
                          if (_emailError != null) _validateEmail();
                        },
                      ),
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
              const SizedBox(height: 24),
              _label('验证码'),
              const SizedBox(height: 12),
              _buildVerifyCodeRow(),
              if (_codeError != null) ...[
                const SizedBox(height: 4),
                _errorText(_codeError!),
              ],
              const SizedBox(height: 24),
              _label('密码'),
              const SizedBox(height: 12),
              _buildPasswordField(),
              if (_pwdError != null) ...[
                const SizedBox(height: 4),
                _errorText(_pwdError!),
              ],
              const SizedBox(height: 24),
              if (!_isRegister) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _grayText('忘记密码',
                        onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) => const ChangePasswordPage()),
                            )),
                    _grayText('注册账号',
                        onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) => const ChangePasswordPage(
                                      title: '注册',
                                      mascotAsset: 'assent/register.png')),
                            )),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              _submitButton(),
              const SizedBox(height: 27),
              Center(child: _agreementRow()),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focusNode.hasFocus
              ? const Color(0xFF6E8DF5)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        style: const TextStyle(
            fontSize: 14, color: Color(0xFF05051A), fontFamily: 'PingFang SC'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9292A6),
              fontFamily: 'PingFang SC'),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildVerifyCodeRow() {
    final canSend = _countdown == 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _codeFocus.hasFocus
              ? const Color(0xFF6E8DF5)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _codeCtrl,
              focusNode: _codeFocus,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) {
                if (_codeError != null) _validateCode();
              },
              style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF05051A),
                  fontFamily: 'PingFang SC'),
              decoration: const InputDecoration(
                hintText: '请输入验证码',
                hintStyle: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9292A6),
                    fontFamily: 'PingFang SC'),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: '',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: canSend ? _sendCode : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 84,
                height: 28,
                decoration: BoxDecoration(
                  color: canSend
                      ? const Color(0xFF4D79FF)
                      : const Color(0xFFB0B8D8),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  canSend ? '发送验证码' : '$_countdown s',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'PingFang SC'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return _buildInputField(
      controller: _pwdCtrl,
      focusNode: _pwdFocus,
      hint: '请输入密码',
      obscureText: _obscurePassword,
      onChanged: (_) {
        if (_pwdError != null) _validatePassword();
      },
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 18,
          color: const Color(0xFF9292A6),
        ),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
                recognizer: TapGestureRecognizer()..onTap = () {},
              ),
              const TextSpan(
                  text: '&', style: TextStyle(color: Color(0xFF9292A6))),
              TextSpan(
                text: '隐私条款',
                style: const TextStyle(color: Color(0xFF4D79FF)),
                recognizer: TapGestureRecognizer()..onTap = () {},
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
