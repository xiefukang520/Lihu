/// 认证模块对外统一导出入口。
///
/// 新同学可以只 import 这个文件，就能同时拿到：
/// 1) 认证页面（`EmailLoginPage`）
/// 2) 认证 UI 的设计常量（tokens）
///
/// 这样做的好处是：业务层不需要关心具体文件分布，后续重构目录时
/// 只要保持这里的导出不变，外部调用代码就不用改。
export 'auth_design_tokens.dart';
export '../../pages/login/email_login_page.dart';
