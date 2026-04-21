import 'package:flutter/material.dart';
import 'package:twemoji/twemoji.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/score_color_scale.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../data/checkins_api.dart';
import '../../data/models/checkin_models.dart';
import '../widgets/daily_checkin_tile.dart';

class DailyCheckInPage extends StatefulWidget {
  final CheckInsApi api;
  final DateTime date;

  const DailyCheckInPage({
    super.key,
    required this.api,
    required this.date,
  });

  @override
  State<DailyCheckInPage> createState() => _DailyCheckInPageState();
}

class _DailyCheckInPageState extends State<DailyCheckInPage> {
  static const List<double> _greyscaleMatrix = <double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ];

  final _descriptionController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  bool _exists = false;
  int _calmScore = 50;

  // emotion -> intensity
  final Map<String, int> _selected = <String, int>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dto = await widget.api.getByDate(_formatDate(widget.date));
      if (!mounted) return;

      if (dto == null) {
        setState(() {
          _exists = false;
          _isLoading = false;
        });
        return;
      }

      _descriptionController.text = dto.description;
      _calmScore = dto.calmScore;
      _selected
        ..clear()
        ..addEntries(dto.emotions.map((e) => MapEntry(e.emotion, e.intensity)));

      setState(() {
        _exists = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Не вдалося завантажити стан на цю дату.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _formatDate(widget.date);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Щоденний стан',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Text(
                  dateText,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 12),
                if (_error != null) ...[
                  ErrorBanner(message: _error!),
                  const SizedBox(height: 12),
                ],
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Опис',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _descriptionController,
                        keyboardType: TextInputType.multiline,
                        minLines: 6,
                        maxLines: 10,
                        decoration: InputDecoration(
                          hintText: 'Коротко опишіть, як минув день…',
                          hintStyle: const TextStyle(color: AppColors.textHint),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: AppColors.primaryBorder),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Емоції',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Натисніть, щоб вибрати. Несумісні емоції будуть заблоковані.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      _emotionGrid(),
                      const SizedBox(height: 16),
                      if (_selected.isNotEmpty) ...[
                        const Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: 12),
                        const Text(
                          'Інтенсивність',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._selected.entries.map(_intensityRow),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Оцініть свій загальний стан',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '$_calmScore/100',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: ScoreColorScale.smooth(_calmScore),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Builder(
                        builder: (context) {
                          final c = ScoreColorScale.smooth(_calmScore);
                          return SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                              activeTrackColor: c,
                              inactiveTrackColor: AppColors.gridLines,
                              thumbColor: c,
                              overlayColor: c.withAlpha(51),
                            ),
                            child: Slider(
                              value: _calmScore.toDouble(),
                              min: 0,
                              max: 100,
                              divisions: 100,
                              onChanged: (v) => setState(() => _calmScore = v.round()),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _calmScoreHint(_calmScore),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Підсумок',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _summaryText(),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _exists ? 'Зберегти зміни' : 'Зберегти',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
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
      child: child,
    );
  }

  Widget _emotionGrid() {
    final blocked = _blockedEmotions();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final emotion in EmotionUi.all)
          _emotionCircle(
            emotion: emotion,
            isSelected: _selected.containsKey(emotion),
            isBlocked: blocked.contains(emotion) && !_selected.containsKey(emotion),
          ),
      ],
    );
  }

  Set<String> _blockedEmotions() {
    final selected = _selected.keys.toList(growable: false);
    final blocked = <String>{};

    for (final e in selected) {
      final conflicts = EmotionUi.incompatible[e];
      if (conflicts != null) blocked.addAll(conflicts);
    }

    return blocked;
  }

  Widget _emotionCircle({
    required String emotion,
    required bool isSelected,
    required bool isBlocked,
  }) {
    final emoji = EmotionUi.emoji[emotion] ?? '🙂';

    final Color bg;
    final Color border;

    if (isBlocked) {
      bg = AppColors.gridLines;
      border = AppColors.border;
    } else if (isSelected) {
      bg = AppColors.primary;
      border = AppColors.primaryBorder;
    } else {
      bg = AppColors.surface;
      border = AppColors.border;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: bg,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: isBlocked ? null : () => _toggleEmotion(emotion),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: border),
              ),
              alignment: Alignment.center,
              child: isBlocked
                  ? Opacity(
                      opacity: 0.45,
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.matrix(_greyscaleMatrix),
                        child: Twemoji(
                          emoji: emoji,
                          height: 28,
                          width: 28,
                          twemojiFormat: TwemojiFormat.png,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  : Twemoji(
                      emoji: emoji,
                      height: 28,
                      width: 28,
                      twemojiFormat: TwemojiFormat.png,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 70,
          child: Text(
            EmotionUi.title(emotion),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: isBlocked ? AppColors.inactive : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        )
      ],
    );
  }

  void _toggleEmotion(String emotion) {
    setState(() {
      if (_selected.containsKey(emotion)) {
        _selected.remove(emotion);
      } else {
        _selected[emotion] = 50;
      }
    });
  }

  Widget _intensityRow(MapEntry<String, int> entry) {
    final emotion = entry.key;
    final value = entry.value;

    final emoji = EmotionUi.emoji[emotion] ?? '🙂';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Center(
              child: Twemoji(
                emoji: emoji,
                height: 20,
                width: 20,
                twemojiFormat: TwemojiFormat.png,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      EmotionUi.title(emotion),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '$value/100',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: value.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.gridLines,
                  onChanged: (v) => setState(() => _selected[emotion] = v.round()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final req = SaveDailyCheckInRequestDto(
        description: _descriptionController.text.trim(),
        calmScore: _calmScore,
        emotions: _selected.entries
            .map((e) => CheckInEmotionDto(emotion: e.key, intensity: e.value))
            .toList(),
      );

      final date = _formatDate(widget.date);

      if (_exists) {
        await widget.api.update(date, req);
      } else {
        await widget.api.create(date, req);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Не вдалося зберегти. Перевірте вибір емоцій та спробуйте ще раз.';
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _summaryText() {
    final scoreText = '$_calmScore/100';
    final stateText = _calmScoreHint(_calmScore);

    if (_selected.isEmpty) {
      return 'Загальний стан: $scoreText. $stateText Додайте 1–2 емоції, щоб краще відслідковувати зміни.';
    }

    final sorted = _selected.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first;
    final topTitle = EmotionUi.title(top.key);
    final topIntensity = '${top.value}/100';

    final String suggestion;
    if (_calmScore >= 75) {
      suggestion = 'Спробуйте коротко відмітити, що саме сьогодні допомогло вам почуватися краще — це корисно повторювати.';
    } else if (_calmScore >= 50) {
      suggestion = 'Невелика пауза, прогулянка або 5 хвилин без телефону можуть м’яко підсилити стан.';
    } else if (_calmScore >= 25) {
      suggestion = 'Спробуйте 1–2 хвилини повільного дихання або коротке розвантаження (вода, їжа, рух).';
    } else {
      suggestion = 'Подбайте про базові потреби (сон, їжа, вода) і, якщо є можливість, поговоріть з близькою людиною або фахівцем.';
    }

    return 'Загальний стан: $scoreText. Домінує: $topTitle ($topIntensity). $stateText $suggestion';
  }

  String _calmScoreHint(int score) {
    if (score >= 75) return 'Високий рівень спокою.';
    if (score >= 50) return 'Стабільний стан.';
    if (score >= 25) return 'Відчутний дискомфорт або напруга.';
    return 'Складний стан.';
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
