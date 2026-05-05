part of '../pages/insights_tab.dart';

class _ReappraisalTrendChart extends StatelessWidget {
  final List<AbcEntryListItemDto> items;
  final _AnalyticsPeriod period;
  final DateTime rangeFrom;
  final DateTime rangeTo;
  final Color initialColor;
  final Color afterColor;

  const _ReappraisalTrendChart({
    required this.items,
    required this.period,
    required this.rangeFrom,
    required this.rangeTo,
    required this.initialColor,
    required this.afterColor,
  });

  @override
  Widget build(BuildContext context) {
    // Group by local day.
    final byDay = <DateTime, List<AbcEntryListItemDto>>{};
    for (final e in items) {
      final d = DateTime(e.createdDate.year, e.createdDate.month, e.createdDate.day);
      (byDay[d] ??= <AbcEntryListItemDto>[]).add(e);
    }

    double avgInitial(AbcEntryListItemDto e) {
      if (e.emotions.isEmpty) return 0;
      final sum = e.emotions.fold<int>(0, (a, b) => a + b.initialIntensity);
      final avgIntensity = sum / e.emotions.length;

      final isPositiveFlow = e.emotions.every((x) => x.emotion == 'Calm' || x.emotion == 'Joy');
      if (isPositiveFlow) {
        // Для позитивних (Calm/Joy) інтенсивність = "стан" (не інвертуємо).
        return avgIntensity;
      }

      // Для негативних інтенсивність = "негативність", тому інвертуємо у "стан/спокій".
      return 100 - avgIntensity;
    }

    ({double initial, double after}) avgForDay(DateTime d) {
      final list = byDay[d];
      if (list == null || list.isEmpty) return (initial: 0, after: 0);

      var sumInitial = 0.0;
      var sumAfter = 0.0;
      for (final e in list) {
        sumInitial += avgInitial(e);
        sumAfter += e.finalEmotionIntensity.toDouble();
      }
      return (
        initial: sumInitial / list.length,
        after: sumAfter / list.length,
      );
    }

    late final List<_TrendValue> initialValues;
    late final List<_TrendValue> afterValues;
    late final List<int> counts;
    late final List<int> xLabelIndices;
    late final List<String> xLabels;

    if (period == _AnalyticsPeriod.week) {
      final days = List<DateTime>.generate(7, (i) {
        final d = rangeFrom.add(Duration(days: i));
        return DateTime(d.year, d.month, d.day);
      });

      initialValues = [
        for (final d in days)
          _TrendValue(
            value: avgForDay(d).initial,
            hasData: byDay.containsKey(d),
          )
      ];
      afterValues = [
        for (final d in days)
          _TrendValue(
            value: avgForDay(d).after,
            hasData: byDay.containsKey(d),
          )
      ];
      counts = [for (final d in days) (byDay[d]?.length ?? 0)];
      xLabelIndices = List<int>.generate(7, (i) => i);
      xLabels = [for (final d in days) _weekdayShort(d)];
    } else if (period == _AnalyticsPeriod.month) {
      final first = DateTime(rangeFrom.year, rangeFrom.month, 1);
      final daysInMonth = DateTime(first.year, first.month + 1, 0).day;

      initialValues = List<_TrendValue>.generate(daysInMonth, (i) {
        final d = DateTime(first.year, first.month, i + 1);
        final has = byDay.containsKey(d);
        return _TrendValue(value: avgForDay(d).initial, hasData: has);
      });
      afterValues = List<_TrendValue>.generate(daysInMonth, (i) {
        final d = DateTime(first.year, first.month, i + 1);
        final has = byDay.containsKey(d);
        return _TrendValue(value: avgForDay(d).after, hasData: has);
      });
      counts = List<int>.generate(daysInMonth, (i) {
        final d = DateTime(first.year, first.month, i + 1);
        return byDay[d]?.length ?? 0;
      });

      final ticks = <int>[1, 6, 11, 16, 21, 26];
      xLabelIndices = [
        for (final day in ticks)
          if (day >= 1 && day <= daysInMonth) day - 1,
      ];
      xLabels = [for (final i in xLabelIndices) '${i + 1}'];
    } else {
      // All time auto-scale (same behavior as the main trend chart).
      final parsed = <DateTime>[
        for (final e in items) DateTime(e.createdDate.year, e.createdDate.month, e.createdDate.day)
      ];

      if (parsed.isEmpty) {
        initialValues = const <_TrendValue>[];
        afterValues = const <_TrendValue>[];
        counts = const <int>[];
        xLabelIndices = const <int>[];
        xLabels = const <String>[];
      } else {
        parsed.sort();
        final firstDt = parsed.first;
        final lastDt = parsed.last;

        final monthsCount = _monthsBetweenInclusive(firstDt, lastDt);

        if (monthsCount <= 1) {
          final first = DateTime(lastDt.year, lastDt.month, 1);
          final daysInMonth = DateTime(first.year, first.month + 1, 0).day;

          initialValues = List<_TrendValue>.generate(daysInMonth, (i) {
            final d = DateTime(first.year, first.month, i + 1);
            final has = byDay.containsKey(d);
            return _TrendValue(value: avgForDay(d).initial, hasData: has);
          });
          afterValues = List<_TrendValue>.generate(daysInMonth, (i) {
            final d = DateTime(first.year, first.month, i + 1);
            final has = byDay.containsKey(d);
            return _TrendValue(value: avgForDay(d).after, hasData: has);
          });
          counts = List<int>.generate(daysInMonth, (i) {
            final d = DateTime(first.year, first.month, i + 1);
            return byDay[d]?.length ?? 0;
          });

          final ticks = <int>[1, 6, 11, 16, 21, 26];
          xLabelIndices = [
            for (final day in ticks)
              if (day >= 1 && day <= daysInMonth) day - 1,
          ];
          xLabels = [for (final i in xLabelIndices) '${i + 1}'];
        } else if (monthsCount <= 60) {
          // Monthly aggregation over the full range.
          final startMonth = DateTime(firstDt.year, firstDt.month, 1);
          final endMonth = DateTime(lastDt.year, lastDt.month, 1);

          final monthAgg = <(int, int), List<({double initial, double after})>>{};
          for (final e in items) {
            final dt = e.createdDate;
            final key = (dt.year, dt.month);
            final pair = (initial: avgInitial(e), after: e.finalEmotionIntensity.toDouble());
            (monthAgg[key] ??= <({double initial, double after})>[]).add(pair);
          }

          final monthKeys = <(int, int)>[];
          var cursor = startMonth;
          while (!cursor.isAfter(endMonth)) {
            monthKeys.add((cursor.year, cursor.month));
            cursor = DateTime(cursor.year, cursor.month + 1, 1);
          }

          initialValues = [
            for (final k in monthKeys)
              if (monthAgg[k] == null)
                const _TrendValue(value: 0, hasData: false)
              else
                _TrendValue(
                  value: monthAgg[k]!.fold<double>(0, (a, b) => a + b.initial) / monthAgg[k]!.length,
                  hasData: true,
                )
          ];
          afterValues = [
            for (final k in monthKeys)
              if (monthAgg[k] == null)
                const _TrendValue(value: 0, hasData: false)
              else
                _TrendValue(
                  value: monthAgg[k]!.fold<double>(0, (a, b) => a + b.after) / monthAgg[k]!.length,
                  hasData: true,
                )
          ];
          counts = [for (final k in monthKeys) (monthAgg[k]?.length ?? 0)];

          final step = monthKeys.length <= 6
              ? 1
              : (monthKeys.length <= 12
                  ? 2
                  : (monthKeys.length <= 24
                      ? 3
                      : (monthKeys.length <= 48 ? 6 : 12)));
          final idx = <int>[];
          for (var i = 0; i < monthKeys.length; i += step) {
            idx.add(i);
          }
          if (idx.isEmpty || idx.first != 0) idx.insert(0, 0);
          if (idx.last != monthKeys.length - 1) idx.add(monthKeys.length - 1);
          xLabelIndices = idx.toSet().toList()..sort();

          final singleYear = monthKeys.first.$1 == monthKeys.last.$1;
          xLabels = [
            for (final i in xLabelIndices)
              _monthShortWithYear(DateTime(monthKeys[i].$1, monthKeys[i].$2, 1), includeYear: !singleYear),
          ];
        } else {
          // Yearly aggregation.
          final years = <int, List<({double initial, double after})>>{};
          for (final e in items) {
            (years[e.createdDate.year] ??= <({double initial, double after})>[]).add(
              (initial: avgInitial(e), after: e.finalEmotionIntensity.toDouble()),
            );
          }
          final yearKeys = years.keys.toList()..sort();
          initialValues = [
            for (final y in yearKeys)
              _TrendValue(
                value: years[y]!.fold<double>(0, (a, b) => a + b.initial) / years[y]!.length,
                hasData: true,
              )
          ];
          afterValues = [
            for (final y in yearKeys)
              _TrendValue(
                value: years[y]!.fold<double>(0, (a, b) => a + b.after) / years[y]!.length,
                hasData: true,
              )
          ];
          counts = [for (final y in yearKeys) years[y]!.length];

          final rawIdx = initialValues.isEmpty
              ? const <int>[]
              : <int>[0, if (initialValues.length > 2) initialValues.length ~/ 2, initialValues.length - 1];
          final unique = <int>{};
          for (final i in rawIdx) {
            unique.add(i);
          }
          xLabelIndices = unique.toList()..sort();
          xLabels = [for (final i in xLabelIndices) yearKeys[i].toString()];
        }
      }
    }

    return CustomPaint(
      painter: _DualTrendChartPainter(
        initialValues: initialValues,
        afterValues: afterValues,
        initialColor: initialColor,
        afterColor: afterColor,
        xLabels: xLabels,
        xLabelIndices: xLabelIndices,
        counts: counts,
      ),
      child: const SizedBox.expand(),
    );
  }

