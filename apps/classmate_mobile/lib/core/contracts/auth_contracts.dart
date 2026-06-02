class AuthMe {
  const AuthMe({
    required this.id,
    required this.email,
    this.username,
    required this.roles,
    required this.actingStudentId,
    required this.schoolId,
    required this.cohortId,
    required this.schoolName,
    required this.schoolLogoUrl,
    this.schoolMinGrade,
    this.schoolMaxGrade,
    this.schoolGradeRanges,
  });

  final String? id;
  final String? email;
  /// User's username (lowercased login identifier). Required on the server
  /// for every account but exposed here as nullable so the contract stays
  /// permissive — pre-username accounts return null.
  final String? username;
  final List<String> roles;
  final String? actingStudentId;
  final String? schoolId;
  final String? cohortId;
  final String? schoolName;
  final String? schoolLogoUrl;
  final int? schoolMinGrade;
  final int? schoolMaxGrade;
  /// Multi-range grade string, e.g. "4-6,9-12". Null/empty = single min..max.
  final String? schoolGradeRanges;

  static AuthMe fromJson(Map<String, dynamic> j) {
    final roles0 =
        (j['roles'] as List?)?.map((e) => e.toString()).toList() ??
        const <String>[];
    return AuthMe(
      id: j['id']?.toString(),
      email: j['email']?.toString(),
      username: j['username']?.toString(),
      roles: roles0,
      actingStudentId: j['actingStudentId']?.toString(),
      schoolId: j['schoolId']?.toString(),
      cohortId: j['cohortId']?.toString(),
      schoolName: j['schoolName']?.toString(),
      schoolLogoUrl: j['schoolLogoUrl']?.toString(),
      schoolMinGrade: (j['schoolMinGrade'] as num?)?.toInt(),
      schoolMaxGrade: (j['schoolMaxGrade'] as num?)?.toInt(),
      schoolGradeRanges: j['schoolGradeRanges']?.toString(),
    );
  }
}
