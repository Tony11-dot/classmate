/// A school-owned subject, with names in up to five supported languages.
/// `nameEn` is the canonical / fallback display string; the others are
/// optional and may be empty/null when the admin hasn't translated them yet.
class SchoolSubject {
  const SchoolSubject({
    required this.nameEn,
    this.nameAr,
    this.nameHe,
    this.nameFr,
    this.nameRu,
  });

  final String nameEn;
  final String? nameAr;
  final String? nameHe;
  final String? nameFr;
  final String? nameRu;

  /// Picks the localized name for the given two-letter language code, falling
  /// back to English if the requested translation is missing or empty.
  String displayName(String langCode) {
    String? candidate;
    switch (langCode.toLowerCase()) {
      case 'ar': candidate = nameAr; break;
      case 'he': candidate = nameHe; break;
      case 'fr': candidate = nameFr; break;
      case 'ru': candidate = nameRu; break;
    }
    final t = (candidate ?? '').trim();
    return t.isNotEmpty ? t : nameEn;
  }

  SchoolSubject copyWith({
    String? nameEn,
    String? nameAr,
    String? nameHe,
    String? nameFr,
    String? nameRu,
  }) => SchoolSubject(
    nameEn: nameEn ?? this.nameEn,
    nameAr: nameAr ?? this.nameAr,
    nameHe: nameHe ?? this.nameHe,
    nameFr: nameFr ?? this.nameFr,
    nameRu: nameRu ?? this.nameRu,
  );

  Map<String, dynamic> toJson() => {
    'nameEn': nameEn,
    if (nameAr != null && nameAr!.isNotEmpty) 'nameAr': nameAr,
    if (nameHe != null && nameHe!.isNotEmpty) 'nameHe': nameHe,
    if (nameFr != null && nameFr!.isNotEmpty) 'nameFr': nameFr,
    if (nameRu != null && nameRu!.isNotEmpty) 'nameRu': nameRu,
  };

  static SchoolSubject fromJson(Object? raw) {
    if (raw is String) return SchoolSubject(nameEn: raw.trim());
    if (raw is! Map) return const SchoolSubject(nameEn: '');
    String? s(String key) {
      final v = raw[key];
      if (v == null) return null;
      final t = v.toString().trim();
      return t.isEmpty ? null : t;
    }
    return SchoolSubject(
      nameEn: s('nameEn') ?? '',
      nameAr: s('nameAr'),
      nameHe: s('nameHe'),
      nameFr: s('nameFr'),
      nameRu: s('nameRu'),
    );
  }
}
