import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/journal_bloc.dart';
import '../bloc/journal_event.dart';
import '../bloc/journal_state.dart';
import '../widgets/wizard_steps/wizard_step_1_situation.dart';
import '../widgets/wizard_steps/wizard_step_2_thoughts.dart';
import '../widgets/wizard_steps/wizard_step_3_evidence.dart';
import '../widgets/wizard_steps/wizard_step_4_reframing.dart';
import '../widgets/wizard_steps/wizard_step_5_result.dart';
import '../../../../core/theme/app_colors.dart';

class AbcWizardPage extends StatefulWidget {
  const AbcWizardPage({super.key});

  @override
  State<AbcWizardPage> createState() => _AbcWizardPageState();
}

class _AbcWizardPageState extends State<AbcWizardPage> {
  final PageController _pageController = PageController();
  final TextEditingController _situationController = TextEditingController();
  final TextEditingController _thoughtController = TextEditingController();
  final TextEditingController _evidenceController = TextEditingController();
  final TextEditingController _alternativeController = TextEditingController();

  final List<String> _stepTitles = [
    'Ситуація',
    'Думки',
    'Докази',
    'Переосмислення',
    'Результат',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _situationController.dispose();
    _thoughtController.dispose();
    _evidenceController.dispose();
    _alternativeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => JournalBloc(),
      child: BlocConsumer<JournalBloc, JournalState>(
        listenWhen: (previous, current) => previous.currentStep != current.currentStep,
        listener: (context, state) {
          _pageController.animateToPage(
            state.currentStep,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Column(
                children: [
                  Text(
                    _stepTitles[state.currentStep],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Крок ${state.currentStep + 1} з 5',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              leading: state.currentStep > 0 
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      onPressed: () => context.read<JournalBloc>().add(PrevStepEvent()),
                    )
                  : IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(8),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 4,
                  child: LinearProgressIndicator(
                    value: (state.currentStep + 1) / 5,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            ),
            body: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                WizardStep1Situation(situationController: _situationController),
                WizardStep2Thoughts(thoughtController: _thoughtController),
                WizardStep3Evidence(evidenceController: _evidenceController),
                WizardStep4Reframing(alternativeController: _alternativeController),
                WizardStep5Result(
                  situationController: _situationController,
                  thoughtController: _thoughtController,
                  alternativeController: _alternativeController,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}