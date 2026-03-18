import '../domain/solutions_models.dart';

class LiveSolutionsPage {
  final List<QuestionSolutionCard> items;
  final bool hasMore;
  final int page;

  const LiveSolutionsPage({
    required this.items,
    required this.hasMore,
    required this.page,
  });
}

class SolutionsLiveMapper {
  static LiveSolutionsPage mapPage(Map<String, dynamic> raw) {
    final itemsRaw = raw['items'];
    final items = itemsRaw is List
        ? itemsRaw
              .whereType<Map>()
              .map((e) => mapUpload(e.map((k, v) => MapEntry('$k', v))))
              .toList(growable: false)
        : const <QuestionSolutionCard>[];

    final page = _asInt(raw['page'], fallback: 1);
    final hasMore = raw['hasMore'] == true;

    return LiveSolutionsPage(items: items, hasMore: hasMore, page: page);
  }

  static QuestionSolutionCard mapUpload(Map<String, dynamic> raw) {
    final files = raw['files'];

    final uploaderName = _firstNonEmpty([
      raw['uploaderName'],
      raw['authorName'],
      raw['userName'],
    ], fallback: 'ClassMate Student');

    final verificationStatus = _firstNonEmpty([
      raw['verificationStatus'],
    ], fallback: 'UNCHECKED');

    return QuestionSolutionCard(
      id: _firstNonEmpty([
        raw['id'],
      ], fallback: 'upload-${DateTime.now().microsecondsSinceEpoch}'),
      uploaderName: uploaderName,
      uploaderInitials: _firstNonEmpty([
        raw['uploaderInitials'],
      ], fallback: _buildInitials(uploaderName)),
      subjectId: _firstNonEmpty([raw['subject']], fallback: 'general'),
      bookId: _firstNonEmpty([
        raw['bookId'],
        raw['bookTitle'],
      ], fallback: 'book'),
      pageNumber: '${_asInt(raw['pageNumber'] ?? raw['page'], fallback: 0)}',
      questionNumber: _firstNonEmpty([raw['questionNumber']], fallback: '—'),
      caption: _firstNonEmpty([raw['caption']], fallback: 'Shared solution'),
      verifiedByNova: verificationStatus.toUpperCase() == 'VERIFIED',
      verificationStatus: verificationStatus,
      verificationNote: _nullableText(raw['verificationNote']),
      moderationStatus: _firstNonEmpty([
        raw['moderationStatus'],
      ], fallback: 'PENDING'),
      assets: files is List
          ? files
                .whereType<Map>()
                .map(
                  (f) => SolutionUploadAsset(
                    id: _firstNonEmpty(
                      [f['id']],
                      fallback:
                          'asset-${DateTime.now().microsecondsSinceEpoch}',
                    ),
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
                    remoteUrl: _nullableText(f['url']),
                    filePath: null,
                    uploadState: UploadState.uploaded,
                  ),
                )
                .toList(growable: false)
          : const <SolutionUploadAsset>[],
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

  static String? _nullableText(Object? value) {
    if (value == null) return null;
    final text = '$value'.trim();
    return text.isEmpty ? null : text;
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
