import 'package:flutter/material.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppTopBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(44);

  bool get _showSubtitle =>
      title.trim().isNotEmpty && title.trim() != 'ClassMate';

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return AppBar(
      centerTitle: true,
      titleSpacing: 0,
      toolbarHeight: 44,
      scrolledUnderElevation: 0,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ClassMate',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
          if (_showSubtitle)
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.labelMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
        ],
      ),
    );
  }
}