  String _weekdayShort(DateTime d) {
    switch (d.weekday) {
      case DateTime.monday:
        return 'Пн';
      case DateTime.tuesday:
        return 'Вт';
      case DateTime.wednesday:
        return 'Ср';
      case DateTime.thursday:
        return 'Чт';
      case DateTime.friday:
        return 'Пт';
      case DateTime.saturday:
        return 'Сб';
      case DateTime.sunday:
        return 'Нд';
      default:
        return '';
    }
  }

  String _monthShort(DateTime dt) {
    const months = <int, String>{
      1: 'Січ',
      2: 'Лют',
      3: 'Бер',
      4: 'Кв',
      5: 'Тр',
      6: 'Чр',
      7: 'Лип',
      8: 'Серп',
      9: 'Вер',
      10: 'Жов',
      11: 'Лис',
      12: 'Гр',
    };
    return months[dt.month] ?? dt.month.toString();
  }

  String _monthShortWithYear(DateTime dt, {required bool includeYear}) {
    final m = _monthShort(dt);
    if (!includeYear) return m;
    final yy = (dt.year % 100).toString().padLeft(2, '0');
    return "$m’$yy";
  }

  int _monthsBetweenInclusive(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + (to.month - from.month) + 1;
  }
}

class _DualTrendChartPainter extends CustomPainter {
  final List<_TrendValue> initialValues;
  final List<_TrendValue> afterValues;
  final List<int> counts;
  final Color initialColor;
  final Color afterColor;
  final List<String> xLabels;
  final List<int> xLabelIndices;

