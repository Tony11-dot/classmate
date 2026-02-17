class AuthSession {
  final String accessToken;
  final String? email;
  final String? role;

  const AuthSession({required this.accessToken, this.email, this.role});

  static String? _pickToken(Map data) {
    final candidates = ['accessToken', 'access_token', 'token', 'jwt'];
    for (final k in candidates) {
      final v = data[k];
      if (v is String && v.isNotEmpty) return v;
    }
    // sometimes Nest returns { data: { accessToken: ... } }
    final inner = data['data'];
    if (inner is Map) {
      for (final k in candidates) {
        final v = inner[k];
        if (v is String && v.isNotEmpty) return v;
      }
    }
    return null;
  }

  factory AuthSession.fromJson(dynamic json) {
    if (json is Map) {
      final token = _pickToken(json);
      if (token == null) {
        throw Exception(
          'AuthSession.fromJson: missing token field in response: $json',
        );
      }

      String? email;
      String? role;

      // common shapes
      final user = json['user'] ?? json['profile'];
      if (user is Map) {
        final e = user['email'];
        final r = user['role'];
        if (e is String) email = e;
        if (r is String) role = r;
      }

      // sometimes top-level includes these
      final e2 = json['email'];
      final r2 = json['role'];
      if (email == null && e2 is String) email = e2;
      if (role == null && r2 is String) role = r2;

      return AuthSession(accessToken: token, email: email, role: role);
    }

    throw Exception(
      'AuthSession.fromJson: expected Map, got ${json.runtimeType}',
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'email': email,
    'role': role,
  };
}
