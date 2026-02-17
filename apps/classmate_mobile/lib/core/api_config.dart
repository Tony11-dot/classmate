class ApiConfig {
  // flutter run --dart-define=API_BASE_URL=http://192.168.33.22:3010
  static const String baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://192.168.33.22:3010');
}
