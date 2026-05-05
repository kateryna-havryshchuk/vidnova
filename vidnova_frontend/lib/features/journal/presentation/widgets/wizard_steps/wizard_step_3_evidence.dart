import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../bloc/journal_bloc.dart';
import '../../bloc/journal_event.dart';
import '../../bloc/journal_state.dart';
import '../dashed_rounded_border.dart';

class WizardStep3Evidence extends StatefulWidget {
  const WizardStep3Evidence({super.key});

  @override
  State<WizardStep3Evidence> createState() => _WizardStep3EvidenceState();
}

class _WizardStep3EvidenceState extends State<WizardStep3Evidence> {
  final TextEditingController _factController = TextEditingController();

  @override
  void dispose() {
    _factController.dispose();
    super.dispose();
  }

  void _addFact(BuildContext context) {
    final text = _factController.text.trim();
    if (text.isEmpty) return;
    context.read<JournalBloc>().add(AddEvidenceToPoolEvent(text));
    _factController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalBloc, JournalState>(
      builder: (context, state) {
        final forCount = state.evidenceFor.length;
        final againstCount = state.evidenceAgainst.length;
        final balanceDelta = forCount - againstCount;

        String balanceText;
        if (balanceDelta == 0) {
          balanceText = 'Фактів порівну — це допомагає бути обʼєктивним.';
        } else if (balanceDelta > 0) {
          balanceText = 'Зараз більше фактів, що підтверджують думку.';
        } else {
          balanceText = 'Зараз більше фактів, що спростовують думку.';
        }

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Аналіз думок',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Коли ми переживаємо, наш мозок фокусується лише на негативі. Давайте перевіримо — чи є реальні факти, що підтверджують вашу тривожну думку, і чи є щось, що їй суперечить?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _BalanceCard(
                        forCount: forCount,
                        againstCount: againstCount,
                        delta: balanceDelta,
                        message: balanceText,
                      ),

                      const SizedBox(height: 16),
                      const Text(
                        'Запишіть факт або спостереження',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Що конкретно сталося? Не оцінки, а факти — те, що можна побачити на камеру.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.25,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(20),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _factController,
                                decoration: const InputDecoration(
                                  hintText: 'Факт або спостереження',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _addFact(context),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 48,
                            width: 48,
                            child: ElevatedButton(
                              onPressed: () => _addFact(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Icon(Icons.add, color: Colors.white),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Text(
                        'Факти',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _PoolWrap(
                        items: state.evidencePool,
                        onRemove: (text) => context.read<JournalBloc>().add(RemoveEvidenceFromPoolEvent(text)),
                      ),
                      if (state.evidencePool.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            'Додайте хоча б один факт — потім перетягніть його в одну з зон.',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: Row(
                          children: [
                            Expanded(
                              child: _DropZone(
                                title: 'Підтверджує',
                                subtitle: '$forCount',
                                itemCount: state.evidenceFor.length,
                                expand: true,
                                onAccept: (text) => context.read<JournalBloc>().add(MoveEvidenceToForEvent(text)),
                                child: _ZoneWrap(
                                  items: state.evidenceFor,
                                  onRemove: (text) => context.read<JournalBloc>().add(RemoveEvidenceFromForEvent(text)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DropZone(
                                title: 'Спростовує',
                                subtitle: '$againstCount',
                                itemCount: state.evidenceAgainst.length,
                                expand: true,
                                onAccept: (text) => context.read<JournalBloc>().add(MoveEvidenceToAgainstEvent(text)),
                                child: _ZoneWrap(
                                  items: state.evidenceAgainst,
                                  onRemove: (text) => context.read<JournalBloc>().add(RemoveEvidenceFromAgainstEvent(text)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.read<JournalBloc>().add(NextStepEvent()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Далі',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final int forCount;
  final int againstCount;
  final int delta;
  final String message;

  const _BalanceCard({
    required this.forCount,
    required this.againstCount,
    required this.delta,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _CountLabel(title: 'Підтверджує', count: forCount),
              ),
              SizedBox(
                width: 130,
                height: 64,
                child: CustomPaint(
                  painter: _BalancePainter(delta: delta),
                ),
              ),
              Expanded(
                child: _CountLabel(title: 'Спростовує', count: againstCount, alignRight: true),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CountLabel extends StatelessWidget {
  final String title;
  final int count;
  final bool alignRight;

  const _CountLabel({
    required this.title,
    required this.count,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          '$count',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _BalancePainter extends CustomPainter {
  final int delta;

  _BalancePainter({required this.delta});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fillPaint = Paint()
      ..color = AppColors.primary.withAlpha(30)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final baseY = size.height * 0.85;
    final topY = size.height * 0.25;

    // Base
    canvas.drawLine(Offset(centerX, baseY), Offset(centerX, topY), paint);

    // Beam (tilt based on delta)
    final clamped = delta.clamp(-3, 3);
    final angle = (-clamped / 3) * 0.35; // radians
    final beamHalf = size.width * 0.36;
    final beamY = size.height * 0.32;

    final left = Offset(centerX - beamHalf, beamY);
    final right = Offset(centerX + beamHalf, beamY);

    Offset rotate(Offset p) {
      final dx = p.dx - centerX;
      final dy = p.dy - beamY;
      final cosA = math.cos(angle);
      final sinA = math.sin(angle);
      return Offset(
        centerX + dx * cosA - dy * sinA,
        beamY + dx * sinA + dy * cosA,
      );
    }

    final leftR = rotate(left);
    final rightR = rotate(right);
    canvas.drawLine(leftR, rightR, paint);

    // Plates
    final plateRadius = 6.0;
    canvas.drawCircle(leftR.translate(0, 14), plateRadius, fillPaint);
    canvas.drawCircle(leftR.translate(0, 14), plateRadius, paint);
    canvas.drawCircle(rightR.translate(0, 14), plateRadius, fillPaint);
    canvas.drawCircle(rightR.translate(0, 14), plateRadius, paint);

    // Pivot
    canvas.drawCircle(Offset(centerX, beamY), 4, fillPaint);
    canvas.drawCircle(Offset(centerX, beamY), 4, paint);
  }

  @override
  bool shouldRepaint(covariant _BalancePainter oldDelegate) => oldDelegate.delta != delta;
}

class _PoolWrap extends StatelessWidget {
  final List<String> items;
  final void Function(String) onRemove;

  const _PoolWrap({required this.items, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final text in items)
          _EvidenceChip(
            text: text,
            trailing: GestureDetector(
              onTap: () => onRemove(text),
              child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
            ),
          ),
      ],
    );
  }
}

class _ZoneWrap extends StatelessWidget {
  final List<String> items;
  final void Function(String) onRemove;

  const _ZoneWrap({required this.items, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final text in items)
          _EvidenceChip(
            text: text,
            trailing: GestureDetector(
              onTap: () => onRemove(text),
              child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
            ),
          ),
      ],
    );
  }
}

class _DropZone extends StatelessWidget {
  final String title;
  final String subtitle;
  final int itemCount;
  final bool expand;
  final void Function(String) onAccept;
  final Widget child;

  const _DropZone({
    required this.title,
    required this.subtitle,
    required this.itemCount,
    required this.expand,
    required this.onAccept,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty;
        final shouldScroll = itemCount > 8;
        final minHeight = itemCount == 0 ? 72.0 : 96.0;

        final zoneBody = DashedRoundedBorder(
          borderRadius: BorderRadius.circular(16),
          color: isActive ? AppColors.primary : AppColors.border,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: minHeight),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary.withAlpha(14) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: shouldScroll
                ? SizedBox(
                    height: 200,
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: child,
                      ),
                    ),
                  )
                : Align(
                    alignment: Alignment.topLeft,
                    child: child,
                  ),
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (expand) Expanded(child: zoneBody) else zoneBody,
          ],
        );
      },
    );
  }
}

class _EvidenceChip extends StatelessWidget {
  final String text;
  final Widget trailing;

  const _EvidenceChip({required this.text, required this.trailing});

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );

    return LongPressDraggable<String>(
      data: text,
      delay: const Duration(milliseconds: 220),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Opacity(opacity: 0.9, child: chip),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: chip),
      child: chip,
    );
  }
}

