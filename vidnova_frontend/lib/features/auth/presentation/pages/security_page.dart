import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../data/models/me_response.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../widgets/profile_section_card.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _changeEmailKey = GlobalKey<FormState>();
  final _setPasswordKey = GlobalKey<FormState>();
  final _changePasswordKey = GlobalKey<FormState>();

  final _newEmail = TextEditingController();
  final _emailPassword = TextEditingController();

  final _setPasswordNew = TextEditingController();
  final _setPasswordConfirm = TextEditingController();

  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _obscureEmailPassword = true;
  bool _obscureSetPasswordNew = true;
  bool _obscureSetPasswordConfirm = true;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool _autoValidateChangeEmail = false;
  bool _autoValidateSetPassword = false;
  bool _autoValidateChangePassword = false;

  @override
  void initState() {
    super.initState();
    final me = context.read<AuthCubit>().state.me;
    if (me != null) {
      _newEmail.text = me.email;
    }
  }

  @override
  void dispose() {
    _newEmail.dispose();
    _emailPassword.dispose();
    _setPasswordNew.dispose();
    _setPasswordConfirm.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Image.asset('assets/logo/logo.png', height: 24, width: 24),
            const SizedBox(width: 10),
            const Text(
              'Безпека',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final MeResponse? me = state.me;
            if (me == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_newEmail.text.trim().isEmpty) {
              _newEmail.text = me.email;
            }

            return RefreshIndicator(
              onRefresh: () => context.read<AuthCubit>().refreshMe(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  if (state.error != null) ...[
                    ErrorBanner(message: state.error!),
                    const SizedBox(height: 12),
                  ],

                  if (me.hasPassword) ...[
                    if (!me.isGoogleAccount) ...[
                      ProfileSectionCard(
                        title: 'Змінити email',
                        child: Form(
                          key: _changeEmailKey,
                          autovalidateMode: _autoValidateChangeEmail
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _newEmail,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Новий email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: (v) {
                                  final value = (v ?? '').trim();
                                  if (value.isEmpty) return 'Введи email';
                                  if (!_looksLikeEmail(value)) return 'Невірний формат email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _emailPassword,
                                obscureText: _obscureEmailPassword,
                                decoration: InputDecoration(
                                  labelText: 'Поточний пароль',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        setState(() => _obscureEmailPassword = !_obscureEmailPassword),
                                    icon: Icon(_obscureEmailPassword ? Icons.visibility_off : Icons.visibility),
                                  ),
                                ),
                                validator: (v) {
                                  final value = v ?? '';
                                  if (value.isEmpty) return 'Введи пароль';
                                  if (value.length < 8) return 'Мінімум 8 символів';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                height: 44,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: state.isLoading ? null : () => _submitChangeEmail(context),
                                  child: state.isLoading
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Зберегти email'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    ProfileSectionCard(
                      title: 'Змінити пароль',
                      child: Form(
                        key: _changePasswordKey,
                        autovalidateMode: _autoValidateChangePassword
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _currentPassword,
                              obscureText: _obscureCurrentPassword,
                              decoration: InputDecoration(
                                labelText: 'Поточний пароль',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                                  icon: Icon(_obscureCurrentPassword ? Icons.visibility_off : Icons.visibility),
                                ),
                              ),
                              validator: (v) {
                                final value = v ?? '';
                                if (value.isEmpty) return 'Введи поточний пароль';
                                if (value.length < 8) return 'Мінімум 8 символів';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _newPassword,
                              obscureText: _obscureNewPassword,
                              decoration: InputDecoration(
                                labelText: 'Новий пароль',
                                prefixIcon: const Icon(Icons.password_outlined),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                                  icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility),
                                ),
                              ),
                              validator: (v) {
                                final value = v ?? '';
                                if (value.isEmpty) return 'Введи новий пароль';
                                if (value.length < 8) return 'Мінімум 8 символів';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _confirmPassword,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: 'Повтори новий пароль',
                                prefixIcon: const Icon(Icons.password_outlined),
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                                ),
                              ),
                              validator: (v) {
                                final value = v ?? '';
                                if (value.isEmpty) return 'Повтори пароль';
                                if (value != _newPassword.text) return 'Паролі не співпадають';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 44,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: state.isLoading ? null : () => _submitChangePassword(context),
                                child: state.isLoading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Змінити пароль'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    ProfileSectionCard(
                      title: 'Встановити пароль (для Google-акаунта)',
                      child: Form(
                        key: _setPasswordKey,
                        autovalidateMode: _autoValidateSetPassword
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Твій акаунт без пароля (вхід через Google). Тут можна задати пароль для входу через email/username.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _setPasswordNew,
                              obscureText: _obscureSetPasswordNew,
                              decoration: InputDecoration(
                                labelText: 'Новий пароль',
                                prefixIcon: const Icon(Icons.password_outlined),
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscureSetPasswordNew = !_obscureSetPasswordNew),
                                  icon: Icon(_obscureSetPasswordNew ? Icons.visibility_off : Icons.visibility),
                                ),
                              ),
                              validator: (v) {
                                final value = v ?? '';
                                if (value.isEmpty) return 'Введи новий пароль';
                                if (value.length < 8) return 'Мінімум 8 символів';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _setPasswordConfirm,
                              obscureText: _obscureSetPasswordConfirm,
                              decoration: InputDecoration(
                                labelText: 'Повтори новий пароль',
                                prefixIcon: const Icon(Icons.password_outlined),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(
                                      () => _obscureSetPasswordConfirm = !_obscureSetPasswordConfirm),
                                  icon: Icon(
                                      _obscureSetPasswordConfirm ? Icons.visibility_off : Icons.visibility),
                                ),
                              ),
                              validator: (v) {
                                final value = v ?? '';
                                if (value.isEmpty) return 'Повтори пароль';
                                if (value != _setPasswordNew.text) return 'Паролі не співпадають';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 44,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: state.isLoading ? null : () => _submitSetPassword(context),
                                child: state.isLoading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Встановити пароль'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submitChangeEmail(BuildContext context) async {
    final isValid = _changeEmailKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() => _autoValidateChangeEmail = true);
      return;
    }

    final cubit = context.read<AuthCubit>();
    await cubit.changeEmail(
      newEmail: _newEmail.text.trim(),
      currentPassword: _emailPassword.text,
    );

    if (!context.mounted) return;
    final err = cubit.state.error;
    if (err == null) {
      setState(() => _autoValidateChangeEmail = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _emailPassword.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email оновлено.')),
      );
    }
  }

  Future<void> _submitSetPassword(BuildContext context) async {
    final isValid = _setPasswordKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() => _autoValidateSetPassword = true);
      return;
    }

    final cubit = context.read<AuthCubit>();
    await cubit.setPassword(
      newPassword: _setPasswordNew.text,
      confirmPassword: _setPasswordConfirm.text,
    );

    if (!context.mounted) return;
    final err = cubit.state.error;
    if (err == null) {
      setState(() => _autoValidateSetPassword = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _setPasswordNew.clear();
        _setPasswordConfirm.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароль встановлено.')),
      );
    }
  }

  Future<void> _submitChangePassword(BuildContext context) async {
    final isValid = _changePasswordKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() => _autoValidateChangePassword = true);
      return;
    }

    final cubit = context.read<AuthCubit>();
    await cubit.changePassword(
      currentPassword: _currentPassword.text,
      newPassword: _newPassword.text,
    );

    if (!context.mounted) return;
    final err = cubit.state.error;
    if (err == null) {
      setState(() => _autoValidateChangePassword = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _currentPassword.clear();
        _newPassword.clear();
        _confirmPassword.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароль змінено.')),
      );
    }
  }

  bool _looksLikeEmail(String value) {
    // Minimal client-side validation; server must validate too.
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return re.hasMatch(value);
  }
}
