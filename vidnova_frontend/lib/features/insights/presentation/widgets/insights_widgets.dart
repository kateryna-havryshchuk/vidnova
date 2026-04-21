part of '../pages/insights_tab.dart';

class _InsightsHeader extends StatelessWidget {
  const _InsightsHeader();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    const bottomCutoutHeight = 26.0;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16, top + 14, 16, 24 + bottomCutoutHeight),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Аналітика',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Відстежуйте динаміку свого стану',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SizedBox(
            height: bottomCutoutHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final Color accentColor;
  final bool bigValue;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accentColor,
    this.bigValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withAlpha(18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: bigValue ? 28 : 22,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: accentColor == AppColors.emotionChart ? AppColors.textTertiary : accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  final _AnalyticsPeriod value;
  final ValueChanged<_AnalyticsPeriod> onChanged;

  const _PeriodToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget chip(String text, _AnalyticsPeriod v) {
      final selected = value == v;
      return GestureDetector(
        onTap: () => onChanged(v),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : AppColors.background,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? AppColors.primaryBorder : AppColors.border),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('Тиж', _AnalyticsPeriod.week),
        const SizedBox(width: 6),
        chip('Міс', _AnalyticsPeriod.month),
        const SizedBox(width: 6),
        chip('Все', _AnalyticsPeriod.all),
      ],
    );
  }
}

class _EmotionBarRow extends StatelessWidget {
  final String emoji;
  final int count;
  final double ratio;

  const _EmotionBarRow({
    required this.emoji,
    required this.count,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 26, child: Text(emoji, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18))),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 14,
              color: AppColors.gridLines,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: ratio.clamp(0.0, 1.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 18,
          child: Text(
            '$count',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _MultiMarkerLegend extends StatelessWidget {
  const _MultiMarkerLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.textSecondary, width: 1.5),
            color: Colors.transparent,
          ),
        ),
        const SizedBox(width: 6),
        const Text('кілька', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
