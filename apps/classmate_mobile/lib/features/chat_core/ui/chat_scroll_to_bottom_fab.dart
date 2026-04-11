import 'package:flutter/material.dart';

class ChatScrollToBottomFab extends StatelessWidget {
  const ChatScrollToBottomFab({
    super.key,
    required this.show,
    required this.hasUnreadBelow,
    required this.bottomInset,
    required this.onPressed,
    required this.heroTag,
  });

  final bool show;
  final bool hasUnreadBelow;
  final double bottomInset;
  final VoidCallback onPressed;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset > 0 ? 92 : 74),
      child: FloatingActionButton.small(
        heroTag: heroTag,
        onPressed: onPressed,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.keyboard_arrow_down_rounded),
            if (hasUnreadBelow)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
