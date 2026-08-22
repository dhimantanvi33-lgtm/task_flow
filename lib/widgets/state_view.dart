import 'package:flutter/material.dart';

import '../core/view_state.dart';
import '../core/widegts/empty_widget.dart';
import '../core/widegts/error_widget.dart';
import '../core/widegts/loading_widget.dart';
class StateView<T> extends StatelessWidget {
  final ViewState<T> state;
  final Widget Function(BuildContext, T) onSuccess;
  final String emptyMessage;
  final IconData emptyIcon;
  final VoidCallback? onRetry;

  const StateView({
    super.key,
    required this.state,
    required this.onSuccess,
    this.emptyMessage = 'Nothing here yet.',
    this.emptyIcon = Icons.inbox_outlined,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) => switch (state) {
    ViewInitial<T>() || ViewLoading<T>() => const LoadingWidget(),
    ViewEmpty<T>() => EmptyWidget(message: emptyMessage, icon: emptyIcon, onRefresh: onRetry),
    ViewError<T>(:final message) => AppErrorWidget(message: message, onRetry: onRetry),
    ViewSuccess<T>(:final data) => onSuccess(context, data),
  };
}