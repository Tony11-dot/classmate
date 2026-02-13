import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import 'auth_controller.dart';

import "../api/api_client.dart";
import "../api/auth_api.dart";
import "../ui/liquid_dropdown.dart";

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final fullName = TextEditingController();
  final username = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  final nationalId = TextEditingController();

  bool loading = false;
  String? err;

  // Schools
  bool loadingSchools = true;
  List<Map<String, dynamic>> schools = [];
  String? selectedSchoolId;

  // Grade (DDL)
  int? selectedGrade = 10;

  // Grade 10–12 extras (local for now; backend wiring next)
  String mathUnits = "5";
  String englishUnits = "5";
  String scientificMajor = "Physics"; // 10-12: Physics/Chemistry/Environment
  String? technologicalMajor; // optional

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  bool get isHighSchool => (selectedGrade ?? 0) >= 10;

  Future<void> _loadSchools() async {
    setState(() {
      loadingSchools = true;
      err = null;
    });

    try {
      final res = await ApiClient.instance.get("/schools");
      final data = res.data;

      final List<Map<String, dynamic>> rows = (data is List)
          ? data.map((e) => (e as Map).cast<String, dynamic>()).toList()
          : <Map<String, dynamic>>[];

      setState(() {
        schools = rows;
        selectedSchoolId = rows.isNotEmpty
            ? (rows.first["id"]?.toString())
            : null;
        loadingSchools = false;
      });
    } catch (e) {
      setState(() {
        loadingSchools = false;
        err = "Failed to load schools: $e";
      });
    }
  }

  void _onGradeChanged(int? g) {
    setState(() {
      selectedGrade = g;
      if ((selectedGrade ?? 0) < 10) {
        // clear 10–12-only fields
        mathUnits = "5";
        englishUnits = "5";
        scientificMajor = "Physics";
        technologicalMajor = null;
      }
    });
  }

  Future<void> _register() async {
    setState(() {
      loading = true;
      err = null;
    });

    try {
      final schoolId = selectedSchoolId;
      if (schoolId == null || schoolId.trim().isEmpty) {
        setState(() => err = "Please select a school.");
        return;
      }

      final grade = selectedGrade ?? 10;

      final api = AuthApi(ApiClient.instance);

      final res = await api.registerFull(
        email: email.text.trim(),
        password: pass.text,
        fullName: fullName.text.trim(),
        username: username.text.trim(),
        nationalId: nationalId.text.trim().isEmpty
            ? null
            : nationalId.text.trim(),
        grade: grade,
        schoolId: schoolId,
        // NEXT: send majors/units once backend accepts them
      );

      if (!mounted) return;

      if (res.isOk) {
        await this.ref.read(authProvider.notifier).refresh();
        context.go("/app");
      } else {
        setState(() => err = res.error);
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    fullName.dispose();
    username.dispose();
    email.dispose();
    pass.dispose();
    nationalId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    DropdownMenuItem<String> itemS(String v) => DropdownMenuItem(
      value: v,
      child: Text(v, overflow: TextOverflow.ellipsis),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Create account")),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Student registration",
                    style: t.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  if (loadingSchools)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    LiquidDropdown<String>(
                      value: selectedSchoolId,
                      label: "School",
                      enabled: !loading,
                      items: schools
                          .map(
                            (s) => DropdownMenuItem<String>(
                              value: s["id"]?.toString(),
                              child: Text(
                                (s["name"] ?? "School").toString(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedSchoolId = v),
                    ),

                  const SizedBox(height: 12),
                  LiquidDropdown<int>(
                    value: selectedGrade,
                    label: "Grade (7–12)",
                    enabled: !loading,
                    items: const [7, 8, 9, 10, 11, 12]
                        .map(
                          (g) => DropdownMenuItem<int>(
                            value: g,
                            child: Text("$g", overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: _onGradeChanged,
                  ),

                  const SizedBox(height: 12),
                  TextField(
                    controller: fullName,
                    decoration: const InputDecoration(labelText: "Full name"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: username,
                    decoration: const InputDecoration(labelText: "Username"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pass,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password (min 6)",
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nationalId,
                    decoration: const InputDecoration(
                      labelText: "National ID (optional)",
                    ),
                  ),

                  if (isHighSchool) ...[
                    const SizedBox(height: 18),
                    Text("10–12 profile", style: t.textTheme.titleMedium),
                    const SizedBox(height: 12),

                    LiquidDropdown<String>(
                      value: mathUnits,
                      label: "Math units",
                      enabled: !loading,
                      items: ["3", "4", "5"].map(itemS).toList(),
                      onChanged: (v) => setState(() => mathUnits = v ?? "5"),
                    ),
                    const SizedBox(height: 12),
                    LiquidDropdown<String>(
                      value: englishUnits,
                      label: "English units",
                      enabled: !loading,
                      items: ["4", "5", "5+"].map(itemS).toList(),
                      onChanged: (v) => setState(() => englishUnits = v ?? "5"),
                    ),
                    const SizedBox(height: 12),

                    // ✅ Biology removed (10–12 only: Physics/Chemistry/Environment)
                    LiquidDropdown<String>(
                      value: scientificMajor,
                      label: "Scientific major",
                      enabled: !loading,
                      items: [
                        "Physics",
                        "Chemistry",
                        "Environment",
                      ].map(itemS).toList(),
                      onChanged: (v) =>
                          setState(() => scientificMajor = v ?? "Physics"),
                    ),
                    const SizedBox(height: 12),

                    LiquidDropdown<String?>(
                      value: technologicalMajor,
                      label: "Technological major (optional)",
                      enabled: !loading,
                      items: const [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            "(none)",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem<String?>(
                          value: "Computer Science",
                          child: Text(
                            "Computer Science",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem<String?>(
                          value: "Electronics",
                          child: Text(
                            "Electronics",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem<String?>(
                          value: "Communication",
                          child: Text(
                            "Communication",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => technologicalMajor = v),
                    ),
                  ],

                  const SizedBox(height: 14),
                  if (err != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        err!,
                        style: TextStyle(color: t.colorScheme.error),
                      ),
                    ),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: loading || loadingSchools ? null : _register,
                      child: Text(loading ? "Creating…" : "Create account"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go("/login"),
                      child: const Text("Back to login"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
