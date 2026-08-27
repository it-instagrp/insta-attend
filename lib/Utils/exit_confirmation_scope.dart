import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExitConfirmationScope extends StatefulWidget {
  const ExitConfirmationScope({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ExitConfirmationScope> createState() => _ExitConfirmationScopeState();
}

class _ExitConfirmationScopeState extends State<ExitConfirmationScope> {
  bool _isExitDialogShowing = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        await _showExitConfirmationDialog();
      },
      child: widget.child,
    );
  }

  Future<void> _showExitConfirmationDialog() async {
    if (_isExitDialogShowing) return;

    _isExitDialogShowing = true;

    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text("Exit App"),
            content: const Text("Are you sure you want to exit the app?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text("Exit"),
              ),
            ],
          ),
        );
      },
    );

    _isExitDialogShowing = false;

    if (shouldExit == true) {
      await SystemNavigator.pop();
    }
  }
}
