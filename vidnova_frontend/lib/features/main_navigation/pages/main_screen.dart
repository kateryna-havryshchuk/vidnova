import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart'; 
import '../bloc/navigation_cubit.dart';
import '../../home/presentation/pages/home_tab.dart';
import '../../insights/pages/insights_tab.dart';
import '../../journal/presentation/pages/journal_tab.dart';
import '../../journal/presentation/pages/abc_wizard_page.dart'; 
import '../widgets/custom_bottom_nav_bar.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: BlocBuilder<NavigationCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: IndexedStack(
              index: currentIndex,
              children: const [
                HomeTab(),       
                JournalTab(),    
                InsightsTab(),   
                Center(child: Text('Вкладка Профіль')),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: AppColors.primary,
              shape: const CircleBorder(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AbcWizardPage(),
                  ),
                );
              },
              child: const Icon(Icons.add, size: 30, color: Colors.white),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: CustomBottomNavBar(currentIndex: currentIndex),
          );
        },
      ),
    );
  }
}