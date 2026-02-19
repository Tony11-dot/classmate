class Env {
  static late final String apiBaseUrl;

  static void init() {
    apiBaseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:3010',
    );
  }
}
