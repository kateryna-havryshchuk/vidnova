import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../bloc/home_bloc.dart';
import '../../bloc/home_event.dart';

class PeriodToggleWidget extends StatelessWidget {
  final bool isWeekSelected;

  const PeriodToggleWidget({
    super.key,
    required this.isWeekSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.read<HomeBloc>().add(ToggleChartPeriod(true)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isWeekSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isWeekSelected
                    ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                    : [],
              ),
              child: Text(
                'Тиждень',
                style: TextStyle(
                  color: isWeekSelected ? AppColors.primary : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => context.read<HomeBloc>().add(ToggleChartPeriod(false)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                'Місяць',
                style: TextStyle(
                  color: !isWeekSelected ? AppColors.primary : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}