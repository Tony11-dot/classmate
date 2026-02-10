class AuthSession {
  final String accessToken;
  final List<String> roles;
  final String? email;
  final String? name;

  const AuthSession({
    required this.accessToken,
    required this.roles,
    this.email,
    this.name,
  });

  String get token => accessToken;

  static AuthSession fromJson(dynamic json) {
    if (json is! Map) {
      throw ArgumentError('AuthSession.fromJson expected Map');
    }

    final token = (json['accessToken'] ?? json['token'] ?? json['jwt'])
        ?.toString();
    if (token == null || token.isEmpty) throw ArgumentError('Missing token');

    final user = (json['user'] is Map) ? (json['user'] as Map) : null;
    final rolesDynamic = (user?['roles'] ?? json['roles']);
    final roles = <String>[];
    if (rolesDynamic is List) {
      for (final r in rolesDynamic) {
        if (r != null) roles.add(r.toString());
      }
    }

    return AuthSession(
      accessToken: token,
      roles: roles,
      email: (user?['email'] ?? json['email'])?.toString(),
      name: (user?['name'] ?? json['name'])?.toString(),
    );
  }
}
