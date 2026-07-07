import 'package:flutter/material.dart';

import '../glass/cm_glass.dart';

/// The app-standard search field: the native iOS 26 glass search capsule.
/// Replaces the 7+ hand-rolled `TextField(filled, prefix search icon,
/// borderless 18-radius)` recipes with one widget.
///
/// A clear button appears automatically while there's text.
class GlassSearchField extends StatefulWidget {
  const GlassSearchField({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.focusNode,
  });

  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  State<GlassSearchField> createState() => _GlassSearchFieldState();
}

class _GlassSearchFieldState extends State<GlassSearchField> {
  TextEditingController? _internal;
  TextEditingController get _ctrl =>
      widget.controller ?? (_internal ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onText);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onText);
    _internal?.dispose();
    super.dispose();
  }

  void _onText() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CMGlass(
      capsule: true,
      child: TextField(
        controller: _ctrl,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: widget.hintText,
          isDense: true,
          // The glass capsule IS the field chrome — no inner borders/fill.
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          prefixIcon:
              Icon(Icons.search_rounded, size: 20, color: cs.onSurfaceVariant),
          suffixIcon: _ctrl.text.isEmpty
              ? null
              : IconButton(
                  tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    _ctrl.clear();
                    widget.onChanged?.call('');
                  },
                ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
