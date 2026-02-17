import "package:dio/dio.dart";
import "../core/result.dart";
import "../core/session.dart";
import "api_client.dart";

class AuthApi {
  AuthApi(this._api);
  final ApiClient _api;

  String _dioMessage(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    final msg = (data is Map && (data["message"] ?? data["error"]) != null)
        ? (data["message"] ?? data["error"]).toString()
        : (e.message ?? "Request failed");
    return "HTTP ${status ?? "-"}: $msg";
  }

  Future<Result<Map<String, dynamic>>> registerFull({
    required String email,
    required String password,
    required String fullName,
    required String username,
    String? nationalId,
    required int grade,
    required String schoolId,
    String? scientificMajor,
    String? technologicalMajor,
    String? mathUnits,
    String? englishUnits,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        "email": email.trim(),
        "password": password,
        "fullName": fullName.trim(),
        "username": username.trim(),
        "grade": grade,
        "schoolId": schoolId.trim(),
      };

      if (scientificMajor != null && scientificMajor.trim().isNotEmpty) {
        payload["scientificMajor"] = scientificMajor.trim();
      }
      if (technologicalMajor != null && technologicalMajor.trim().isNotEmpty) {
        payload["technologicalMajor"] = technologicalMajor.trim();
      }
      if (mathUnits != null && mathUnits.trim().isNotEmpty) {
        payload["mathUnits"] = mathUnits.trim();
      }
      if (englishUnits != null && englishUnits.trim().isNotEmpty) {
        payload["englishUnits"] = englishUnits.trim();
      }
      // majors/units (grade 10–12)
      if (scientificMajor != null && scientificMajor.trim().isNotEmpty) {
        payload["scientificMajor"] = scientificMajor.trim();
      }
      if (technologicalMajor != null && technologicalMajor.trim().isNotEmpty) {
        payload["technologicalMajor"] = technologicalMajor.trim();
      }
      if (mathUnits != null && mathUnits.trim().isNotEmpty) {
        payload["mathUnits"] = mathUnits.trim();
      }
      if (englishUnits != null && englishUnits.trim().isNotEmpty) {
        payload["englishUnits"] = englishUnits.trim();
      }

      // majors/units (grade 10–12)


      // Only include nationalId if valid
      if (nationalId != null && nationalId.trim().length >= 5) {
        payload["nationalId"] = nationalId.trim();
      }

      final res = await _api.post("/auth/register", data: payload);

      final data = (res.data is Map)
          ? (res.data as Map).cast<String, dynamic>()
          : <String, dynamic>{};

      final token = (data["token"] ?? "").toString();
      if (token.isNotEmpty) {
        await Session.saveAuth(
          token: token,
          role: "student",
          email: (data["email"] ?? email).toString(),
          name: (data["name"] ?? data["fullName"] ?? fullName).toString(),
        );
        _api.setBearer(token);
      }

      return Result.ok(data);
    } on DioException catch (e) {
      return Result.err(_dioMessage(e));
    } catch (e) {
      return Result.err(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _api.post(
        "/auth/login",
        data: {"email": email.trim(), "password": password},
      );

      final data = (res.data is Map)
          ? (res.data as Map).cast<String, dynamic>()
          : <String, dynamic>{};
      final token = (data["token"] ?? "").toString();

      if (token.isNotEmpty) {
        await Session.saveAuth(
          token: token,
          role: "student",
          email: (data["email"] ?? email).toString(),
          name: (data["name"] ?? "").toString(),
        );
        _api.setBearer(token);
      }

      return Result.ok(data);
    } on DioException catch (e) {
      return Result.err(_dioMessage(e));
    } catch (e) {
      return Result.err(e.toString());
    }
  }
}
