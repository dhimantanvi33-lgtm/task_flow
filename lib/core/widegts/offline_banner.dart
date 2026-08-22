import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/connectivity_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final offline = context.watch<ConnectivityProvider>().isOffline;
    if (!offline) return const SizedBox.shrink();
    final colors = ColorManager.of(context);
    return Container(
      width: double.infinity,
      color: AppColors.warning.withValues(alpha: 0.15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        Icon(Icons.cloud_off_rounded, size: 16, color: AppColors.warning),
        const SizedBox(width: 8),
        Expanded(child: Text('Offline — showing saved data, which may be out of date.', style: AppTextStyles.caption(context).copyWith(color: colors.textPrimary))),
      ]),
    );
  }
}