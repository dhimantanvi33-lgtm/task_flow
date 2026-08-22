import '../data/data_source/local_storage_data_source.dart';
import '../data/repositories/auth_repository.dart';

class AuthService {
  AuthService(this._repo, this._storage);
  final AuthRepository _repo;
  final LocalStorageDataSource _storage;

  Future<AuthSession> login(String email, String password) async {
    final session = await _repo.login(email: email, password: password);
    await _persist(session);
    return session;
  }

  Future<AuthSession> register(String name, String email, String password) async {
    final session = await _repo.register(name: name, email: email, password: password);
    await _persist(session);
    return session;
  }

  Future<AuthSession?> restoreSession() async {
    final s = await _storage.readSession();
    if (s.accessToken == null || s.refreshToken == null || s.userId == null || s.orgId == null) {
      return null;
    }

    var tokens = AuthTokens(
      accessToken: s.accessToken!,
      refreshToken: s.refreshToken!,
      expiresAt: s.expiresAt ?? DateTime.now(),
    );
    if (tokens.isExpired) {
      tokens = await _repo.refresh(tokens.refreshToken);
      await _storage.updateTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiresAt: tokens.expiresAt,
      );
    }

    final user = await _repo.resolveUser(userId: s.userId!, orgId: s.orgId!);
    final orgName = await _repo.orgName(s.orgId!);
    return AuthSession(user: user, orgId: s.orgId!, orgName: orgName, tokens: tokens);
  }

  Future<AuthTokens> ensureValidToken(AuthTokens current) async {
    if (!current.isExpired) return current;
    final tokens = await _repo.refresh(current.refreshToken);
    await _storage.updateTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresAt: tokens.expiresAt,
    );
    return tokens;
  }

  Future<void> logout() => _storage.clearSession();

  Future<void> _persist(AuthSession session) => _storage.saveSession(
    accessToken: session.tokens.accessToken,
    refreshToken: session.tokens.refreshToken,
    expiresAt: session.tokens.expiresAt,
    userId: session.user.id,
    orgId: session.orgId,
  );
}