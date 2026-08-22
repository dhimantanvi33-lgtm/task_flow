import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../provider/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    final auth = context.read<AuthProvider>();
    await Future.delayed(const Duration(milliseconds: 700));
    await auth.bootstrap();
    if (!mounted) return;
    final route = auth.status == AuthStatus.authenticated ? '/home' : '/login';
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [colors.primary, colors.primaryLight]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 8))],
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.check_rounded, size: 46, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text('TaskFlow', style: AppTextStyles.heading1(context)),
          const SizedBox(height: 6),
          Text('Projects & tasks, together', style: AppTextStyles.bodySecondary(context)),
          const SizedBox(height: 40),
          SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.4, color: colors.primary)),
        ]),
      ),
    );
  }
}