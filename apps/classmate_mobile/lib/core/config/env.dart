class Env {
  static late final String apiBaseUrl;

  static void init() {
    apiBaseUrl = const String.fromEnvironment(
      'CM_API_BASE_URL',
      defaultValue: 'http://127.0.0.1:3000',
    );
  }
}