  _DualTrendChartPainter({
    required this.initialValues,
    required this.afterValues,
    required this.counts,
    required this.initialColor,
    required this.afterColor,
    required this.xLabels,
    required this.xLabelIndices,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final leftPad = 26.0;
    final topPad = 10.0;
    final bottomPad = 28.0;
    final chartW = size.width - leftPad;
    final chartH = size.height - topPad - bottomPad;

    final gridPaint = Paint()
      ..color = AppColors.gridLines
      ..strokeWidth = 1;

    const yTicks = [0, 25, 50, 75, 100];
    for (final y in yTicks) {
      final dy = topPad + chartH * (1 - (y / 100));
      canvas.drawLine(Offset(leftPad, dy), Offset(leftPad + chartW, dy), gridPaint);
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (final y in yTicks) {
      final dy = topPad + chartH * (1 - (y / 100));
      textPainter.text = TextSpan(
        text: '$y',
        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, dy - textPainter.height / 2));
    }

    // X-axis labels
    final len = math.min(initialValues.length, afterValues.length);
    if (len >= 2 && xLabelIndices.isNotEmpty && xLabels.isNotEmpty) {
      for (var i = 0; i < xLabelIndices.length && i < xLabels.length; i++) {
        final idx = xLabelIndices[i].clamp(0, len - 1);
        final x = leftPad + chartW * (idx / (len - 1));
        textPainter.text = TextSpan(
          text: xLabels[i],
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        );
        textPainter.layout();
        final dx = (x - textPainter.width / 2).clamp(leftPad, leftPad + chartW - textPainter.width);
        final dy = topPad + chartH + 6;
        textPainter.paint(canvas, Offset(dx, dy));
      }
    }

    void drawSeries(List<_TrendValue> values, Color color, {required bool fill}) {
      _drawSeriesWithGaps(
        canvas: canvas,
        leftPad: leftPad,
        topPad: topPad,
        chartW: chartW,
        chartH: chartH,
        values: values.take(len).toList(growable: false),
        color: color,
        fill: fill,
      );
    }

    // Draw initial first, then after on top.
    drawSeries(initialValues, initialColor, fill: false);
    drawSeries(afterValues, afterColor, fill: true);

    // Mark buckets with multiple situations.
    if (counts.isNotEmpty) {
      Offset pointAt(List<_TrendValue> values, int i) {
        final x = leftPad + chartW * (i / (len - 1));
        final v = values[i].value.clamp(0, 100);
        final y = topPad + chartH * (1 - (v / 100));
        return Offset(x, y);
      }

      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = AppColors.textSecondary;

      for (var i = 0; i < math.min(counts.length, len); i++) {
        if (counts[i] <= 1) continue;
        if (!initialValues[i].hasData && !afterValues[i].hasData) continue;

        final p = afterValues[i].hasData ? pointAt(afterValues, i) : pointAt(initialValues, i);
        canvas.drawCircle(p, 6, ringPaint);
      }
    }
  }

  void _drawSeriesWithGaps({
    required Canvas canvas,
    required double leftPad,
    required double topPad,
    required double chartW,
    required double chartH,
    required List<_TrendValue> values,
    required Color color,
    required bool fill,
  }) {
    if (values.length < 2) return;

    Offset pointAt(int i) {
      final x = leftPad + chartW * (i / (values.length - 1));
      final sv = values[i].value.clamp(0, 100);
      final y = topPad + chartH * (1 - (sv / 100));
      return Offset(x, y);
    }

    final solidRuns = <List<Offset>>[];
    var run = <Offset>[];
    final isolatedPoints = <Offset>[];

    bool hasNeighborData(int i) {
      final left = i > 0 && values[i - 1].hasData;
      final right = i < values.length - 1 && values[i + 1].hasData;
      return left || right;
    }

    for (var i = 0; i < values.length; i++) {
      if (!values[i].hasData) {
        if (run.length >= 2) solidRuns.add(run);
        run = <Offset>[];
        continue;
      }

      final p = pointAt(i);
      if (!hasNeighborData(i)) {
        isolatedPoints.add(p);
      }
      run.add(p);
    }
    if (run.length >= 2) solidRuns.add(run);

    final baseY = topPad + chartH;

    for (final points in solidRuns) {
      final smooth = _smoothPath(points);

      if (fill) {
        final fillPath = Path.from(smooth)
          ..lineTo(points.last.dx, baseY)
          ..lineTo(points.first.dx, baseY)
          ..close();

        final fillPaint = Paint()
          ..style = PaintingStyle.fill
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withAlpha(44), Colors.transparent],
          ).createShader(Rect.fromLTRB(leftPad, topPad, leftPad + chartW, baseY));

        canvas.drawPath(fillPath, fillPaint);
      }

      final linePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(smooth, linePaint);
    }

