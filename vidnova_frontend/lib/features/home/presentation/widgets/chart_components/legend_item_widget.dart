import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class LegendItemWidget extends StatelessWidget {
  final Color color;
  final String text;
  final bool isDashed;

  const LegendItemWidget({
    super.key,
    required this.color,
    required this.text,
    required this.isDashed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: isDashed
                ? [
                    Container(width: 4, height: 2, color: color),
                    const SizedBox(width: 2),
                    Container(width: 4, height: 2, color: color),
                    const SizedBox(width: 2),
                    Container(width: 4, height: 2, color: color),
                  ]
                : [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(width: 24, height: 2, color: color),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ],
                    ),
                  ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}