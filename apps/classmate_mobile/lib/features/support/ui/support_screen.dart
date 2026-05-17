import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _supportEmail = 'tony@classmateapp.org';
const _supportPhone = '+972525488441';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const _categories = <_FaqCategory>[
    _FaqCategory(
      title: 'Getting started',
      icon: Icons.rocket_launch_rounded,
      faqs: [
        _Faq(
          q: 'How do I log in?',
          a: 'Tap "Sign in" on the welcome screen and enter the email or username your school administrator gave you, plus your temporary password. You\'ll be asked to set a new password the first time.',
        ),
        _Faq(
          q: "I don't have a login yet.",
          a: 'Your school administrator creates accounts. Ask them to add you in their admin app, or to share a join code if your school uses self-enrolment.',
        ),
        _Faq(
          q: 'Can I use the app in my language?',
          a: 'Yes — ClassMate supports English, Arabic, Hebrew, French, and Russian. Open Settings to switch language. You can also set a preferred name language in Profile.',
        ),
        _Faq(
          q: 'How do I switch between dark and light mode?',
          a: 'Open Settings from the drawer and toggle the appearance switch. The app respects your system preference by default.',
        ),
      ],
    ),
    _FaqCategory(
      title: 'Account & password',
      icon: Icons.lock_outline_rounded,
      faqs: [
        _Faq(
          q: 'I forgot my password.',
          a: 'Tap "Forgot password?" on the login screen. You\'ll get a reset link by email or a code by SMS. If neither channel is verified yet, ask your school administrator to issue you a new temporary password.',
        ),
        _Faq(
          q: 'How do I change my password?',
          a: 'Open Profile from the drawer, scroll to Security, and tap the password row. You\'ll need your current password to set a new one.',
        ),
        _Faq(
          q: 'How do I change my email or phone number?',
          a: 'Open Profile, tap the field you want to change, and follow the verification prompts. A code is sent to your CURRENT email/phone first to confirm it\'s really you, then you can set the new value.',
        ),
        _Faq(
          q: 'My school administrator can change my password — how does that work?',
          a: 'When an administrator resets your password, you\'ll get an email and SMS with a one-tap link to set your own password. The admin never sees what you choose.',
        ),
      ],
    ),
    _FaqCategory(
      title: 'For students',
      icon: Icons.school_rounded,
      faqs: [
        _Faq(
          q: 'Where do I see my schedule?',
          a: 'Schedule is the first item in the drawer. You\'ll see this week\'s periods, who teaches each one, and any changes the admin has posted.',
        ),
        _Faq(
          q: 'How do I join a classroom?',
          a: 'A teacher will add you directly, or share a join code. To use a join code, open Classrooms from the drawer and tap "Join with code".',
        ),
        _Faq(
          q: 'How do attendance and grades work?',
          a: 'Teachers mark attendance during the lesson. Open Attendance or Grades from the drawer to see your records. Parents linked to your account see the same data.',
        ),
        _Faq(
          q: 'What is Nova?',
          a: 'Nova is your AI study buddy — ask it to explain a concept, generate a quiz, or walk through a problem step by step. Open Nova from the drawer to start a session.',
        ),
      ],
    ),
    _FaqCategory(
      title: 'For teachers',
      icon: Icons.co_present_rounded,
      faqs: [
        _Faq(
          q: 'How do I create a classroom?',
          a: 'Open Classrooms from the drawer and tap the + button. Give it a name and subject; students can be added by hand or via a join code.',
        ),
        _Faq(
          q: 'How do I mark attendance?',
          a: 'Open Attendance from the drawer, pick the date and period, then tap each student to set their status. Changes save automatically.',
        ),
        _Faq(
          q: 'How do I assign homework?',
          a: 'Open Assignments, tap +, fill in the title/due date/attachments, and pick a target (whole school, specific cohorts, or named students). Students see it instantly in their drawer.',
        ),
        _Faq(
          q: 'Can I issue a diploma or certificate?',
          a: 'Yes — open Diplomas from the drawer, tap +, pick the student, fill in the title and details, and save. The student sees it in their own Diplomas section.',
        ),
      ],
    ),
    _FaqCategory(
      title: 'For administrators',
      icon: Icons.admin_panel_settings_rounded,
      faqs: [
        _Faq(
          q: 'Where do I start setting up a school?',
          a: 'Open the Admin Dashboard. The School Setup widget at the top shows a 7-step checklist (logo, name, subjects, bell schedule, cohorts, students, teachers). Each step deep-links to where you complete it.',
        ),
        _Faq(
          q: 'How do cohorts work?',
          a: 'A cohort is a group of students that share a schedule. Open Cohorts from the drawer to create them, assign students, and generate join codes. A single cohort can span multiple grades.',
        ),
        _Faq(
          q: 'Can a cohort cover more than one grade?',
          a: 'Yes — when creating a cohort, select multiple grades. The cohort then appears in any of those grades\' filters and views, and announcements/templates targeted at any of those grades reach it.',
        ),
        _Faq(
          q: 'How do I build the weekly schedule?',
          a: 'Open Schedule from the drawer. Tap any cell to add a period — pick the day/period, teacher, subject, and audience (cohort/student/grade). Bell-schedule times come from School Settings.',
        ),
        _Faq(
          q: 'How do I bulk-export students?',
          a: 'Open Export Data from the drawer. Choose whether to select by student or by cohort, pick the rows, and tap Export. Optionally generate fresh temporary passwords during export.',
        ),
        _Faq(
          q: 'A user asked me to reset their password. What do I do?',
          a: 'You can either set their password directly (Profile of the user → Security) or wait for them to file a request via "Forgot password" and approve it from Password Requests in the drawer.',
        ),
      ],
    ),
    _FaqCategory(
      title: 'For parents',
      icon: Icons.family_restroom_rounded,
      faqs: [
        _Faq(
          q: 'How do I link my account to my child?',
          a: 'Ask your child\'s school administrator to either add the link from their admin app, or share a one-time parent link code. Open Profile and enter the code under Family.',
        ),
        _Faq(
          q: 'What can I see about my child?',
          a: 'Attendance, grades, announcements, and homework — exactly what your child sees plus the trends across time. You won\'t see private chats or Nova sessions.',
        ),
      ],
    ),
    _FaqCategory(
      title: 'Privacy & data',
      icon: Icons.privacy_tip_rounded,
      faqs: [
        _Faq(
          q: 'Who can see my data?',
          a: 'Only people in your school. Teachers see their classrooms\' data, admins see school-wide data, parents see their linked children. We never sell data to advertisers.',
        ),
        _Faq(
          q: 'How do I delete my account?',
          a: 'Ask your school administrator to delete it. They can remove the account from their admin app, which wipes your profile, schedule, and chats.',
        ),
      ],
    ),
  ];

  Future<void> _open(BuildContext ctx, Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text("Couldn't open ${uri.scheme} link")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: cs.surface,
      // No local AppBar — the shell's top bar already shows a "Support"
      // pill when this route is active. Avoids stacking two titles.
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // ── Contact CTAs ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.support_agent_rounded, color: cs.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Talk to us',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Can't find your answer below? Get in touch and we'll come back to you within a working day.",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                _ContactRow(
                  icon: Icons.email_rounded,
                  label: 'Email',
                  value: _supportEmail,
                  onTap: () => _open(context, Uri(scheme: 'mailto', path: _supportEmail)),
                ),
                const SizedBox(height: 10),
                _ContactRow(
                  icon: Icons.phone_rounded,
                  label: 'Phone',
                  value: _supportPhone,
                  onTap: () => _open(context, Uri(scheme: 'tel', path: _supportPhone)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // ── FAQ by category ──────────────────────────────────────────────
          ...{
            for (final cat in _categories)
              cat: cat.faqs,
          }.entries.map((entry) => _CategoryBlock(category: entry.key, faqs: entry.value)),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, this.version = '1.0.0'});
  final String version;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: cs.surface,
      // No local AppBar — the shell's top bar already shows an "About"
      // pill when this route is active.
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          _AboutBlock(
            title: 'What is ClassMate?',
            body: 'ClassMate is the school operating system for students, teachers, administrators, and parents. One app, four roles, every part of the school day in a single place — schedule, attendance, grades, classrooms, assignments, messaging, and an AI study buddy.',
          ),
          _AboutBlock(
            title: 'Built for schools that speak more than one language',
            body: 'Every name, subject, and announcement can carry up to five language variants (English, Arabic, Hebrew, French, Russian). Students see the language they\'re most comfortable with; teachers manage in theirs.',
          ),
          _AboutBlock(
            title: 'Privacy first',
            body: 'School data stays inside the school. Roles map cleanly onto what each person can see — teachers see their classrooms, admins see their school, parents see their children. No third-party trackers, no ad networks.',
          ),
          _AboutBlock(
            title: 'Contact',
            body: 'Built by Tony Aboud and the ClassMate team.\nQuestions: tony@classmateapp.org',
          ),
          const SizedBox(height: 8),
          // Tiny version stamp at the bottom — still discoverable, no longer
          // a hero block stealing focus.
          Center(
            child: Text(
              'ClassMate · v$version',
              style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internals
// ─────────────────────────────────────────────────────────────────────────────

class _FaqCategory {
  const _FaqCategory({required this.title, required this.icon, required this.faqs});
  final String title;
  final IconData icon;
  final List<_Faq> faqs;
}

class _Faq {
  const _Faq({required this.q, required this.a});
  final String q;
  final String a;
}

class _CategoryBlock extends StatelessWidget {
  const _CategoryBlock({required this.category, required this.faqs});
  final _FaqCategory category;
  final List<_Faq> faqs;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                category.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: faqs.asMap().entries.map((e) => Column(
                children: [
                  if (e.key > 0)
                    Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.4), indent: 16, endIndent: 16),
                  _FaqTile(faq: e.value),
                ],
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq});
  final _Faq faq;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return ExpansionTile(
      title: Text(
        faq.q,
        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      iconColor: cs.primary,
      collapsedIconColor: cs.onSurfaceVariant,
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: const Border(),
      collapsedShape: const Border(),
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            faq.a,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.45,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                  Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _AboutBlock extends StatelessWidget {
  const _AboutBlock({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
