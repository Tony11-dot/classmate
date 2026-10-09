import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/classroom_order_prefs.dart';
import '../providers/classrooms_providers.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/cm_surfaces.dart';

class ClassroomOrderScreen extends ConsumerStatefulWidget {
  const ClassroomOrderScreen({super.key});

  @override
  ConsumerState<ClassroomOrderScreen> createState() => _ClassroomOrderScreenState();
}

class _ClassroomOrderScreenState extends ConsumerState<ClassroomOrderScreen> {
  List<Map<String, dynamic>> _items = const <Map<String, dynamic>>[];
  bool _dirty = false;
  bool _saving = false;

  String _pick(
    Map<String, dynamic> item,
    String key, {
    String fallback = '',
  }) => (item[key] ?? fallback).toString();

  String _idOf(Map<String, dynamic> item) =>
      _pick(item, 'id', fallback: _pick(item, 'courseId')).trim();

  String _titleOf(Map<String, dynamic> item) {
    final title = _pick(
      item,
      'name',
      fallback: _pick(item, 'title', fallback: _pick(item, 'subject')),
    ).trim();
    return title.isEmpty ? 'Classroom' : title;
  }

  String _subtitleOf(Map<String, dynamic> item) =>
      _pick(item, 'subtitle', fallback: _pick(item, 'subject')).trim();

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await saveSavedClassroomOrder(
        _items.map(_idOf).where((id) => id.isNotEmpty).toList(),
      );
      if (!mounted) return;
      ref.invalidate(orderedStudentClassroomsProvider);
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(orderedStudentClassroomsProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: CmBarTitle(AppLocalizations.of(context)!.classroomsReorderTitle),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const CmLoading(size: 16)
                : Text(AppLocalizations.of(context)!.actionSave),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CmLoading()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(AppLocalizations.of(context)!.classroomsCouldNotLoadWithError(e.toString()), textAlign: TextAlign.center),
          ),
        ),
        data: (items) {
          if (_items.isEmpty && items.isNotEmpty && !_dirty) {
            _items = List<Map<String, dynamic>>.from(items);
          }

          if (_items.isEmpty) {
            return Center(
              child: CmEmptyState(
                icon: Icons.class_rounded,
                title: AppLocalizations.of(context)!.classroomsNoClassroomsToReorder,
              ),
            );
          }

          return SafeArea(
            bottom: false,
            child: ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: _items.length,
            proxyDecorator: cmReorderProxy,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final next = List<Map<String, dynamic>>.from(_items);
                final moved = next.removeAt(oldIndex);
                next.insert(newIndex, moved);
                _items = next;
                _dirty = true;
              });
            },
            itemBuilder: (context, index) {
              final item = _items[index];
              final id = _idOf(item).isEmpty ? 'row_$index' : _idOf(item);
              final title = _titleOf(item);
              final subtitle = _subtitleOf(item);

              return CmReorderTile(
                key: ValueKey(id),
                lead: _NumberBadge(number: index + 1),
                title: title,
                subtitle: subtitle,
              );
            },
          ),
          );
        },
      ),
    );
  }
}

/// Position number shown on each classroom while reordering.
class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: cs.brightness == Brightness.dark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$number',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}
