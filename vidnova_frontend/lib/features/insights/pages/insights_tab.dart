import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class InsightsTab extends StatelessWidget {
  const InsightsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Модуль Аналітики:\nХмара когнітивних викривлень',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
      ),
    );
  }
}