    if (isolatedPoints.isNotEmpty) {
      final dotPaint = Paint()..color = color;
      for (final p in isolatedPoints) {
        canvas.drawCircle(p, 3.5, dotPaint);
      }
    }

    final dashPaint = Paint()
      ..color = color.withAlpha(140)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < values.length - 1; i++) {
      final aHas = values[i].hasData;
      final bHas = values[i + 1].hasData;
      if (aHas && bHas) continue;
      _drawDashedLine(canvas, pointAt(i), pointAt(i + 1), dashPaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 6.0;
    const gap = 4.0;

    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist <= 0.001) return;

    final dirX = dx / dist;
    final dirY = dy / dist;

    var t = 0.0;
    while (t < dist) {
      final start = t;
      final end = (t + dash).clamp(0.0, dist);
      final p1 = Offset(a.dx + dirX * start, a.dy + dirY * start);
      final p2 = Offset(a.dx + dirX * end, a.dy + dirY * end);
      canvas.drawLine(p1, p2, paint);
      t += dash + gap;
    }
  }

  Path _smoothPath(List<Offset> points) {
    if (points.length < 2) return Path();
    if (points.length == 2) {
      return Path()
        ..moveTo(points[0].dx, points[0].dy)
        ..lineTo(points[1].dx, points[1].dy);
    }

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = i == 0 ? points[i] : points[i - 1];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = (i + 2 < points.length) ? points[i + 2] : p2;

      final c1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final c2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );

      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _DualTrendChartPainter oldDelegate) {
    return oldDelegate.initialValues != initialValues ||
        oldDelegate.afterValues != afterValues ||
        oldDelegate.counts != counts ||
        oldDelegate.initialColor != initialColor ||
        oldDelegate.afterColor != afterColor ||
        oldDelegate.xLabels != xLabels ||
        oldDelegate.xLabelIndices != xLabelIndices;
  }
}
