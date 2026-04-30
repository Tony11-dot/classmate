class AuthMe {
  const AuthMe({
    required this.id,
    required this.email,
    required this.roles,
    required this.actingStudentId,
    required this.schoolId,
    required this.cohortId,
    required this.schoolName,
    required this.schoolLogoUrl,
  });

  final String? id;
  final String? email;
  final List<String> roles;
  final String? actingStudentId;
  final String? schoolId;
  final String? cohortId;
  final String? schoolName;
  final String? schoolLogoUrl;

  static AuthMe fromJson(Map<String, dynamic> j) {
    final roles0 =
        (j['roles'] as List?)?.map((e) => e.toString()).toList() ??
        const <String>[];
    return AuthMe(
      id: j['id']?.toString(),
      email: j['email']?.toString(),
      roles: roles0,
      actingStudentId: j['actingStudentId']?.toString(),
      schoolId: j['schoolId']?.toString(),
      cohortId: j['cohortId']?.toString(),
      schoolName: j['schoolName']?.toString(),
      schoolLogoUrl: j['schoolLogoUrl']?.toString(),
    );
  }
}
