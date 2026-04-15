import 'package:shared_preferences/shared_preferences.dart';

const _classroomOrderPrefsKey = 'student_classrooms_custom_order_v1';

String _idOf(Map<String, dynamic> item) =>
    (item['id'] ?? item['courseId'] ?? '').toString().trim();

Future<List<String>> loadSavedClassroomOrder() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getStringList(_classroomOrderPrefsKey) ?? const <String>[];
  final seen = <String>{};
  final out = <String>[];
  for (final id in raw) {
    final clean = id.trim();
    if (clean.isEmpty || seen.contains(clean)) continue;
    seen.add(clean);
    out.add(clean);
  }
  return out;
}

Future<void> saveSavedClassroomOrder(List<String> ids) async {
  final prefs = await SharedPreferences.getInstance();
  final seen = <String>{};
  final out = <String>[];
  for (final id in ids) {
    final clean = id.trim();
    if (clean.isEmpty || seen.contains(clean)) continue;
    seen.add(clean);
    out.add(clean);
  }
  await prefs.setStringList(_classroomOrderPrefsKey, out);
}

List<Map<String, dynamic>> applySavedClassroomOrder(
  List<Map<String, dynamic>> items,
  List<String> savedOrder,
) {
  if (items.isEmpty || savedOrder.isEmpty) {
    return List<Map<String, dynamic>>.from(items);
  }

  final byId = <String, Map<String, dynamic>>{};
  for (final item in items) {
    final id = _idOf(item);
    if (id.isEmpty) continue;
    byId[id] = item;
  }

  final ordered = <Map<String, dynamic>>[];
  final used = <String>{};

  for (final id in savedOrder) {
    final item = byId[id];
    if (item == null) continue;
    ordered.add(item);
    used.add(id);
  }

  for (final item in items) {
    final id = _idOf(item);
    if (id.isNotEmpty && used.contains(id)) continue;
    ordered.add(item);
  }

  return ordered;
}
