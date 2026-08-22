import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _validateConfirm(String? v) {
    if ((v ?? '').isEmpty) return 'Confirm your password';
    if (v != _password.text) return 'Passwords do not match';
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pushReplacementNamed('/home'); // UI-only
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(alignment: Alignment.centerLeft, child: IconButton(onPressed: () => Navigator.of(context).maybePop(), icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary))),
                    const SizedBox(height: 12),
                    Text('Get started', style: AppTextStyles.heading1(context)),
                    const SizedBox(height: 6),
                    Text('Create your TaskFlow account', style: AppTextStyles.bodySecondary(context)),
                    const SizedBox(height: 28),
                    _AuthField(controller: _name, label: 'Full name', icon: Icons.person_outline_rounded, textInputAction: TextInputAction.next, validator: Validators.name),
                    const SizedBox(height: 16),
                    _AuthField(controller: _email, label: 'Email', hint: 'you@company.com', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, validator: Validators.email),
                    const SizedBox(height: 16),
                    _AuthField(controller: _password, label: 'Password', icon: Icons.lock_outline_rounded, obscure: _obscure, textInputAction: TextInputAction.next, validator: Validators.password,
                        trailing: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: colors.textHint), onPressed: () => setState(() => _obscure = !_obscure))),
                    const SizedBox(height: 16),
                    _AuthField(controller: _confirm, label: 'Confirm password', icon: Icons.lock_outline_rounded, obscure: _obscureConfirm, textInputAction: TextInputAction.done, onSubmitted: (_) => _submit(), validator: _validateConfirm,
                        trailing: IconButton(icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: colors.textHint), onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm))),
                    const SizedBox(height: 24),
                    _PrimaryButton(label: 'Create account', onPressed: _submit),
                    const SizedBox(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('Already have an account?', style: AppTextStyles.bodySecondary(context)),
                      TextButton(onPressed: () => Navigator.of(context).maybePop(), child: Text('Sign in', style: AppTextStyles.link(context))),
                    ]),
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
  final VoidCallback onPressed;
  const _PrimaryButton({required this.label, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: colors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        child: Text(label, style: AppTextStyles.button(context)),
      ),
    );
  }
}
