import 'package:flutter/material.dart';
import 'glass.dart';
import 'glass.dart';

class CMScaffold extends StatelessWidget {
  const CMScaffold({
    super.key,
    required this.title,
    this.actions,
    required this.body,
    this.fab,
    this.bottom,
    this.padding = const EdgeInsets.all(16),
  });

  final String title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? fab;
  final Widget? bottom;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: GlassBar(
              title: title,
              actions: actions,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: padding,
        child: body,
      ),
      floatingActionButton: fab,
      bottomNavigationBar: bottom,
    );
  }
}

class CMSection extends StatelessWidget {
  const CMSection({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class CMEmpty extends StatelessWidget {
  const CMEmpty({super.key, required this.title, this.subtitle, this.icon});

  final String title;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon ?? Icons.auto_awesome_rounded, size: 40),
                const SizedBox(height: 10),
                Text(title, style: t.titleMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(subtitle!, style: t.bodyMedium, textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
