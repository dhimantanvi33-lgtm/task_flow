import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../provider/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_email.text, _password.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.errorMessage ?? 'Login failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    final submitting = context.watch<AuthProvider>().submitting;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(gradient: LinearGradient(colors: [colors.primary, colors.primaryLight]), borderRadius: BorderRadius.circular(16)),
                      alignment: Alignment.center,
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 24),
                    Text('Welcome back', style: AppTextStyles.heading1(context)),
                    const SizedBox(height: 6),
                    Text('Sign in to continue to TaskFlow', style: AppTextStyles.bodySecondary(context)),
                    const SizedBox(height: 32),
                    _AuthField(controller: _email, label: 'Email', hint: 'you@company.com', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, validator: Validators.email),
                    const SizedBox(height: 16),
                    _AuthField(
                      controller: _password, label: 'Password', icon: Icons.lock_outline_rounded, obscure: _obscure, textInputAction: TextInputAction.done, onSubmitted: (_) => _submit(), validator: Validators.password,
                      trailing: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: colors.textHint), onPressed: () => setState(() => _obscure = !_obscure)),
                    ),
                    const SizedBox(height: 20),
                    _PrimaryButton(label: 'Sign in', loading: submitting, onPressed: _submit),
                    const SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text("Don't have an account?", style: AppTextStyles.bodySecondary(context)),
                      TextButton(onPressed: () => Navigator.of(context).pushNamed('/register'), child: Text('Register', style: AppTextStyles.link(context))),
                    ]),
                    const SizedBox(height: 8),
                    const _CredentialHint(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CredentialHint extends StatelessWidget {
  const _CredentialHint();
  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Test logins (password: Password123!)', style: AppTextStyles.caption(context).copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('ava.admin@nimbusdigital.test — Org A admin', style: AppTextStyles.caption(context)),
        Text('marcus.member@nimbusdigital.test — Org A member', style: AppTextStyles.caption(context)),
        Text('daniel.admin@harborlightstudios.test — Org B admin', style: AppTextStyles.caption(context)),
        Text('elena.member@harborlightstudios.test — Org B member', style: AppTextStyles.caption(context)),
      ]),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;
  final Widget? trailing;
  const _AuthField({required this.controller, required this.label, required this.icon, this.hint, this.obscure = false, this.keyboardType, this.textInputAction, this.validator, this.onSubmitted, this.trailing});
  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c, width: w));
    return TextFormField(
      controller: controller, obscureText: obscure, keyboardType: keyboardType, textInputAction: textInputAction, onFieldSubmitted: onSubmitted, validator: validator,
      style: AppTextStyles.body(context), cursorColor: colors.primary,
      decoration: InputDecoration(
        labelText: label, hintText: hint, hintStyle: AppTextStyles.bodySecondary(context), labelStyle: AppTextStyles.bodySecondary(context),
        floatingLabelStyle: AppTextStyles.caption(context).copyWith(color: colors.primary),
        prefixIcon: Icon(icon, color: colors.textHint, size: 20), suffixIcon: trailing,
        filled: true, fillColor: colors.card, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: b(colors.border), focusedBorder: b(colors.primary, 1.6), errorBorder: b(colors.error), focusedErrorBorder: b(colors.error, 1.6),
        errorStyle: AppTextStyles.caption(context).copyWith(color: colors.error),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;
  const _PrimaryButton({required this.label, required this.onPressed, this.loading = false});
  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: colors.primary, foregroundColor: Colors.white, disabledBackgroundColor: colors.primary.withValues(alpha: 0.5), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        child: loading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
            : Text(label, style: AppTextStyles.button(context)),
      ),
    );
  }
}