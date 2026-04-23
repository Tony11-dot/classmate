import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/glass/liquid_glass_card.dart';

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
  void dispose() {
    name.dispose();
    school.dispose();
    grade.dispose();
    majors.dispose();
    bio.dispose();
    status.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.editProfileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LiquidGlassCard(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(24),
            blurSigma: 18,
            gradient: LinearGradient(
              colors: [
                cs.primaryContainer,
                cs.surfaceContainerHigh,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: cs.primary.withValues(alpha: 0.16),
                  child: Text(
                    'TA',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.editProfileTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.profileSave,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _FormSection(
            title: l.profileFullName,
            child: Column(
              children: [
                TextField(
                  controller: name,
                  decoration: InputDecoration(labelText: l.profileFullName),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: school,
                  decoration: InputDecoration(labelText: l.editProfileSchool),
                ),
                const SizedBox(height: 12),
                _PrivacyToggleCard(
                  title: l.editProfileSchoolPublic,
                  value: schoolPublic,
                  onChanged: (v) => setState(() => schoolPublic = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _FormSection(
            title: l.navGrades,
            child: Column(
              children: [
                TextField(
                  controller: grade,
                  decoration: InputDecoration(labelText: l.navGrades),
                ),
                const SizedBox(height: 12),
                _PrivacyToggleCard(
                  title: l.editProfileGradePublic,
                  value: gradePublic,
                  onChanged: (v) => setState(() => gradePublic = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: majors,
                  decoration: InputDecoration(labelText: l.editProfileMajors),
                ),
                const SizedBox(height: 12),
                _PrivacyToggleCard(
                  title: l.editProfileMajorsPublic,
                  value: majorsPublic,
                  onChanged: (v) => setState(() => majorsPublic = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _FormSection(
            title: l.editProfileBio,
            child: Column(
              children: [
                TextField(
                  controller: bio,
                  decoration: InputDecoration(labelText: l.editProfileBio),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                _PrivacyToggleCard(
                  title: l.editProfileBioPublic,
                  value: bioPublic,
                  onChanged: (v) => setState(() => bioPublic = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: status,
                  decoration: InputDecoration(labelText: l.editProfileStatus),
                ),
                const SizedBox(height: 12),
                _PrivacyToggleCard(
                  title: l.editProfileStatusPublic,
                  value: statusPublic,
                  onChanged: (v) => setState(() => statusPublic = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          LiquidGlassCard(
            padding: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(20),
            blurSigma: 12,
            color: cs.surface.withValues(alpha: 0.78),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.18)),
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l.profileSave),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(22),
      blurSigma: 14,
      color: cs.surfaceContainerLow.withValues(alpha: 0.8),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PrivacyToggleCard extends StatelessWidget {
  const _PrivacyToggleCard({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: BorderRadius.circular(16),
      blurSigma: 10,
      color: cs.surface.withValues(alpha: 0.76),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.18)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
