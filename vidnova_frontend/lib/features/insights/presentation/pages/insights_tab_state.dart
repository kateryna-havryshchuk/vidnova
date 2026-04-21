part of 'insights_tab.dart';

class _InsightsTabState extends State<InsightsTab> {
  late final CheckInsApi _checkInsApi;
  late final JournalApi _journalApi;

  _AnalyticsPeriod _period = _AnalyticsPeriod.month;
  late final ValueNotifier<_AnalyticsPeriod> _reappraisalPeriodNotifier;
  DateTime _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDay;

  Future<DailyCheckInResponseDto?>? _todayFuture;
  Future<List<DailyCheckInResponseDto>>? _monthFuture;
  Future<List<DailyCheckInResponseDto>>? _periodFuture;
  Future<List<AbcEntryListItemDto>>? _abcFuture;

  String? _lastUserKey;

  @override
  void initState() {
    super.initState();

    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    final tokenStorage = TokenStorage();
    final dio = DioFactory(
      baseUrl: ApiConfig.baseUrl(isAndroidEmulator: isAndroid),
      tokenStorage: tokenStorage,
    ).create();

    _checkInsApi = CheckInsApi(dio);
    _journalApi = JournalApi(dio);
    _reappraisalPeriodNotifier = ValueNotifier(_AnalyticsPeriod.month);
    _reloadAll();
  }

  @override
  void dispose() {
    _reappraisalPeriodNotifier.dispose();
    super.dispose();
  }

  void _reloadAll() {
    _reloadToday();
    _reloadMonth();
    _reloadPeriod();
    _reloadAbc();
  }

  Future<void> _refresh() async {
    final today = DateTime.now();
    final todayFuture = _checkInsApi.getByDate(_formatDate(today));

    final monthFrom = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final monthTo = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0);
    final monthFuture = _checkInsApi.listRange(
      from: _formatDate(monthFrom),
      to: _formatDate(monthTo),
    );

    final now = DateTime.now();
    late final DateTime periodFrom;
    late final DateTime periodTo;

    switch (_period) {
      case _AnalyticsPeriod.week:
        final start = _startOfWeek(DateTime(now.year, now.month, now.day));
        periodFrom = start;
        periodTo = start.add(const Duration(days: 6));
        break;
      case _AnalyticsPeriod.month:
        periodFrom = monthFrom;
        periodTo = monthTo;
        break;
      case _AnalyticsPeriod.all:
        periodFrom = DateTime(2000, 1, 1);
        periodTo = now;
        break;
    }

    final periodFuture = _checkInsApi.listRange(
      from: _formatDate(periodFrom),
      to: _formatDate(periodTo),
    );

    final abcFuture = _journalApi.listAbc();

    setState(() {
      _todayFuture = todayFuture;
      _monthFuture = monthFuture;
      _periodFuture = periodFuture;
      _abcFuture = abcFuture;
    });

