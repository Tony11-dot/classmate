class Env {
  static late final String apiBaseUrl;
  static late final String schoolId;
  static late final String devToken;

  static void init() {
    final rawBase = const String.fromEnvironment('CM_API_BASE_URL');
    apiBaseUrl = rawBase.trim().isEmpty
        ? const String.fromEnvironment(
            'CM_API_BASE',
            defaultValue: 'http://127.0.0.1:3000',
          )
        : rawBase.trim();

    final rawSchool = const String.fromEnvironment('CM_SCHOOL_ID');
    schoolId = rawSchool.trim().isEmpty ? 'demo-school' : rawSchool.trim();

    final rawToken = const String.fromEnvironment('CM_DEV_TOKEN');
    devToken = rawToken.trim();
  }
}
