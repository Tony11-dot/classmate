import 'package:flutter/material.dart';

/// The app-standard search input: a filled pill with a leading search glyph and
/// a self-managing clear button. This is the single source of truth for how a
/// search bar looks across ClassMate (introduced with the Permissions redesign)
/// — drop it in anywhere a bespoke search `TextField` used to live so every
/// search bar matches.
///
/// [controller] is optional: callers that only listen via [onChanged] can omit
/// it and an internal controller is used. The clear (✕) button appears
/// automatically whenever there's text and wipes the field + notifies
/// [onChanged] with an empty string, so callers don't have to wire it up.
class CmSearchField extends StatefulWidget {
  const CmSearchField({
    super.key,
    this.controller,
    required this.hint,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.onTapOutside,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Extra callback fired after the field is cleared via the ✕ button (on top
  /// of the automatic `onChanged('')`). Optional.
  final VoidCallback? onClear;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final TapRegionCallback? onTapOutside;

  @override
  State<CmSearchField> createState() => _CmSearchFieldState();
}

class _CmSearchFieldState extends State<CmSearchField> {
  TextEditingController? _own;

  TextEditingController get _ctrl =>
      widget.controller ?? (_own ??= TextEditingController());

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    OutlineInputBorder pill([BorderSide? side]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(999),
      borderSide: side ?? BorderSide.none,
    );

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _ctrl,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;
        return TextField(
          controller: _ctrl,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          onTapOutside: widget.onTapOutside,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: hasText
                ? IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).deleteButtonTooltip,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _ctrl.clear();
                      widget.onChanged?.call('');
                      widget.onClear?.call();
                    },
                  )
                : null,
            filled: true,
            fillColor: cs.surfaceContainerHigh,
            border: pill(),
            enabledBorder: pill(),
            focusedBorder: pill(BorderSide(color: cs.primary, width: 1.5)),
            disabledBorder: pill(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
          ),
        );
      },
    );
  }
}
