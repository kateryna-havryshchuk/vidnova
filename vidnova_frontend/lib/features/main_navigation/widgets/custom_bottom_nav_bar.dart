import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/navigation_cubit.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.surface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.home, label: 'Головна', index: 0, currentIndex: currentIndex),
            _NavItem(icon: Icons.book, label: 'Журнал', index: 1, currentIndex: currentIndex),
            const SizedBox(width: 30),
            _NavItem(icon: Icons.pie_chart, label: 'Аналітика', index: 2, currentIndex: currentIndex),
            _NavItem(icon: Icons.person, label: 'Профіль', index: 3, currentIndex: currentIndex),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    final color = isActive ? AppColors.primary : AppColors.inactive;

    return InkWell(
      onTap: () => context.read<NavigationCubit>().changeTab(index),
       borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.primary.withAlpha(51), // Колір splash ефекту
        highlightColor: AppColors.primary.withAlpha(25), // Колір highl
         child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
    );
  }
}