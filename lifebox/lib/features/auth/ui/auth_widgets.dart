import 'package:flutter/material.dart';
import 'package:lifebox/l10n/app_localizations.dart';

class AuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;

  /// 表单内容（输入框 + 按钮）
  final Widget child;

  /// 底部额外区域（例如：去注册 / 返回登录）
  final List<Widget> footer;

  /// 是否显示 Terms
  final bool showTerms;

  /// Logo：默认是文字 Logo，也可以传入 Image.asset(...)
  final Widget? logo;

  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer = const [],
    this.showTerms = true,
    this.logo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Stack(
          children: [
            // 背景渐变“光晕”
            Positioned(
              top: -120,
              left: -80,
              child: _GlowBlob(size: 260),
            ),
            Positioned(
              top: 40,
              right: -90,
              child: _GlowBlob(size: 220),
            ),

            ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              children: [
                _Header(
                  title: title,
                  subtitle: subtitle,
                  logo: logo,
                ),
                const SizedBox(height: 14),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: Colors.black.withOpacity(0.06)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: child,
                  ),
                ),
                if (footer.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  ...footer,
                ],
                if (showTerms) ...[
                  const SizedBox(height: 18),
                  const _TermsText(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? logo;

  const _Header({
    required this.title,
    required this.subtitle,
    this.logo,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final logoWidget = logo ??
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LogoMark(),
            SizedBox(width: 10),
            Text(
              l10n.app_name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
                letterSpacing: 0.3,
              ),
            ),
          ],
        );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF111827).withOpacity(0.06),
            const Color(0xFF111827).withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          logoWidget,
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              height: 1.35,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF374151)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.12),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'L',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double size;
  const _GlowBlob({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF111827).withOpacity(0.10),
            const Color(0xFF111827).withOpacity(0.00),
          ],
        ),
      ),
    );
  }
}

/// —— 输入框（统一样式：黑字 + 圆角 + 柔和边框）——
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffix;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF111827);
    const hintColor = Color(0xFF6B7280);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: hintColor),
        hintText: hint,
        hintStyle: const TextStyle(color: hintColor),
        prefixIcon: Icon(icon, color: hintColor),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black.withOpacity(0.10)),
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black.withOpacity(0.28)),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

/// —— 主按钮 ——
/// 如果你想用品牌色，可在 ThemeData 里设置 colorScheme.primary
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const AuthPrimaryButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

/// —— 次按钮（例如 Google / 返回登录）——
class AuthSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const AuthSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: Colors.black.withOpacity(0.12)),
        ),
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.login, color: const Color(0xFF111827)),
        label: Text(label, style: const TextStyle(color: Color(0xFF111827))),
      ),
    );
  }
}

/// —— 分割线（“或”）——
class AuthDivider extends StatelessWidget {
  final String text;
  const AuthDivider({
    super.key,
    required this.text, 
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Divider(color: Colors.black.withOpacity(0.10), height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
        ),
        Expanded(
            child: Divider(color: Colors.black.withOpacity(0.10), height: 1)),
      ],
    );
  }
}

/// —— 小提示文字 ——
class AuthHintText extends StatelessWidget {
  final String text;
  const AuthHintText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 12,
        height: 1.35,
      ),
    );
  }
}

/// —— Terms / Privacy 文案 ——
class _TermsText extends StatelessWidget {
  const _TermsText();

  @override
  Widget build(BuildContext context) {
    final style =
        const TextStyle(color: Color(0xFF6B7280), fontSize: 11, height: 1.35);
    final linkStyle = style.copyWith(
        color: const Color(0xFF111827), fontWeight: FontWeight.w700);
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(l10n.terms_agree_prefix, style: style),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.open_terms_action)),
              );
            },
            child: Text(l10n.terms_title, style: linkStyle),
          ),
          Text(l10n.terms_and, style: style),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.open_privacy_action)),
              );
            },
            child: Text(l10n.privacy_title, style: linkStyle),
          ),
          Text('。', style: style),
        ],
      ),
    );
  }
}
