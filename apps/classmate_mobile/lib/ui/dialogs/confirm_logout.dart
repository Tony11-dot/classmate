import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Confirmation dialog shown before signing out. A stray tap on "Log out"
/// used to drop the session instantly — forcing the user to re-enter their
/// credentials. This gates it behind an explicit Yes.
///
/// Returns true only when the user confirms.
Future<bool> confirmLogout(BuildContext context) async {
  final l = AppLocalizations.of(context)!;
  final ok = await showDialog<bool>(
    context: context,
    builder: (dCtx) => AlertDialog(
      title: Text(l.logoutConfirmTitle),
      content: Text(l.logoutConfirmBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dCtx).pop(false),
          child: Text(l.actionCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(dCtx).colorScheme.error,
          ),
          onPressed: () => Navigator.of(dCtx).pop(true),
          child: Text(l.navLogout),
        ),
      ],
    ),
  );
  return ok == true;
}
