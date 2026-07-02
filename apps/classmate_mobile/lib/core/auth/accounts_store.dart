import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// One signed-in account remembered on this device for the Instagram-style
/// account switcher. The JWT is the identity; the cached profile fields let
/// the switcher render (and a switch feel instant) without a network round-trip.
class StoredAccount {
  const StoredAccount({
    required this.userId,
    required this.token,
    required this.displayName,
    required this.roleLabel,
    this.roles = const [],
    this.schoolName,
  });

  final String userId;
  final String token;
  final String displayName;
  final String roleLabel;
  final List<String> roles;
  final String? schoolName;

  StoredAccount copyWith({String? token, String? displayName, String? roleLabel, List<String>? roles, String? schoolName}) =>
      StoredAccount(
        userId: userId,
        token: token ?? this.token,
        displayName: displayName ?? this.displayName,
        roleLabel: roleLabel ?? this.roleLabel,
        roles: roles ?? this.roles,
        schoolName: schoolName ?? this.schoolName,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'token': token,
        'displayName': displayName,
        'roleLabel': roleLabel,
        'roles': roles,
        if (schoolName != null) 'schoolName': schoolName,
      };

  factory StoredAccount.fromJson(Map<String, dynamic> j) => StoredAccount(
        userId: '${j['userId'] ?? ''}',
        token: '${j['token'] ?? ''}',
        displayName: '${j['displayName'] ?? ''}',
        roleLabel: '${j['roleLabel'] ?? ''}',
        roles: (j['roles'] as List? ?? []).map((e) => '$e').where((e) => e.isNotEmpty).toList(),
        schoolName: (j['schoolName'] == null || '${j['schoolName']}'.trim().isEmpty) ? null : '${j['schoolName']}',
      );
}

/// Secure-storage-backed list of remembered accounts + the active pointer.
/// JWTs live in the Keychain / encrypted prefs (NOT the plaintext
/// SharedPreferences the live session token uses).
class AccountsStore {
  static const _kAccounts = 'cm_accounts_v1';
  static const _kActive = 'cm_active_account_v1';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<List<StoredAccount>> all() async {
    try {
      final raw = await _storage.read(key: _kAccounts);
      if (raw == null || raw.isEmpty) return const [];
      final list = jsonDecode(raw);
      if (list is! List) return const [];
      return list
          .whereType<Map>()
          .map((e) => StoredAccount.fromJson(Map<String, dynamic>.from(e)))
          .where((a) => a.userId.isNotEmpty && a.token.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _write(List<StoredAccount> accounts) async {
    await _storage.write(
      key: _kAccounts,
      value: jsonEncode(accounts.map((a) => a.toJson()).toList()),
    );
  }

  Future<void> upsert(StoredAccount account) async {
    final list = List<StoredAccount>.from(await all());
    final i = list.indexWhere((a) => a.userId == account.userId);
    if (i >= 0) {
      list[i] = account;
    } else {
      list.add(account);
    }
    await _write(list);
  }

  Future<void> remove(String userId) async {
    final list = (await all()).where((a) => a.userId != userId).toList();
    await _write(list);
    final active = await activeId();
    if (active == userId) {
      await setActive(list.isNotEmpty ? list.first.userId : null);
    }
  }

  Future<String?> activeId() => _storage.read(key: _kActive);

  Future<void> setActive(String? userId) async {
    if (userId == null || userId.isEmpty) {
      await _storage.delete(key: _kActive);
    } else {
      await _storage.write(key: _kActive, value: userId);
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccounts);
    await _storage.delete(key: _kActive);
  }
}

final accountsStoreProvider = Provider<AccountsStore>((ref) => AccountsStore());

/// Reactive view of the remembered accounts for the switcher UI.
class AccountsState {
  const AccountsState({this.accounts = const [], this.activeId});
  final List<StoredAccount> accounts;
  final String? activeId;
}

class AccountsController extends Notifier<AccountsState> {
  @override
  AccountsState build() {
    _load();
    return const AccountsState();
  }

  Future<void> _load() async {
    final store = ref.read(accountsStoreProvider);
    final accounts = await store.all();
    final active = await store.activeId();
    state = AccountsState(accounts: accounts, activeId: active);
  }

  Future<void> reload() => _load();
}

final accountsControllerProvider =
    NotifierProvider<AccountsController, AccountsState>(AccountsController.new);
