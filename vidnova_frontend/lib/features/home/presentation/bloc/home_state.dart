class HomeState{
  final bool isLoading;
  final String userName;
  final bool isWeekSelected;

  HomeState({
    this.isLoading = false,
    this.userName = '',
    this.isWeekSelected = true,
  });

  HomeState copyWith({
    bool? isLoading,
    String? userName,
    bool? isWeekSelected,
  }) {
    return HomeState (
      isLoading: isLoading ?? this.isLoading,
      userName: userName ?? this.userName,
      isWeekSelected: isWeekSelected ?? this.isWeekSelected
    );
  }
}