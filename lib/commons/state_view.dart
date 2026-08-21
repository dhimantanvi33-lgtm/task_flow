import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

enum ViewState { loading, error, empty, content }

class StateView extends StatelessWidget {
  final ViewState state;
  final Widget child;
  final String? errorMessage;
  final String? emptyMessage;
  final VoidCallback? onRetry;
  final IconData emptyIcon;

  const StateView({
    super.key,
    required this.state,
    required this.child,
    this.errorMessage,
    this.emptyMessage,
    this.onRetry,
    this.emptyIcon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);

    switch (state) {
      case ViewState.loading:
        return Center(child: CircularProgressIndicator(color: colors.primary));

      case ViewState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: colors.error),
                const SizedBox(height: 12),
                Text(
                  errorMessage ?? 'Something went wrong',
                  style: AppTextStyles.body(context),
                  textAlign: TextAlign.center,
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 160,
                    child: AppButton(label: 'Retry', onPressed: onRetry, height: 44),
                  ),
                ],
              ],
            ),
          ),
        );

      case ViewState.empty:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(emptyIcon, size: 48, color: colors.textHint),
                const SizedBox(height: 12),
                Text(
                  emptyMessage ?? 'Nothing here yet',
                  style: AppTextStyles.bodySecondary(context),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );

      case ViewState.content:
        return child;
    }
  }
}
