import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/cm_api_provider.dart';
import '../../core/ui/cm_scaffold.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, required this.role});
  final String role;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? me;
  String? err;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = ref.read(cmApiProvider);
      final j = await api.getJson('/api/auth/me');
      setState(() => me = j);
    } catch (e) {
      setState(() => err = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (err != null) {
      return CMEmpty(title: 'Profile failed to load', subtitle: err);
    }
    if (me == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final u = (me!['user'] as Map?) ?? {};
    final roles = (u['roles'] as List?)?.map((e) => e.toString()).join(', ') ?? '';

    return ListView(
      children: [
        CMSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Role: ${widget.role}'),
              const SizedBox(height: 8),
              Text('User ID: ${u['id'] ?? ''}'),
              const SizedBox(height: 8),
              Text('JWT roles: $roles'),
            ],
          ),
        ),
      ],
    );
  }
}
