/// A single file attached to a bagrut exam.
class BagrutExamFile {
  const BagrutExamFile({
    required this.id,
    required this.kind,
    required this.url,
    this.mimeType,
    this.fileName,
    this.fileSize,
  });

  final String id;
  final String kind; // questions | answers | solution | advanced
  final String url; // absolute (resolved)
  final String? mimeType;
  final String? fileName;
  final int? fileSize;

  bool get isPdf => (mimeType ?? '').toLowerCase() == 'application/pdf' ||
      url.toLowerCase().endsWith('.pdf');

  factory BagrutExamFile.fromJson(Map<String, dynamic> j, String Function(String) resolveUrl) {
    return BagrutExamFile(
      id: (j['id'] ?? '').toString(),
      kind: (j['kind'] ?? '').toString(),
      url: resolveUrl((j['url'] ?? '').toString()),
      mimeType: j['mimeType']?.toString(),
      fileName: j['fileName']?.toString(),
      fileSize: j['fileSize'] is int ? j['fileSize'] as int : int.tryParse('${j['fileSize']}'),
    );
  }
}

/// A past bagrut exam bundling a few files by kind.
class BagrutExam {
  const BagrutExam({
    required this.id,
    required this.subject,
    required this.year,
    required this.term,
    required this.title,
    required this.files,
  });

  final String id;
  final String subject;
  final int year;
  final String term;
  final String title;
  final List<BagrutExamFile> files;

  BagrutExamFile? fileOfKind(String kind) {
    for (final f in files) {
      if (f.kind == kind) return f;
    }
    return null;
  }

  factory BagrutExam.fromJson(Map<String, dynamic> j, String Function(String) resolveUrl) {
    final rawFiles = (j['files'] as List?) ?? const [];
    return BagrutExam(
      id: (j['id'] ?? '').toString(),
      subject: (j['subject'] ?? '').toString(),
      year: j['year'] is int ? j['year'] as int : int.tryParse('${j['year']}') ?? 0,
      term: (j['term'] ?? '').toString(),
      title: (j['title'] ?? '').toString(),
      files: rawFiles
          .whereType<Map>()
          .map((f) => BagrutExamFile.fromJson(Map<String, dynamic>.from(f), resolveUrl))
          .toList(),
    );
  }
}
