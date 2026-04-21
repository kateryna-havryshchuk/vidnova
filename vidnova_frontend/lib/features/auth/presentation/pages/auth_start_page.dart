import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_logo.dart';
import '../../../../core/widgets/error_banner.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import 'login_page.dart';
import 'register_page.dart';

class AuthStartPage extends StatelessWidget {
  const AuthStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AnimatedLogo(),
                      const SizedBox(height: 20),
                      if (state.error != null) ...[
                        ErrorBanner(message: state.error!),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.primary.withAlpha(120),
                            disabledForegroundColor: Colors.white.withAlpha(200),
                          ),
                          onPressed: state.isLoading
                              ? null
                              : () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: context.read<AuthCubit>(),
                                        child: const LoginPage(),
                                      ),
                                    ),
                                  );
                                  if (!context.mounted) return;
                                  context.read<AuthCubit>().clearError();
                                },
                          child: const Text('Увійти'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary, width: 1.2),
                          ),
                          onPressed: state.isLoading
                              ? null
                              : () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: context.read<AuthCubit>(),
                                        child: const RegisterPage(),
                                      ),
                                    ),
                                  );
                                  if (!context.mounted) return;
                                  context.read<AuthCubit>().clearError();
                                },
                          child: const Text('Зареєструватися'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
