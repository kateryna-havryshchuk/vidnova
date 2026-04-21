import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/app_flags_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_logo.dart';
import '../../../../core/widgets/error_banner.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();

  bool _obscurePassword = true;
  bool _autoValidate = false;

  @override
  void dispose() {
    _email.dispose();
    _username.dispose();
    _password.dispose();
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Реєстрація'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listenWhen: (prev, next) => prev.isAuthenticated != next.isAuthenticated,
          listener: (context, state) async {
            if (state.isAuthenticated) {
              // Show the help prompt once after registration (persisted locally).
              final flags = AppFlagsStorage();
              final alreadyShown = await flags.readHelpPromptShown();
              if (!alreadyShown) {
                await flags.writeHelpPromptPending(true);
              }

              if (!context.mounted) return;
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
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: (v) {
                                  final value = (v ?? '').trim();
                                  if (value.isEmpty) return 'Введи email';
                                  final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
                                  if (!emailOk) return 'Невірний формат email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _username,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (v) {
                                  final value = (v ?? '').trim();
                                  if (value.isEmpty) return 'Введи username';
                                  if (value.length < 3) return 'Мінімум 3 символи';
                                  final ok = RegExp(r'^[a-zA-Z0-9_\.\-]+$').hasMatch(value);
                                  if (!ok) return 'Тільки латиниця/цифри/_ . -';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _password,
                                textInputAction: TextInputAction.next,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Пароль (мін 8 символів)',
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
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _firstName,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: "Ім'я",
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                                validator: (v) {
                                  final value = (v ?? '').trim();
                                  if (value.isEmpty) return "Введи ім'я";
                                  if (value.length < 2) return 'Мінімум 2 символи';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _lastName,
                                textInputAction: TextInputAction.done,
                                decoration: const InputDecoration(
                                  labelText: 'Прізвище',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                                validator: (v) {
                                  final value = (v ?? '').trim();
                                  if (value.isEmpty) return 'Введи прізвище';
                                  if (value.length < 2) return 'Мінімум 2 символи';
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
                                      : const Text('Зареєструватися'),
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

    await context.read<AuthCubit>().register(
          email: _email.text.trim(),
          username: _username.text.trim(),
          password: _password.text,
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
        );
  }
}
