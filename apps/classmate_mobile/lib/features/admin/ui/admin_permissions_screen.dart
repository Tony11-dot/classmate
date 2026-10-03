// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/cm_refresh_indicator.dart';
import '../data/admin_repository.dart';

/// Admin-managed permissions. A searchable checklist of capabilities, each with
/// a switch per configurable role (Secretaries / Teachers). Admins always have
/// full access, so they are never shown here. Secretary abilities default OFF;
/// teacher abilities default ON — an admin flips either.
///
/// Body-only: the app shell supplies the top bar. Saving happens from a pinned
/// bottom bar that only appears when there are unsaved changes.
class AdminPermissionsScreen extends ConsumerStatefulWidget {
  const AdminPermissionsScreen({super.key});

  @override
  ConsumerState<AdminPermissionsScreen> createState() => _AdminPermissionsScreenState();
}

class _AdminPermissionsScreenState extends ConsumerState<AdminPermissionsScreen> {
  List<PermissionCapability> _caps = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;
  String _query = '';
  final _searchCtrl = TextEditingController();

  /// Current (possibly edited) values: capKey -> role -> enabled.
  final Map<String, Map<String, bool>> _state = {};
  /// The values as last loaded/saved, to detect "dirty".
  final Map<String, Map<String, bool>> _baseline = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final caps = await ref.read(adminRepositoryProvider).fetchPermissions();
      if (!mounted) return;
      setState(() {
        _caps = caps;
        _hydrate(caps);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = '$e'; _loading = false; });
    }
  }

  void _hydrate(List<PermissionCapability> caps) {
    _state.clear();
    _baseline.clear();
    for (final c in caps) {
      final cur = <String, bool>{};
      final base = <String, bool>{};
      for (final role in c.configurableRoles) {
        final v = c.enabledFor(role);
        cur[role] = v;
        base[role] = v;
      }
      _state[c.key] = cur;
      _baseline[c.key] = base;
    }
  }

  bool get _dirty {
    for (final entry in _state.entries) {
      final base = _baseline[entry.key] ?? const {};
      for (final r in entry.value.entries) {
        if (base[r.key] != r.value) return true;
      }
    }
    return false;
  }

  /// Build the overrides payload: ROLE -> { capKey: bool }.
  Map<String, Map<String, bool>> _buildOverrides() {
    final out = <String, Map<String, bool>>{};
    for (final c in _caps) {
      final cur = _state[c.key];
      if (cur == null) continue;
      for (final role in c.configurableRoles) {
        final v = cur[role];
        if (v == null) continue;
        (out[role] ??= <String, bool>{})[c.key] = v;
      }
    }
    return out;
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final caps = await ref.read(adminRepositoryProvider).savePermissions(_buildOverrides());
      if (!mounted) return;
      setState(() {
        _caps = caps;
        _hydrate(caps);
        _saving = false;
      });
      messenger.showSnackBar(SnackBar(content: Text(l.permissionsSaved)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l.permissionsSaveFailed(e.toString()))));
    }
  }

  void _discard() => setState(() => _hydrate(_caps));

  List<PermissionCapability> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _caps;
    return _caps.where((c) {
      return c.label.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q) ||
          c.module.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    if (_loading) return const Center(child: CmLoading());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline_rounded, size: 40, color: cs.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(l.permissionsLoadFailed(_error!), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: _load, child: Text(l.permissionsResetChanges)),
            ],
          ),
        ),
      );
    }

    // Group filtered caps by module, preserving catalog order.
    final filtered = _filtered;
    final modules = <String>[];
    final byModule = <String, List<PermissionCapability>>{};
    for (final c in filtered) {
      byModule.putIfAbsent(c.module, () {
        modules.add(c.module);
        return [];
      }).add(c);
    }

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          _SearchField(
            controller: _searchCtrl,
            hint: l.permissionsSearchHint,
            onChanged: (v) => setState(() => _query = v),
            onClear: () => setState(() { _searchCtrl.clear(); _query = ''; }),
          ),
          Expanded(
            child: CmRefreshIndicator(
              onRefresh: _load,
              child: filtered.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 80),
                        Icon(Icons.search_off_rounded, size: 40, color: cs.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Center(child: Text(l.permissionsNoResults(_query))),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                      children: [
                        if (_query.isEmpty) _HeaderBlurb(text: l.permissionsHeaderBlurb),
                        for (final m in modules) ...[
                          const SizedBox(height: 18),
                          _ModuleHeader(label: m),
                          const SizedBox(height: 8),
                          for (final c in byModule[m]!) _CapabilityCard(
                            cap: c,
                            state: _state[c.key] ?? const {},
                            onToggle: (role, val) => setState(() {
                              (_state[c.key] ??= {})[role] = val;
                            }),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _dirty ? _SaveBar(
        saving: _saving,
        onSave: _save,
        onDiscard: _discard,
      ) : null,
    );
  }
}

class _HeaderBlurb extends StatelessWidget {
  const _HeaderBlurb({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onClear,
  });
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: onClear,
                ),
          filled: true,
          fillColor: cs.surfaceContainerHigh,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
        ),
      ),
    );
  }
}

class _ModuleHeader extends StatelessWidget {
  const _ModuleHeader({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: cs.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _CapabilityCard extends StatelessWidget {
  const _CapabilityCard({
    required this.cap,
    required this.state,
    required this.onToggle,
  });
  final PermissionCapability cap;
  final Map<String, bool> state;
  final void Function(String role, bool value) onToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    String roleLabel(String r) => switch (r) {
      'SECRETARY' => l.permissionsColSecretary,
      'TEACHER' => l.permissionsColTeacher,
      _ => r,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cap.label,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(cap.description,
              style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          for (final role in cap.configurableRoles)
            _RoleToggleRow(
              label: roleLabel(role),
              value: state[role] ?? cap.enabledFor(role),
              isDefault: (state[role] ?? cap.enabledFor(role)) == cap.defaultFor(role),
              changedLabel: l.permissionsChangedBadge,
              onChanged: (v) => onToggle(role, v),
            ),
        ],
      ),
    );
  }
}

class _RoleToggleRow extends StatelessWidget {
  const _RoleToggleRow({
    required this.label,
    required this.value,
    required this.isDefault,
    required this.changedLabel,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final bool isDefault;
  final String changedLabel;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isDefault) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    changedLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.onTertiaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.saving, required this.onSave, required this.onDiscard});
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
        ),
        child: Row(
          children: [
            TextButton(
              onPressed: saving ? null : onDiscard,
              child: Text(l.permissionsResetChanges),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: saving ? null : onSave,
              icon: saving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(l.permissionsSave),
            ),
          ],
        ),
      ),
    );
  }
}
