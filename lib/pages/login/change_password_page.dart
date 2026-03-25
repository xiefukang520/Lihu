import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'email_login_page.dart';

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
  static const Color _enabledButtonColor = Color(0xFF3B53CF);
  static const Color _disabledButtonColor = Color(0xFF8298F9);
  static const Color _sendCodeButtonColor = Color(0xFF4D79FF);
  static const String _numberFontFamily = 'DIN Alternate';

  // 水平统一边距，页面里多处复用，避免到处写 magic number。
  static const double _hPad = 24.0;
  // 邮箱格式正则，用于输入校验。
  static final _emailReg = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');

  // true: 密码明文隐藏；false: 显示明文。
  bool _obscurePassword = true;
  // 是否勾选了协议。
  bool _agreed = false;
  // 提交按钮加载态，避免重复点击。
  bool _loading = false;

  // 验证码倒计时（单位：秒），0 代表可重新发送。
  int _countdown = 0;
  // 周期定时器：每秒把倒计时减 1。
  Timer? _timer;

  // 文本输入控制器：读取和监听输入框内容。
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  // 焦点节点：监听“获得焦点/失去焦点”以决定何时校验。
  final _emailFocus = FocusNode();
  final _codeFocus = FocusNode();
  final _pwdFocus = FocusNode();

  // 各输入项的错误文案（null 表示无错误）。
  String? _emailError;
  String? _codeError;
  String? _pwdError;

  // 本页面复用“注册/修改密码”两种场景，通过 title 区分。
  bool get _isRegister => widget.title == '注册';

  // 是否满足最基础的提交条件（仅判断是否为空）。
  // 更严格的格式校验在 _handleSubmit 中执行。
  bool get _canSubmit =>
      _emailCtrl.text.isNotEmpty &&
      _codeCtrl.text.isNotEmpty &&
      _pwdCtrl.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // 输入变化后触发 setState，让按钮可用态、错误提示等及时刷新。
    _emailCtrl.addListener(() => setState(() {}));
    _codeCtrl.addListener(() => setState(() {}));
    _pwdCtrl.addListener(() => setState(() {}));
    // 失焦时做校验；聚焦时清理/刷新当前展示状态。
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
    // 页面销毁前释放资源，避免内存泄漏和定时器继续运行。
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
    final err = v.isEmpty
        ? '请输入验证码'
        : v.length < 4
        ? '验证码格式不正确'
        : null;
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
    // 1) 先校验邮箱，邮箱合法才允许发验证码。
    if (!_validateEmail()) return;
    // 2) 倒计时中直接返回，避免重复发送。
    if (_countdown > 0) return;
    // 3) 开始 60 秒倒计时并刷新按钮文案。
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 1) {
        // 倒计时结束：停止定时器并恢复“发送验证码”状态。
        t.cancel();
        setState(() => _countdown = 0);
      } else {
        setState(() => _countdown--);
      }
    });
    // TODO: 调用发送验证码接口
  }

  Future<void> _handleSubmit() async {
    // 提交前做完整校验：邮箱、验证码、密码都合法才继续。
    final emailOk = _validateEmail();
    final codeOk = _validateCode();
    final pwdOk = _validatePassword();
    if (!emailOk || !codeOk || !pwdOk) return;
    // 协议未勾选时，直接给出提示并阻止提交。
    if (!_agreed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先阅读并同意用户协议与隐私条款')));
      return;
    }
    // 模拟网络请求：进入加载态 -> 等待 -> 退出加载态。
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);

    // TODO: 替换为真实接口，接口失败时调用对应弹框
    // 注册失败示例：
    // if (_isRegister) {
    //   showRegisterFailDialog(context, message: '该邮箱已被注册');
    //   return;
    // }
    // 修改密码失败示例：
    // showChangePasswordFailDialog(context, message: '验证码错误或已过期');
    // return;

    if (_isRegister) {
      // 注册成功后回到根页面；修改密码场景保持当前返回逻辑。
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _goToForgotPassword() {
    if (!_isRegister) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const ChangePasswordPage()),
    );
  }

  void _goToRegister() {
    if (_isRegister) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ChangePasswordPage(
          title: '注册',
          mascotAsset: 'assent/register.png',
        ),
      ),
    );
  }

  void _goToEmailLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const EmailLoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 根手势：点击空白收起键盘，避免遮挡输入框。
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
                      onTap: _goToEmailLogin,
                      behavior: HitTestBehavior.opaque,
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: Color(0xFF05051A),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(child: _buildContent()),
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
    // 顶部（标题+插画）和底部（表单）分层构建，便于维护。
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
                  child: Image.asset(
                    widget.mascotAsset,
                    width: 225,
                    fit: BoxFit.fitWidth,
                  ),
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
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF05051A),
                              fontFamily: 'PingFang SC',
                              height: 1.0,
                            ),
                          ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _grayText('忘记密码', onTap: _goToForgotPassword),
                  _grayText('注册账号', onTap: _goToRegister),
                ],
              ),
              const SizedBox(height: 24),
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
          fontSize: 14,
          color: Color(0xFF05051A),
          fontFamily: 'PingFang SC',
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF9292A6),
            fontFamily: 'PingFang SC',
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
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
                fontFamily: 'PingFang SC',
              ),
              decoration: const InputDecoration(
                hintText: '请输入验证码',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9292A6),
                  fontFamily: 'PingFang SC',
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
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
                  color: canSend ? _sendCodeButtonColor : _disabledButtonColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: canSend
                    ? const Text(
                        '发送验证码',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'PingFang SC',
                        ),
                      )
                    : RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$_countdown',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: _numberFontFamily,
                              ),
                            ),
                            const TextSpan(
                              text: '秒',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: 'PingFang SC',
                              ),
                            ),
                          ],
                        ),
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

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF05051A),
      fontFamily: 'PingFang SC',
      height: 1.0,
    ),
  );

  Widget _errorText(String msg) =>
      Text(msg, style: const TextStyle(fontSize: 12, color: Color(0xFFFF4D4F)));

  Widget _grayText(String text, {VoidCallback? onTap}) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF9292A6),
        fontFamily: 'PingFang SC',
      ),
    ),
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
          color: enabled ? _enabledButtonColor : _disabledButtonColor,
        ),
        child: Center(
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  '完成',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'PingFang SC',
                  ),
                ),
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
              fontSize: 14,
              fontFamily: 'PingFang SC',
              height: 1.0,
            ),
            children: [
              const TextSpan(
                text: '我已阅读并同意',
                style: TextStyle(color: Color(0xFF9292A6)),
              ),
              TextSpan(
                text: '用户协议',
                style: const TextStyle(color: Color(0xFF4D79FF)),
                recognizer: TapGestureRecognizer()..onTap = () {},
              ),
              const TextSpan(
                text: '&',
                style: TextStyle(color: Color(0xFF9292A6)),
              ),
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
              child: FractionallySizedBox(
                widthFactor: 0.33,
                child: Divider(color: Color(0xFFD6DAE6), thickness: 0.5),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '其他登陆方式',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9292A6),
                  fontFamily: 'PingFang SC',
                ),
              ),
            ),
            Expanded(
              child: FractionallySizedBox(
                widthFactor: 0.33,
                child: Divider(color: Color(0xFFD6DAE6), thickness: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: icons
              .map((path) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        path,
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              })
              .toList(growable: false),
        ),
      ],
    );
  }
}
