import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import 'legend_item_widget.dart';

class ChartLegendWidget extends StatelessWidget {
  const ChartLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LegendItemWidget(
          color: AppColors.primary,
          text: 'Серед. настрій',
          isDashed: false,
        ),
        SizedBox(width: 24),
        LegendItemWidget(
          color: AppColors.emotionChart,
          text: 'Активність',
          isDashed: true,
        ),
      ],
    );
  }
}