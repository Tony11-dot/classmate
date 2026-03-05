import 'package:flutter/material.dart';
import '../ui/core/app_drawer.dart';
import '../ui/core/app_top_bar.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String title;

  const AppShell({super.key, required this.child, this.title = "ClassMate"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppTopBar(title: title),
      body: child,
    );
  }
}
