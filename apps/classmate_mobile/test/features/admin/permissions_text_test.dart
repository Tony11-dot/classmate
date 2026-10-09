import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:classmate_mobile/features/admin/data/admin_repository.dart';
import 'package:classmate_mobile/features/admin/ui/admin_permissions_screen.dart';
import 'package:classmate_mobile/l10n/app_localizations.dart';

/// The Permissions screen translates the server's English catalog by key.
/// A capability or section added to the catalog without a translation here
/// would show up in English for Hebrew/Arabic/French/Russian admins.
void main() {
  final catalog = File('../../services/api/src/permissions/permissions.catalog.ts').readAsStringSync();
  final keys = RegExp(r"key: '([^']+)'").allMatches(catalog).map((m) => m[1]!).toList();
  final modules = RegExp(r"module: '([^']+)'").allMatches(catalog).map((m) => m[1]!).toSet();
  final he = lookupAppLocalizations(const Locale('he'));

  test('the catalog parses', () {
    expect(keys, isNotEmpty);
    expect(modules, isNotEmpty);
  });

  test('every capability has its own translation', () {
    for (final k in keys) {
      final cap = PermissionCapability.fromJson({'key': k, 'module': '', 'label': '§', 'description': '§'});
      final t = capabilityText(he, cap);
      expect(t.label, isNot('§'), reason: k);
      expect(t.description, isNot('§'), reason: k);
    }
  });

  test('every section has its own translation', () {
    for (final m in modules) {
      expect(moduleText(he, m), isNot(m), reason: m);
    }
  });
}
