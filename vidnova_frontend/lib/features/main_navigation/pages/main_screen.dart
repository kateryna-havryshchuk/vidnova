import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart'; 
import '../bloc/navigation_cubit.dart';
import '../../home/presentation/pages/home_tab.dart';
import '../../insights/presentation/pages/insights_tab.dart';
import '../../journal/presentation/pages/journal_tab.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../../auth/presentation/pages/profile_tab.dart';
import '../../help/presentation/widgets/help_prompt_gate.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: BlocBuilder<NavigationCubit, int>(
        builder: (context, currentIndex) {
          return HelpPromptGate(
            child: Scaffold(
              backgroundColor: AppColors.background,
              body: IndexedStack(
                index: currentIndex,
                children: const [
                  HomeTab(),
                  JournalTab(),
                  InsightsTab(),
                  ProfileTab(),
                ],
              ),
              bottomNavigationBar: CustomBottomNavBar(currentIndex: currentIndex),
            ),
          );
        },
      ),
    );
  }
}