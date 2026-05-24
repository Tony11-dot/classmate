/// Mirror of the server `UserProfileDto`. One source of truth for what
/// a profile-sheet / member-tap renders.
class UserProfileChild {
  final String id;
  final String name;
  final String? grade;
  const UserProfileChild({required this.id, required this.name, this.grade});

  factory UserProfileChild.fromJson(Map<String, dynamic> j) => UserProfileChild(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        grade: (j['grade'] ?? '').toString().isEmpty ? null : j['grade'] as String,
      );
}

class UserProfileParent {
  final String id;
  final String name;
  const UserProfileParent({required this.id, required this.name});

  factory UserProfileParent.fromJson(Map<String, dynamic> j) => UserProfileParent(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
      );
}

class UserProfile {
  final String id;
  final String displayName;
  final String initials;
  final String role; // 'STUDENT' | 'TEACHER' | ...
  final String? schoolName;
  final String? grade;
  final String? cohortName;
  final List<UserProfileChild> children;
  final List<UserProfileParent> parents;

  const UserProfile({
    required this.id,
    required this.displayName,
    required this.initials,
    required this.role,
    this.schoolName,
    this.grade,
    this.cohortName,
    this.children = const [],
    this.parents = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) {
    String? str(dynamic v) {
      final s = (v ?? '').toString().trim();
      return s.isEmpty ? null : s;
    }

    return UserProfile(
      id: (j['id'] ?? '').toString(),
      displayName: (j['displayName'] ?? '').toString(),
      initials: (j['initials'] ?? '').toString(),
      role: (j['role'] ?? '').toString(),
      schoolName: str(j['schoolName']),
      grade: str(j['grade']),
      cohortName: str(j['cohortName']),
      children: (j['children'] is List)
          ? (j['children'] as List)
              .whereType<Map>()
              .map((m) => UserProfileChild.fromJson(Map<String, dynamic>.from(m)))
              .toList()
          : const [],
      parents: (j['parents'] is List)
          ? (j['parents'] as List)
              .whereType<Map>()
              .map((m) => UserProfileParent.fromJson(Map<String, dynamic>.from(m)))
              .toList()
          : const [],
    );
  }
}
