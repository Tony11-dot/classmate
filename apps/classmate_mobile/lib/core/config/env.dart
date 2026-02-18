class Env {
  static late final String apiBaseUrl;

  static void init() {
    const v = String.fromEnvironment('API_BASE_URL');
    apiBaseUrl = v.isEmpty ? 'http://127.0.0.1:3010' : v;
  }
}
