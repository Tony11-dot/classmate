import 'package:flutter/material.dart';
import '../../demo/demo_store.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final name = TextEditingController(text: DemoStore.user.name);
  late final school = TextEditingController(text: DemoStore.user.school);
  late final grade = TextEditingController(text: DemoStore.user.grade);

  @override
  Widget build(BuildContext context) {
    final u = DemoStore.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person_outline_rounded),
              ),
              title: Text(
                u.name,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text('${u.school} • Grade ${u.grade}'),
            ),
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
                  const SizedBox(height: 10),
                  TextField(
                    controller: school,
                    decoration: const InputDecoration(labelText: 'School'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: grade,
                    decoration: const InputDecoration(labelText: 'Grade'),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        setState(() {
                          DemoStore.user.name = name.text.trim();
                          DemoStore.user.school = school.text.trim();
                          DemoStore.user.grade = grade.text.trim();
                        });
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Saved.')));
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
