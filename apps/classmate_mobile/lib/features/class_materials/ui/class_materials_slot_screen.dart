import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'class_materials_section.dart';

/// Full-screen view of one period's shared class materials. Used by teachers
/// (reached from the period action sheet) so they get the same add/see flow
/// students get inline in their period sheet.
class ClassMaterialsSlotScreen extends StatelessWidget {
  const ClassMaterialsSlotScreen({
    super.key,
    required this.slotId,
    this.date = '',
    this.title = '',
  });

  final String slotId;
  final String date;
  final String title;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(title.isNotEmpty ? title : l.classMaterialsTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: ClassMaterialsSection(slotId: slotId, date: date),
      ),
    );
  }
}
