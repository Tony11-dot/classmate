import '../domain/solutions_models.dart';

class LiveSolutionsPage {
  final List<QuestionSolutionCard> items;
  final bool hasMore;
  final int nextPage;
  final int total;

  const LiveSolutionsPage({
    required this.items,
    required this.hasMore,
    required this.nextPage,
    required this.total,
  });

  static const empty = LiveSolutionsPage(
    items: <QuestionSolutionCard>[],
    hasMore: false,
    nextPage: 2,
    total: 0,
  );
}

class SolutionsLiveMapper {
  static LiveSolutionsPage pageFromJson(Map<String, dynamic> raw) {
    final list =
        (raw['items'] ??
                raw['uploads'] ??
                raw['rows'] ??
                raw['data'] ??
                const <dynamic>[])
            as List<dynamic>;

    final items = list
        .whereType<Map>()
        .map((e) => mapUpload(e.map((k, v) => MapEntry(k.toString(), v))))
        .toList(growable: false);

    final page = _asInt(raw['page'], fallback: 1);
    final limit = _asInt(
      raw['limit'],
      fallback: items.length == 0 ? 12 : items.length,
    );
    final total = _asInt(raw['total'], fallback: items.length);
    final hasMore =
        raw['hasMore'] == true || ((page * (limit == 0 ? 1 : limit)) < total);

    return LiveSolutionsPage(
      items: items,
      hasMore: hasMore,
      nextPage: page + 1,
      total: total,
    );
  }

  static QuestionSolutionCard mapUpload(Map<String, dynamic> raw) {
    final files =
        (raw['files'] ?? raw['assets'] ?? const <dynamic>[]) as List<dynamic>;

    final subject = _firstNonEmpty([
      raw['subject'],
      raw['book'] is Map ? (raw['book'] as Map)['subject'] : null,
      raw['subjectId'],
    ], fallback: 'general');

    final bookId = _firstNonEmpty([
      raw['bookId'],
      raw['book'] is Map ? (raw['book'] as Map)['id'] : null,
      raw['bookTitle'],
      raw['sourceName'],
    ], fallback: 'book');

    final pageNumber = _firstNonEmpty([
      raw['pageNumber'],
      raw['page'],
    ], fallback: '0');

    final questionNumber = _firstNonEmpty([
      raw['questionNumber'],
      raw['question'],
    ], fallback: '0');

    final uploaderName = _firstNonEmpty([
      raw['uploaderName'],
      raw['authorName'],
      raw['author'] is Map ? (raw['author'] as Map)['name'] : null,
      raw['user'] is Map ? (raw['user'] as Map)['name'] : null,
    ], fallback: 'ClassMate student');

    final uploaderInitials = _buildInitials(
      _firstNonEmpty([
        raw['uploaderInitials'],
        raw['authorInitials'],
      ], fallback: uploaderName),
    );

    final verified =
        _firstNonEmpty([
          raw['verificationStatus'],
          raw['verifiedByNova'] == true ? 'VERIFIED' : null,
        ]).toUpperCase() ==
        'VERIFIED';

    return QuestionSolutionCard(
      id: _firstNonEmpty([
        raw['id'],
      ], fallback: 'solution-${DateTime.now().microsecondsSinceEpoch}'),
      uploaderName: uploaderName,
      uploaderInitials: uploaderInitials,
      subjectId: subject,
      bookId: bookId,
      pageNumber: pageNumber,
      questionNumber: questionNumber,
      caption: _firstNonEmpty([
        raw['caption'],
        raw['body'],
        raw['verificationNote'],
      ], fallback: 'Shared solution'),
      verifiedByNova: verified,
      assets: files
          .whereType<Map>()
          .map(
            (f) => SolutionUploadAsset(
              id: _firstNonEmpty([
                f['id'],
              ], fallback: 'asset-${DateTime.now().microsecondsSinceEpoch}'),
              name: _firstNonEmpty([
                f['fileName'],
                f['originalName'],
                f['name'],
                f['url'],
              ], fallback: 'attachment'),
              kind: _toKind(
                _firstNonEmpty([
                  f['kind'],
                  f['mimeType'],
                  f['mime'],
                ], fallback: 'image'),
              ),
            ),
          )
          .toList(growable: false),
      createdAt:
          DateTime.tryParse(
            _firstNonEmpty([
              raw['createdAt'],
            ], fallback: DateTime.now().toIso8601String()),
          ) ??
          DateTime.now(),
    );
  }

  static SolutionAssetKind _toKind(String raw) {
    final v = raw.toLowerCase();
    if (v.contains('pdf')) return SolutionAssetKind.pdf;
    return SolutionAssetKind.image;
  }

  static int _asInt(Object? raw, {required int fallback}) {
    if (raw is int) return raw;
    return int.tryParse('${raw ?? ''}') ?? fallback;
  }

  static String _firstNonEmpty(List<Object?> values, {String fallback = ''}) {
    for (final value in values) {
      final s = '${value ?? ''}'.trim();
      if (s.isNotEmpty) return s;
    }
    return fallback;
  }

  static String _buildInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.trim().isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return 'CM';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
