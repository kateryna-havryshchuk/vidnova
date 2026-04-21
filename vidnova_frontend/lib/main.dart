import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/api_config.dart';
import 'core/network/dio_factory.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/data/auth_api.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/auth_start_page.dart';
import 'features/main_navigation/pages/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vidnova',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _NoOverscrollBehavior(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const AuthRoot(),
    );
  }
}

class _NoOverscrollBehavior extends MaterialScrollBehavior {
  const _NoOverscrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class AuthRoot extends StatefulWidget {
  const AuthRoot({super.key});

  @override
  State<AuthRoot> createState() => _AuthRootState();
}

class _AuthRootState extends State<AuthRoot> {
  late final AuthCubit _cubit;

  @override
  void initState() {
    super.initState();

    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    final tokenStorage = TokenStorage();
    final dio = DioFactory(
      baseUrl: ApiConfig.baseUrl(isAndroidEmulator: isAndroid),
      tokenStorage: tokenStorage,
    ).create();

    final repo = AuthRepository(
      api: AuthApi(dio),
      tokenStorage: tokenStorage,
    );

    _cubit = AuthCubit(repo)..bootstrap();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return state.isAuthenticated ? const MainScreen() : const AuthStartPage();
        },
      ),
    );
  }
}