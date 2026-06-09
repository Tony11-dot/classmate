import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';

const _supportEmail = 'support@classmateapp.org';
const _supportPhone = '+972525488441';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  List<_FaqCategory> _categoriesFor(AppLocalizations l) => <_FaqCategory>[
    _FaqCategory(
      title: l.supportSectionGettingStarted,
      icon: Icons.rocket_launch_rounded,
      faqs: [
        _Faq(q: l.faqStartedQ1, a: l.faqStartedA1),
        _Faq(q: l.faqStartedQ2, a: l.faqStartedA2),
        _Faq(q: l.faqStartedQ3, a: l.faqStartedA3),
        _Faq(q: l.faqStartedQ4, a: l.faqStartedA4),
      ],
    ),
    _FaqCategory(
      title: l.supportSectionAccountPassword,
      icon: Icons.lock_outline_rounded,
      faqs: [
        _Faq(q: l.faqAccountQ1, a: l.faqAccountA1),
        _Faq(q: l.faqAccountQ2, a: l.faqAccountA2),
        _Faq(q: l.faqAccountQ3, a: l.faqAccountA3),
        _Faq(q: l.faqAccountQ4, a: l.faqAccountA4),
      ],
    ),
    _FaqCategory(
      title: l.supportSectionForStudents,
      icon: Icons.school_rounded,
      faqs: [
        _Faq(q: l.faqStudentsQ1, a: l.faqStudentsA1),
        _Faq(q: l.faqStudentsQ2, a: l.faqStudentsA2),
        _Faq(q: l.faqStudentsQ3, a: l.faqStudentsA3),
        _Faq(q: l.faqStudentsQ4, a: l.faqStudentsA4),
      ],
    ),
    _FaqCategory(
      title: l.supportSectionForTeachers,
      icon: Icons.co_present_rounded,
      faqs: [
        _Faq(q: l.faqTeachersQ1, a: l.faqTeachersA1),
        _Faq(q: l.faqTeachersQ2, a: l.faqTeachersA2),
        _Faq(q: l.faqTeachersQ3, a: l.faqTeachersA3),
        _Faq(q: l.faqTeachersQ4, a: l.faqTeachersA4),
      ],
    ),
    _FaqCategory(
      title: l.supportSectionForAdministrators,
      icon: Icons.admin_panel_settings_rounded,
      faqs: [
        _Faq(q: l.faqAdminsQ1, a: l.faqAdminsA1),
        _Faq(q: l.faqAdminsQ2, a: l.faqAdminsA2),
        _Faq(q: l.faqAdminsQ3, a: l.faqAdminsA3),
        _Faq(q: l.faqAdminsQ4, a: l.faqAdminsA4),
        _Faq(q: l.faqAdminsQ5, a: l.faqAdminsA5),
        _Faq(q: l.faqAdminsQ6, a: l.faqAdminsA6),
      ],
    ),
    _FaqCategory(
      title: l.supportSectionForParents,
      icon: Icons.family_restroom_rounded,
      faqs: [
        _Faq(q: l.faqParentsQ1, a: l.faqParentsA1),
        _Faq(q: l.faqParentsQ2, a: l.faqParentsA2),
      ],
    ),
    _FaqCategory(
      title: l.supportSectionPrivacyData,
      icon: Icons.privacy_tip_rounded,
      faqs: [
        _Faq(q: l.faqPrivacyQ1, a: l.faqPrivacyA1),
        _Faq(q: l.faqPrivacyQ2, a: l.faqPrivacyA2),
      ],
    ),
  ];

  Future<void> _open(BuildContext ctx, Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(ctx)!.commonCouldNotOpenLink(uri.scheme))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final categories = _categoriesFor(l);

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
                      AppLocalizations.of(context)!.supportContactTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context)!.supportContactDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                _ContactRow(
                  icon: Icons.email_rounded,
                  label: AppLocalizations.of(context)!.supportEmailLabel,
                  value: _supportEmail,
                  onTap: () => _open(context, Uri(scheme: 'mailto', path: _supportEmail)),
                ),
                const SizedBox(height: 10),
                _ContactRow(
                  icon: Icons.phone_rounded,
                  label: AppLocalizations.of(context)!.supportPhoneLabel,
                  value: _supportPhone,
                  onTap: () => _open(context, Uri(scheme: 'tel', path: _supportPhone)),
                  // Calling is the primary tap action; surface SMS as a
                  // secondary icon so users who'd rather text get one
                  // tap to message instead of dialing.
                  trailingActions: [
                    _ContactAction(
                      icon: Icons.sms_rounded,
                      tooltip: AppLocalizations.of(context)!.supportSmsLabel,
                      onTap: () => _open(context, Uri(scheme: 'sms', path: _supportPhone)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // ── FAQ by category ──────────────────────────────────────────────
          ...{
            for (final cat in categories)
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

    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: cs.surface,
      // No local AppBar — the shell's top bar already shows an "About"
      // pill when this route is active.
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          _AboutBlock(
            title: l.aboutWhatIsClassmate,
            body: l.aboutClassmateDescription,
          ),
          _AboutBlock(
            title: l.aboutMultilingualTitle,
            body: l.aboutMultilingualDescription,
          ),
          _AboutBlock(
            title: l.aboutPrivacyTitle,
            body: l.aboutPrivacyDescription,
          ),
          _AboutBlock(
            title: l.aboutContactTitle,
            body: l.aboutContactDescription,
          ),
          const SizedBox(height: 8),
          // Tiny version stamp at the bottom — still discoverable, no longer
          // a hero block stealing focus.
          Center(
            child: Text(
              l.aboutVersionLabel(version),
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

class _ContactAction {
  const _ContactAction({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.trailingActions = const [],
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  /// Optional extra-tap icons rendered on the trailing edge — for the
  /// phone row this is the "send SMS" button alongside the primary call
  /// tap-anywhere. When empty, falls back to the chevron.
  final List<_ContactAction> trailingActions;

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
            if (trailingActions.isEmpty)
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: cs.onSurfaceVariant)
            else
              for (final a in trailingActions)
                IconButton(
                  tooltip: a.tooltip,
                  icon: Icon(a.icon, size: 20),
                  color: cs.primary,
                  visualDensity: VisualDensity.compact,
                  onPressed: a.onTap,
                ),
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
