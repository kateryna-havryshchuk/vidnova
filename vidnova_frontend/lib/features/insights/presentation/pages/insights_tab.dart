import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/score_color_scale.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../checkins/data/checkins_api.dart';
import '../../../checkins/data/models/checkin_models.dart';
import '../../../checkins/presentation/widgets/daily_checkin_tile.dart' show EmotionUi;
import '../../../journal/data/journal_api.dart';
import '../../../journal/data/models/journal_models.dart';

part 'insights_tab_state.dart';
part '../widgets/insights_widgets.dart';
part '../charts/insights_charts.dart';
part '../charts/insights_reappraisal_chart.dart';
part 'insights_tab_sections.dart';

enum _AnalyticsPeriod { week, month, all }

class InsightsTab extends StatefulWidget {
  const InsightsTab({super.key});

  @override
  State<InsightsTab> createState() => _InsightsTabState();
}

