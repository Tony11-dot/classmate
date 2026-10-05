import 'package:flutter/material.dart';

/// The app-standard search input: a filled pill with a leading search glyph and
/// a self-managing clear button. This is the single source of truth for how a
/// search bar looks across ClassMate (introduced with the Permissions redesign)
/// — drop it in anywhere a bespoke search `TextField` used to live so every
/// search bar matches.
///
/// The clear (✕) button appears automatically whenever there's text and wipes
/// the field + notifies [onChanged] with an empty string, so callers don't have
/// to wire it up themselves.
class CmSearchField extends StatelessWidget {
  const CmSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Extra callback fired after the field is cleared via the ✕ button (on top
  /// of the automatic `onChanged('')`). Optional.
  final VoidCallback? onClear;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    OutlineInputBorder pill([BorderSide? side]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: side ?? BorderSide.none,
        );

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;
        return TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          enabled: enabled,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: hasText
                ? IconButton(
                    tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      controller.clear();
                      onChanged?.call('');
                      onClear?.call();
                    },
                  )
                : null,
            filled: true,
            fillColor: cs.surfaceContainerHigh,
            border: pill(),
            enabledBorder: pill(),
            focusedBorder: pill(BorderSide(color: cs.primary, width: 1.5)),
            disabledBorder: pill(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
        );
      },
    );
  }
}
