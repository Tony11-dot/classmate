import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../data/class_materials_repository.dart';
import 'class_material_pill.dart';

/// Drawer tab listing every shared material across the periods the current
/// user takes part in. Read-only entry point — there is intentionally NO FAB;
/// materials can only be added from inside a period's detail sheet.
class ClassMaterialsScreen extends ConsumerStatefulWidget {
  const ClassMaterialsScreen({super.key});

  @override
  ConsumerState<ClassMaterialsScreen> createState() => _ClassMaterialsScreenState();
}

class _ClassMaterialsScreenState extends ConsumerState<ClassMaterialsScreen> {
  late Future<List<ClassMaterial>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ClassMaterial>> _load() {
    return ref.read(classMaterialsRepositoryProvider).mine();
  }

  Future<void> _refresh() async {
    final f = _load();
    setState(() => _future = f);
    await f;
  }

  String _periodLine(ClassMaterial m, AppLocalizations l) {
    final parts = <String>[];
    if (m.subject.trim().isNotEmpty) parts.add(m.subject.trim());
    if (m.period != null) parts.add(l.teacherPeriod(m.period!));
    final date = m.date.trim();
    if (date.isNotEmpty) {
      final parsed = DateTime.tryParse(date);
      if (parsed != null) {
        final locale = Localizations.localeOf(context).toString();
        parts.add(DateFormat.MMMd(locale).format(parsed));
      } else {
        parts.add(date);
      }
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.classMaterialsTitle)),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<ClassMaterial>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Text(
                      l.classMaterialsLoadError,
                      style: theme.textTheme.bodyMedium?.copyWith(color: cs.error),
                    ),
                  ),
                ],
              );
            }
            final items = snap.data ?? const <ClassMaterial>[];
            if (items.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 100),
                  Icon(Icons.collections_bookmark_outlined,
                      size: 56, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 14),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        l.classMaterialsTabEmpty,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final m = items[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _periodLine(m, l),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                        ),
                      ),
                      if (m.teacherName.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          m.teacherName,
                          style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                      const SizedBox(height: 10),
                      ClassMaterialPill(material: m),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
