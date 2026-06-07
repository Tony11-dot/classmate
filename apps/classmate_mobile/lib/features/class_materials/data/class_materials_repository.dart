import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/config/env.dart';
import '../../../core/http/cm_api.dart';

/// A single shared material attached to a schedule period by any participant
/// (student or teacher). The collaborative "drop box" per period — distinct
/// from the teacher's curated material library.
class ClassMaterial {
  ClassMaterial({
    required this.id,
    required this.caption,
    required this.fileUrl,
    required this.fileName,
    required this.mimeType,
    required this.date,
    required this.uploaderId,
    required this.uploaderName,
    required this.canDelete,
    // Only present on the drawer-tab ("mine") feed.
    this.slotId = '',
    this.subject = '',
    this.period,
    this.dayOfWeek,
    this.teacherName = '',
  });

  final String id;
  final String caption;
  final String fileUrl;
  final String fileName;
  final String mimeType;
  final String date;
  final String uploaderId;
  final String uploaderName;
  final bool canDelete;

  final String slotId;
  final String subject;
  final int? period;
  final int? dayOfWeek;
  final String teacherName;

  /// The pill label: caption if the uploader gave one, else the file name,
  /// else a generic fallback. Never truncated by the UI.
  String get displayName {
    final c = caption.trim();
    if (c.isNotEmpty) return c;
    final f = fileName.trim();
    if (f.isNotEmpty) return f;
    return 'Material';
  }

  /// 'pdf' | 'image' | 'file' — drives the icon + which viewer opens.
  String get kind {
    final m = mimeType.toLowerCase();
    final u = fileUrl.toLowerCase();
    if (m.contains('pdf') || u.endsWith('.pdf')) return 'pdf';
    if (m.contains('image') ||
        u.endsWith('.jpg') ||
        u.endsWith('.jpeg') ||
        u.endsWith('.png') ||
        u.endsWith('.webp')) {
      return 'image';
    }
    return 'file';
  }

  factory ClassMaterial.fromJson(Map<String, dynamic> m) => ClassMaterial(
        id: (m['id'] ?? '').toString(),
        caption: (m['caption'] ?? '').toString(),
        fileUrl: (m['fileUrl'] ?? '').toString(),
        fileName: (m['fileName'] ?? '').toString(),
        mimeType: (m['mimeType'] ?? '').toString(),
        date: (m['date'] ?? '').toString(),
        uploaderId: (m['uploaderId'] ?? '').toString(),
        uploaderName: (m['uploaderName'] ?? '').toString(),
        canDelete: m['canDelete'] == true,
        slotId: (m['slotId'] ?? '').toString(),
        subject: (m['subject'] ?? '').toString(),
        period: (m['period'] as num?)?.toInt(),
        dayOfWeek: (m['dayOfWeek'] as num?)?.toInt(),
        teacherName: (m['teacherName'] ?? '').toString(),
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

  /// Materials shared on a single period.
  Future<List<ClassMaterial>> listForSlot(String slotId) async {
    final raw = await _api.getJson('/shared-materials/slot/$slotId');
    return _l(_m(raw)['materials'])
        .map((e) => ClassMaterial.fromJson(_m(e)))
        .toList();
  }

  /// Every shared material across the periods I take part in (drawer tab).
  Future<List<ClassMaterial>> mine() async {
    final raw = await _api.getJson('/shared-materials/mine');
    return _l(_m(raw)['materials'])
        .map((e) => ClassMaterial.fromJson(_m(e)))
        .toList();
  }

  /// Two-step add: upload the file bytes to /uploads/attachment, then attach
  /// the returned URL (plus optional caption) to the period.
  Future<ClassMaterial> add({
    required String slotId,
    required String filePath,
    String? mimeType,
    String caption = '',
    String date = '',
  }) async {
    final base = Env.stripApiSuffix(Env.apiBaseUrl).replaceAll(RegExp(r'/+$'), '');
    final uploadUri = Uri.parse('$base/uploads/attachment');
    final up = await _api.multipartUpload(uploadUri, filePath, mimeType: mimeType);

    final raw = await _api.postJson('/shared-materials/slot/$slotId', body: {
      'fileUrl': (up['fileUrl'] ?? '').toString(),
      'fileName': (up['fileName'] ?? '').toString(),
      'mimeType': (up['mimeType'] ?? mimeType ?? '').toString(),
      'caption': caption.trim(),
      'date': date.trim(),
    });
    return ClassMaterial.fromJson(_m(_m(raw)['material']));
  }

  Future<void> remove(String id) async {
    await _api.deleteJson('/shared-materials/$id');
  }
}
