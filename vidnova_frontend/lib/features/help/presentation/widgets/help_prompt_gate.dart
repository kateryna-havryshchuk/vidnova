import 'package:flutter/material.dart';

import '../../../../core/storage/app_flags_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../pages/help_page.dart';

class HelpPromptGate extends StatefulWidget {
  final Widget child;

  const HelpPromptGate({
    super.key,
    required this.child,
  });

  @override
  State<HelpPromptGate> createState() => _HelpPromptGateState();
}

class _HelpPromptGateState extends State<HelpPromptGate> {
  final AppFlagsStorage _flags = AppFlagsStorage();
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShow();
    });
  }

  Future<void> _maybeShow() async {
    if (_checked) return;
    _checked = true;

    final pending = await _flags.readHelpPromptPending();
    final shown = await _flags.readHelpPromptShown();

    if (!mounted) return;

    if (pending && !shown) {
      // Mark as handled before showing, so it can't appear twice.
      await _flags.writeHelpPromptPending(false);
      await _flags.writeHelpPromptShown(true);

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            title: const Text('Рекомендуємо прочитати довідку'),
            content: const Text(
              'Перед використанням Vidnova радимо коротко ознайомитися з довідкою — так буде простіше і корисніше.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Пізніше'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(this.context).push(
                    MaterialPageRoute(builder: (_) => const HelpPage()),
                  );
                },
                child: const Text('Перейти в довідку'),
              ),
            ],
          );
        },
      );

      return;
    }

    if (pending && shown) {
      await _flags.writeHelpPromptPending(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
