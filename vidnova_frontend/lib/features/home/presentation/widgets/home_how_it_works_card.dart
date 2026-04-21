import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeHowItWorksCard extends StatelessWidget {
  final VoidCallback onTryNow;

  const HomeHowItWorksCard({super.key, required this.onTryNow});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Запишіть конкретну ситуацію',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Icon(Icons.edit_note, size: 20, color: AppColors.textPrimary),
              SizedBox(width: 10),
              Text(
                'Як це працює?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _HowItWorksStepRow(
            index: 1,
            title: 'Опишіть ситуацію',
            subtitle: 'Що сталося і яку емоцію це викликало',
            leadingIcon: Icons.edit,
          ),
          const SizedBox(height: 10),
          const _HowItWorksStepRow(
            index: 2,
            title: 'Перевірте думки фактами',
            subtitle: 'Які реальні докази за і проти?',
            leadingIcon: Icons.fact_check,
          ),
          const SizedBox(height: 10),
          const _HowItWorksStepRow(
            index: 3,
            title: 'Побачте ясніше',
            subtitle: 'Сформуйте збалансований погляд',
            leadingIcon: Icons.lightbulb_outline,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 46,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTryNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Спробувати зараз',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorksStepRow extends StatelessWidget {
  final int index;
  final String title;
  final String subtitle;
  final IconData leadingIcon;

  const _HowItWorksStepRow({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            index.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(leadingIcon, size: 18, color: AppColors.textPrimary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.25,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
