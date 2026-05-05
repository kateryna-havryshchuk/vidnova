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
import '../../../../core/di/service_locator.dart';
import '../../data/journal_api.dart';

class AbcWizardPage extends StatefulWidget {
  final String? entryId;
  const AbcWizardPage({super.key, this.entryId});

  @override
  State<AbcWizardPage> createState() => _AbcWizardPageState();
}

class _AbcWizardPageState extends State<AbcWizardPage> {
  final PageController _pageController = PageController();
  final TextEditingController _situationController = TextEditingController();
  final TextEditingController _thoughtController = TextEditingController();
  final TextEditingController _alternativeController = TextEditingController();

  late final JournalApi _api;
  bool _seededControllers = false;

  final List<String> _stepTitles = [
    'Ситуація',
    'Думки',
    'Докази',
    'Переосмислення',
    'Результат',
  ];

  @override
  void initState() {
    super.initState();
    _api = getIt<JournalApi>();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _situationController.dispose();
    _thoughtController.dispose();
    _alternativeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => JournalBloc(api: _api, entryId: widget.entryId),
      child: BlocConsumer<JournalBloc, JournalState>(
        listenWhen: (previous, current) =>
            previous.currentStep != current.currentStep ||
            previous.saveSucceeded != current.saveSucceeded ||
            previous.errorMessage != current.errorMessage ||
            previous.isLoading != current.isLoading,
        listener: (context, state) {
          if (!_seededControllers && !state.isLoading && state.draftEntry.id != null) {
            _seededControllers = true;
            _situationController.text = state.draftEntry.situation;
            _thoughtController.text = state.draftEntry.automaticThought;
            _alternativeController.text = state.draftEntry.alternativeThought;
          }

          if (_pageController.hasClients) {
            _pageController.animateToPage(
              state.currentStep,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }

          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }

          if (state.saveSucceeded) {
            Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          final isEditing = widget.entryId != null;
          final needsInitialLoad = isEditing && state.draftEntry.id == null;

          final isPositiveFlow = state.draftEntry.emotions.isNotEmpty &&
              state.draftEntry.emotions.every((e) => e == 'Calm' || e == 'Joy');

          final int totalSteps = isPositiveFlow ? 3 : 5;
          final int displayStep = switch (state.currentStep) {
            0 => 1,
            3 when isPositiveFlow => 2,
            4 when isPositiveFlow => 3,
            _ => state.currentStep + 1,
          };

          final String stepTitle = switch (state.currentStep) {
            0 => 'Ситуація',
            3 when isPositiveFlow => 'Позитивний досвід',
            4 when isPositiveFlow => 'Результат',
            _ => _stepTitles[state.currentStep],
          };

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              titleSpacing: 6,
              leadingWidth: 44,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stepTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Крок $displayStep з $totalSteps',
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
                    value: displayStep / totalSteps,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            ),
            body: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    WizardStep1Situation(situationController: _situationController),
                    WizardStep2Thoughts(thoughtController: _thoughtController),
                    const WizardStep3Evidence(),
                    WizardStep4Reframing(alternativeController: _alternativeController),
                    WizardStep5Result(
                      situationController: _situationController,
                      thoughtController: _thoughtController,
                      alternativeController: _alternativeController,
                    ),
                  ],
                ),
                if (needsInitialLoad)
                  Positioned.fill(
                    child: Container(
                      color: AppColors.background,
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: state.errorMessage != null && state.errorMessage!.isNotEmpty
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    state.errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: () => context
                                        .read<JournalBloc>()
                                        .add(LoadAbcEntryEvent(widget.entryId!)),
                                    child: const Text('Спробувати ще раз'),
                                  ),
                                ],
                              )
                            : const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(strokeWidth: 3),
                              ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}