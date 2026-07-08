import 'package:flutter/material.dart';
import '../../ui/widgets/cm_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/nav/drawer_tools_order.dart';

/// Lets the user drag-reorder the drawer's "School Tools" section.
/// Same flow as the classroom reorder screen: view them ordered, drag to change.
class DrawerToolsOrderScreen extends ConsumerStatefulWidget {
  const DrawerToolsOrderScreen({super.key});

  @override
  ConsumerState<DrawerToolsOrderScreen> createState() => _DrawerToolsOrderScreenState();
}

class _DrawerToolsOrderScreenState extends ConsumerState<DrawerToolsOrderScreen> {
  List<DrawerTool> _items = const <DrawerTool>[];
  bool _seeded = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final session = ref.watch(authSessionProvider);
    final roleKey = drawerToolsRoleKey(
      primaryRole: session.primaryRole,
      isTeacherLike: session.isTeacherLike,
    );
    final order = ref.watch(drawerToolsOrderProvider);

    if (!_seeded) {
      _items = applyDrawerToolsOrder(defaultDrawerTools(roleKey, l), order);
      _seeded = true;
    }

    Future<void> save() async {
      if (_saving) return;
      setState(() => _saving = true);
      await ref.read(drawerToolsOrderProvider.notifier).setOrder(
            _items.map((t) => t.route).toList(),
          );
      if (!mounted) return;
      setState(() => _saving = false);
      context.pop();
    }

    Future<void> reset() async {
      await ref.read(drawerToolsOrderProvider.notifier).reset();
      if (!mounted) return;
      setState(() {
        _items = defaultDrawerTools(roleKey, l);
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l.a11yBack,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(l.reorderToolsTitle),
        actions: [
          TextButton(
            onPressed: reset,
            child: Text(l.reorderToolsReset),
          ),
          TextButton(
            onPressed: _saving ? null : save,
            child: _saving
                ? const CmLoading(size: 16)
                : Text(l.actionSave),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
            child: Text(
              l.reorderToolsSubtitle,
              style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: _items.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final next = List<DrawerTool>.from(_items);
                  final moved = next.removeAt(oldIndex);
                  next.insert(newIndex, moved);
                  _items = next;
                });
              },
              itemBuilder: (context, index) {
                final t = _items[index];
                return Card(
                  key: ValueKey(t.route),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: cs.primaryContainer,
                      child: Icon(t.icon, size: 18, color: cs.onPrimaryContainer),
                    ),
                    title: Text(t.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.drag_handle_rounded),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
