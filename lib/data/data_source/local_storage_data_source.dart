import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/storage_files.dart';

class LocalStorageDataSource {
  LocalStorageDataSource([FlutterSecureStorage? secure])
      : _secure = secure ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secure;

  // ---------------- session (secure) ----------------
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
    required String userId,
    required String orgId,
  }) async {
    await _secure.write(key: StorageKeys.accessToken, value: accessToken);
    await _secure.write(key: StorageKeys.refreshToken, value: refreshToken);
    await _secure.write(key: StorageKeys.tokenExpiry, value: expiresAt.toIso8601String());
    await _secure.write(key: StorageKeys.userId, value: userId);
    await _secure.write(key: 'tf_org_id', value: orgId);
  }

  Future<({String? accessToken, String? refreshToken, DateTime? expiresAt, String? userId, String? orgId})> readSession() async {
    final expiry = await _secure.read(key: StorageKeys.tokenExpiry);
    return (
    accessToken: await _secure.read(key: StorageKeys.accessToken),
    refreshToken: await _secure.read(key: StorageKeys.refreshToken),
    expiresAt: expiry == null ? null : DateTime.tryParse(expiry),
    userId: await _secure.read(key: StorageKeys.userId),
    orgId: await _secure.read(key: 'tf_org_id'),
    );
  }

  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    await _secure.write(key: StorageKeys.accessToken, value: accessToken);
    await _secure.write(key: StorageKeys.refreshToken, value: refreshToken);
    await _secure.write(key: StorageKeys.tokenExpiry, value: expiresAt.toIso8601String());
  }

  Future<void> clearSession() async {
    await _secure.delete(key: StorageKeys.accessToken);
    await _secure.delete(key: StorageKeys.refreshToken);
    await _secure.delete(key: StorageKeys.tokenExpiry);
    await _secure.delete(key: StorageKeys.userId);
    await _secure.delete(key: 'tf_org_id');
  }

  // ---------------- offline cache (SharedPreferences) ----------------
  Future<void> cache(String key, String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${StorageKeys.cachePrefix}$key', json);
  }

  Future<String?> readCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('${StorageKeys.cachePrefix}$key');
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    for (final k in prefs.getKeys().where((k) => k.startsWith(StorageKeys.cachePrefix))) {
      await prefs.remove(k);
    }
  }
}