import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});
  @override
  Widget build(BuildContext context) =>
      Center(child: CircularProgressIndicator(color: ColorManager.of(context).primary));
}
