import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final name = TextEditingController(text: 'Tony Aboud');
  final school = TextEditingController();
  final grade = TextEditingController();
  final majors = TextEditingController();
  final bio = TextEditingController();
  final status = TextEditingController();

  bool schoolPublic = false;
  bool gradePublic = true;
  bool majorsPublic = true;
  bool bioPublic = true;
  bool statusPublic = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(child: CircleAvatar(radius: 38, child: Text('TA'))),
          const SizedBox(height: 16),
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Full name'),
          ),
          TextField(
            controller: school,
            decoration: const InputDecoration(labelText: 'School'),
          ),
          SwitchListTile(
            title: const Text('School public'),
            value: schoolPublic,
            onChanged: (v) => setState(() => schoolPublic = v),
          ),
          TextField(
            controller: grade,
            decoration: const InputDecoration(labelText: 'Grade'),
          ),
          SwitchListTile(
            title: const Text('Grade public'),
            value: gradePublic,
            onChanged: (v) => setState(() => gradePublic = v),
          ),
          TextField(
            controller: majors,
            decoration: const InputDecoration(labelText: 'Majors'),
          ),
          SwitchListTile(
            title: const Text('Majors public'),
            value: majorsPublic,
            onChanged: (v) => setState(() => majorsPublic = v),
          ),
          TextField(
            controller: bio,
            decoration: const InputDecoration(labelText: 'Bio'),
          ),
          SwitchListTile(
            title: const Text('Bio public'),
            value: bioPublic,
            onChanged: (v) => setState(() => bioPublic = v),
          ),
          TextField(
            controller: status,
            decoration: const InputDecoration(labelText: 'Status'),
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
