import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_logo.dart';
import '../../../../core/widgets/error_banner.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();

  bool _obscurePassword = true;
  bool _autoValidate = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Вхід'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listenWhen: (prev, next) => prev.isAuthenticated != next.isAuthenticated,
          listener: (context, state) {
            if (state.isAuthenticated) {
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          },
          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AnimatedLogo(),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          autovalidateMode:
                              _autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (state.error != null) ...[
                                ErrorBanner(message: state.error!),
                                const SizedBox(height: 12),
                              ],
                              TextFormField(
                                controller: _username,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Email або Username',
                                  prefixIcon: Icon(Icons.alternate_email),
                                ),
                                validator: (v) {
                                  final value = (v ?? '').trim();
                                  if (value.isEmpty) return 'Введи email або username';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _password,
                                textInputAction: TextInputAction.done,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Пароль',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() => _obscurePassword = !_obscurePassword);
                                    },
                                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                  ),
                                ),
                                validator: (v) {
                                  final value = v ?? '';
                                  if (value.isEmpty) return 'Введи пароль';
                                  if (value.length < 8) return 'Мінімум 8 символів';
                                  return null;
                                },
                                onFieldSubmitted: (_) => _submit(context, state),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: AppColors.primary.withAlpha(120),
                                    disabledForegroundColor: Colors.white.withAlpha(200),
                                  ),
                                  onPressed: state.isLoading ? null : () => _submit(context, state),
                                  child: state.isLoading
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Увійти'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 48,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(color: AppColors.primary, width: 1.2),
                                  ),
                                  onPressed: state.isLoading ? null : () => context.read<AuthCubit>().loginWithGoogle(),
                                  icon: const Icon(Icons.g_mobiledata, size: 28),
                                  label: const Text('Продовжити з Google'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context, AuthState state) async {
    if (state.isLoading) return;
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      if (!_autoValidate) setState(() => _autoValidate = true);
      return;
    }

    await context.read<AuthCubit>().login(
          username: _username.text.trim(),
          password: _password.text,
        );
  }
}
