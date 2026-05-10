/// Supported display-name languages.
/// Single source of truth for language codes — avoids raw strings scattered
/// across auth_session, profile_screen, and JWT contract.
enum NameLang {
  en('en', 'English'),
  ar('ar', 'عربي'),
  he('he', 'עברית'),
  fr('fr', 'Français'),
  ru('ru', 'Русский');

  const NameLang(this.code, this.nativeName);

  final String code;
  final String nativeName;

  static NameLang? fromCode(String? c) {
    if (c == null || c.isEmpty) return null;
    for (final lang in values) {
      if (lang.code == c.trim().toLowerCase()) return lang;
    }
    return null;
  }
}
