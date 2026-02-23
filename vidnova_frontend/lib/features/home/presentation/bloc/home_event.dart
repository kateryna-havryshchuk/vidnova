abstract class HomeEvent{}

class LoadHomeData extends HomeEvent {}

class ToggleChartPeriod extends HomeEvent {
  final bool isWeekSelected;
  ToggleChartPeriod(this.isWeekSelected);
}