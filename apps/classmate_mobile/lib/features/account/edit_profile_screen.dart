import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final name = TextEditingController(text: 'Tony Aboud');
  final school = TextEditingController(
    text: 'Technion / ClassMate demo school',
  );
  final grade = TextEditingController(text: 'CS • Physics • Mathematics');
  final bio = TextEditingController(
    text: 'Builder, tennis player, physics/math/AI lover.',
  );
  final status = TextEditingController(text: 'Shipping student app tonight.');

  bool schoolPublic = true;
  bool gradePublic = true;
  bool bioPublic = true;
  bool statusPublic = true;

  @override
  void dispose() {
    name.dispose();
    school.dispose();
    grade.dispose();
    bio.dispose();
    status.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 34,
              child: Text('TA', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Full name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: school,
            decoration: const InputDecoration(labelText: 'School'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: grade,
            decoration: const InputDecoration(labelText: 'Grade / majors'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: bio,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Bio'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: status,
            decoration: const InputDecoration(labelText: 'Status'),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('School public'),
            value: schoolPublic,
            onChanged: (v) => setState(() => schoolPublic = v),
          ),
          SwitchListTile(
            title: const Text('Grade / majors public'),
            value: gradePublic,
            onChanged: (v) => setState(() => gradePublic = v),
          ),
          SwitchListTile(
            title: const Text('Bio public'),
            value: bioPublic,
            onChanged: (v) => setState(() => bioPublic = v),
          ),
          SwitchListTile(
            title: const Text('Status public'),
            value: statusPublic,
            onChanged: (v) => setState(() => statusPublic = v),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
