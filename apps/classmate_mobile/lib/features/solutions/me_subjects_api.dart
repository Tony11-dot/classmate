import '../../api/api_client.dart';

class MeSubject {
  final String id;
  final String name;

  const MeSubject({required this.id, required this.name});

  static MeSubject fromJson(dynamic json) {
    if (json is! Map) throw ArgumentError('MeSubject.fromJson expected Map');
    return MeSubject(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}

class MeSubjectsApi {
  final ApiClient client;
  const MeSubjectsApi(this.client);

  Future<List<MeSubject>> list() async {
    final res = await client.get('/me/subjects');
    final data = res.data;
    if (data is! List) return const [];
    return data.map((e) => MeSubject.fromJson(e)).toList();
  }
}
