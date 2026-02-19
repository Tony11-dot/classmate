import 'package:flutter/material.dart';
import '../../core/session.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final grade = TextEditingController(text: '10');
  String? saved;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    name.text = (await Session.getName()) ?? '';
    email.text = (await Session.getEmail()) ?? '';
    setState(() {});
  }

  Future<void> _save() async {
    // Pilot local-save only. Next: PATCH /users/me
    await Session.saveAuth(
      token: (await Session.getToken()) ?? '',
      name: name.text.trim(),
      email: email.text.trim(),
      role: (await Session.getRole()) ?? '',
    );
    setState(() => saved = 'Saved ✅');
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => saved = null);
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    grade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: email,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: grade,
                  decoration: const InputDecoration(labelText: 'Grade'),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _save,
                    child: Text(saved ?? 'Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Card(
          child: ListTile(
            title: Text('Next'),
            subtitle: Text('School selection from DB + student ID + username.'),
          ),
        ),
      ],
    );
  }
}
