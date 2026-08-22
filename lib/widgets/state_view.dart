import 'package:flutter/material.dart';

import '../core/widegts/empty_widget.dart';
import '../core/widegts/error_widget.dart';
import '../core/widegts/loading_widget.dart';

enum ViewStatus { loading, success, empty, error }

class StateView extends StatelessWidget {
  final ViewStatus status;
  final Widget child;
  final String emptyMessage;
  final IconData emptyIcon;
  final String errorMessage;
  final VoidCallback? onRetry;

  const StateView({
    super.key,
    required this.status,
    required this.child,
    this.emptyMessage = 'Nothing here yet.',
    this.emptyIcon = Icons.inbox_outlined,
    this.errorMessage = 'Something went wrong.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) => switch (status) {
    ViewStatus.loading => const LoadingWidget(),
    ViewStatus.empty => EmptyWidget(message: emptyMessage, icon: emptyIcon, onRefresh: onRetry),
    ViewStatus.error => AppErrorWidget(message: errorMessage, onRetry: onRetry),
    ViewStatus.success => child,
  };
}
