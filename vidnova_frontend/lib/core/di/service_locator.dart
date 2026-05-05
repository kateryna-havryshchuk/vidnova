import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../network/api_config.dart';
import '../network/dio_factory.dart';
import '../storage/token_storage.dart';
import '../../features/auth/data/auth_api.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/checkins/data/checkins_api.dart';
import '../../features/journal/data/journal_api.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator({required bool isAndroidEmulator}) {
  if (getIt.isRegistered<Dio>()) return;

  final tokenStorage = TokenStorage();
  final dio = DioFactory(
    baseUrl: ApiConfig.baseUrl(isAndroidEmulator: isAndroidEmulator),
    tokenStorage: tokenStorage,
  ).create();

  getIt.registerSingleton<TokenStorage>(tokenStorage);
  getIt.registerSingleton<Dio>(dio);

  getIt.registerLazySingleton<AuthApi>(() => AuthApi(getIt<Dio>()));
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      api: getIt<AuthApi>(),
      tokenStorage: getIt<TokenStorage>(),
    ),
  );
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()));

  getIt.registerLazySingleton<CheckInsApi>(() => CheckInsApi(getIt<Dio>()));
  getIt.registerLazySingleton<JournalApi>(() => JournalApi(getIt<Dio>()));
}
