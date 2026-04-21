import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_logo.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../data/models/me_response.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../widgets/profile_section_card.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'security_page.dart';
import '../../../help/presentation/pages/help_page.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state.isLoading && !state.isAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!state.isAuthenticated) {
            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
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
                            ),
                            onPressed: () async {
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
                            onPressed: () async {
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
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 48,
                          width: double.infinity,
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
              ),
            );
          }

          final me = state.me!;
          return _ProfileAuthenticatedView(me: me);
        },
      ),
    );
  }
}

class _ProfileAuthenticatedView extends StatefulWidget {
  final MeResponse me;

  const _ProfileAuthenticatedView({
    required this.me,
  });

  @override
  State<_ProfileAuthenticatedView> createState() => _ProfileAuthenticatedViewState();
}

class _ProfileAuthenticatedViewState extends State<_ProfileAuthenticatedView> {
  @override
  Widget build(BuildContext context) {
    final me = widget.me;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final displayName = ('${me.firstName} ${me.lastName}').trim();
        final name = displayName.isEmpty ? me.userName : displayName;

        return Column(
          children: [
            _ProfileHeader(name: name),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<AuthCubit>().refreshMe(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  children: [
                    if (state.error != null) ...[
                      ErrorBanner(message: state.error!),
                      const SizedBox(height: 12),
                    ],

                    ProfileSectionCard(
                      title: 'Дані профілю',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            me.email,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Username',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            me.userName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

              _MenuCard(
                children: [
                  _MenuTile(
                    icon: Icons.security_outlined,
                    title: 'Безпека',
                    subtitle: me.isGoogleAccount ? 'Google-акаунт • пароль' : 'Email • пароль',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<AuthCubit>(),
                            child: const SecurityPage(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _MenuCard(
                children: [
                  _MenuTile(
                    icon: Icons.help_outline,
                    title: 'Довідка',
                    subtitle: 'Як користуватися Vidnova',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpPage(),
                        ),
                      );
                    },
                  ),
                  _MenuTile(
                    icon: Icons.info_outline,
                    title: 'Про додаток',
                    subtitle: 'Vidnova v1.0.0',
                    showDivider: false,
                    showChevron: false,
                    onTap: null,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: state.isLoading ? null : () => context.read<AuthCubit>().logout(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Вийти з аккаунту'),
                ),
              ),
              const SizedBox(height: 14),
                    Center(
                      child: Text(
                        'Vidnova — ваш щоденний помічник\nНе замінює професійну психотерапію',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                              height: 1.3,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;

  const _ProfileHeader({
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    const bottomCutoutHeight = 26.0;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16, top + 14, 16, 20 + bottomCutoutHeight),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 40,
                    child: Image.asset(
                      'assets/logo/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Vidnova',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SizedBox(
            height: bottomCutoutHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;

  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(children: children),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool showChevron;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.showDivider = true,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final tile = ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
      trailing: showChevron ? const Icon(Icons.chevron_right, color: AppColors.textTertiary) : null,
      onTap: onTap,
      enabled: onTap != null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    );

    if (!showDivider) return tile;

    return Column(
      children: [
        tile,
        Padding(
          padding: const EdgeInsets.only(left: 56),
          child: Container(height: 1, color: AppColors.border),
        ),
      ],
    );
  }
}
