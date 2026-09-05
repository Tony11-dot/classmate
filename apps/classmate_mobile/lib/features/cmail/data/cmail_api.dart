import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/auth/auth_controller.dart';
import '../../../core/config/env.dart';
import '../../../core/http/cm_api.dart';

final cmailApiProvider = Provider<CMailApi>((ref) {
  final session = ref.watch(authSessionProvider);
  return CMailApi(token: (session.token ?? '').trim());
});

final cmailInboxProvider = FutureProvider.autoDispose<CMailInbox>((ref) {
  return ref.watch(cmailApiProvider).fetchInbox();
});

final cmailSentProvider =
    FutureProvider.autoDispose<List<CMailSummary>>((ref) {
  return ref.watch(cmailApiProvider).fetchSent();
});

final cmailDetailProvider =
    FutureProvider.autoDispose.family<CMailDetail, String>((ref, id) {
  return ref.watch(cmailApiProvider).fetchDetail(id);
});

final cmailDdlProvider = FutureProvider.autoDispose<CMailDdl>((ref) {
  return ref.watch(cmailApiProvider).fetchDdl();
});

class CMailAttachment {
  const CMailAttachment({
    required this.url,
    this.mimeType,
    this.fileName,
    this.fileSize,
  });

  final String url;
  final String? mimeType;
  final String? fileName;
  final int? fileSize;

