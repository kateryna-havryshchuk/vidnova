import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState(isLoading: true)) {
    on<LoadHomeData>(_onLoadData);
    on<ToggleChartPeriod>(_onTogglePeriod);
  }

  void _onLoadData(LoadHomeData event, Emitter<HomeState> emit) async {
    await Future.delayed(const Duration(seconds: 1));
    emit(state.copyWith(isLoading: false, userName: 'Sarah'));
  }

  void _onTogglePeriod(ToggleChartPeriod event, Emitter<HomeState> emit) {
    emit(state.copyWith(isWeekSelected: event.isWeekSelected));
  }
}