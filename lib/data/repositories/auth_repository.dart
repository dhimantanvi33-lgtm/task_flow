import '../../models/user_model.dart';

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  const AuthTokens({required this.accessToken, required this.refreshToken, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory AuthTokens.fromLoginResponse(Map<String, dynamic> res, {DateTime? now}) {
    final seconds = (res['access_token_expires_in_seconds'] as num).toInt();
    return AuthTokens(
      accessToken: res['access_token'] as String,
      refreshToken: res['refresh_token'] as String,
      expiresAt: (now ?? DateTime.now()).add(Duration(seconds: seconds)),
    );
  }
}

class AuthSession {
  final UserModel user;
  final String orgId;
  final String orgName;
  final AuthTokens tokens;
  const AuthSession({required this.user, required this.orgId, required this.orgName, required this.tokens});
}

abstract class AuthRepository {
  Future<AuthSession> login({required String email, required String password});
  Future<AuthSession> register({required String name, required String email, required String password});
  Future<AuthTokens> refresh(String refreshToken);

  Future<UserModel> resolveUser({required String userId, required String orgId});

  Future<String> orgName(String orgId);
}