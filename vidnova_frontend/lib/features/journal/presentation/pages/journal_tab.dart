import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/network/dio_factory.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/score_color_scale.dart';
import '../../../checkins/presentation/widgets/daily_checkin_tile.dart' show EmotionUi;
import '../../data/journal_api.dart';
import '../../data/models/journal_models.dart';
import '../journal_changes.dart';
import '../widgets/dashed_rounded_border.dart';
import 'abc_wizard_page.dart';

class JournalTab extends StatefulWidget {
  const JournalTab({super.key});

  @override
  State<JournalTab> createState() => _JournalTabState();
}

class _JournalTabState extends State<JournalTab> {
  late final JournalApi _api;
  Future<List<AbcEntryListItemDto>>? _future;

  @override
  void initState() {
    super.initState();

    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    final dio = DioFactory(
      baseUrl: ApiConfig.baseUrl(isAndroidEmulator: isAndroid),
      tokenStorage: TokenStorage(),
    ).create();

    _api = JournalApi(dio);
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _api.listAbc();
    });
  }

  Future<void> _openNew() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AbcWizardPage()),
    );
    if (changed == true) _reload();
  }

  Future<void> _openEdit(String id) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AbcWizardPage(entryId: id)),
    );
    if (changed == true) _reload();
  }

  Future<void> _delete(String id) async {
    try {
      await _api.deleteAbc(id);
      JournalChanges.bump();
      _reload();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не вдалося видалити запис')),
      );
    }
  }

  String _formatDay(DateTime dt) {
    final local = dt.toLocal();
    final dd = local.day.toString().padLeft(2, '0');
    final mm = local.month.toString().padLeft(2, '0');
    final yyyy = local.year.toString();
    return '$dd.$mm.$yyyy';
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$hh:$min';
  }

  bool _isSameLocalDay(DateTime a, DateTime b) {
    final aa = a.toLocal();
    final bb = b.toLocal();
    return aa.year == bb.year && aa.month == bb.month && aa.day == bb.day;
  }

  ({String title, String? preview}) _splitSituation(String situation) {
    final text = situation.trim();
    if (text.isEmpty) return (title: 'Без назви', preview: null);

    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.isEmpty) return (title: 'Без назви', preview: null);

    if (lines.length == 1) {
      final s = lines.first;
      if (s.length <= 42) return (title: s, preview: null);
      return (title: '${s.substring(0, 42).trim()}…', preview: null);
    }

    final title = lines.first.length <= 42 ? lines.first : '${lines.first.substring(0, 42).trim()}…';
    final preview = lines.skip(1).join(' ');
    final pv = preview.length <= 110 ? preview : '${preview.substring(0, 110).trim()}…';
    return (title: title, preview: pv);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _Header(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: GestureDetector(
              onTap: _openNew,
              child: DashedRoundedBorder(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.primaryBorder,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Додати нову ситуацію',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<AbcEntryListItemDto>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Не вдалося завантажити журнал',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _reload,
                            child: const Text('Спробувати ще раз'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final items = snap.data ?? const [];
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'Поки що немає записів',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                final sorted = items.toList(growable: false)
                  ..sort((a, b) => b.createdDate.compareTo(a.createdDate));

                return RefreshIndicator(
                  onRefresh: () async {
                    final f = _api.listAbc();
                    setState(() => _future = f);
                    try {
                      await f;
                    } catch (_) {}
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: sorted.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final item = sorted[i];
                      final showDayHeader = i == 0 || !_isSameLocalDay(item.createdDate, sorted[i - 1].createdDate);
                      final split = _splitSituation(item.situation);
                      final avgInitialIntensity = item.emotions.isEmpty
                          ? 0
                          : (item.emotions.map((e) => e.initialIntensity).reduce((a, b) => a + b) /
                                  item.emotions.length)
                              .round();

                      final isPositiveFlow = item.emotions.isNotEmpty &&
                          item.emotions.every((e) => e.emotion == 'Calm' || e.emotion == 'Joy');

                      // Для негативних: initialIntensity = "негативність" -> інвертуємо у "стан".
                      // Для позитивних (Calm/Joy): initialIntensity = "стан" -> не інвертуємо.
                      final initialCalm = item.emotions.isEmpty
                          ? 0
                          : (isPositiveFlow ? avgInitialIntensity : (100 - avgInitialIntensity)).clamp(0, 100);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDayHeader)
                            Padding(
                              padding: EdgeInsets.fromLTRB(4, i == 0 ? 0 : 8, 4, 8),
                              child: Text(
                                _formatDay(item.createdDate),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          _SituationCard(
                            title: split.title,
                            preview: split.preview,
                            dateText: _formatTime(item.createdDate),
                            finalIntensity: item.finalEmotionIntensity,
                            intensityPercent: initialCalm,
                            emotions: item.emotions.map((e) => e.emotion).toList(),
                            onEdit: () => _openEdit(item.id),
                            onDelete: () => _delete(item.id),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    // “Inverse rounding” effect: gradient header + a background-colored rounded
    // shape overlapping the bottom so it looks like the white background is rounded.
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
                'Журнал ситуацій',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Фіксуйте та аналізуйте стресові інциденти',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: bottomCutoutHeight,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
          ),
        ),
      ],
    );
  }
}

class _SituationCard extends StatelessWidget {
  final String title;
  final String? preview;
  final String dateText;
  final int finalIntensity;
  final int? intensityPercent;
  final List<String> emotions;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SituationCard({
    required this.title,
    required this.preview,
    required this.dateText,
    required this.finalIntensity,
    required this.intensityPercent,
    required this.emotions,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(18);
    final percent = (intensityPercent ?? 0).clamp(0, 100);
    final initialColor = ScoreColorScale.discrete(percent);
    final finalColor = _finalScoreColor(finalIntensity);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: finalColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Після: $finalIntensity/100',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: finalColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dateText,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                if (preview != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    preview!,
                    style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                  ),
                ],
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const emojiFontSize = 18.0;
                    const emojiSpacing = 6.0;

                    const minBarWidth = 160.0;
                    final availableForEmoji = constraints.maxWidth - minBarWidth - 12;

                    double measureEmojiRowWidth() {
                      if (emotions.isEmpty) return 0;
                      final emojis = emotions.map((e) => EmotionUi.emoji[e] ?? '🙂').toList();
                      final painter = TextPainter(
                        textDirection: TextDirection.ltr,
                        maxLines: 1,
                      );

                      var width = 0.0;
                      for (var i = 0; i < emojis.length; i++) {
                        painter.text = TextSpan(
                          text: emojis[i],
                          style: const TextStyle(fontSize: emojiFontSize),
                        );
                        painter.layout();
                        width += painter.width;
                        if (i != emojis.length - 1) width += emojiSpacing;
                      }
                      return width;
                    }

                    final emojiRowWidth = measureEmojiRowWidth();
                    final canInline = availableForEmoji > 0 && emojiRowWidth <= (availableForEmoji - 4);

                    final emojiWrap = Wrap(
                      spacing: emojiSpacing,
                      runSpacing: 4,
                      children: emotions
                          .map(
                            (e) => Text(
                              EmotionUi.emoji[e] ?? '🙂',
                              style: const TextStyle(fontSize: emojiFontSize),
                            ),
                          )
                          .toList(),
                    );

                    final emojiRow = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List<Widget>.generate(
                        emotions.length,
                        (i) {
                          final e = emotions[i];
                          final widgets = <Widget>[
                            Text(
                              EmotionUi.emoji[e] ?? '🙂',
                              style: const TextStyle(fontSize: emojiFontSize),
                            ),
                          ];
                          if (i != emotions.length - 1) {
                            widgets.add(const SizedBox(width: emojiSpacing));
                          }
                          return Row(mainAxisSize: MainAxisSize.min, children: widgets);
                        },
                        growable: false,
                      ),
                    );

                    Widget bar() {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'На початку',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              const Spacer(),
                              Text(
                                '$percent%',
                                style: TextStyle(fontSize: 12, color: initialColor, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 6,
                              value: percent / 100,
                              backgroundColor: AppColors.gridLines,
                              valueColor: AlwaysStoppedAnimation<Color>(initialColor),
                            ),
                          ),
                        ],
                      );
                    }

                    if (canInline) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: availableForEmoji),
                            child: ClipRect(child: emojiRow),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minWidth: minBarWidth),
                              child: bar(),
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        emojiWrap,
                        const SizedBox(height: 10),
                        bar(),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, color: AppColors.primary, size: 18),
                    label: const Text('Редагувати', style: TextStyle(color: AppColors.primary)),
                  ),
                ),
                Container(width: 1, height: 42, color: AppColors.border),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, color: AppColors.emotionNegative, size: 18),
                    label: const Text('Видалити', style: TextStyle(color: AppColors.emotionNegative)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _finalScoreColor(int score) {
    return ScoreColorScale.discrete(score);
  }
}
