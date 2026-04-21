import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/network/dio_factory.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../checkins/data/checkins_api.dart';
import '../../../checkins/data/models/checkin_models.dart';
import '../../../checkins/presentation/pages/daily_checkin_page.dart';
import '../../../checkins/presentation/widgets/daily_checkin_tile.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../main_navigation/bloc/navigation_cubit.dart';
import '../widgets/home_how_it_works_card.dart';
import '../widgets/home_scroll_behavior.dart';
import '../widgets/home_today_insight_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late final CheckInsApi _checkInsApi;
  Future<DailyCheckInResponseDto?>? _todayFuture;
  Future<DailyCheckInAiInsightResponseDto?>? _todayInsightFuture;
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
    _reloadToday();
  }

  void _reloadToday() {
    final today = DateTime.now();
    final date = _formatDate(today);

    setState(() {
      _todayFuture = _checkInsApi.getByDate(date);
      _todayInsightFuture = _todayFuture!.then((dto) async {
        if (dto == null) return null;
        return _checkInsApi.getInsightByDate(date);
      });
    });
  }

  Future<void> _refresh() async {
    final today = DateTime.now();
    final date = _formatDate(today);
    final future = _checkInsApi.getByDate(date);
    final insightFuture = future.then((dto) async {
      if (dto == null) return null;
      return _checkInsApi.getInsightByDate(date);
    });

    setState(() {
      _todayFuture = future;
      _todayInsightFuture = insightFuture;
    });

    try {
      await Future.wait([future, insightFuture]);
    } catch (_) {
      // RefreshIndicator only needs the Future to complete.
    }
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    // Reload when user changes (login/logout) so data doesn't get stuck.
    final me = context.select((AuthCubit c) => c.state.me);
    final currentUserKey = me == null ? null : '${me.userId}:${me.email}';
    if (_lastUserKey != currentUserKey) {
      _lastUserKey = currentUserKey;
      // Schedule to avoid setState during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _reloadToday();
      });
    }

    final firstName = (me?.firstName ?? '').trim();

    return SafeArea(
      child: ScrollConfiguration(
        behavior: const HomeScrollBehavior(),
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            children: [
              const SizedBox(height: 14),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 40,
                    child: Image.asset(
                      'assets/logo/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Vidnova',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(height: 1, color: AppColors.border),
              const SizedBox(height: 14),
              Text(
                firstName.isEmpty ? 'Привіт!' : 'Привіт, $firstName',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Як ви почуваєтесь сьогодні?',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 18),
              FutureBuilder<DailyCheckInResponseDto?>(
                future: _todayFuture,
                builder: (context, snapshot) {
                  final isLoading = snapshot.connectionState == ConnectionState.waiting;
                  final error = snapshot.hasError
                      ? 'Не вдалося завантажити стан. Натисніть, щоб повторити.'
                      : null;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DailyCheckInTile(
                        checkIn: snapshot.data,
                        isLoading: isLoading,
                        error: error,
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DailyCheckInPage(
                                api: _checkInsApi,
                                date: DateTime.now(),
                              ),
                            ),
                          );

                          if (result == true || error != null) {
                            _reloadToday();
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      FutureBuilder<DailyCheckInAiInsightResponseDto?>(
                        future: _todayInsightFuture,
                        builder: (context, insightSnap) {
                          final isAiLoading = insightSnap.connectionState == ConnectionState.waiting;
                          final aiText = insightSnap.data?.responseText;

                          return HomeTodayInsightCard(
                            dto: snapshot.data,
                            hasError: snapshot.hasError,
                            aiText: aiText,
                            isAiLoading: isAiLoading,
                            aiHasError: insightSnap.hasError,
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      HomeHowItWorksCard(
                        onTryNow: () => context.read<NavigationCubit>().changeTab(1),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

