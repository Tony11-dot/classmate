import '../../api/api_client.dart';

class AiTutorApi {
  final ApiClient _c;
  const AiTutorApi(this._c);

  Future<String> chat(List<Map<String, String>> messages) async {
    final res = await _c.post(
      "/tutor/chat",
      data: {"messages": messages},
    );
    return (res.data?["reply"] ?? "").toString();
  }
}
