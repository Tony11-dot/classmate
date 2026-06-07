import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/config/env.dart';
import '../../../core/http/cm_api.dart';

/// A material attached to a schedule period. Students (and teachers) add these
/// from the period detail sheet; they are ordinary `TeacherMaterial` records
/// behind the scenes, so they also appear in the Materials tab. Subject +
/// audience are inherited from the period — the author only gives a title and
/// files.
class SlotMaterial {
  SlotMaterial({
    required this.id,
    required this.title,
    required this.url,
    required this.mime,
    required this.attachments,
    required this.canDelete,
    this.uploaderName = '',
  });

  final String id;
  final String title;
  final String url;
  final String mime;
  final List<Map<String, dynamic>> attachments;
  final bool canDelete;
  final String uploaderName;

  /// Pill `type` understood by AttachmentPill ('pdf'|'image'|'file'|'link').
  String get pillType {
    final m = mime.toLowerCase();
    final u = url.toLowerCase();
    if (m.contains('pdf') || u.endsWith('.pdf')) return 'pdf';
    if (m.contains('image') ||
        u.endsWith('.jpg') || u.endsWith('.jpeg') ||
        u.endsWith('.png') || u.endsWith('.webp')) {
      return 'image';
    }
    if (u.startsWith('http') && !u.contains('/uploads/')) return 'link';
    return 'file';
  }

  factory SlotMaterial.fromJson(Map<String, dynamic> m) => SlotMaterial(
        id: (m['id'] ?? '').toString(),
        title: (m['title'] ?? '').toString(),
        url: (m['url'] ?? '').toString(),
        mime: (m['mime'] ?? '').toString(),
        attachments: (m['attachments'] is List)
            ? (m['attachments'] as List)
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
            : <Map<String, dynamic>>[],
        canDelete: m['canDelete'] == true,
        uploaderName: (m['uploaderName'] ?? '').toString(),
      );
}

final classMaterialsRepositoryProvider = Provider<ClassMaterialsRepository>((ref) {
  final token = ref.watch(authSessionProvider).token ?? '';
  return ClassMaterialsRepository(token: token);
});

class ClassMaterialsRepository {
  ClassMaterialsRepository({required this.token});

  final String token;

  CMApi get _api => CMApi(token: token);

  Map<String, dynamic> _m(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
  List _l(dynamic v) => v is List ? v : const [];

  /// Materials attached to a single period (for the given date occurrence).
  Future<List<SlotMaterial>> listForSlot(String slotId, {String date = ''}) async {
    final raw = await _api.getJson('/shared-materials/slot/$slotId',
        query: date.isNotEmpty ? {'date': date} : null);
    return _l(_m(raw)['materials']).map((e) => SlotMaterial.fromJson(_m(e))).toList();
  }

  /// Upload one or more files, then attach them as a single titled material to
  /// the period. Subject + audience are inherited server-side from the slot.
  Future<SlotMaterial> add({
    required String slotId,
    required String title,
    required List<({String path, String? mime, String name})> files,
    String date = '',
  }) async {
    final base = Env.stripApiSuffix(Env.apiBaseUrl).replaceAll(RegExp(r'/+$'), '');
    final uploadUri = Uri.parse('$base/uploads/attachment');

    final attachments = <Map<String, dynamic>>[];
    for (final f in files) {
      final up = await _api.multipartUpload(uploadUri, f.path, mimeType: f.mime);
      attachments.add({
        'url': (up['fileUrl'] ?? up['url'] ?? '').toString(),
        'name': (up['fileName'] ?? f.name).toString(),
        'mime': (up['mimeType'] ?? f.mime ?? '').toString(),
      });
    }

    final raw = await _api.postJson('/shared-materials/slot/$slotId', body: {
      'title': title.trim(),
      'attachments': attachments,
      'date': date.trim(),
    });
    return SlotMaterial.fromJson(_m(_m(raw)['material']));
  }

  Future<void> remove(String id) async {
    await _api.deleteJson('/shared-materials/$id');
  }
}
