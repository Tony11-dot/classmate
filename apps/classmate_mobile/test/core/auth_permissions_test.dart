import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:classmate_mobile/core/auth/auth_session.dart';
import 'package:classmate_mobile/core/config/env.dart';
import 'package:classmate_mobile/core/contracts/auth_contracts.dart';

/// The app shows admin-managed controls (schedule editing, class roster
/// add/remove, announcement posting) by PERMISSION, not by role — otherwise an
/// admin's grant in Settings → Permissions never surfaces (web QA #55).
void main() {
  setUpAll(Env.init); // AuthSession reads Env.clearSession (late final)
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('AuthMe parses permissions; missing field means none', () {
    final me = AuthMe.fromJson({
      'roles': ['SECRETARY'],
      'permissions': ['schedule.edit', 'announcements.post'],
    });
    expect(me.permissions, ['schedule.edit', 'announcements.post']);

    final old = AuthMe.fromJson({'roles': ['SECRETARY']});
    expect(old.permissions, isNull); // older server: unknown, not "none"
  });

  test('can(): secretary only holds what was granted', () async {
    final s = AuthSession();
    await s.setRoles(['SECRETARY']);
    await s.setPermissions(['announcements.post']);
    expect(s.can('announcements.post'), isTrue);
    expect(s.can('schedule.edit'), isFalse);
    expect(s.can('cohorts.manageMembers'), isFalse);

    await s.setPermissions(['announcements.post', 'schedule.edit']);
    expect(s.can('schedule.edit'), isTrue);
  });

  test('can(): ADMIN and MANAGER can do everything (mirrors the server)',
      () async {
    final s = AuthSession();
    await s.setRoles(['ADMIN']);
    await s.setPermissions(const []);
    expect(s.can('schedule.edit'), isTrue);
    expect(s.can('cohorts.manage'), isTrue);

    await s.setRoles(['MANAGER']);
    expect(s.can('announcements.post'), isTrue);
  });

  test('permissions persist across sessions and clear on logout', () async {
    final a = AuthSession();
    await a.setRoles(['TEACHER']);
    await a.setPermissions(['announcements.post']);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('auth_permissions_v1'), ['announcements.post']);

    await a.logout();
    expect(a.permissions, isEmpty);
    expect(prefs.getStringList('auth_permissions_v1'), isNull);
  });

  test('older backend (no permissions field) keeps today\'s behavior', () async {
    final s = AuthSession();
    await s.setRoles(['TEACHER']);
    await s.setPermissions(null);
    // Staff could always post — must NOT disappear before the backend ships.
    expect(s.can('announcements.post'), isTrue);
    expect(s.can('schedule.edit'), isFalse);

    await s.setRoles(['SECRETARY']);
    expect(s.can('announcements.post'), isTrue);
    expect(s.can('cohorts.manageMembers'), isFalse); // was admin-only

    await s.setRoles(['STUDENT']);
    expect(s.can('announcements.post'), isFalse);
  });

  test('server-reported empty list means nothing granted (not legacy)', () async {
    final s = AuthSession();
    await s.setRoles(['TEACHER']);
    await s.setPermissions(const []);
    expect(s.can('announcements.post'), isFalse); // admin switched it off
  });
}