    try {
      await Future.wait([
        todayFuture,
        monthFuture,
        periodFuture,
        abcFuture,
      ]);
    } catch (_) {
      // RefreshIndicator only needs the Future to complete.
    }
  }

  void _reloadToday() {
    final today = DateTime.now();
    setState(() {
      _todayFuture = _checkInsApi.getByDate(_formatDate(today));
    });
  }

  void _reloadMonth() {
    final from = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final to = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0);
    setState(() {
      _monthFuture = _checkInsApi.listRange(
        from: _formatDate(from),
        to: _formatDate(to),
      );
    });
  }

  void _reloadPeriod() {
    final now = DateTime.now();
    late final DateTime from;
    late final DateTime to;

    switch (_period) {
      case _AnalyticsPeriod.week:
        final start = _startOfWeek(DateTime(now.year, now.month, now.day));
        from = start;
        to = start.add(const Duration(days: 6));
        break;
      case _AnalyticsPeriod.month:
        from = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
        to = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0);
        break;
      case _AnalyticsPeriod.all:
        from = DateTime(2000, 1, 1);
        to = now;
        break;
    }

    setState(() {
      _periodFuture = _checkInsApi.listRange(
        from: _formatDate(from),
        to: _formatDate(to),
      );
    });
  }

  void _reloadAbc() {
    setState(() {
      _abcFuture = _journalApi.listAbc();
    });
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    final me = context.select((AuthCubit c) => c.state.me);
    final currentUserKey = me == null ? null : '${me.userId}:${me.email}';
    if (_lastUserKey != currentUserKey) {
      _lastUserKey = currentUserKey;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _reloadAll();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _InsightsHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                children: [
                  FutureBuilder<DailyCheckInResponseDto?>(
                    future: _todayFuture,
                    builder: (context, todaySnap) {
                      final todayState = todaySnap.data?.calmScore;
                      return FutureBuilder<List<DailyCheckInResponseDto>>(
                        future: _monthFuture,
                        builder: (context, monthSnap) {
                          final monthItems = monthSnap.data ?? const <DailyCheckInResponseDto>[];
                          final monthAvg = _avg(monthItems.map((e) => e.calmScore));
                          final monthTopEmotion = monthItems.isEmpty ? null : _mostFrequentEmotion(monthItems);
                          final monthCount = monthItems.length;

                          return _summaryGrid(
                            todayState: todayState,
                            monthAvgState: monthAvg,
                            monthTopEmotion: monthTopEmotion,
                            monthCount: monthCount,
                            monthTitle: _monthTitle(_calendarMonth),
                            isLoading: todaySnap.connectionState == ConnectionState.waiting ||
                                monthSnap.connectionState == ConnectionState.waiting,
                            hasError: todaySnap.hasError || monthSnap.hasError,
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  FutureBuilder<List<DailyCheckInResponseDto>>(
                    future: _monthFuture,
                    builder: (context, snap) {
                      return _calendarCard(
                        items: snap.data ?? const <DailyCheckInResponseDto>[],
                        isLoading: snap.connectionState == ConnectionState.waiting,
                        hasError: snap.hasError,
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  FutureBuilder<List<DailyCheckInResponseDto>>(
                    future: _periodFuture,
                    builder: (context, snap) {
                      final items = (snap.data ?? const <DailyCheckInResponseDto>[]).toList()
                        ..sort((a, b) => a.date.compareTo(b.date));
                      return _trendCard(
                        items: items,
                        isLoading: snap.connectionState == ConnectionState.waiting,
                        hasError: snap.hasError,
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  FutureBuilder<List<DailyCheckInResponseDto>>(
                    future: _periodFuture,
                    builder: (context, snap) {
                      return _emotionFrequencyCard(
                        items: snap.data ?? const <DailyCheckInResponseDto>[],
                        isLoading: snap.connectionState == ConnectionState.waiting,
                        hasError: snap.hasError,
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  FutureBuilder<List<AbcEntryListItemDto>>(
                    future: _abcFuture,
                    builder: (context, snap) {
                      return _reappraisalDynamicsCard(
                        items: snap.data ?? const <AbcEntryListItemDto>[],
                        isLoading: snap.connectionState == ConnectionState.waiting,
                        hasError: snap.hasError,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reappraisalDynamicsCard({
    required List<AbcEntryListItemDto> items,
    required bool isLoading,
    required bool hasError,
  }) {
    return ValueListenableBuilder<_AnalyticsPeriod>(
      valueListenable: _reappraisalPeriodNotifier,
      builder: (context, period, _) {
        // Filter by this chart's own period settings.
        final from = _reappraisalRangeFrom(period);
        final to = _reappraisalRangeTo(period);
        final inRange = <AbcEntryListItemDto>[];
        for (final e in items) {
          final d = DateTime(e.createdDate.year, e.createdDate.month, e.createdDate.day);
          if (d.isBefore(DateTime(from.year, from.month, from.day)) || d.isAfter(DateTime(to.year, to.month, to.day))) {
            continue;
          }
          inRange.add(e);
        }
        inRange.sort((a, b) => a.createdDate.compareTo(b.createdDate));

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
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Динаміка стану після переосмислення',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _PeriodToggle(
                    value: period,
                    onChanged: (v) {
                      _reappraisalPeriodNotifier.value = v;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Графік показує середній рівень вашого стану ("спокою") в записаних вами ситуаціях: “На початку” (до переосмислення) та “Після” (після альтернативної думки).\n'
                'Якщо за день було кілька ситуацій — береться середнє значення; такі точки позначені кружечком.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
              ),
              const SizedBox(height: 10),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (hasError)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Не вдалося завантажити дані журналу.', style: TextStyle(color: AppColors.textSecondary)),
                )
              else if (inRange.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Немає записів у журналі за вибраний період.', style: TextStyle(color: AppColors.textSecondary)),
                )
              else
                SizedBox(
                  height: 200,
                  child: _ReappraisalTrendChart(
                    items: inRange,
                    period: period,
                    rangeFrom: from,
                    rangeTo: to,
                    initialColor: AppColors.emotionChart,
                    afterColor: AppColors.secondary,
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendLine(AppColors.emotionChart),
                  const SizedBox(width: 6),
                  const Text('На початку', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: 12),
                  _legendLine(AppColors.secondary),
                  const SizedBox(width: 6),
                  const Text('Після', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: 12),
                  const _MultiMarkerLegend(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryGrid({
    required int? todayState,
    required int? monthAvgState,
    required String? monthTopEmotion,
    required int monthCount,
    required String monthTitle,
    required bool isLoading,
    required bool hasError,
  }) {
    final topEmoji = monthTopEmotion == null ? '—' : (EmotionUi.emoji[monthTopEmotion] ?? '🙂');

    String showScore(int? v) => v == null ? '—/100' : '$v/100';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                title: 'Стан сьогодні',
                value: isLoading ? '…' : (hasError ? '—/100' : showScore(todayState)),
                subtitle: 'Поточний стан',
                accentColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStatCard(
                title: 'Середній стан',
                value: isLoading ? '…' : (hasError ? '—/100' : showScore(monthAvgState)),
                subtitle: monthTitle,
                accentColor: AppColors.emotionChart,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                title: 'Найчастіша емоція',
                value: isLoading ? '…' : (hasError ? '—' : topEmoji),
                subtitle: isLoading
                    ? null
                    : (hasError ? null : (monthTopEmotion == null ? null : EmotionUi.title(monthTopEmotion))),
                accentColor: AppColors.secondary,
                bigValue: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStatCard(
                title: 'Записів у місяці',
                value: isLoading ? '…' : (hasError ? '0' : monthCount.toString()),
                subtitle: monthTitle,
                accentColor: AppColors.emotionPositive,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _calendarCard({
    required List<DailyCheckInResponseDto> items,
    required bool isLoading,
    required bool hasError,
  }) {
    final map = <DateTime, DailyCheckInResponseDto>{};
    for (final e in items) {
      final dt = DateTime.tryParse(e.date);
      if (dt == null) continue;
      map[DateTime(dt.year, dt.month, dt.day)] = e;
    }

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
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month - 1, 1);
                    _selectedDay = null;
                  });
                  _reloadMonth();
                  if (_period == _AnalyticsPeriod.month) _reloadPeriod();
                },
                icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _monthTitle(_calendarMonth),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 1);
                    _selectedDay = null;
                  });
                  _reloadMonth();
                  if (_period == _AnalyticsPeriod.month) _reloadPeriod();
                },
                icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _weekdayRow(),
          const SizedBox(height: 8),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (hasError)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Не вдалося завантажити календар.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            _monthGrid(map),
          const SizedBox(height: 12),
          _calendarLegend(),
        ],
      ),
    );
  }

  Widget _weekdayRow() {
    const labels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];
    return Row(
      children: [
        for (final l in labels)
          Expanded(
            child: Center(
              child: Text(
                l,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          )
      ],
    );
  }

  Widget _monthGrid(Map<DateTime, DailyCheckInResponseDto> map) {
    final first = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final daysInMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0).day;
    final firstWeekday = first.weekday; // 1..7 (Mon..Sun)
    final leadingEmpty = firstWeekday - 1;
    final totalCells = ((leadingEmpty + daysInMonth) / 7).ceil() * 7;

    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemBuilder: (context, i) {
        final dayNumber = i - leadingEmpty + 1;
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final dateKey = DateTime(_calendarMonth.year, _calendarMonth.month, dayNumber);
        final dto = map[dateKey];
        final bg = dto == null ? AppColors.gridLines : _scoreColor(dto.calmScore);
        final isSelected = _selectedDay != null &&
            DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day) == dateKey;
        final isToday = dateKey == todayKey;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = dateKey;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppColors.secondary, width: 2)
                  : (isToday ? Border.all(color: AppColors.primary, width: 1.5) : null),
            ),
            alignment: Alignment.center,
            child: Text(
              '$dayNumber',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: dto == null ? AppColors.textHint : Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _calendarLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Поганий', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(width: 10),
        _legendDot(AppColors.emotionNegative),
        const SizedBox(width: 6),
        _legendDot(AppColors.emotionChart),
        const SizedBox(width: 6),
        _legendDot(AppColors.primary),
        const SizedBox(width: 6),
        _legendDot(AppColors.secondary),
        const SizedBox(width: 6),
        _legendDot(AppColors.emotionPositive),
        const SizedBox(width: 10),
        const Text('Добрий', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _legendDot(Color c) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
  }

  Widget _trendCard({
    required List<DailyCheckInResponseDto> items,
    required bool isLoading,
    required bool hasError,
  }) {
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
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Динаміка стану',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _PeriodToggle(
                value: _period,
                onChanged: (v) {
                  setState(() => _period = v);
                  _reloadPeriod();
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (hasError)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Не вдалося завантажити графік.', style: TextStyle(color: AppColors.textSecondary)),
            )
          else if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Немає даних за вибраний період.', style: TextStyle(color: AppColors.textSecondary)),
            )
          else
            SizedBox(
              height: 190,
              child: _TrendChart(
                items: items,
                period: _period,
                rangeFrom: _trendRangeFrom(),
                rangeTo: _trendRangeTo(),
                lineColor: AppColors.secondary,
              ),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendLine(AppColors.secondary),
              const SizedBox(width: 8),
              const Text('Стан', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendLine(Color c) {
    return Container(width: 18, height: 3, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(99)));
  }

  Widget _emotionFrequencyCard({
    required List<DailyCheckInResponseDto> items,
    required bool isLoading,
    required bool hasError,
  }) {
    final freq = _emotionFrequency(items);
    final maxCount = freq.isEmpty ? 1 : freq.first.$2;

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
            'Частота емоцій',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (hasError)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Не вдалося завантажити емоції.', style: TextStyle(color: AppColors.textSecondary)),
            )
          else if (freq.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Немає даних за вибраний період.', style: TextStyle(color: AppColors.textSecondary)),
            )
          else
            Column(
              children: [
                for (final (emotion, count) in freq.take(6))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _EmotionBarRow(
                      emoji: EmotionUi.emoji[emotion] ?? '🙂',
                      count: count,
                      ratio: count / maxCount,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  int? _avg(Iterable<int> values) {
    final list = values.toList();
    if (list.isEmpty) return null;
    final sum = list.fold<int>(0, (a, b) => a + b);
    return (sum / list.length).round();
  }

  String? _mostFrequentEmotion(List<DailyCheckInResponseDto> items) {
    final counts = <String, int>{};
    for (final dto in items) {
      for (final e in dto.emotions) {
        counts[e.emotion] = (counts[e.emotion] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return null;
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  List<(String, int)> _emotionFrequency(List<DailyCheckInResponseDto> items) {
    final counts = <String, int>{};
    for (final dto in items) {
      for (final e in dto.emotions) {
        counts[e.emotion] = (counts[e.emotion] ?? 0) + 1;
      }
    }
    final list = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return list.map((e) => (e.key, e.value)).toList();
  }

  Color _scoreColor(int score) {
    return ScoreColorScale.discrete(score);
  }

  DateTime _trendRangeFrom() {
    final now = DateTime.now();
    switch (_period) {
      case _AnalyticsPeriod.week:
        return _startOfWeek(DateTime(now.year, now.month, now.day));
      case _AnalyticsPeriod.month:
        return DateTime(_calendarMonth.year, _calendarMonth.month, 1);
      case _AnalyticsPeriod.all:
        return DateTime(2000, 1, 1);
    }
  }

  DateTime _trendRangeTo() {
    final now = DateTime.now();
    switch (_period) {
      case _AnalyticsPeriod.week:
        final start = _startOfWeek(DateTime(now.year, now.month, now.day));
        return start.add(const Duration(days: 6));
      case _AnalyticsPeriod.month:
        return DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0);
      case _AnalyticsPeriod.all:
        return now;
    }
  }

  DateTime _reappraisalRangeFrom(_AnalyticsPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case _AnalyticsPeriod.week:
        return _startOfWeek(DateTime(now.year, now.month, now.day));
      case _AnalyticsPeriod.month:
        return DateTime(_calendarMonth.year, _calendarMonth.month, 1);
      case _AnalyticsPeriod.all:
        return DateTime(2000, 1, 1);
    }
  }

  DateTime _reappraisalRangeTo(_AnalyticsPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case _AnalyticsPeriod.week:
        final start = _startOfWeek(DateTime(now.year, now.month, now.day));
        return start.add(const Duration(days: 6));
      case _AnalyticsPeriod.month:
        return DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0);
      case _AnalyticsPeriod.all:
        return now;
    }
  }

  DateTime _startOfWeek(DateTime day) {
    // Monday as the first day of week.
    final delta = day.weekday - DateTime.monday;
    return day.subtract(Duration(days: delta));
  }

  String _monthTitle(DateTime dt) {
    const months = <int, String>{
      1: 'Січень',
      2: 'Лютий',
      3: 'Березень',
      4: 'Квітень',
      5: 'Травень',
      6: 'Червень',
      7: 'Липень',
      8: 'Серпень',
      9: 'Вересень',
      10: 'Жовтень',
      11: 'Листопад',
      12: 'Грудень',
    };
    return '${months[dt.month] ?? dt.month} ${dt.year}';
  }
}
