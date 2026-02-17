import 'package:flutter/material.dart';
import '../../core/session.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? email;
  String? role;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final e = await Session.email();
    final r = await Session.role();
    if (!mounted) return;
    setState(() {
      email = e;
      role = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Email: ${email ?? '—'}\nRole: ${role ?? '—'}'));
  }
}
