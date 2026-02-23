import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class MoodChartWidget extends StatelessWidget {
  const MoodChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.gridLines,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: _bottomTitleWidgets,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                reservedSize: 32,
                getTitlesWidget: _leftTitleWidgets,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 3,
          minY: 0,
          maxY: 10,
          lineBarsData: [
            // Лінія настрою (суцільна синя)
            LineChartBarData(
              spots: const [
                FlSpot(0, 4),
                FlSpot(1, 5),
                FlSpot(2, 3),
                FlSpot(3, 4.5),
              ],
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primary,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),
            // Лінія активності (пунктирна помаранчева)
            LineChartBarData(
              spots: const [
                FlSpot(0, 2),
                FlSpot(1, 3),
                FlSpot(2, 1),
                FlSpot(3, 2.5),
              ],
              isCurved: true,
              color: AppColors.emotionChart,
              barWidth: 2,
              isStrokeCapRound: true,
              dashArray: [5, 5],
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(color: AppColors.inactive, fontSize: 12);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Text(
        value.toInt().toString(),
        style: style,
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(color: AppColors.inactive, fontSize: 12);
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('Пн', style: style);
        break;
      case 1:
        text = const Text('Вт', style: style);
        break;
      case 2:
        text = const Text('Ср', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }
}