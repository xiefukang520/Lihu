import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// 枚举：对话框模式，控制确认按钮颜色语义
// ─────────────────────────────────────────────
enum DialogMode {
  warning, // 警告：红色确认按钮（删除等危险操作）
  error,   // 错误：橙红色，单按钮"我知道了"
  success, // 成功：绿色确认按钮
  info,    // 普通提示：蓝色确认按钮
}

// ─────────────────────────────────────────────
// 核心 showWarningDialog
// ─────────────────────────────────────────────
Future<void> showWarningDialog(
  BuildContext context, {
  String title = '提示',
  required String message,
  DialogMode mode = DialogMode.warning,

  // 按钮文字（showCancel=false 时只显示确认按钮）
  bool showCancel = true,
  String cancelText = '取消',
  String confirmText = '确定',

  // 自定义确认按钮颜色（优先级高于 mode）
  Color? confirmColor,

  // 回调
  VoidCallback? onCancel,
  VoidCallback? onConfirm,

  // 小狐狸图片
  String mascotAsset = 'assent/waring.png',

  // 点击遮罩是否关闭
  bool barrierDismissible = false,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (_) => WarningDialog(
      title: title,
      message: message,
      mode: mode,
      showCancel: showCancel,
      cancelText: cancelText,
      confirmText: confirmText,
      confirmColor: confirmColor,
      onCancel: onCancel,
      onConfirm: onConfirm,
      mascotAsset: mascotAsset,
    ),
  );
}

// ─────────────────────────────────────────────
// 快捷方法：登录失败
// ─────────────────────────────────────────────
Future<void> showLoginFailDialog(
  BuildContext context, {
  String message = '登录失败，请检查邮箱或密码后重试',
  VoidCallback? onConfirm,
}) {
  return showWarningDialog(
    context,
    title: '登录失败',
    message: message,
    mode: DialogMode.error,
    showCancel: false,
    confirmText: '我知道了',
    onConfirm: onConfirm,
  );
}

// ─────────────────────────────────────────────
// 快捷方法：注册失败
// ─────────────────────────────────────────────
Future<void> showRegisterFailDialog(
  BuildContext context, {
  String message = '注册失败，该邮箱已被注册或网络异常',
  VoidCallback? onConfirm,
}) {
  return showWarningDialog(
    context,
    title: '注册失败',
    message: message,
    mode: DialogMode.error,
    showCancel: false,
    confirmText: '我知道了',
    onConfirm: onConfirm,
  );
}

// ─────────────────────────────────────────────
// 快捷方法：修改密码失败
// ─────────────────────────────────────────────
Future<void> showChangePasswordFailDialog(
  BuildContext context, {
  String message = '修改失败，验证码错误或已过期',
  VoidCallback? onConfirm,
}) {
  return showWarningDialog(
    context,
    title: '修改失败',
    message: message,
    mode: DialogMode.error,
    showCancel: false,
    confirmText: '我知道了',
    onConfirm: onConfirm,
  );
}

// ─────────────────────────────────────────────
// 快捷方法：危险确认（删除等）
// ─────────────────────────────────────────────
Future<void> showDeleteConfirmDialog(
  BuildContext context, {
  String message = '确定删除吗?删除后不可恢复！',
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
}) {
  return showWarningDialog(
    context,
    title: '提示',
    message: message,
    mode: DialogMode.warning,
    showCancel: true,
    cancelText: '取消',
    confirmText: '删除',
    onConfirm: onConfirm,
    onCancel: onCancel,
  );
}

// ─────────────────────────────────────────────
// Dialog Widget
// ─────────────────────────────────────────────
class WarningDialog extends StatelessWidget {
  const WarningDialog({
    super.key,
    this.title = '提示',
    required this.message,
    this.mode = DialogMode.warning,
    this.showCancel = true,
    this.cancelText = '取消',
    this.confirmText = '确定',
    this.confirmColor,
    this.onCancel,
    this.onConfirm,
    this.mascotAsset = 'assent/waring.png',
  });

  final String title;
  final String message;
  final DialogMode mode;
  final bool showCancel;
  final String cancelText;
  final String confirmText;
  final Color? confirmColor;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final String mascotAsset;

  // mode → 确认按钮颜色
  Color get _resolvedConfirmColor {
    if (confirmColor != null) return confirmColor!;
    switch (mode) {
      case DialogMode.warning:
        return const Color(0xFFE53935);
      case DialogMode.error:
        return const Color(0xFFFF6B35);
      case DialogMode.success:
        return const Color(0xFF4CAF50);
      case DialogMode.info:
        return const Color(0xFF4D79FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double mascotW = 160.0;
    const double mascotOverhang = 90.0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── 白色卡片 ──
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题（右侧留空给小狐狸）
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 100, 12),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF05051A),
                        fontFamily: 'PingFang SC',
                      ),
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                  // 消息内容
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF333333),
                        fontFamily: 'PingFang SC',
                        height: 1.5,
                      ),
                    ),
                  ),
                  // 按钮行
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: Row(
                      children: [
                        if (showCancel) ...[
                          Expanded(child: _cancelBtn(context)),
                          const SizedBox(width: 12),
                        ],
                        Expanded(child: _confirmBtn(context)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── 小狐狸 ──
            Positioned(
              top: -mascotOverhang,
              right: -8,
              child: IgnorePointer(
                child: Image.asset(
                  mascotAsset,
                  width: mascotW,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cancelBtn(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        onCancel?.call();
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: Text(
          cancelText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
            fontFamily: 'PingFang SC',
          ),
        ),
      ),
    );
  }

  Widget _confirmBtn(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        onConfirm?.call();
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: _resolvedConfirmColor,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: Text(
          confirmText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'PingFang SC',
          ),
        ),
      ),
    );
  }
}
