class StudentProfile {
  final String id;
  final String fullName;
  final String avatarUrl;
  final String? school;
  final String? grade;
  final String? majors;
  final String? bio;
  final String? status;
  final Map<String, bool> privacy;

  const StudentProfile({
    required this.id,
    required this.fullName,
    required this.avatarUrl,
    this.school,
    this.grade,
    this.majors,
    this.bio,
    this.status,
    required this.privacy,
  });
}
