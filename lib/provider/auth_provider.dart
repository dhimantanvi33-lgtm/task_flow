import 'package:flutter/foundation.dart';

import '../data/repositories/auth_repository.dart';
import '../models/api_errors.dart';
import '../models/user_model.dart';
import '../service/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service);
  final AuthService _service;

  AuthStatus status = AuthStatus.unknown;
  UserModel? currentUser;
  String? orgId;
  String? orgName;
  AuthTokens? _tokens;

  bool submitting = false;
  String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isAdmin => currentUser?.role.isAdmin ?? false;

  Future<void> bootstrap() async {
    try {
      final session = await _service.restoreSession();
      if (session == null) {
        _setUnauthenticated();
        return;
      }
      _apply(session);
    } catch (_) {
      await _service.logout();
      _setUnauthenticated();
    }
  }

  Future<bool> login(String email, String password) =>
      _run(() => _service.login(email, password));

  Future<bool> register(String name, String email, String password) =>
      _run(() => _service.register(name, email, password));

  Future<bool> _run(Future<AuthSession> Function() action) async {
    submitting = true;
    errorMessage = null;
    notifyListeners();
    try {
      _apply(await action());
      submitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      submitting = false;
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'Unexpected error. Please try again.';
      submitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> ensureValidToken() async {
    if (_tokens == null) return;
    _tokens = await _service.ensureValidToken(_tokens!);
  }

  Future<void> logout() async {
    await _service.logout();
    currentUser = null;
    orgId = null;
    orgName = null;
    _tokens = null;
    _setUnauthenticated();
  }

  void _apply(AuthSession s) {
    currentUser = s.user;
    orgId = s.orgId;
    orgName = s.orgName;
    _tokens = s.tokens;
    status = AuthStatus.authenticated;
    notifyListeners();
  }

  void _setUnauthenticated() {
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}