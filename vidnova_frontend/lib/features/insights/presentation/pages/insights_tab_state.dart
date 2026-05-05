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
    _checkInsApi = getIt<CheckInsApi>();
    _journalApi = getIt<JournalApi>();
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

}
