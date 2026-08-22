import '../../models/api_errors.dart';
import '../../models/user_model.dart';
import '../data_source/mock_data_source.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._ds);
  final TaskFlowDataSource _ds;

  @override
  Future<AuthSession> login({required String email, required String password}) async {
    await _ds.load();
    final cred = await _ds.findCredential(email, password);
    if (cred == null) throw const ApiException.unauthorized();

    final user = await _ds.userByEmail(email);
    if (user == null) throw const ApiException.notFound('User record not found.');

    final tokens = AuthTokens.fromLoginResponse(await _ds.loginResponse());
    final orgName = await _ds.orgName(cred.orgId);
    return AuthSession(user: user.copyWith(role: cred.role), orgId: cred.orgId, orgName: orgName, tokens: tokens);
  }

  @override
  Future<AuthSession> register({required String name, required String email, required String password}) async {
    await _ds.load();
    final tokens = AuthTokens.fromLoginResponse(await _ds.loginResponse());
    const orgId = 'org_a1b2c3';
    final orgName = await _ds.orgName(orgId);
    final user = UserModel(
      id: 'usr_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      role: MemberRole.member,
    );
    return AuthSession(user: user, orgId: orgId, orgName: orgName, tokens: tokens);
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    await _ds.load();
    return AuthTokens.fromLoginResponse(await _ds.loginResponse());
  }

  @override
  Future<UserModel> resolveUser({required String userId, required String orgId}) async {
    await _ds.load();
    final user = await _ds.userById(userId);
    if (user == null) throw const ApiException.unauthorized('Session is no longer valid.');
    final role = await _ds.roleOf(userId, orgId) ?? MemberRole.member;
    return user.copyWith(role: role);
  }

  @override
  Future<String> orgName(String orgId) => _ds.orgName(orgId);
}