  factory CMailAttachment.fromJson(Map<String, dynamic> j) => CMailAttachment(
        url: '${j['url'] ?? ''}',
        mimeType: j['mimeType'] as String?,
        fileName: j['fileName'] as String?,
        fileSize: (j['fileSize'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        if (mimeType != null) 'mimeType': mimeType,
        if (fileName != null) 'fileName': fileName,
        if (fileSize != null) 'fileSize': fileSize,
      };
}

class CMailSummary {
  const CMailSummary({
    required this.id,
    required this.subject,
    required this.preview,
    required this.createdAt,
    this.senderName = '',
    this.attachmentCount = 0,
    this.read = true,
    this.audience,
    this.recipientCount,
    this.readCount,
  });

  final String id;
  final String subject;
  final String preview;
  final DateTime createdAt;
  final String senderName;
  final int attachmentCount;
  final bool read;
  final String? audience;
  final int? recipientCount;
  final int? readCount;

  factory CMailSummary.fromJson(Map<String, dynamic> j) => CMailSummary(
        id: '${j['id'] ?? ''}',
        subject: '${j['subject'] ?? ''}',
        preview: '${j['preview'] ?? ''}',
        senderName: '${j['senderName'] ?? ''}',
        attachmentCount: (j['attachmentCount'] as num?)?.toInt() ?? 0,
        read: j['read'] != false,
        audience: j['audience'] as String?,
        recipientCount: (j['recipientCount'] as num?)?.toInt(),
        readCount: (j['readCount'] as num?)?.toInt(),
        createdAt:
            DateTime.tryParse('${j['createdAt'] ?? ''}')?.toLocal() ??
                DateTime.now(),
      );
}

class CMailInbox {
  const CMailInbox({required this.mails, required this.unreadCount});
  final List<CMailSummary> mails;
  final int unreadCount;
}

class CMailDetail {
  const CMailDetail({
    required this.id,
    required this.subject,
    required this.body,
    required this.senderName,
    required this.audience,
    required this.recipientCount,
    required this.isSender,
    required this.attachments,
    required this.createdAt,
    this.audienceMeta,
  });

  final String id;
  final String subject;
  final String body;
  final String senderName;
  final String audience;
  final int recipientCount;
  final bool isSender;
  final List<CMailAttachment> attachments;
  final DateTime createdAt;
  final Map<String, dynamic>? audienceMeta;

  factory CMailDetail.fromJson(Map<String, dynamic> j) => CMailDetail(
        id: '${j['id'] ?? ''}',
        subject: '${j['subject'] ?? ''}',
        body: '${j['body'] ?? ''}',
        senderName: '${j['senderName'] ?? ''}',
        audience: '${j['audience'] ?? ''}',
        recipientCount: (j['recipientCount'] as num?)?.toInt() ?? 0,
        isSender: j['isSender'] == true,
        audienceMeta: j['audienceMeta'] is Map
            ? Map<String, dynamic>.from(j['audienceMeta'] as Map)
            : null,
        attachments: (j['attachments'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => CMailAttachment.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        createdAt:
            DateTime.tryParse('${j['createdAt'] ?? ''}')?.toLocal() ??
                DateTime.now(),
      );
}

class CMailRecipient {
  const CMailRecipient({
    required this.id,
    required this.name,
    this.role,
    this.read = false,
  });
  final String id;
  final String name;
  final String? role;
  final bool read;

  factory CMailRecipient.fromJson(Map<String, dynamic> j) => CMailRecipient(
        id: '${j['id'] ?? ''}',
        name: '${j['name'] ?? ''}',
        role: j['role'] == null ? null : '${j['role']}',
        read: j['read'] == true,
      );
}

class CMailCohort {
  const CMailCohort({required this.id, required this.name, this.grade});
  final String id;
  final String name;
  final int? grade;
}

class CMailPerson {
  const CMailPerson({
    required this.id,
    required this.name,
    required this.role,
    this.grade,
  });
  final String id;
  final String name;
  final String role;
  final int? grade;
}

class CMailDdl {
  const CMailDdl({
    required this.grades,
    required this.cohorts,
    required this.people,
  });
  final List<int> grades;
  final List<CMailCohort> cohorts;
  final List<CMailPerson> people;
}

class CMailApi {
  const CMailApi({this.token = ''});

  final String token;

  CMApi get _api => CMApi(token: token);

  Future<CMailInbox> fetchInbox() async {
    final raw = await _api.getJson('/cmail/inbox');
    final map = raw is Map ? raw : const {};
    return CMailInbox(
      mails: (map['mails'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => CMailSummary.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      unreadCount: (map['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }

  Future<List<CMailSummary>> fetchSent() async {
    final raw = await _api.getJson('/cmail/sent');
    return ((raw is Map ? raw['mails'] : null) as List? ?? const [])
        .whereType<Map>()
        .map((e) => CMailSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<CMailDetail> fetchDetail(String id) async {
    final raw = await _api.getJson('/cmail/$id');
    final mail = raw is Map ? raw['mail'] : null;
    return CMailDetail.fromJson(
        mail is Map ? Map<String, dynamic>.from(mail) : const {});
  }

  /// Sender-only recipient roster for the "N recipients" chip (QA #44).
  Future<List<CMailRecipient>> fetchRecipients(String id) async {
    final raw = await _api.getJson('/cmail/$id/recipients');
    final list = raw is Map ? raw['recipients'] as List? : null;
    return (list ?? const [])
        .whereType<Map>()
        .map((e) => CMailRecipient.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<CMailDdl> fetchDdl() async {
    final raw = await _api.getJson('/cmail/ddl');
    final map = raw is Map ? raw : const {};
    return CMailDdl(
      grades: (map['grades'] as List? ?? const [])
          .whereType<num>()
          .map((e) => e.toInt())
          .toList(),
      cohorts: (map['cohorts'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => CMailCohort(
                id: '${e['id'] ?? ''}',
                name: '${e['name'] ?? ''}',
                grade: (e['grade'] as num?)?.toInt(),
              ))
          .toList(),
      people: (map['people'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => CMailPerson(
                id: '${e['id'] ?? ''}',
                name: '${e['name'] ?? ''}',
                role: '${e['role'] ?? ''}',
                grade: (e['grade'] as num?)?.toInt(),
              ))
          .toList(),
    );
  }

  Future<void> send({
    required String subject,
    required String body,
    required String audience,
    List<int>? grades,
    List<String>? cohortIds,
    List<String>? userIds,
    List<CMailAttachment>? attachments,
  }) async {
    await _api.postJson('/cmail/send', body: {
      'subject': subject,
      'body': body,
      'audience': audience,
      if (grades != null && grades.isNotEmpty) 'grades': grades,
      if (cohortIds != null && cohortIds.isNotEmpty) 'cohortIds': cohortIds,
      if (userIds != null && userIds.isNotEmpty) 'userIds': userIds,
      if (attachments != null && attachments.isNotEmpty)
        'attachments': attachments.map((a) => a.toJson()).toList(),
    });
  }

  Future<void> delete(String id) async {
    await _api.deleteJson('/cmail/$id');
  }

  /// Toggle MY read state without opening the mail (inbox long-press).
  Future<void> markRead(String id) async {
    await _api.postJson('/cmail/$id/read', body: const {});
  }

  Future<void> markUnread(String id) async {
    await _api.postJson('/cmail/$id/unread', body: const {});
  }

  /// Uploads one file to the shared attachment store and returns its
  /// attachment descriptor (server-relative /uploads/... URL). Pass [bytes]
  /// on web, where the picker exposes no real file path.
  Future<CMailAttachment> uploadAttachment(String? filePath,
      {String? fileName, List<int>? bytes}) async {
    final base = Env.stripApiSuffix(Env.apiBaseUrl)
        .replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$base/uploads/attachment');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(bytes != null
          ? http.MultipartFile.fromBytes('file', bytes,
              filename: fileName ?? 'attachment')
          : await http.MultipartFile.fromPath('file', filePath!));
    final streamed =
        await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CMApiException(
          statusCode: response.statusCode, uri: uri, body: response.body);
    }
    final decoded = jsonDecode(response.body);
    final map = decoded is Map
        ? Map<String, dynamic>.from(decoded)
        : <String, dynamic>{};
    return CMailAttachment(
      url: '${map['url'] ?? map['fileUrl'] ?? ''}',
      mimeType: map['mimeType'] as String?,
      fileName: '${map['fileName'] ?? fileName ?? ''}',
      fileSize: (map['fileSize'] as num?)?.toInt(),
    );
  }
}
