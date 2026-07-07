import 'package:flutter/material.dart';

/// iOS 26 scroll-edge effect: keeps floating chrome legible where content
/// scrolls beneath it, without giving the bar an opaque background.
///
/// Equivalent of SwiftUI's `.scrollEdgeEffectStyle(.soft/.hard, for: edge)`.
/// Wrap the SCROLLABLE (not the bar): the scrims live on the content layer,
/// under the glass, and fade in only once content actually extends past the
/// edge — a screen scrolled to the very top shows no top scrim at all.
///
///  • [ScrollEdgeStyle.soft] — tall, gentle wash for regular lists.
///  • [ScrollEdgeStyle.hard] — short, dense edge for data-dense grids
///    (spreadsheet-style screens) where a long fade would eat rows.
enum ScrollEdgeStyle { soft, hard }

class ScrollEdgeEffect extends StatefulWidget {
  const ScrollEdgeEffect({
    super.key,
    required this.child,
    this.top = ScrollEdgeStyle.soft,
    this.bottom = ScrollEdgeStyle.soft,
    this.showTop = true,
    this.showBottom = true,
  });

  final Widget child;
  final ScrollEdgeStyle top;
  final ScrollEdgeStyle bottom;
  final bool showTop;
  final bool showBottom;

  @override
  State<ScrollEdgeEffect> createState() => _ScrollEdgeEffectState();
}

class _ScrollEdgeEffectState extends State<ScrollEdgeEffect> {
  double _topAmount = 0; // 0..1 — how much content is hidden past the top
  double _bottomAmount = 1; // assume more content below until told otherwise

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0) return false;
    final m = n.metrics;
    final top = m.hasPixels ? (m.pixels - m.minScrollExtent) : 0.0;
    final bottom =
        m.hasContentDimensions ? (m.maxScrollExtent - m.pixels) : 0.0;
    final newTop = (top / 32).clamp(0.0, 1.0);
    final newBottom = (bottom / 32).clamp(0.0, 1.0);
    if (newTop != _topAmount || newBottom != _bottomAmount) {
      setState(() {
        _topAmount = newTop;
        _bottomAmount = newBottom;
      });
    }
    return false;
  }

  double _height(ScrollEdgeStyle s) => s == ScrollEdgeStyle.soft ? 64 : 28;
  double _peak(ScrollEdgeStyle s) => s == ScrollEdgeStyle.soft ? 0.9 : 1.0;

  Widget _scrim({
    required Alignment begin,
    required ScrollEdgeStyle style,
    required double amount,
  }) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return IgnorePointer(
      child: Opacity(
        opacity: amount,
        child: Container(
          height: _height(style),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin,
              end: begin == Alignment.topCenter
                  ? Alignment.bottomCenter
                  : Alignment.topCenter,
              colors: [
                bg.withValues(alpha: _peak(style)),
                bg.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: Stack(
        children: [
          widget.child,
          if (widget.showTop)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _scrim(
                begin: Alignment.topCenter,
                style: widget.top,
                amount: _topAmount,
              ),
            ),
          if (widget.showBottom)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _scrim(
                begin: Alignment.bottomCenter,
                style: widget.bottom,
                amount: _bottomAmount,
              ),
            ),
        ],
      ),
    );
  }
}
