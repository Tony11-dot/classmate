class AuthSession {
  final String accessToken;
  final String? role;
  final String? email;
  final String? name;

  const AuthSession({
    required this.accessToken,
    this.role,
    this.email,
    this.name,
  });

  /// Backward-compat alias
  String get token => accessToken;

  static AuthSession fromJson(dynamic json) {
    if (json is! Map) {
      throw ArgumentError(
        'AuthSession.fromJson expected Map, got: ${json.runtimeType}',
      );
    }

    final token = (json['accessToken'] ?? json['token'] ?? json['jwt'])
        ?.toString();
    if (token == null || token.isEmpty) {
      throw ArgumentError('AuthSession missing accessToken/token');
    }

    // Many APIs return { user: {...} }
    final user = (json['user'] is Map) ? (json['user'] as Map) : null;

    String? pick(dynamic v) => (v == null) ? null : v.toString();

    return AuthSession(
      accessToken: token,
      role: pick(json['role'] ?? user?['role']),
      email: pick(json['email'] ?? user?['email']),
      name: pick(
        json['name'] ?? user?['name'] ?? json['fullName'] ?? user?['fullName'],
      ),
    );
  }
}
